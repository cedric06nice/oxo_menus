import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a widget instance from a column.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class DeleteWidgetInTemplateUseCase extends UseCase<int, void> {
  DeleteWidgetInTemplateUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<void, DomainError>> execute(int widgetId) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.delete(widgetId);
  }
}
