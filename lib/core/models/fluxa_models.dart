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
