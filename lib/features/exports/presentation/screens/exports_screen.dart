import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ExportsScreen extends ConsumerStatefulWidget {
  const ExportsScreen({super.key});

  @override
  ConsumerState<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends ConsumerState<ExportsScreen> {
  bool _isBusy = false;
  String? _error;
  FluxaJob? _job;
  FluxaJobResult? _jobResult;
  String _statusFilter = 'open';

  Future<void> _createExport() async {
    final auth = ref.read(authControllerProvider).state;
    final session = auth.session;
    if (session == null) {
      return;
    }

    setState(() {
      _error = null;
      _isBusy = true;
    });

    try {
      final job = await ref.read(fluxaApiClientProvider).createTaskExport(
            session.accessToken,
            filters: {
              'status': _statusFilter,
            },
            idempotencyKey: DateTime.now().microsecondsSinceEpoch.toString(),
          );
      setState(() {
        _job = job;
      });
      await _refreshJob();
    } catch (error) {
      setState(() {
        _error = '$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _refreshJob() async {
    final auth = ref.read(authControllerProvider).state;
    final session = auth.session;
    final job = _job;
    if (session == null || job == null) {
      return;
    }

    setState(() {
      _error = null;
      _isBusy = true;
    });

    try {
      final nextJob =
          await ref.read(fluxaApiClientProvider).getJob(session.accessToken, job.id);
      FluxaJobResult? jobResult = _jobResult;

      if (nextJob.status == 'completed') {
        jobResult = await ref
            .read(fluxaApiClientProvider)
            .getJobResult(session.accessToken, nextJob.id);
      }

      setState(() {
        _job = nextJob;
        _jobResult = jobResult;
      });
    } catch (error) {
      setState(() {
        _error = '$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).state;
    final session = auth.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task export builder',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a background export job against the active tenant.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Task status filter',
                    ),
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('In progress'),
                      ),
                      DropdownMenuItem(value: 'done', child: Text('Done')),
                      DropdownMenuItem(value: 'archived', child: Text('Archived')),
                    ],
                    onChanged: _isBusy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _statusFilter = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isBusy || session == null ? null : _createExport,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(_isBusy ? 'Working...' : 'Create export'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_job != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest export job',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Job ID: ${_job!.id}'),
                    Text('Type: ${_job!.jobType}'),
                    Text('Status: ${_job!.status}'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isBusy ? null : _refreshJob,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh job status'),
                    ),
                    if (_jobResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Result payload keys: ${_jobResult!.result.keys.join(', ')}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
