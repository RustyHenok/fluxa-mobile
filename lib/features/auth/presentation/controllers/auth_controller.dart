import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/fluxa_exception.dart';
import '../../../../core/models/fluxa_models.dart';
import '../../../../core/networking/fluxa_api_client.dart';
import '../../../../core/storage/session_store.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.isBusy,
    required this.status,
    this.errorMessage,
    this.session,
  });

  const AuthState.authenticated(FluxaSession session)
      : this(
          isBusy: false,
          session: session,
          status: AuthStatus.authenticated,
        );

  const AuthState.loading()
      : this(
          isBusy: true,
          status: AuthStatus.loading,
        );

  const AuthState.unauthenticated({String? errorMessage})
      : this(
          errorMessage: errorMessage,
          isBusy: false,
          status: AuthStatus.unauthenticated,
        );

  final String? errorMessage;
  final bool isBusy;
  final FluxaSession? session;
  final AuthStatus status;

  AuthState copyWith({
    String? errorMessage,
    bool? isBusy,
    FluxaSession? session,
    AuthStatus? status,
  }) {
    return AuthState(
      errorMessage: errorMessage,
      isBusy: isBusy ?? this.isBusy,
      session: session ?? this.session,
      status: status ?? this.status,
    );
  }
}

final fluxaApiClientProvider = Provider<FluxaApiClient>((ref) {
  return FluxaApiClient();
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return const SessionStore();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    apiClient: ref.watch(fluxaApiClientProvider),
    sessionStore: ref.watch(sessionStoreProvider),
  );
});

class AuthController extends ChangeNotifier {
  AuthController({
    required FluxaApiClient apiClient,
    required SessionStore sessionStore,
  })  : _apiClient = apiClient,
        _sessionStore = sessionStore {
    unawaited(_bootstrap());
  }

  final FluxaApiClient _apiClient;
  final SessionStore _sessionStore;

  AuthState _state = const AuthState.loading();

  AuthState get state => _state;

  Future<void> _bootstrap() async {
    final storedSession = await _sessionStore.read();

    if (storedSession == null) {
      _state = const AuthState.unauthenticated();
      notifyListeners();
      return;
    }

    try {
      final session = await _apiClient.refresh(
        request: FluxaRefreshRequest(
          refreshToken: storedSession.refreshToken,
          tenantId: storedSession.activeTenantId,
        ),
      );
      await _sessionStore.save(session);
      _state = AuthState.authenticated(session);
      notifyListeners();
    } catch (_) {
      await _sessionStore.clear();
      _state = const AuthState.unauthenticated(
        errorMessage: 'Your saved session expired. Please sign in again.',
      );
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = _state.copyWith(errorMessage: null, isBusy: true);
    notifyListeners();

    try {
      final session = await _apiClient.login(
        request: FluxaLoginRequest(
          email: email,
          password: password,
          tenantId: null,
        ),
      );
      await _sessionStore.save(session);
      _state = AuthState.authenticated(session);
      notifyListeners();
      return true;
    } catch (error) {
      _state = AuthState.unauthenticated(
        errorMessage: _messageFor(error),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = _state.session?.refreshToken;

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.logout(
          FluxaLogoutRequest(refreshToken: refreshToken),
        );
      }
    } catch (_) {
      // Logout is best-effort for the upstream token revoke. Local session
      // state should still be cleared reliably.
    }

    await _sessionStore.clear();
    _state = const AuthState.unauthenticated();
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String tenantName,
  }) async {
    _state = _state.copyWith(errorMessage: null, isBusy: true);
    notifyListeners();

    try {
      final session = await _apiClient.register(
        request: FluxaRegisterRequest(
          email: email,
          password: password,
          tenantName: tenantName,
        ),
      );
      await _sessionStore.save(session);
      _state = AuthState.authenticated(session);
      notifyListeners();
      return true;
    } catch (error) {
      _state = AuthState.unauthenticated(
        errorMessage: _messageFor(error),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchTenant(String tenantId) async {
    final session = _state.session;

    if (session == null) {
      return false;
    }

    _state = _state.copyWith(errorMessage: null, isBusy: true);
    notifyListeners();

    try {
      final nextSession = await _apiClient.switchTenant(
        session.accessToken,
        FluxaSwitchTenantRequest(tenantId: tenantId),
      );
      await _sessionStore.save(nextSession);
      _state = AuthState.authenticated(nextSession);
      notifyListeners();
      return true;
    } catch (error) {
      _state = AuthState(
        errorMessage: _messageFor(error),
        isBusy: false,
        session: session,
        status: AuthStatus.authenticated,
      );
      notifyListeners();
      return false;
    }
  }

  String _messageFor(Object error) {
    if (error is FluxaException) {
      return error.message;
    }

    return 'Unexpected authentication error.';
  }
}
