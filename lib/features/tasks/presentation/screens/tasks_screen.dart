import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final taskProjectFilterProvider = StateProvider<String?>((ref) => null);

final taskListProvider = FutureProvider<TaskListSnapshot>((ref) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  final projectId = ref.watch(taskProjectFilterProvider);
  final tasksFuture = api.listTasks(
    session.accessToken,
    query: FluxaTaskListQuery(
      limit: 12,
      projectId: projectId,
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

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'No due date';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);
    final selectedProjectId = ref.watch(taskProjectFilterProvider);

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

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(taskListProvider);
              await ref.read(taskListProvider.future);
            },
            child: ListView.builder(
              itemCount: taskPage.data.isEmpty ? 2 : taskPage.data.length + 1,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
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
                          'Create, review, and edit tasks from the same mobile flow.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          value: effectiveSelectedProjectId,
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
                            ref.read(taskProjectFilterProvider.notifier).state =
                                value;
                          },
                        ),
                      ],
                    ),
                  );
                }

                if (taskPage.data.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start with your first task and it will show up here for the active tenant.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => context.push('/tasks/new'),
                            icon: const Icon(Icons.add_task),
                            label: const Text('Create first task'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final task = taskPage.data[index - 1];
                final projectName = projectNameFor(task.projectId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${projectName ?? 'No project'} · ${task.status} · ${task.priority} · ${_formatDate(task.dueAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/tasks/${task.id}'),
                  ),
                );
              },
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
