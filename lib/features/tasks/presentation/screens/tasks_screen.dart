import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final taskListProvider = FutureProvider<FluxaTaskPage>((ref) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  return api.listTasks(
    session.accessToken,
    query: const {
      'limit': 12,
    },
  );
});

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
      body: taskListAsync.when(
        data: (taskPage) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(taskListProvider);
              await ref.read(taskListProvider.future);
            },
            child: ListView.builder(
              itemCount: taskPage.data.length + 1,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Tenant-scoped work queue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                }

                final task = taskPage.data[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.status} · ${task.priority} · ${_formatDate(task.dueAt)}',
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
