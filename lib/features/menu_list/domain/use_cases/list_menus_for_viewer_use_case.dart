import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Lists the menus visible to the current viewer.
///
/// Encapsulates the visibility rule:
/// - **Admin** — every menu, every status, every area.
/// - **Regular user** — published menus, scoped to their assigned areas (an
///   empty area list yields an empty result rather than every menu).
/// - **Anonymous** — never reaches the repository; returns
///   [UnauthorizedError].
class ListMenusForViewerUseCase extends UseCase<NoInput, List<Menu>> {
  ListMenusForViewerUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) {
    final user = _authGateway.currentUser;
    if (user == null) {
      return Future.value(
        const Failure<List<Menu>, DomainError>(UnauthorizedError()),
      );
    }
    final isAdmin = user.role == UserRole.admin;
    if (isAdmin) {
      return _menuRepository.listAll(onlyPublished: false);
    }
    return _menuRepository.listAll(
      onlyPublished: true,
      areaIds: user.areas.map((a) => a.id).toList(),
    );
  }
}
