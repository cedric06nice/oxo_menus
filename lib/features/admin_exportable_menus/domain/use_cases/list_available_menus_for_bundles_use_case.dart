import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Lists every menu (drafts + published) for the bundle create/edit dialog.
///
/// Bundles compose menus regardless of status, so this use case asks the
/// repository for the full list rather than the published-only view used by
/// the regular menu list screen.
///
/// Authorisation rule:
/// - **Admin** — returns every menu in repository order.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without touching
///   the repository.
class ListAvailableMenusForBundlesUseCase
    extends UseCase<NoInput, List<Menu>> {
  ListAvailableMenusForBundlesUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return Future.value(
        const Failure<List<Menu>, DomainError>(UnauthorizedError()),
      );
    }
    return _menuRepository.listAll(onlyPublished: false);
  }
}
