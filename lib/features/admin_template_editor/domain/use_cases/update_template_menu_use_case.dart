import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Generic menu-level update for the template editor.
///
/// Routes through [UpdateMenuInput] so a single use case can serve every
/// menu-scoped admin action surfaced by the editor: save (style), publish
/// (status), update display options, allowed widgets, page-size, area, name.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class UpdateTemplateMenuUseCase extends UseCase<UpdateMenuInput, Menu> {
  UpdateTemplateMenuUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<Menu, DomainError>> execute(UpdateMenuInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Menu, DomainError>(UnauthorizedError());
    }
    return _menuRepository.update(input);
  }
}
