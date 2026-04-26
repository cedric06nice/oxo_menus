import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class AuthCall {
  const AuthCall();
}

final class LoginCall extends AuthCall {
  final String email;
  final String password;
  const LoginCall({required this.email, required this.password});
}

final class LogoutCall extends AuthCall {
  const LogoutCall();
}

final class GetCurrentUserCall extends AuthCall {
  const GetCurrentUserCall();
}

final class RefreshSessionCall extends AuthCall {
  const RefreshSessionCall();
}

final class TryRestoreSessionCall extends AuthCall {
  const TryRestoreSessionCall();
}

final class RequestPasswordResetCall extends AuthCall {
  final String email;
  final String? resetUrl;
  const RequestPasswordResetCall({required this.email, this.resetUrl});
}

final class ConfirmPasswordResetCall extends AuthCall {
  final String token;
  final String password;
  const ConfirmPasswordResetCall({required this.token, required this.password});
}

// ---------------------------------------------------------------------------
// FakeAuthRepository
// ---------------------------------------------------------------------------

/// Manual fake for [AuthRepository].
///
/// Every call is recorded in [calls] as a typed [AuthCall].
/// Return values are configured via `when*` setters before the call.
/// Unconfigured methods throw [StateError] immediately.
///
/// [tryRestoreSession] additionally accepts a [defaultTryRestoreSessionResponse]
/// so tests that instantiate an `AuthNotifier` (which calls `tryRestoreSession`
/// in its constructor) do not need to wire it manually each time.
class FakeAuthRepository implements AuthRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<AuthCall> calls = [];

  // -------------------------------------------------------------------------
  // Default responses (wire once, reuse across notifier constructions)
  // -------------------------------------------------------------------------

  /// Pre-wired response returned by [tryRestoreSession] if no per-call
  /// override has been set.  Defaults to a [NotFoundError] failure so the
  /// notifier starts in an unauthenticated state without extra setup.
  Result<User, DomainError> defaultTryRestoreSessionResponse =
      Failure<User, DomainError>(const NotFoundError('No session'));

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<User, DomainError>? _loginResponse;
  Result<void, DomainError>? _logoutResponse;
  Result<User, DomainError>? _getCurrentUserResponse;
  Result<void, DomainError>? _refreshSessionResponse;
  Result<User, DomainError>? _tryRestoreSessionResponse;
  Result<void, DomainError>? _requestPasswordResetResponse;
  Result<void, DomainError>? _confirmPasswordResetResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenLogin(Result<User, DomainError> response) {
    _loginResponse = response;
  }

  void whenLogout(Result<void, DomainError> response) {
    _logoutResponse = response;
  }

  void whenGetCurrentUser(Result<User, DomainError> response) {
    _getCurrentUserResponse = response;
  }

  void whenRefreshSession(Result<void, DomainError> response) {
    _refreshSessionResponse = response;
  }

  void whenTryRestoreSession(Result<User, DomainError> response) {
    _tryRestoreSessionResponse = response;
  }

  void whenRequestPasswordReset(Result<void, DomainError> response) {
    _requestPasswordResetResponse = response;
  }

  void whenConfirmPasswordReset(Result<void, DomainError> response) {
    _confirmPasswordResetResponse = response;
  }

  // -------------------------------------------------------------------------
  // AuthRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    calls.add(LoginCall(email: email, password: password));
    if (_loginResponse != null) {
      return _loginResponse!;
    }
    throw StateError('FakeAuthRepository: no response configured for login()');
  }

  @override
  Future<Result<void, DomainError>> logout() async {
    calls.add(const LogoutCall());
    if (_logoutResponse != null) {
      return _logoutResponse!;
    }
    throw StateError('FakeAuthRepository: no response configured for logout()');
  }

  @override
  Future<Result<User, DomainError>> getCurrentUser() async {
    calls.add(const GetCurrentUserCall());
    if (_getCurrentUserResponse != null) {
      return _getCurrentUserResponse!;
    }
    throw StateError(
      'FakeAuthRepository: no response configured for getCurrentUser()',
    );
  }

  @override
  Future<Result<void, DomainError>> refreshSession() async {
    calls.add(const RefreshSessionCall());
    if (_refreshSessionResponse != null) {
      return _refreshSessionResponse!;
    }
    throw StateError(
      'FakeAuthRepository: no response configured for refreshSession()',
    );
  }

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async {
    calls.add(const TryRestoreSessionCall());
    if (_tryRestoreSessionResponse != null) {
      return _tryRestoreSessionResponse!;
    }
    return defaultTryRestoreSessionResponse;
  }

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async {
    calls.add(RequestPasswordResetCall(email: email, resetUrl: resetUrl));
    if (_requestPasswordResetResponse != null) {
      return _requestPasswordResetResponse!;
    }
    throw StateError(
      'FakeAuthRepository: no response configured for requestPasswordReset()',
    );
  }

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    calls.add(ConfirmPasswordResetCall(token: token, password: password));
    if (_confirmPasswordResetResponse != null) {
      return _confirmPasswordResetResponse!;
    }
    throw StateError(
      'FakeAuthRepository: no response configured for confirmPasswordReset()',
    );
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<LoginCall> get loginCalls => calls.whereType<LoginCall>().toList();
  List<LogoutCall> get logoutCalls => calls.whereType<LogoutCall>().toList();
  List<GetCurrentUserCall> get getCurrentUserCalls =>
      calls.whereType<GetCurrentUserCall>().toList();
  List<RefreshSessionCall> get refreshSessionCalls =>
      calls.whereType<RefreshSessionCall>().toList();
  List<TryRestoreSessionCall> get tryRestoreSessionCalls =>
      calls.whereType<TryRestoreSessionCall>().toList();
  List<RequestPasswordResetCall> get requestPasswordResetCalls =>
      calls.whereType<RequestPasswordResetCall>().toList();
  List<ConfirmPasswordResetCall> get confirmPasswordResetCalls =>
      calls.whereType<ConfirmPasswordResetCall>().toList();
}
