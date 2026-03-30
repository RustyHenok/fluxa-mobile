import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final taskProjectFilterProvider = StateProvider<String?>((ref) => null);
final taskStatusFilterProvider = StateProvider<String?>((ref) => null);
final taskPriorityFilterProvider = StateProvider<String?>((ref) => null);
final taskSearchFilterProvider = StateProvider<String>((ref) => '');

final taskListProvider = FutureProvider<TaskListSnapshot>((ref) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  final projectId = ref.watch(taskProjectFilterProvider);
  final status = ref.watch(taskStatusFilterProvider);
  final priority = ref.watch(taskPriorityFilterProvider);
  final searchQuery = ref.watch(taskSearchFilterProvider).trim();
  final tasksFuture = api.listTasks(
    session.accessToken,
    query: FluxaTaskListQuery(
      limit: 12,
      priority: priority,
      projectId: projectId,
      q: searchQuery.isEmpty ? null : searchQuery,
      status: status,
    ),
  );
  final projectsFuture = api.listProjects(session.accessToken);

  return TaskListSnapshot(
    projects: await projectsFuture,
    tasks: await tasksFuture,
  );
});

class TaskListSnapshot {
  const TaskListSnapshot({
    required this.projects,
    required this.tasks,
  });

  final List<FluxaProject> projects;
  final FluxaTaskPage tasks;
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
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

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(taskSearchFilterProvider),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'No due date';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  String _formatLabel(String value) {
    return value
        .split('_')
        .map(
          (segment) => segment.isEmpty
              ? segment
              : '${segment[0].toUpperCase()}${segment.substring(1)}',
        )
        .join(' ');
  }

  void _applySearchFilter() {
    ref.read(taskSearchFilterProvider.notifier).state =
        _searchController.text.trim();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(taskProjectFilterProvider.notifier).state = null;
    ref.read(taskStatusFilterProvider.notifier).state = null;
    ref.read(taskPriorityFilterProvider.notifier).state = null;
    ref.read(taskSearchFilterProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final taskListAsync = ref.watch(taskListProvider);
    final selectedProjectId = ref.watch(taskProjectFilterProvider);
    final selectedStatus = ref.watch(taskStatusFilterProvider);
    final selectedPriority = ref.watch(taskPriorityFilterProvider);
    final searchQuery = ref.watch(taskSearchFilterProvider);
    final hasActiveFilters = selectedProjectId != null ||
        selectedStatus != null ||
        selectedPriority != null ||
        searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(taskListProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add_task),
        label: const Text('New task'),
      ),
      body: taskListAsync.when(
        data: (snapshot) {
          final taskPage = snapshot.tasks;
          final projects = snapshot.projects;
          final hasSelectedProject = selectedProjectId != null &&
              projects.any((project) => project.id == selectedProjectId);
          final effectiveSelectedProjectId =
              hasSelectedProject ? selectedProjectId : null;

          if (selectedProjectId != null && !hasSelectedProject) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(taskProjectFilterProvider.notifier).state = null;
            });
          }

          String? projectNameFor(String? projectId) {
            if (projectId == null || projectId.isEmpty) {
              return null;
            }

            for (final project in projects) {
              if (project.id == projectId) {
                return project.name;
              }
            }

            return null;
          }

          final activeFilterChips = [
            if (searchQuery.isNotEmpty) 'Search: "$searchQuery"',
            if (effectiveSelectedProjectId != null)
              'Project: ${projectNameFor(effectiveSelectedProjectId) ?? effectiveSelectedProjectId}',
            if (selectedStatus != null) 'Status: ${_formatLabel(selectedStatus)}',
            if (selectedPriority != null)
              'Priority: ${_formatLabel(selectedPriority)}',
          ];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(taskListProvider);
              await ref.read(taskListProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tenant-scoped work queue',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search, filter, and edit tasks from the same mobile flow.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Search title or description',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isEmpty &&
                                  _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _applySearchFilter();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                        onSubmitted: (_) => _applySearchFilter(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _applySearchFilter,
                          icon: const Icon(Icons.filter_alt_outlined),
                          label: const Text('Apply search'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        key: ValueKey(
                          'task-project-filter-${effectiveSelectedProjectId ?? 'all'}',
                        ),
                        initialValue: effectiveSelectedProjectId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Project filter',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All projects'),
                          ),
                          ...projects.map(
                            (project) => DropdownMenuItem<String?>(
                              value: project.id,
                              child: Text(project.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(taskProjectFilterProvider.notifier).state = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              key: ValueKey(
                                'task-status-filter-${selectedStatus ?? 'all'}',
                              ),
                              initialValue: selectedStatus,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Status',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All statuses'),
                                ),
                                ..._statusOptions.map(
                                  (status) => DropdownMenuItem<String?>(
                                    value: status,
                                    child: Text(_formatLabel(status)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                ref.read(taskStatusFilterProvider.notifier).state =
                                    value;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              key: ValueKey(
                                'task-priority-filter-${selectedPriority ?? 'all'}',
                              ),
                              initialValue: selectedPriority,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Priority',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All priorities'),
                                ),
                                ..._priorityOptions.map(
                                  (priority) => DropdownMenuItem<String?>(
                                    value: priority,
                                    child: Text(_formatLabel(priority)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                ref.read(taskPriorityFilterProvider.notifier).state =
                                    value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${taskPage.data.length} task${taskPage.data.length == 1 ? '' : 's'} loaded${taskPage.nextCursor != null ? ' · more available' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          if (hasActiveFilters)
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reset filters'),
                            ),
                        ],
                      ),
                      if (activeFilterChips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: activeFilterChips
                              .map((label) => Chip(label: Text(label)))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (taskPage.data.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasActiveFilters ? 'No tasks match these filters' : 'No tasks yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasActiveFilters
                                ? 'Try clearing one or more filters to broaden the result set.'
                                : 'Start with your first task and it will show up here for the active tenant.',
                          ),
                          const SizedBox(height: 16),
                          if (hasActiveFilters)
                            OutlinedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Clear filters'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () => context.push('/tasks/new'),
                              icon: const Icon(Icons.add_task),
                              label: const Text('Create first task'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ...taskPage.data.map((task) {
                  final projectName = projectNameFor(task.projectId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        '${projectName ?? 'No project'} · ${_formatLabel(task.status)} · ${_formatLabel(task.priority)} · ${_formatDate(task.dueAt)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/tasks/${task.id}'),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load tasks right now.\n\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
