import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Updates a container's style and/or layout configuration.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class UpdateContainerInTemplateUseCase
    extends UseCase<UpdateContainerInput, Container> {
  UpdateContainerInTemplateUseCase({
    required AuthGateway authGateway,
    required ContainerRepository containerRepository,
  }) : _authGateway = authGateway,
       _containerRepository = containerRepository;

  final AuthGateway _authGateway;
  final ContainerRepository _containerRepository;

  @override
  Future<Result<Container, DomainError>> execute(
    UpdateContainerInput input,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Container, DomainError>(UnauthorizedError());
    }
    return _containerRepository.update(input);
  }
}
