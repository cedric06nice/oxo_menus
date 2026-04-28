import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [LoginUseCase] — bundles the credentials needed to authenticate.
final class LoginInput {
  const LoginInput({required this.email, required this.password});

  final String email;
  final String password;

  @override
  bool operator ==(Object other) =>
      other is LoginInput && other.email == email && other.password == password;

  @override
  int get hashCode => Object.hash(email, password);
}

/// Authenticates a user with email/password.
///
/// Delegates to [AuthGateway.login] so that the gateway remains the single
/// source of truth for authentication state. The use case exists so that
/// [LoginViewModel] depends on a feature-shaped abstraction and not on the
/// gateway directly.
class LoginUseCase extends UseCase<LoginInput, User> {
  LoginUseCase({required AuthGateway gateway}) : _gateway = gateway;

  final AuthGateway _gateway;

  @override
  Future<Result<User, DomainError>> execute(LoginInput input) {
    return _gateway.login(input.email, input.password);
  }
}
