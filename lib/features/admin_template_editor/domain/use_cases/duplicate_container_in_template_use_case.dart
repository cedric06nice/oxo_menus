import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Duplicates a container (and all its descendants) inside a template.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the inner [DuplicateContainerUseCase] being
/// invoked.
class DuplicateContainerInTemplateUseCase extends UseCase<int, Container> {
  DuplicateContainerInTemplateUseCase({
    required AuthGateway authGateway,
    required DuplicateContainerUseCase duplicateContainerUseCase,
  }) : _authGateway = authGateway,
       _duplicateContainerUseCase = duplicateContainerUseCase;

  final AuthGateway _authGateway;
  final DuplicateContainerUseCase _duplicateContainerUseCase;

  @override
  Future<Result<Container, DomainError>> execute(int containerId) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Container, DomainError>(UnauthorizedError());
    }
    return _duplicateContainerUseCase.execute(containerId);
  }
}
