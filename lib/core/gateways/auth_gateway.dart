import 'dart:async';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

/// Sealed authentication status emitted by [AuthGateway].
sealed class AuthStatus {
  const AuthStatus();
}

final class AuthStatusInitial extends AuthStatus {
  const AuthStatusInitial();

  @override
  bool operator ==(Object other) => other is AuthStatusInitial;

  @override
  int get hashCode => (AuthStatusInitial).hashCode;
}

final class AuthStatusLoading extends AuthStatus {
  const AuthStatusLoading();

  @override
  bool operator ==(Object other) => other is AuthStatusLoading;

  @override
  int get hashCode => (AuthStatusLoading).hashCode;
}

final class AuthStatusAuthenticated extends AuthStatus {
  const AuthStatusAuthenticated(this.user);
  final User user;

  @override
  bool operator ==(Object other) =>
      other is AuthStatusAuthenticated && other.user == user;

  @override
  int get hashCode => user.hashCode;
}

final class AuthStatusUnauthenticated extends AuthStatus {
  const AuthStatusUnauthenticated();

  @override
  bool operator ==(Object other) => other is AuthStatusUnauthenticated;

  @override
  int get hashCode => (AuthStatusUnauthenticated).hashCode;
}

final class AuthStatusError extends AuthStatus {
  const AuthStatusError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      other is AuthStatusError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

/// Gateway that owns authentication state and exposes it as a stream.
///
/// One instance lives on [AppContainer] for the app's lifetime. Both the
/// MainRouter (auth gate) and the legacy go_router redirect subscribe to its
/// [statusStream] so there is exactly one source of truth during the
/// migration.
class AuthGateway {
  AuthGateway({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;
  final StreamController<AuthStatus> _controller =
      StreamController<AuthStatus>.broadcast();

  AuthStatus _status = const AuthStatusInitial();
  bool _disposed = false;

  AuthStatus get status => _status;

  bool get isAuthenticated => _status is AuthStatusAuthenticated;

  User? get currentUser => switch (_status) {
    AuthStatusAuthenticated(:final user) => user,
    _ => null,
  };

  /// Broadcast stream of status transitions. Subscribers should read [status]
  /// for the current value at subscription time.
  Stream<AuthStatus> get statusStream => _controller.stream;

  bool get isDisposed => _disposed;

  Future<Result<User, DomainError>> tryRestoreSession() async {
    _emit(const AuthStatusLoading());
    final result = await _repository.tryRestoreSession();
    return result.fold(
      onSuccess: (user) {
        _emit(AuthStatusAuthenticated(user));
        return Success<User, DomainError>(user);
      },
      onFailure: (_) {
        _emit(const AuthStatusUnauthenticated());
        return result;
      },
    );
  }

  Future<Result<User, DomainError>> login(String email, String password) async {
    _emit(const AuthStatusLoading());
    final result = await _repository.login(email, password);
    return result.fold(
      onSuccess: (user) {
        _emit(AuthStatusAuthenticated(user));
        return Success<User, DomainError>(user);
      },
      onFailure: (error) {
        _emit(AuthStatusError(error.message));
        return result;
      },
    );
  }

  Future<Result<void, DomainError>> logout() async {
    final result = await _repository.logout();
    _emit(const AuthStatusUnauthenticated());
    return result;
  }

  /// Request a password reset email for [email].
  ///
  /// Side-channel operation: it does NOT change the gateway's auth status —
  /// the caller is typically unauthenticated and remains so. [resetUrl] is
  /// the platform-specific URL the user should be redirected to from the
  /// reset email; pass `null` to fall back to the Directus default.
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) {
    return _repository.requestPasswordReset(email, resetUrl: resetUrl);
  }

  /// Re-checks the current user with the backend. Used to refresh stale
  /// authentication data without forcing a re-login.
  Future<Result<User, DomainError>> refresh() async {
    _emit(const AuthStatusLoading());
    final result = await _repository.getCurrentUser();
    return result.fold(
      onSuccess: (user) {
        _emit(AuthStatusAuthenticated(user));
        return Success<User, DomainError>(user);
      },
      onFailure: (_) {
        _emit(const AuthStatusUnauthenticated());
        return result;
      },
    );
  }

  void _emit(AuthStatus next) {
    if (_disposed) {
      return;
    }
    _status = next;
    _controller.add(next);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _controller.close();
  }
}
