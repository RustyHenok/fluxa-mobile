import 'generated/fluxa_contract_models.dart';

export 'generated/fluxa_contract_models.dart';

class StoredSession {
  const StoredSession({
    required this.activeTenantId,
    required this.refreshToken,
  });

  final String? activeTenantId;
  final String refreshToken;
}

class OverviewSnapshot {
  const OverviewSnapshot({
    required this.me,
    required this.members,
    required this.projects,
    required this.summary,
    required this.tasks,
    required this.tenants,
  });

  final FluxaMe me;
  final List<FluxaTenantMember> members;
  final List<FluxaProject> projects;
  final FluxaDashboardSummary summary;
  final FluxaTaskPage tasks;
  final List<FluxaTenantMembership> tenants;
}

class TaskDetailSnapshot {
  const TaskDetailSnapshot({
    required this.audit,
    required this.members,
    required this.projects,
    required this.task,
  });

  final FluxaTaskAuditPage audit;
  final List<FluxaTenantMember> members;
  final List<FluxaProject> projects;
  final FluxaTask task;
}

class ProjectDetailSnapshot {
  const ProjectDetailSnapshot({
    required this.project,
    required this.summary,
    required this.tasks,
  });

  final FluxaProject project;
  final FluxaProjectSummary summary;
  final FluxaTaskPage tasks;
}

class FluxaPatchField<T> {
  const FluxaPatchField.unset()
      : isSet = false,
        value = null;

  const FluxaPatchField.set(this.value) : isSet = true;

  final bool isSet;
  final T? value;
}

class FluxaTaskPatchRequest {
  const FluxaTaskPatchRequest({
    this.assigneeId = const FluxaPatchField<String>.unset(),
    this.description = const FluxaPatchField<String>.unset(),
    this.dueAt = const FluxaPatchField<String>.unset(),
    this.priority = const FluxaPatchField<String>.unset(),
    this.projectId = const FluxaPatchField<String>.unset(),
    this.status = const FluxaPatchField<String>.unset(),
    this.title = const FluxaPatchField<String>.unset(),
  });

  factory FluxaTaskPatchRequest.fromTaskPayload(FluxaTaskPayload payload) {
    return FluxaTaskPatchRequest(
      assigneeId: FluxaPatchField.set(payload.assigneeId),
      description: FluxaPatchField.set(payload.description),
      dueAt: FluxaPatchField.set(payload.dueAt),
      priority: FluxaPatchField.set(payload.priority),
      projectId: FluxaPatchField.set(payload.projectId),
      status: FluxaPatchField.set(payload.status),
      title: FluxaPatchField.set(payload.title),
    );
  }

  final FluxaPatchField<String> assigneeId;
  final FluxaPatchField<String> description;
  final FluxaPatchField<String> dueAt;
  final FluxaPatchField<String> priority;
  final FluxaPatchField<String> projectId;
  final FluxaPatchField<String> status;
  final FluxaPatchField<String> title;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (assigneeId.isSet) {
      data['assignee_id'] = assigneeId.value;
    }
    if (description.isSet) {
      data['description'] = description.value;
    }
    if (dueAt.isSet) {
      data['due_at'] = dueAt.value;
    }
    if (priority.isSet) {
      data['priority'] = priority.value;
    }
    if (projectId.isSet) {
      data['project_id'] = projectId.value;
    }
    if (status.isSet) {
      data['status'] = status.value;
    }
    if (title.isSet) {
      data['title'] = title.value;
    }

    return data;
  }
}

class FluxaTaskListQuery {
  const FluxaTaskListQuery({
    this.assigneeId,
    this.cursor,
    this.dueAfter,
    this.dueBefore,
    this.limit,
    this.priority,
    this.projectId,
    this.q,
    this.status,
    this.updatedAfter,
  });

  final String? assigneeId;
  final String? cursor;
  final String? dueAfter;
  final String? dueBefore;
  final int? limit;
  final String? priority;
  final String? projectId;
  final String? q;
  final String? status;
  final String? updatedAfter;

  FluxaTaskFilters toFilters() {
    return FluxaTaskFilters(
      assigneeId: assigneeId,
      dueAfter: dueAfter,
      dueBefore: dueBefore,
      priority: priority,
      projectId: projectId,
      q: q,
      status: status,
      updatedAfter: updatedAfter,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final data = <String, dynamic>{
      ...toFilters().toJson(),
      if (cursor != null && cursor!.isNotEmpty) 'cursor': cursor,
      if (limit != null) 'limit': limit,
    };

    data.removeWhere((_, value) => value == null || value == '');
    return data;
  }
}
