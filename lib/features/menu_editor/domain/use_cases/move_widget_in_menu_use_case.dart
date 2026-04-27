import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Input for [MoveWidgetInMenuUseCase].
///
/// Carries the moving widget plus its source and target columns / index. When
/// the source and target column match the use case picks the lighter
/// `reorder` repository call so an in-column drag doesn't take the cross-
/// column code path on the server.
final class MoveWidgetInput {
  const MoveWidgetInput({
    required this.widget,
    required this.sourceColumnId,
    required this.targetColumnId,
    required this.targetIndex,
  });

  final WidgetInstance widget;
  final int sourceColumnId;
  final int targetColumnId;
  final int targetIndex;

  @override
  bool operator ==(Object other) =>
      other is MoveWidgetInput &&
      other.widget == widget &&
      other.sourceColumnId == sourceColumnId &&
      other.targetColumnId == targetColumnId &&
      other.targetIndex == targetIndex;

  @override
  int get hashCode =>
      Object.hash(widget, sourceColumnId, targetColumnId, targetIndex);
}

/// Moves a widget within its column or to a different column on a menu.
///
/// Authorisation: any authenticated user. Anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
///
/// Within the same column the use case adjusts the destination index so a
/// drag past the original slot doesn't insert before its own removal — the
/// existing legacy notifier behaviour. Cross-column moves go through
/// `WidgetRepository.moveTo`.
class MoveWidgetInMenuUseCase extends UseCase<MoveWidgetInput, void> {
  MoveWidgetInMenuUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<void, DomainError>> execute(MoveWidgetInput input) async {
    if (_authGateway.currentUser == null) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    if (input.sourceColumnId == input.targetColumnId) {
      final adjusted = input.targetIndex > input.widget.index
          ? input.targetIndex - 1
          : input.targetIndex;
      return _widgetRepository.reorder(input.widget.id, adjusted);
    }
    return _widgetRepository.moveTo(
      input.widget.id,
      input.targetColumnId,
      input.targetIndex,
    );
  }
}
