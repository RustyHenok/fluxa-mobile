import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ExportsScreen extends ConsumerStatefulWidget {
  const ExportsScreen({super.key});

  @override
  ConsumerState<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends ConsumerState<ExportsScreen> {
  static const _pollInterval = Duration(seconds: 2);

  bool _isBusy = false;
  Timer? _pollingTimer;
  String? _error;
  FluxaJob? _job;
  FluxaJobResult? _jobResult;
  String _statusFilter = '';
  String _priorityFilter = '';

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not available';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  String _labelize(String value) {
    return value.replaceAll('_', ' ');
  }

  List<FluxaTask> _tasksFromResult(FluxaJobResult result) {
    final rawTasks = result.result['tasks'] as List? ?? const [];

    return rawTasks
        .map(
          (entry) => FluxaTask.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  int _taskCountFromResult(FluxaJobResult result) {
    return result.result['task_count'] as int? ?? _tasksFromResult(result).length;
  }

  void _schedulePolling() {
    _pollingTimer?.cancel();

    if (_job == null || (_job!.status != 'queued' && _job!.status != 'running')) {
      return;
    }

    _pollingTimer = Timer(_pollInterval, () {
      if (mounted) {
        _refreshJob(triggeredByPolling: true);
      }
    });
  }

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
            FluxaExportRequest(
              assigneeId: null,
              dueAfter: null,
              dueBefore: null,
              priority: _priorityFilter.isEmpty ? null : _priorityFilter,
              projectId: null,
              q: null,
              status: _statusFilter.isEmpty ? null : _statusFilter,
              updatedAfter: null,
            ),
            idempotencyKey:
                'mobile-export-${DateTime.now().microsecondsSinceEpoch}',
          );
      setState(() {
        _job = job;
        _jobResult = null;
      });
      _schedulePolling();
      await _refreshJob(triggeredByPolling: true);
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

  Future<void> _refreshJob({bool triggeredByPolling = false}) async {
    final auth = ref.read(authControllerProvider).state;
    final session = auth.session;
    final job = _job;
    if (session == null || job == null) {
      return;
    }

    if (!triggeredByPolling) {
      setState(() {
        _error = null;
        _isBusy = true;
      });
    }

    try {
      final nextJob =
          await ref.read(fluxaApiClientProvider).getJob(session.accessToken, job.id);
      FluxaJobResult? jobResult = _jobResult;

      if (nextJob.status == 'completed') {
        jobResult = await ref
            .read(fluxaApiClientProvider)
            .getJobResult(session.accessToken, nextJob.id);
      } else if (nextJob.status == 'dead_letter') {
        _pollingTimer?.cancel();
      }

      setState(() {
        _job = nextJob;
        _jobResult = jobResult;
      });

      if (nextJob.status == 'queued' || nextJob.status == 'running') {
        _schedulePolling();
      } else {
        _pollingTimer?.cancel();
      }
    } catch (error) {
      setState(() {
        _error = '$error';
      });
      _pollingTimer?.cancel();
    } finally {
      if (mounted && !triggeredByPolling) {
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
        actions: [
          if (_job != null)
            IconButton(
              onPressed: _isBusy ? null : () => _refreshJob(),
              icon: const Icon(Icons.refresh),
            ),
        ],
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
                      border: OutlineInputBorder(),
                      labelText: 'Task status filter',
                    ),
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Any status')),
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Task priority filter',
                    ),
                    value: _priorityFilter,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Any priority')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: _isBusy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _priorityFilter = value;
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Latest export job',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Chip(
                          label: Text(_labelize(_job!.status)),
                          avatar: _job!.status == 'queued' || _job!.status == 'running'
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Job ID: ${_job!.id}'),
                    Text('Type: ${_job!.jobType}'),
                    Text('Finished: ${_formatDateTime(_job!.finishedAt)}'),
                    const SizedBox(height: 12),
                    if (_job!.status == 'queued' || _job!.status == 'running')
                      Text(
                        'Polling job status automatically until completion.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (_jobResult != null) ...[
                      const SizedBox(height: 16),
                      _ExportResultCard(
                        result: _jobResult!,
                        tasks: _tasksFromResult(_jobResult!),
                        taskCount: _taskCountFromResult(_jobResult!),
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

class _ExportResultCard extends StatelessWidget {
  const _ExportResultCard({
    required this.result,
    required this.taskCount,
    required this.tasks,
  });

  final FluxaJobResult result;
  final int taskCount;
  final List<FluxaTask> tasks;

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not available';
    }

    return DateFormat.yMMMd().add_jm().format(DateTime.parse(value).toLocal());
  }

  String _labelize(String value) {
    return value.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final requestedBy = result.result['requested_by'] as String? ?? 'Unknown';
    final generatedAt = result.result['generated_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export result',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Generated ${_formatDateTime(generatedAt)} with $taskCount matching tasks.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Chip(label: Text('$taskCount tasks')),
            Chip(label: Text('Requested by $requestedBy')),
            Chip(label: Text('Finished ${_formatDateTime(result.finishedAt)}')),
          ],
        ),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          const Text('No tasks matched the selected filters.')
        else
          ...tasks.map(
            (task) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(task.title),
                subtitle: Text('${_labelize(task.status)} · ${_labelize(task.priority)}'),
                trailing: Text(
                  task.dueAt == null || task.dueAt!.isEmpty
                      ? 'No due'
                      : _formatDateTime(task.dueAt),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
