import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a bundle for the admin-exportable-menus screen.
///
/// Authorisation rule:
/// - **Admin** — forwards the bundle id to the repository.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without touching
///   the repository.
class DeleteMenuBundleForAdminUseCase extends UseCase<int, void> {
  DeleteMenuBundleForAdminUseCase({
    required AuthGateway authGateway,
    required MenuBundleRepository bundleRepository,
  }) : _authGateway = authGateway,
       _bundleRepository = bundleRepository;

  final AuthGateway _authGateway;
  final MenuBundleRepository _bundleRepository;

  @override
  Future<Result<void, DomainError>> execute(int id) {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return Future.value(
        const Failure<void, DomainError>(UnauthorizedError()),
      );
    }
    return _bundleRepository.delete(id);
  }
}
