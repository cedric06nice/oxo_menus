import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Input for [LockWidgetForEditingUseCase].
final class LockWidgetForEditingInput {
  const LockWidgetForEditingInput({
    required this.widgetId,
    required this.userId,
  });

  final int widgetId;
  final String userId;

  @override
  bool operator ==(Object other) =>
      other is LockWidgetForEditingInput &&
      other.widgetId == widgetId &&
      other.userId == userId;

  @override
  int get hashCode => Object.hash(widgetId, userId);
}

/// Marks a widget as being edited by the given user. Drives the per-widget
/// editor badge so other collaborators see the widget locked while the editor
/// is open.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class LockWidgetForEditingUseCase
    extends UseCase<LockWidgetForEditingInput, void> {
  LockWidgetForEditingUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<void, DomainError>> execute(
    LockWidgetForEditingInput input,
  ) async {
    if (_authGateway.currentUser == null) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _widgetRepository.lockForEditing(input.widgetId, input.userId);
  }
}
