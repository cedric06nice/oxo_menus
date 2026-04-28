import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Creates a widget instance inside a column.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class CreateWidgetInTemplateUseCase
    extends UseCase<CreateWidgetInput, WidgetInstance> {
  CreateWidgetInTemplateUseCase({
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
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<WidgetInstance, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.create(input);
  }
}
