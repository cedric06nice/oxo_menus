import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a column from a container.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class DeleteColumnInTemplateUseCase extends UseCase<int, void> {
  DeleteColumnInTemplateUseCase({
    required AuthGateway authGateway,
    required ColumnRepository columnRepository,
  }) : _authGateway = authGateway,
       _columnRepository = columnRepository;

  final AuthGateway _authGateway;
  final ColumnRepository _columnRepository;

  @override
  Future<Result<void, DomainError>> execute(int columnId) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _columnRepository.delete(columnId);
  }
}
