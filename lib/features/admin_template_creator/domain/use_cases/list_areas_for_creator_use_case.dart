import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';

/// Lists every area for the admin-template-creator dropdown.
///
/// Authorisation rule:
/// - **Admin** — returns every area in repository order so the admin can pick
///   any area when authoring a template (or "None" to leave it unset).
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError]. Mirrors [ListSizesForCreatorUseCase] for
///   defence-in-depth on this admin-only screen.
class ListAreasForCreatorUseCase extends UseCase<NoInput, List<Area>> {
  ListAreasForCreatorUseCase({
    required AuthGateway authGateway,
    required AreaRepository areaRepository,
  }) : _authGateway = authGateway,
       _areaRepository = areaRepository;

  final AuthGateway _authGateway;
  final AreaRepository _areaRepository;

  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<Area>, DomainError>(UnauthorizedError());
    }
    return _areaRepository.getAll();
  }
}
