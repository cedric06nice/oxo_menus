import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [ReorderContainerInTemplateUseCase].
class ReorderContainerInput {
  const ReorderContainerInput({
    required this.containerId,
    required this.direction,
  });

  final int containerId;
  final ReorderDirection direction;

  @override
  bool operator ==(Object other) =>
      other is ReorderContainerInput &&
      other.containerId == containerId &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(containerId, direction);
}

/// Reorders a container up or down within its parent.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the inner [ReorderContainerUseCase] being
/// invoked.
class ReorderContainerInTemplateUseCase {
  ReorderContainerInTemplateUseCase({
    required AuthGateway authGateway,
    required ReorderContainerUseCase reorderContainerUseCase,
  }) : _authGateway = authGateway,
       _reorderContainerUseCase = reorderContainerUseCase;

  final AuthGateway _authGateway;
  final ReorderContainerUseCase _reorderContainerUseCase;

  Future<Result<void, DomainError>> execute(ReorderContainerInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _reorderContainerUseCase.execute(input.containerId, input.direction);
  }
}
