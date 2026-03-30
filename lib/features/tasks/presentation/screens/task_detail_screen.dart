import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import 'tasks_screen.dart';

final taskDetailProvider = FutureProvider.family<TaskDetailSnapshot, String>(
  (ref, taskId) async {
    final auth = ref.watch(authControllerProvider).state;
    final session = auth.session;
    if (session == null) {
      throw StateError('No authenticated session available.');
    }

    final api = ref.watch(fluxaApiClientProvider);
    return api.loadTaskDetail(session.accessToken, taskId);
  },
);

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    required this.taskId,
    super.key,
  });

  final String taskId;

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'No due date';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  String _formatEvent(String value) {
    return value.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task detail'),
        actions: [
          IconButton(
            onPressed: () => context.push('/tasks/$taskId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => ref.invalidate(taskDetailProvider(taskId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: taskAsync.when(
        data: (snapshot) {
          final task = snapshot.task;
          FluxaTenantMember? assignee;
          FluxaProject? project;
          for (final member in snapshot.members) {
            if (member.userId == task.assigneeId) {
              assignee = member;
              break;
            }
          }
          for (final entry in snapshot.projects) {
            if (entry.id == task.projectId) {
              project = entry;
              break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(task.description ?? 'No description provided yet.'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Chip(label: Text(task.status)),
                          Chip(label: Text(task.priority)),
                          Chip(label: Text(_formatDate(task.dueAt))),
                          Chip(
                            label: Text(
                              assignee?.email ?? 'Unassigned',
                            ),
                          ),
                          if (project != null)
                            ActionChip(
                              label: Text(project.name),
                              onPressed: () => context.push('/projects/${project.id}'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: task.status == 'archived'
                            ? null
                            : () async {
                                final auth = ref.read(authControllerProvider).state;
                                final session = auth.session;
                                if (session == null) {
                                  return;
                                }

                                await ref.read(fluxaApiClientProvider).updateTask(
                                      session.accessToken,
                                      task.id,
                                      const FluxaTaskPatchRequest(
                                        status: FluxaPatchField<String>.set(
                                          'archived',
                                        ),
                                      ),
                                    );
                                ref.invalidate(taskDetailProvider(taskId));
                                ref.invalidate(taskListProvider);
                                ref.invalidate(overviewProvider);
                                ref.invalidate(projectListProvider);
                                if (task.projectId != null &&
                                    task.projectId!.isNotEmpty) {
                                  ref.invalidate(
                                    projectDetailProvider(task.projectId!),
                                  );
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Task archived.'),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.archive_outlined),
                        label: Text(
                          task.status == 'archived'
                              ? 'Already archived'
                              : 'Archive task',
                        ),
                      ),
                      if (project != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/projects/${project.id}'),
                          icon: const Icon(Icons.folder_open_outlined),
                          label: const Text('Open project'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit timeline',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (snapshot.audit.data.isEmpty)
                        const Text('No audit activity yet.'),
                      for (final entry in snapshot.audit.data)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_formatEvent(entry.eventType)),
                          subtitle: Text(_formatDate(entry.createdAt)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load the task detail.\n\n$error',
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
