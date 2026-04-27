import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

part 'auth_provider.freezed.dart';

/// Authentication state
///
/// Represents the current authentication status of the user
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state before auth check
  const factory AuthState.initial() = _Initial;

  /// Loading state during authentication operations
  const factory AuthState.loading() = _Loading;

  /// Authenticated state with user data
  const factory AuthState.authenticated(User user) = _Authenticated;

  /// Unauthenticated state
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Error state with error message
  const factory AuthState.error(String message) = _Error;
}

/// Authentication state notifier
///
/// Delegates to [AuthGateway] (single source of truth) and mirrors its
/// [AuthStatus] as the legacy [AuthState] for existing Riverpod consumers.
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AuthStatus>? _subscription;

  @override
  AuthState build() {
    final gateway = ref.read(authGatewayProvider);
    _subscription = gateway.statusStream.listen((status) {
      state = _toAuthState(status);
    });
    ref.onDispose(() => _subscription?.cancel());
    Future.microtask(() async {
      state = const AuthState.loading();
      await gateway.tryRestoreSession();
      state = _toAuthState(gateway.status);
    });
    return _toAuthState(gateway.status);
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    final gateway = ref.read(authGatewayProvider);
    state = const AuthState.loading();
    await gateway.login(email, password);
    state = _toAuthState(gateway.status);
  }

  /// Logout the current user
  Future<void> logout() async {
    final gateway = ref.read(authGatewayProvider);
    await gateway.logout();
    state = const AuthState.unauthenticated();
  }

  /// Refresh authentication status
  Future<void> refresh() async {
    final gateway = ref.read(authGatewayProvider);
    state = const AuthState.loading();
    await gateway.refresh();
    state = _toAuthState(gateway.status);
  }

  static AuthState _toAuthState(AuthStatus status) => switch (status) {
    AuthStatusInitial() => const AuthState.initial(),
    AuthStatusLoading() => const AuthState.loading(),
    AuthStatusAuthenticated(:final user) => AuthState.authenticated(user),
    AuthStatusUnauthenticated() => const AuthState.unauthenticated(),
    AuthStatusError(:final message) => AuthState.error(message),
  };
}

/// Auth state provider
///
/// Provides the current authentication state and methods for authentication
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Current user provider
///
/// Convenience provider that returns the current user if authenticated, null otherwise
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(authenticated: (user) => user, orElse: () => null);
});

/// Admin "view as user" override notifier.
///
/// Session-only toggle that lets an admin pretend to be a regular user.
/// When `true`, [isAdminProvider] returns `false` even for admin users.
///
/// Reads/writes through the [AdminViewAsUserGateway] on the [AppContainer]
/// so the migrated Settings VM and the legacy go_router shell stay in sync.
/// In tests where the container is not overridden, the notifier silently
/// falls back to local state so existing widget tests keep working.
class AdminViewAsUserNotifier extends Notifier<bool> {
  StreamSubscription<bool>? _subscription;
  AdminViewAsUserGateway? _gateway;

  @override
  bool build() {
    final gateway = _safeGateway();
    _gateway = gateway;
    if (gateway != null) {
      _subscription = gateway.valueStream.listen((value) {
        state = value;
      });
      ref.onDispose(() => _subscription?.cancel());
      return gateway.currentValue;
    }
    return false;
  }

  void set(bool value) {
    final gateway = _gateway;
    if (gateway != null) {
      gateway.set(value);
      // The stream listener will mirror the change into [state]; mirror
      // synchronously too so callers that read immediately see the new value.
      state = gateway.currentValue;
      return;
    }
    state = value;
  }

  void toggle() => set(!state);

  AdminViewAsUserGateway? _safeGateway() {
    try {
      return ref.read(appContainerProvider).adminViewAsUserGateway;
    } catch (_) {
      return null;
    }
  }
}

final adminViewAsUserProvider = NotifierProvider<AdminViewAsUserNotifier, bool>(
  AdminViewAsUserNotifier.new,
);

/// Is admin provider
///
/// Convenience provider that returns true if the current user is an admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final viewAsUser = ref.watch(adminViewAsUserProvider);
  return user?.role == UserRole.admin && !viewAsUser;
});
