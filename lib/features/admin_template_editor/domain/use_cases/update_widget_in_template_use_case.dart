import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Updates a widget instance — props, lock-for-edition flag, etc.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched. The same use case
/// serves "update props after the inline editor saves" and
/// "toggle lock-for-edition", because both go through `WidgetRepository.update`
/// with [UpdateWidgetInput].
class UpdateWidgetInTemplateUseCase
    extends UseCase<UpdateWidgetInput, WidgetInstance> {
  UpdateWidgetInTemplateUseCase({
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
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<WidgetInstance, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.update(input);
  }
}
