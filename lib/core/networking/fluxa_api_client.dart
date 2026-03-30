import 'package:dio/dio.dart';

import '../errors/fluxa_exception.dart';
import '../models/fluxa_models.dart';
import '../config/app_config.dart';

class FluxaApiClient {
  FluxaApiClient({
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Options _authorized(String accessToken, {Map<String, String>? headers}) {
    return Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        ...?headers,
      },
    );
  }

  FluxaException _toException(Object error) {
    if (error is DioException) {
      final response = error.response;
      final body = response?.data;

      if (body is Map && body['error'] is Map) {
        final errorBody = Map<String, dynamic>.from(body['error'] as Map);
        return FluxaException(
          code: errorBody['code'] as String? ?? 'internal_error',
          message: errorBody['message'] as String? ?? 'Unexpected API error.',
          statusCode: response?.statusCode,
        );
      }

      return FluxaException(
        message: error.message ?? 'Unexpected network error.',
        statusCode: response?.statusCode,
      );
    }

    if (error is FluxaException) {
      return error;
    }

    return const FluxaException(message: 'Unexpected application error.');
  }

  Future<FluxaJob> createTaskExport(
    String accessToken, {
    Map<String, dynamic>? filters,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/exports/tasks',
        data: filters ?? const {},
        options: _authorized(
          accessToken,
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      return FluxaJob.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTask> createTask(
    String accessToken,
    Map<String, dynamic> payload, {
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/tasks',
        data: payload,
        options: _authorized(
          accessToken,
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      return FluxaTask.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaProject> createProject(
    String accessToken,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/projects',
        data: payload,
        options: _authorized(accessToken),
      );

      return FluxaProject.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<void> deleteProject(String accessToken, String projectId) async {
    try {
      await _dio.delete<void>(
        '/v1/projects/$projectId',
        options: _authorized(accessToken),
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<void> deleteTask(String accessToken, String taskId) async {
    try {
      await _dio.delete<void>(
        '/v1/tasks/$taskId',
        options: _authorized(accessToken),
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaDashboardSummary> getDashboardSummary(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/dashboard/summary',
        options: _authorized(accessToken),
      );

      return FluxaDashboardSummary.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaJob> getJob(String accessToken, String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/jobs/$jobId',
        options: _authorized(accessToken),
      );

      return FluxaJob.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaJobResult> getJobResult(String accessToken, String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/jobs/$jobId/result',
        options: _authorized(accessToken),
      );

      return FluxaJobResult.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaMe> getMe(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/me',
        options: _authorized(accessToken),
      );

      return FluxaMe.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaProject> getProject(String accessToken, String projectId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/projects/$projectId',
        options: _authorized(accessToken),
      );

      return FluxaProject.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaProjectSummary> getProjectSummary(
    String accessToken,
    String projectId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/projects/$projectId/summary',
        options: _authorized(accessToken),
      );

      return FluxaProjectSummary.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTask> getTask(String accessToken, String taskId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/tasks/$taskId',
        options: _authorized(accessToken),
      );

      return FluxaTask.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<List<FluxaTenantMembership>> getTenants(String accessToken) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/v1/me/tenants',
        options: _authorized(accessToken),
      );

      return (response.data ?? const [])
          .map(
            (entry) => FluxaTenantMembership.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<List<FluxaTenantMember>> listTenantMembers(
    String accessToken,
    String tenantId,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/v1/tenants/$tenantId/members',
        options: _authorized(accessToken),
      );

      return (response.data ?? const [])
          .map(
            (entry) => FluxaTenantMember.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<List<FluxaProject>> listProjects(String accessToken) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/v1/projects',
        options: _authorized(accessToken),
      );

      return (response.data ?? const [])
          .map(
            (entry) => FluxaProject.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTaskPage> listProjectTasks(
    String accessToken,
    String projectId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/projects/$projectId/tasks',
        options: _authorized(accessToken),
      );

      return FluxaTaskPage.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTaskAuditPage> listTaskAudit(
    String accessToken,
    String taskId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/tasks/$taskId/audit',
        options: _authorized(accessToken),
      );

      return FluxaTaskAuditPage.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTaskPage> listTasks(
    String accessToken, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/tasks',
        options: _authorized(accessToken),
        queryParameters: query,
      );

      return FluxaTaskPage.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<OverviewSnapshot> loadOverview(String accessToken) async {
    try {
      final meFuture = getMe(accessToken);
      final tenantsFuture = getTenants(accessToken);
      final summaryFuture = getDashboardSummary(accessToken);
      final projectsFuture = listProjects(accessToken);
      final tasksFuture = listTasks(
        accessToken,
        query: const {
          'limit': 6,
        },
      );

      final me = await meFuture;
      final members = await listTenantMembers(accessToken, me.activeTenant.tenantId);
      final projects = await projectsFuture;
      final tenants = await tenantsFuture;
      final summary = await summaryFuture;
      final tasks = await tasksFuture;

      return OverviewSnapshot(
        me: me,
        members: members,
        projects: projects,
        summary: summary,
        tasks: tasks,
        tenants: tenants,
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<TaskDetailSnapshot> loadTaskDetail(
    String accessToken,
    String taskId,
  ) async {
    try {
      final task = await getTask(accessToken, taskId);
      final auditFuture = listTaskAudit(accessToken, taskId);
      final membersFuture = listTenantMembers(accessToken, task.tenantId);
      final projectsFuture = listProjects(accessToken);

      return TaskDetailSnapshot(
        audit: await auditFuture,
        members: await membersFuture,
        projects: await projectsFuture,
        task: task,
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<ProjectDetailSnapshot> loadProjectDetail(
    String accessToken,
    String projectId,
  ) async {
    try {
      final projectFuture = getProject(accessToken, projectId);
      final summaryFuture = getProjectSummary(accessToken, projectId);
      final tasksFuture = listProjectTasks(accessToken, projectId);

      return ProjectDetailSnapshot(
        project: await projectFuture,
        summary: await summaryFuture,
        tasks: await tasksFuture,
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaSession> login({
    required String email,
    required String password,
    String? tenantId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          if (tenantId != null && tenantId.isNotEmpty) 'tenant_id': tenantId,
        },
      );

      return FluxaSession.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/v1/auth/logout',
        data: {
          'refresh_token': refreshToken,
        },
      );
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaSession> refresh({
    required String refreshToken,
    String? tenantId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/refresh',
        data: {
          'refresh_token': refreshToken,
          if (tenantId != null && tenantId.isNotEmpty) 'tenant_id': tenantId,
        },
      );

      return FluxaSession.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaSession> register({
    required String email,
    required String password,
    required String tenantName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'tenant_name': tenantName,
        },
      );

      return FluxaSession.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaSession> switchTenant(
    String accessToken,
    String tenantId,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/switch-tenant',
        data: {
          'tenant_id': tenantId,
        },
        options: _authorized(accessToken),
      );

      return FluxaSession.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaTask> updateTask(
    String accessToken,
    String taskId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/v1/tasks/$taskId',
        data: payload,
        options: _authorized(accessToken),
      );

      return FluxaTask.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }

  Future<FluxaProject> updateProject(
    String accessToken,
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/v1/projects/$projectId',
        data: payload,
        options: _authorized(accessToken),
      );

      return FluxaProject.fromJson(response.data ?? const {});
    } catch (error) {
      throw _toException(error);
    }
  }
}
