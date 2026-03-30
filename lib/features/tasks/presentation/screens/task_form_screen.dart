import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import 'task_detail_screen.dart';
import 'tasks_screen.dart';

final taskFormSnapshotProvider =
    FutureProvider.family<TaskFormSnapshot, String?>((ref, taskId) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);

  if (taskId == null || taskId.isEmpty) {
    final membersFuture = api.listTenantMembers(
      session.accessToken,
      session.activeTenant.tenantId,
    );
    final projectsFuture = api.listProjects(session.accessToken);

    return TaskFormSnapshot(
      members: await membersFuture,
      projects: await projectsFuture,
      task: null,
    );
  }

  final snapshot = await api.loadTaskDetail(session.accessToken, taskId);
  return TaskFormSnapshot(
    members: snapshot.members,
    projects: snapshot.projects,
    task: snapshot.task,
  );
});

class TaskFormSnapshot {
  const TaskFormSnapshot({
    required this.members,
    required this.projects,
    required this.task,
  });

  final List<FluxaTenantMember> members;
  final List<FluxaProject> projects;
  final FluxaTask? task;
}

class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({
    this.initialProjectId,
    this.taskId,
    super.key,
  });

  final String? initialProjectId;
  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(taskFormSnapshotProvider(taskId));
    final isEditing = taskId != null && taskId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit task' : 'Create task'),
      ),
      body: snapshotAsync.when(
        data: (snapshot) => _TaskFormBody(
          initialProjectId: initialProjectId,
          snapshot: snapshot,
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load the task form.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TaskFormBody extends ConsumerStatefulWidget {
  const _TaskFormBody({
    required this.initialProjectId,
    required this.snapshot,
  });

  final String? initialProjectId;
  final TaskFormSnapshot snapshot;

  @override
  ConsumerState<_TaskFormBody> createState() => _TaskFormBodyState();
}

class _TaskFormBodyState extends ConsumerState<_TaskFormBody> {
  static const _statusOptions = [
    'open',
    'in_progress',
    'done',
    'archived',
  ];

  static const _priorityOptions = [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;
  String? _assigneeId;
  DateTime? _dueAt;
  late String _priority;
  String? _projectId;
  late String _status;

  bool get _isEditing => widget.snapshot.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.snapshot.task;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _status = task?.status ?? 'open';
    _priority = task?.priority ?? 'medium';
    _assigneeId = task?.assigneeId;
    _projectId = task?.projectId ?? widget.initialProjectId;
    final dueAt = task?.dueAt;
    _dueAt = dueAt == null || dueAt.isEmpty ? null : DateTime.parse(dueAt).toLocal();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatStatus(String value) {
    return value.replaceAll('_', ' ');
  }

  String _formatDate(DateTime value) {
    return DateFormat.yMMMd().format(value);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _dueAt ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      initialDate: initialDate,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _dueAt = DateTime(picked.year, picked.month, picked.day, 12);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final auth = ref.read(authControllerProvider).state;
    final session = auth.session;
    if (session == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final api = ref.read(fluxaApiClientProvider);
      final description = _descriptionController.text.trim();
      final taskPayload = FluxaTaskPayload(
        assigneeId: _assigneeId,
        description: description.isEmpty ? null : description,
        dueAt: _dueAt?.toUtc().toIso8601String(),
        priority: _priority,
        projectId: _projectId,
        status: _status,
        title: _titleController.text.trim(),
      );

      final task = _isEditing
          ? await api.updateTask(
              session.accessToken,
              widget.snapshot.task!.id,
              taskPayload.toJson(),
            )
          : await api.createTask(
              session.accessToken,
              taskPayload,
              idempotencyKey:
                  'mobile-task-${DateTime.now().microsecondsSinceEpoch}',
            );

      ref.invalidate(taskListProvider);
      ref.invalidate(overviewProvider);
      ref.invalidate(projectListProvider);
      ref.invalidate(taskFormSnapshotProvider(widget.snapshot.task?.id));
      ref.invalidate(taskDetailProvider(task.id));
      if (task.projectId != null && task.projectId!.isNotEmpty) {
        ref.invalidate(projectDetailProvider(task.projectId!));
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Task updated successfully.' : 'Task created successfully.',
          ),
        ),
      );
      context.go('/tasks/${task.id}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save task.\n$error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.snapshot.members;
    final projects = widget.snapshot.projects;
    final hasSelectedProject = _projectId != null &&
        projects.any((project) => project.id == _projectId);
    final selectedProjectId = hasSelectedProject ? _projectId : null;

    if (_projectId != null && !hasSelectedProject) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _projectId = null;
        });
      });
    }

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing ? 'Update task details' : 'Create a new tenant task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing
                  ? 'Edit status, ownership, and timing without leaving the mobile flow.'
                  : 'Capture work quickly, assign it to a teammate, and push it to the backend API.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String?>(
              value: selectedProjectId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No project'),
                ),
                ...projects.map(
                  (project) => DropdownMenuItem<String?>(
                    value: project.id,
                    child: Text(project.name),
                  ),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _projectId = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                hintText: 'Ship billing API',
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
                hintText: 'Add implementation notes or next actions.',
              ),
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Status',
              ),
              items: _statusOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_formatStatus(value)),
                    ),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _status = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Priority',
              ),
              items: _priorityOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_formatStatus(value)),
                    ),
                  )
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _priority = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _assigneeId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Assignee',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Unassigned'),
                ),
                ...members.map(
                  (member) => DropdownMenuItem<String?>(
                    value: member.userId,
                    child: Text('${member.email} · ${_formatStatus(member.role)}'),
                  ),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _assigneeId = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due date',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dueAt == null ? 'No due date set yet.' : _formatDate(_dueAt!),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _pickDueDate,
                          icon: const Icon(Icons.event_outlined),
                          label: Text(_dueAt == null ? 'Pick date' : 'Change date'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSubmitting || _dueAt == null
                              ? null
                              : () {
                                  setState(() {
                                    _dueAt = null;
                                  });
                                },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save_outlined : Icons.add_task),
              label: Text(_isEditing ? 'Save changes' : 'Create task'),
            ),
          ],
        ),
      ),
    );
  }
}
