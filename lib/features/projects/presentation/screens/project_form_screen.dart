import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/fluxa_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import 'project_detail_screen.dart';
import 'projects_screen.dart';

final projectFormProvider =
    FutureProvider.family<FluxaProject?, String?>((ref, projectId) async {
  if (projectId == null || projectId.isEmpty) {
    return null;
  }

  final auth = ref.watch(authControllerProvider).state;
  final session = auth.session;
  if (session == null) {
    throw StateError('No authenticated session available.');
  }

  final api = ref.watch(fluxaApiClientProvider);
  return api.getProject(session.accessToken, projectId);
});

class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({
    this.projectId,
    super.key,
  });

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectFormProvider(projectId));
    final isEditing = projectId != null && projectId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit project' : 'Create project'),
      ),
      body: projectAsync.when(
        data: (project) => _ProjectFormBody(project: project),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load the project form.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ProjectFormBody extends ConsumerStatefulWidget {
  const _ProjectFormBody({
    required this.project,
  });

  final FluxaProject? project;

  @override
  ConsumerState<_ProjectFormBody> createState() => _ProjectFormBodyState();
}

class _ProjectFormBodyState extends ConsumerState<_ProjectFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      final createPayload = FluxaProjectPayload(
        description: description.isEmpty ? null : description,
        name: _nameController.text.trim(),
      );
      final patchPayload = FluxaProjectPatchPayload(
        description: createPayload.description,
        name: createPayload.name,
      );

      final project = _isEditing
          ? await api.updateProject(
              session.accessToken,
              widget.project!.id,
              patchPayload,
            )
          : await api.createProject(
              session.accessToken,
              createPayload,
            );

      ref.invalidate(projectListProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(overviewProvider);
      ref.invalidate(projectFormProvider(widget.project?.id));
      ref.invalidate(projectDetailProvider(project.id));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Project updated successfully.'
                : 'Project created successfully.',
          ),
        ),
      );
      context.go('/projects/${project.id}');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save project.\n$error'),
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
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing ? 'Update project details' : 'Create a project lane',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing
                  ? 'Keep project naming and context fresh so the rest of the team can align tasks to the right stream.'
                  : 'Create a dedicated project so tasks can be grouped by delivery stream, customer, or initiative.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
                hintText: 'Add a short summary of what this project owns.',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: Icon(
                  _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                ),
                label: Text(
                  _isSubmitting
                      ? (_isEditing ? 'Saving…' : 'Creating…')
                      : (_isEditing ? 'Save project' : 'Create project'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
