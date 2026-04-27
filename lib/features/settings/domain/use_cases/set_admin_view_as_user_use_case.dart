import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Updates the admin "view as user" toggle through
/// [AdminViewAsUserGateway].
class SetAdminViewAsUserUseCase extends SyncUseCase<bool, void> {
  SetAdminViewAsUserUseCase({required AdminViewAsUserGateway gateway})
    : _gateway = gateway;

  final AdminViewAsUserGateway _gateway;

  @override
  Result<void, DomainError> execute(bool input) {
    _gateway.set(input);
    return const Success(null);
  }
}
