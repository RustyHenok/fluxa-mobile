class FluxaUser {
  const FluxaUser({
    required this.createdAt,
    required this.email,
    required this.id,
  });

  final String createdAt;
  final String email;
  final String id;

  factory FluxaUser.fromJson(Map<String, dynamic> json) {
    return FluxaUser(
      createdAt: json['created_at'] as String? ?? '',
      email: json['email'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }
}

class FluxaTenantMembership {
  const FluxaTenantMembership({
    required this.createdAt,
    required this.role,
    required this.tenantId,
    required this.tenantName,
  });

  final String createdAt;
  final String role;
  final String tenantId;
  final String tenantName;

  factory FluxaTenantMembership.fromJson(Map<String, dynamic> json) {
    return FluxaTenantMembership(
      createdAt: json['created_at'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      tenantId: json['tenant_id'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
    );
  }
}

class FluxaTenantMember {
  const FluxaTenantMember({
    required this.email,
    required this.joinedAt,
    required this.role,
    required this.userId,
  });

  final String email;
  final String joinedAt;
  final String role;
  final String userId;

  factory FluxaTenantMember.fromJson(Map<String, dynamic> json) {
    return FluxaTenantMember(
      email: json['email'] as String? ?? '',
      joinedAt: json['joined_at'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      userId: json['user_id'] as String? ?? '',
    );
  }
}

class FluxaSession {
  const FluxaSession({
    required this.accessToken,
    required this.activeTenant,
    required this.expiresInSeconds,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final FluxaTenantMembership activeTenant;
  final int expiresInSeconds;
  final String refreshToken;
  final FluxaUser user;

  factory FluxaSession.fromJson(Map<String, dynamic> json) {
    return FluxaSession(
      accessToken: json['access_token'] as String? ?? '',
      activeTenant: FluxaTenantMembership.fromJson(
        Map<String, dynamic>.from(json['active_tenant'] as Map? ?? const {}),
      ),
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 0,
      refreshToken: json['refresh_token'] as String? ?? '',
      user: FluxaUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
    );
  }
}

class StoredSession {
  const StoredSession({
    required this.activeTenantId,
    required this.refreshToken,
  });

  final String? activeTenantId;
  final String refreshToken;
}

class FluxaMe {
  const FluxaMe({
    required this.activeTenant,
    required this.user,
  });

  final FluxaTenantMembership activeTenant;
  final FluxaUser user;

  factory FluxaMe.fromJson(Map<String, dynamic> json) {
    return FluxaMe(
      activeTenant: FluxaTenantMembership.fromJson(
        Map<String, dynamic>.from(json['active_tenant'] as Map? ?? const {}),
      ),
      user: FluxaUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
    );
  }
}

class FluxaDashboardSummary {
  const FluxaDashboardSummary({
    required this.doneTaskCount,
    required this.inProgressTaskCount,
    required this.openTaskCount,
    required this.overdueTaskCount,
    required this.recentActivityCount,
  });

  final int doneTaskCount;
  final int inProgressTaskCount;
  final int openTaskCount;
  final int overdueTaskCount;
  final int recentActivityCount;

  factory FluxaDashboardSummary.fromJson(Map<String, dynamic> json) {
    return FluxaDashboardSummary(
      doneTaskCount: json['done_task_count'] as int? ?? 0,
      inProgressTaskCount: json['in_progress_task_count'] as int? ?? 0,
      openTaskCount: json['open_task_count'] as int? ?? 0,
      overdueTaskCount: json['overdue_task_count'] as int? ?? 0,
      recentActivityCount: json['recent_activity_count'] as int? ?? 0,
    );
  }
}

class FluxaProject {
  const FluxaProject({
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.id,
    required this.name,
    required this.tenantId,
    required this.updatedAt,
    required this.updatedBy,
  });

  final String createdAt;
  final String createdBy;
  final String? description;
  final String id;
  final String name;
  final String tenantId;
  final String updatedAt;
  final String updatedBy;

  factory FluxaProject.fromJson(Map<String, dynamic> json) {
    return FluxaProject(
      createdAt: json['created_at'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      description: json['description'] as String?,
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      updatedBy: json['updated_by'] as String? ?? '',
    );
  }
}

class FluxaProjectSummary {
  const FluxaProjectSummary({
    required this.doneTaskCount,
    required this.inProgressTaskCount,
    required this.openTaskCount,
    required this.overdueTaskCount,
    required this.projectId,
    required this.projectName,
    required this.recentActivityCount,
  });

  final int doneTaskCount;
  final int inProgressTaskCount;
  final int openTaskCount;
  final int overdueTaskCount;
  final String projectId;
  final String projectName;
  final int recentActivityCount;

  factory FluxaProjectSummary.fromJson(Map<String, dynamic> json) {
    return FluxaProjectSummary(
      doneTaskCount: json['done_task_count'] as int? ?? 0,
      inProgressTaskCount: json['in_progress_task_count'] as int? ?? 0,
      openTaskCount: json['open_task_count'] as int? ?? 0,
      overdueTaskCount: json['overdue_task_count'] as int? ?? 0,
      projectId: json['project_id'] as String? ?? '',
      projectName: json['project_name'] as String? ?? '',
      recentActivityCount: json['recent_activity_count'] as int? ?? 0,
    );
  }
}

class FluxaTask {
  const FluxaTask({
    required this.assigneeId,
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.dueAt,
    required this.id,
    required this.priority,
    required this.projectId,
    required this.status,
    required this.tenantId,
    required this.title,
    required this.updatedAt,
    required this.updatedBy,
  });

  final String? assigneeId;
  final String createdAt;
  final String createdBy;
  final String? description;
  final String? dueAt;
  final String id;
  final String priority;
  final String? projectId;
  final String status;
  final String tenantId;
  final String title;
  final String updatedAt;
  final String updatedBy;

  factory FluxaTask.fromJson(Map<String, dynamic> json) {
    return FluxaTask(
      assigneeId: json['assignee_id'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      description: json['description'] as String?,
      dueAt: json['due_at'] as String?,
      id: json['id'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      projectId: json['project_id'] as String?,
      status: json['status'] as String? ?? 'open',
      tenantId: json['tenant_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      updatedBy: json['updated_by'] as String? ?? '',
    );
  }
}

class FluxaTaskPage {
  const FluxaTaskPage({
    required this.data,
    required this.nextCursor,
  });

  final List<FluxaTask> data;
  final String? nextCursor;

  factory FluxaTaskPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List? ?? const [];

    return FluxaTaskPage(
      data: rawData
          .map(
            (entry) => FluxaTask.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class FluxaTaskAuditEntry {
  const FluxaTaskAuditEntry({
    required this.actorUserId,
    required this.createdAt,
    required this.eventType,
    required this.id,
    required this.payload,
  });

  final String actorUserId;
  final String createdAt;
  final String eventType;
  final String id;
  final Map<String, dynamic> payload;

  factory FluxaTaskAuditEntry.fromJson(Map<String, dynamic> json) {
    return FluxaTaskAuditEntry(
      actorUserId: json['actor_user_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
    );
  }
}

class FluxaTaskAuditPage {
  const FluxaTaskAuditPage({
    required this.data,
    required this.nextCursor,
  });

  final List<FluxaTaskAuditEntry> data;
  final String? nextCursor;

  factory FluxaTaskAuditPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List? ?? const [];

    return FluxaTaskAuditPage(
      data: rawData
          .map(
            (entry) => FluxaTaskAuditEntry.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class FluxaJob {
  const FluxaJob({
    required this.id,
    required this.jobType,
    required this.status,
    required this.finishedAt,
  });

  final String id;
  final String jobType;
  final String status;
  final String? finishedAt;

  factory FluxaJob.fromJson(Map<String, dynamic> json) {
    return FluxaJob(
      id: json['id'] as String? ?? '',
      jobType: json['job_type'] as String? ?? 'task_export',
      status: json['status'] as String? ?? 'queued',
      finishedAt: json['finished_at'] as String?,
    );
  }
}

class FluxaJobResult {
  const FluxaJobResult({
    required this.finishedAt,
    required this.jobId,
    required this.jobType,
    required this.result,
  });

  final String? finishedAt;
  final String jobId;
  final String jobType;
  final Map<String, dynamic> result;

  factory FluxaJobResult.fromJson(Map<String, dynamic> json) {
    return FluxaJobResult(
      finishedAt: json['finished_at'] as String?,
      jobId: json['job_id'] as String? ?? '',
      jobType: json['job_type'] as String? ?? 'task_export',
      result: Map<String, dynamic>.from(json['result'] as Map? ?? const {}),
    );
  }
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
