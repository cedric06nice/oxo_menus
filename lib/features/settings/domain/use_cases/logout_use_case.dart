import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Logs the current user out via [AuthGateway].
///
/// The gateway flips its status to [AuthStatusUnauthenticated], which the
/// MainRouter and legacy go_router both observe to redirect to the login
/// screen.
class LogoutUseCase extends UseCase<NoInput, void> {
  LogoutUseCase({required AuthGateway authGateway})
    : _authGateway = authGateway;

  final AuthGateway _authGateway;

  @override
  Future<Result<void, DomainError>> execute(NoInput input) =>
      _authGateway.logout();
}
