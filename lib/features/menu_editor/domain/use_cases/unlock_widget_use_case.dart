import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Releases a widget editing lock so other collaborators can edit it again.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class UnlockWidgetUseCase extends UseCase<int, void> {
  UnlockWidgetUseCase({
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
    return _widgetRepository.unlockEditing(widgetId);
  }
}
