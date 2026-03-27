import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/fluxa_models.dart';

class SessionStore {
  const SessionStore([this._storage = const FlutterSecureStorage()]);

  static const _refreshTokenKey = 'fluxa_refresh_token';
  static const _activeTenantIdKey = 'fluxa_active_tenant_id';

  final FlutterSecureStorage _storage;

  Future<void> clear() async {
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _activeTenantIdKey);
  }

  Future<StoredSession?> read() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final activeTenantId = await _storage.read(key: _activeTenantIdKey);
    return StoredSession(
      activeTenantId: activeTenantId,
      refreshToken: refreshToken,
    );
  }

  Future<void> save(FluxaSession session) async {
    await _storage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
    await _storage.write(
      key: _activeTenantIdKey,
      value: session.activeTenant.tenantId,
    );
  }
}
