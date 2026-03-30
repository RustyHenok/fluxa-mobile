import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import 'projects_screen.dart';

final projectDetailProvider =
    FutureProvider.family<ProjectDetailSnapshot, String>((ref, projectId) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  return api.loadProjectDetail(session.accessToken, projectId);
});

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    required this.projectId,
    super.key,
  });

  final String projectId;

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Not available';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project detail'),
        actions: [
          IconButton(
            onPressed: () => context.push('/projects/$projectId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => ref.invalidate(projectDetailProvider(projectId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: projectAsync.when(
        data: (snapshot) {
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
                        snapshot.project.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.project.description?.isNotEmpty == true
                            ? snapshot.project.description!
                            : 'No project description yet.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Chip(label: Text('Open ${snapshot.summary.openTaskCount}')),
                          Chip(
                            label: Text(
                              'In progress ${snapshot.summary.inProgressTaskCount}',
                            ),
                          ),
                          Chip(label: Text('Done ${snapshot.summary.doneTaskCount}')),
                          Chip(
                            label: Text('Overdue ${snapshot.summary.overdueTaskCount}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Updated ${_formatDate(snapshot.project.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.push(
                                '/tasks/new?projectId=${snapshot.project.id}',
                              ),
                              icon: const Icon(Icons.add_task),
                              label: const Text('New task'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final auth =
                                    ref.read(authControllerProvider).state;
                                final session = auth.session;
                                if (session == null) {
                                  return;
                                }

                                final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete project'),
                                        content: const Text(
                                          'This removes the project record. Existing tasks will no longer be linked to it.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (!confirmed) {
                                  return;
                                }

                                try {
                                  await ref
                                      .read(fluxaApiClientProvider)
                                      .deleteProject(
                                        session.accessToken,
                                        snapshot.project.id,
                                      );
                                  ref.invalidate(projectListProvider);
                                  ref.invalidate(taskListProvider);
                                  ref.invalidate(overviewProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Project deleted.'),
                                      ),
                                    );
                                    context.go('/projects');
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Unable to delete project.\n$error',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
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
                        'Project tasks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (snapshot.tasks.data.isEmpty)
                        const Text('No tasks are linked to this project yet.'),
                      for (final task in snapshot.tasks.data)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(task.title),
                          subtitle: Text(
                            '${task.status} · ${task.priority} · ${task.dueAt?.isNotEmpty == true ? _formatDate(task.dueAt!) : 'No due date'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/tasks/${task.id}'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load the project detail.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
