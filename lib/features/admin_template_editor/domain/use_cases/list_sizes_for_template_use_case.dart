import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Lists every page size available to the template-editor page-size picker.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class ListSizesForTemplateUseCase extends UseCase<NoInput, List<domain.Size>> {
  ListSizesForTemplateUseCase({
    required AuthGateway authGateway,
    required SizeRepository sizeRepository,
  }) : _authGateway = authGateway,
       _sizeRepository = sizeRepository;

  final AuthGateway _authGateway;
  final SizeRepository _sizeRepository;

  @override
  Future<Result<List<domain.Size>, DomainError>> execute(NoInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<domain.Size>, DomainError>(UnauthorizedError());
    }
    return _sizeRepository.getAll();
  }
}
