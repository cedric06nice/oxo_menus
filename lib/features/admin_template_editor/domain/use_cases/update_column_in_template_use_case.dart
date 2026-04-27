import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Updates a column's style, flex, width, or droppable flag.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class UpdateColumnInTemplateUseCase extends UseCase<UpdateColumnInput, Column> {
  UpdateColumnInTemplateUseCase({
    required AuthGateway authGateway,
    required ColumnRepository columnRepository,
  }) : _authGateway = authGateway,
       _columnRepository = columnRepository;

  final AuthGateway _authGateway;
  final ColumnRepository _columnRepository;

  @override
  Future<Result<Column, DomainError>> execute(UpdateColumnInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Column, DomainError>(UnauthorizedError());
    }
    return _columnRepository.update(input);
  }
}
