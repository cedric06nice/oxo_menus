import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Updates a widget instance (props, type, version, index, or style) on a menu.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class UpdateWidgetInMenuUseCase
    extends UseCase<UpdateWidgetInput, WidgetInstance> {
  UpdateWidgetInMenuUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    UpdateWidgetInput input,
  ) async {
    if (_authGateway.currentUser == null) {
      return const Failure<WidgetInstance, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.update(input);
  }
}
