import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../tenants/presentation/widgets/tenant_picker_card.dart';

final overviewProvider = FutureProvider<OverviewSnapshot>((ref) async {
  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  return api.loadOverview(session.accessToken);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'No due date';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).state;
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(overviewProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: overviewAsync.when(
        data: (overview) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(overviewProvider);
              await ref.read(overviewProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${overview.me.user.email} · ${overview.me.activeTenant.tenantName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TenantPickerCard(
                  activeTenantId: overview.me.activeTenant.tenantId,
                  isBusy: auth.isBusy,
                  onSwitch: (tenantId) async {
                    final success =
                        await ref.read(authControllerProvider).switchTenant(tenantId);
                    if (success) {
                      ref.invalidate(overviewProvider);
                    }
                  },
                  tenants: overview.tenants,
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    _SummaryCard(
                      label: 'Open',
                      value: overview.summary.openTaskCount,
                    ),
                    _SummaryCard(
                      label: 'In Progress',
                      value: overview.summary.inProgressTaskCount,
                    ),
                    _SummaryCard(
                      label: 'Done',
                      value: overview.summary.doneTaskCount,
                    ),
                    _SummaryCard(
                      label: 'Overdue',
                      value: overview.summary.overdueTaskCount,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent task pulse',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recent tasks from the tenant-scoped backend contract.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        if (overview.tasks.data.isEmpty)
                          const Text('No tasks yet for this tenant.'),
                        for (final task in overview.tasks.data)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(task.title),
                            subtitle: Text(
                              '${task.status} · ${task.priority} · ${_formatDate(task.dueAt)}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/tasks/${task.id}'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go('/tasks'),
                        icon: const Icon(Icons.task_alt_outlined),
                        label: const Text('Open tasks'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/exports'),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Exports'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load the dashboard right now.\n\n$error',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
