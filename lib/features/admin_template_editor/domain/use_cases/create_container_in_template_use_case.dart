import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Creates a container in a template — root or child of an existing container.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched. The
/// `parentContainerId` and `direction` fields on [CreateContainerInput] decide
/// whether this is a root or child container.
class CreateContainerInTemplateUseCase
    extends UseCase<CreateContainerInput, Container> {
  CreateContainerInTemplateUseCase({
    required AuthGateway authGateway,
    required ContainerRepository containerRepository,
  }) : _authGateway = authGateway,
       _containerRepository = containerRepository;

  final AuthGateway _authGateway;
  final ContainerRepository _containerRepository;

  @override
  Future<Result<Container, DomainError>> execute(
    CreateContainerInput input,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Container, DomainError>(UnauthorizedError());
    }
    return _containerRepository.create(input);
  }
}
