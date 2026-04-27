import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Lists every menu bundle for the admin-exportable-menus screen.
///
/// Authorisation rule:
/// - **Admin** — returns every bundle in repository order so the admin can
///   browse, edit, delete, and re-publish.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError]. Regular users never see this screen, so the use case
///   doubles as a defence-in-depth check.
class ListMenuBundlesForAdminUseCase
    extends UseCase<NoInput, List<MenuBundle>> {
  ListMenuBundlesForAdminUseCase({
    required AuthGateway authGateway,
    required MenuBundleRepository bundleRepository,
  }) : _authGateway = authGateway,
       _bundleRepository = bundleRepository;

  final AuthGateway _authGateway;
  final MenuBundleRepository _bundleRepository;

  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<MenuBundle>, DomainError>(UnauthorizedError());
    }
    return _bundleRepository.getAll();
  }
}
