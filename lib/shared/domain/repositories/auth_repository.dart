import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Repository interface for Authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<Result<User, DomainError>> login(String email, String password);

  /// Logout the current user
  Future<Result<void, DomainError>> logout();

  /// Get the current authenticated user
  Future<Result<User, DomainError>> getCurrentUser();

  /// Refresh the current session
  Future<Result<void, DomainError>> refreshSession();

  /// Try to restore session from stored tokens
  ///
  /// Returns the user if session was restored successfully
  Future<Result<User, DomainError>> tryRestoreSession();

  /// Request a password reset email for the given email address
  ///
  /// Optionally provide a [resetUrl] to redirect the user to a custom
  /// reset page instead of the Directus default.
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  });

  /// Confirm a password reset with the token received via email
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  });
}
