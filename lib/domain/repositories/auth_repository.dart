import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';

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
}
