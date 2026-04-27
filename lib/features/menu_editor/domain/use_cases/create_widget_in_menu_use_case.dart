import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Creates a widget instance inside a column on a menu.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched. Allowed-widget
/// gating is enforced by the screen — the use case respects the caller's
/// decision so the same flow can be reused by future bulk-import features.
class CreateWidgetInMenuUseCase
    extends UseCase<CreateWidgetInput, WidgetInstance> {
  CreateWidgetInMenuUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    CreateWidgetInput input,
  ) async {
    if (_authGateway.currentUser == null) {
      return const Failure<WidgetInstance, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.create(input);
  }
}
