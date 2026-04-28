import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Updates an existing bundle for the admin-exportable-menus screen.
///
/// Authorisation rule:
/// - **Admin** — forwards the input to the repository.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without touching
///   the repository.
class UpdateMenuBundleForAdminUseCase
    extends UseCase<UpdateMenuBundleInput, MenuBundle> {
  UpdateMenuBundleForAdminUseCase({
    required AuthGateway authGateway,
    required MenuBundleRepository bundleRepository,
  }) : _authGateway = authGateway,
       _bundleRepository = bundleRepository;

  final AuthGateway _authGateway;
  final MenuBundleRepository _bundleRepository;

  @override
  Future<Result<MenuBundle, DomainError>> execute(UpdateMenuBundleInput input) {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return Future.value(
        const Failure<MenuBundle, DomainError>(UnauthorizedError()),
      );
    }
    return _bundleRepository.update(input);
  }
}
