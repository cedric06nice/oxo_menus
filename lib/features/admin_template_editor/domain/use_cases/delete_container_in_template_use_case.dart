import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a container from a template.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class DeleteContainerInTemplateUseCase extends UseCase<int, void> {
  DeleteContainerInTemplateUseCase({
    required AuthGateway authGateway,
    required ContainerRepository containerRepository,
  }) : _authGateway = authGateway,
       _containerRepository = containerRepository;

  final AuthGateway _authGateway;
  final ContainerRepository _containerRepository;

  @override
  Future<Result<void, DomainError>> execute(int containerId) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _containerRepository.delete(containerId);
  }
}
