import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Input for [RequestPasswordResetUseCase] — bundles the email to send the
/// reset link to and an optional [resetUrl] (the deep-link target embedded in
/// the reset email, resolved per-platform by the presentation layer).
final class RequestPasswordResetInput {
  const RequestPasswordResetInput({required this.email, this.resetUrl});

  final String email;
  final String? resetUrl;

  @override
  bool operator ==(Object other) =>
      other is RequestPasswordResetInput &&
      other.email == email &&
      other.resetUrl == resetUrl;

  @override
  int get hashCode => Object.hash(email, resetUrl);
}

/// Sends a password-reset email for the given account.
///
/// Delegates to [AuthGateway.requestPasswordReset]. The use case exists so
/// that `ForgotPasswordViewModel` depends on a feature-shaped abstraction and
/// not on the gateway directly. The gateway is the single source of truth for
/// auth state, but this call is a side channel — it does not change auth
/// status.
class RequestPasswordResetUseCase
    extends UseCase<RequestPasswordResetInput, void> {
  RequestPasswordResetUseCase({required AuthGateway gateway})
    : _gateway = gateway;

  final AuthGateway _gateway;

  @override
  Future<Result<void, DomainError>> execute(RequestPasswordResetInput input) {
    return _gateway.requestPasswordReset(input.email, resetUrl: input.resetUrl);
  }
}
