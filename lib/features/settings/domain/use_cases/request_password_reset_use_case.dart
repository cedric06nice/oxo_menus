import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Input for [RequestPasswordResetUseCase].
final class RequestPasswordResetInput {
  const RequestPasswordResetInput({required this.email, this.resetUrl});

  /// Address of the account to receive the reset email.
  final String email;

  /// Optional platform-specific URL the user is sent to from the reset email.
  /// `null` falls back to the Directus default.
  final String? resetUrl;

  @override
  bool operator ==(Object other) =>
      other is RequestPasswordResetInput &&
      other.email == email &&
      other.resetUrl == resetUrl;

  @override
  int get hashCode => Object.hash(email, resetUrl);
}

/// Sends a password-reset email through [AuthGateway].
///
/// Side-channel operation — does not change auth status.
class RequestPasswordResetUseCase
    extends UseCase<RequestPasswordResetInput, void> {
  RequestPasswordResetUseCase({required AuthGateway authGateway})
    : _authGateway = authGateway;

  final AuthGateway _authGateway;

  @override
  Future<Result<void, DomainError>> execute(RequestPasswordResetInput input) {
    return _authGateway.requestPasswordReset(
      input.email,
      resetUrl: input.resetUrl,
    );
  }
}
