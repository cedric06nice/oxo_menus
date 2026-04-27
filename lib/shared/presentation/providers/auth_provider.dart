import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/types/result.dart';
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
/// Manages authentication state and provides methods for login/logout
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_tryRestoreSession);
    return const AuthState.initial();
  }

  /// Try to restore session from stored tokens
  Future<void> _tryRestoreSession() async {
    state = const AuthState.loading();
    final result = await ref.read(authRepositoryProvider).tryRestoreSession();

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    final result = await ref.read(authRepositoryProvider).getCurrentUser();

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .login(email, password);

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (error) => state = AuthState.error(error.message),
    );
  }

  /// Logout the current user
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
  }

  /// Refresh authentication status
  Future<void> refresh() async {
    await _checkAuthStatus();
  }
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

/// Admin "view as user" override notifier
///
/// Session-only toggle that lets an admin pretend to be a regular user.
/// When `true`, [isAdminProvider] returns `false` even for admin users.
class AdminViewAsUserNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;

  void toggle() => state = !state;
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
