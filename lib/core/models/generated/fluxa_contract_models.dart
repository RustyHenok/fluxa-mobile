// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

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
      activeTenant: FluxaTenantMembership.fromJson(Map<String, dynamic>.from(json['active_tenant'] as Map? ?? const {})),
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 0,
      refreshToken: json['refresh_token'] as String? ?? '',
      user: FluxaUser.fromJson(Map<String, dynamic>.from(json['user'] as Map? ?? const {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'active_tenant': activeTenant.toJson(),
      'expires_in_seconds': expiresInSeconds,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'done_task_count': doneTaskCount,
      'in_progress_task_count': inProgressTaskCount,
      'open_task_count': openTaskCount,
      'overdue_task_count': overdueTaskCount,
      'recent_activity_count': recentActivityCount,
    };
  }
}

class FluxaJob {
  const FluxaJob({
    required this.attempts,
    required this.finishedAt,
    required this.id,
    required this.jobType,
    required this.lastError,
    required this.maxAttempts,
    required this.payload,
    required this.resultPayload,
    required this.scheduledAt,
    required this.startedAt,
    required this.status,
    required this.tenantId,
  });

  final int attempts;
  final String? finishedAt;
  final String id;
  final String jobType;
  final String? lastError;
  final int maxAttempts;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? resultPayload;
  final String scheduledAt;
  final String? startedAt;
  final String status;
  final String? tenantId;

  factory FluxaJob.fromJson(Map<String, dynamic> json) {
    return FluxaJob(
      attempts: json['attempts'] as int? ?? 0,
      finishedAt: json['finished_at'] as String?,
      id: json['id'] as String? ?? '',
      jobType: json['job_type'] as String? ?? '',
      lastError: json['last_error'] as String?,
      maxAttempts: json['max_attempts'] as int? ?? 0,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      resultPayload: json['result_payload'] == null ? null : Map<String, dynamic>.from(json['result_payload'] as Map),
      scheduledAt: json['scheduled_at'] as String? ?? '',
      startedAt: json['started_at'] as String?,
      status: json['status'] as String? ?? '',
      tenantId: json['tenant_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempts': attempts,
      'finished_at': finishedAt,
      'id': id,
      'job_type': jobType,
      'last_error': lastError,
      'max_attempts': maxAttempts,
      'payload': payload,
      'result_payload': resultPayload,
      'scheduled_at': scheduledAt,
      'started_at': startedAt,
      'status': status,
      'tenant_id': tenantId,
    };
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
      jobType: json['job_type'] as String? ?? '',
      result: Map<String, dynamic>.from(json['result'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finished_at': finishedAt,
      'job_id': jobId,
      'job_type': jobType,
      'result': result,
    };
  }
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
      activeTenant: FluxaTenantMembership.fromJson(Map<String, dynamic>.from(json['active_tenant'] as Map? ?? const {})),
      user: FluxaUser.fromJson(Map<String, dynamic>.from(json['user'] as Map? ?? const {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_tenant': activeTenant.toJson(),
      'user': user.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'id': id,
      'name': name,
      'tenant_id': tenantId,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'done_task_count': doneTaskCount,
      'in_progress_task_count': inProgressTaskCount,
      'open_task_count': openTaskCount,
      'overdue_task_count': overdueTaskCount,
      'project_id': projectId,
      'project_name': projectName,
      'recent_activity_count': recentActivityCount,
    };
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
    return FluxaTaskAuditPage(
      data: (json['data'] as List? ?? const []).map((entry) => FluxaTaskAuditEntry.fromJson(Map<String, dynamic>.from(entry as Map))).toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((entry) => entry.toJson()).toList(),
      'next_cursor': nextCursor,
    };
  }
}

class FluxaTaskAuditEntry {
  const FluxaTaskAuditEntry({
    required this.actorUserId,
    required this.createdAt,
    required this.eventType,
    required this.id,
    required this.payload,
    required this.taskId,
    required this.tenantId,
  });

  final String actorUserId;
  final String createdAt;
  final String eventType;
  final String id;
  final Map<String, dynamic> payload;
  final String? taskId;
  final String tenantId;

  factory FluxaTaskAuditEntry.fromJson(Map<String, dynamic> json) {
    return FluxaTaskAuditEntry(
      actorUserId: json['actor_user_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      taskId: json['task_id'] as String?,
      tenantId: json['tenant_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actor_user_id': actorUserId,
      'created_at': createdAt,
      'event_type': eventType,
      'id': id,
      'payload': payload,
      'task_id': taskId,
      'tenant_id': tenantId,
    };
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
    return FluxaTaskPage(
      data: (json['data'] as List? ?? const []).map((entry) => FluxaTask.fromJson(Map<String, dynamic>.from(entry as Map))).toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((entry) => entry.toJson()).toList(),
      'next_cursor': nextCursor,
    };
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
      priority: json['priority'] as String? ?? '',
      projectId: json['project_id'] as String?,
      status: json['status'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      updatedBy: json['updated_by'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignee_id': assigneeId,
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'due_at': dueAt,
      'id': id,
      'priority': priority,
      'project_id': projectId,
      'status': status,
      'tenant_id': tenantId,
      'title': title,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
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
      role: json['role'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'joined_at': joinedAt,
      'role': role,
      'user_id': userId,
    };
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
      role: json['role'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'role': role,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
    };
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'email': email,
      'id': id,
    };
  }
}
