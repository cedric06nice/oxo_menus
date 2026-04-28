import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

/// Touches the menu record so its updated-at timestamp moves forward, mirroring
/// the legacy "Save Menu" flow that committed any debounced widget edits.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class SaveMenuUseCase extends UseCase<int, Menu> {
  SaveMenuUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<Menu, DomainError>> execute(int menuId) async {
    if (_authGateway.currentUser == null) {
      return const Failure<Menu, DomainError>(UnauthorizedError());
    }
    return _menuRepository.update(UpdateMenuInput(id: menuId));
  }
}
