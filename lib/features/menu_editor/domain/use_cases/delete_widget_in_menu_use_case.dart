import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Deletes a widget instance from a menu.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class DeleteWidgetInMenuUseCase extends UseCase<int, void> {
  DeleteWidgetInMenuUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<void, DomainError>> execute(int widgetId) async {
    if (_authGateway.currentUser == null) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.delete(widgetId);
  }
}
