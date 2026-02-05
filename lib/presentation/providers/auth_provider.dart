import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

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
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _tryRestoreSession();
  }

  /// Try to restore session from stored tokens
  Future<void> _tryRestoreSession() async {
    state = const AuthState.loading();
    final result = await _authRepository.tryRestoreSession();

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    final result = await _authRepository.getCurrentUser();

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    final result = await _authRepository.login(email, password);

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (error) => state = AuthState.error(error.message),
    );
  }

  /// Logout the current user
  Future<void> logout() async {
    await _authRepository.logout();
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
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// authState.when(
///   initial: () => CircularProgressIndicator(),
///   loading: () => CircularProgressIndicator(),
///   authenticated: (user) => Text('Welcome ${user.email}'),
///   unauthenticated: () => LoginButton(),
///   error: (message) => Text('Error: $message'),
/// );
/// ```
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Current user provider
///
/// Convenience provider that returns the current user if authenticated, null otherwise
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   print('Current user: ${user.email}');
/// }
/// ```
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});

/// Is admin provider
///
/// Convenience provider that returns true if the current user is an admin
///
/// Example usage:
/// ```dart
/// final isAdmin = ref.watch(isAdminProvider);
/// if (isAdmin) {
///   // Show admin-only features
/// }
/// ```
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.admin;
});
