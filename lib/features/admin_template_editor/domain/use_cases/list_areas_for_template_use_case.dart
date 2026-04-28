import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';

/// Lists every area available to the template-editor area-picker dialog.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class ListAreasForTemplateUseCase extends UseCase<NoInput, List<Area>> {
  ListAreasForTemplateUseCase({
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
