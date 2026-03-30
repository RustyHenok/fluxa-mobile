import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final projectListProvider = FutureProvider<List<FluxaProject>>((ref) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  return api.listProjects(session.accessToken);
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Recently updated';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(projectListProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/new'),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New project'),
      ),
      body: projectsAsync.when(
        data: (projects) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(projectListProvider);
              await ref.read(projectListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: projects.isEmpty ? 2 : projects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenant delivery lanes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Group related tasks into project streams so mobile users can stay organized by outcome, not just by raw task lists.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (projects.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No projects yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first project to organize tasks by initiative or customer workflow.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => context.push('/projects/new'),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Create first project'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final project = projects[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(project.name),
                    subtitle: Text(
                      '${project.description?.isNotEmpty == true ? project.description : 'No description'}\nUpdated ${_formatDate(project.updatedAt)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/projects/${project.id}'),
                  ),
                );
              },
            ),
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load projects right now.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
