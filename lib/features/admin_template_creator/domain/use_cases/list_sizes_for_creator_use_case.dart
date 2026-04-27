import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Lists every page size for the admin-template-creator dropdown.
///
/// Authorisation rule:
/// - **Admin** — returns every size in repository order so the admin can pick
///   any defined size when authoring a template.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError]. Regular users never see this screen, so the use case
///   doubles as a defence-in-depth check.
class ListSizesForCreatorUseCase extends UseCase<NoInput, List<Size>> {
  ListSizesForCreatorUseCase({
    required AuthGateway authGateway,
    required SizeRepository sizeRepository,
  }) : _authGateway = authGateway,
       _sizeRepository = sizeRepository;

  final AuthGateway _authGateway;
  final SizeRepository _sizeRepository;

  @override
  Future<Result<List<Size>, DomainError>> execute(NoInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<Size>, DomainError>(UnauthorizedError());
    }
    return _sizeRepository.getAll();
  }
}
