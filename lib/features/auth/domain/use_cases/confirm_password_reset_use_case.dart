import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Input for [ConfirmPasswordResetUseCase] — bundles the [token] received via
/// the reset email and the new [password] to set on the account.
final class ConfirmPasswordResetInput {
  const ConfirmPasswordResetInput({
    required this.token,
    required this.password,
  });

  final String token;
  final String password;

  @override
  bool operator ==(Object other) =>
      other is ConfirmPasswordResetInput &&
      other.token == token &&
      other.password == password;

  @override
  int get hashCode => Object.hash(token, password);
}

/// Confirms a password reset using the token from the reset email.
///
/// Delegates to [AuthGateway.confirmPasswordReset]. The use case exists so
/// `ResetPasswordViewModel` depends on a feature-shaped abstraction and not on
/// the gateway directly. The call is a side channel — it does not change the
/// gateway's auth status; the user must log in afterwards with the new
/// password.
class ConfirmPasswordResetUseCase
    extends UseCase<ConfirmPasswordResetInput, void> {
  ConfirmPasswordResetUseCase({required AuthGateway gateway})
    : _gateway = gateway;

  final AuthGateway _gateway;

  @override
  Future<Result<void, DomainError>> execute(ConfirmPasswordResetInput input) {
    return _gateway.confirmPasswordReset(
      token: input.token,
      password: input.password,
    );
  }
}
