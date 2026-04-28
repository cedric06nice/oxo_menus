import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [MoveWidgetInTemplateUseCase].
class MoveWidgetInput {
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

/// Moves a widget within the same column or across columns.
///
/// Same-column moves use `WidgetRepository.reorder` with an index adjusted
/// for the source position (Riverpod parity), cross-column moves use
/// `WidgetRepository.moveTo`.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class MoveWidgetInTemplateUseCase {
  MoveWidgetInTemplateUseCase({
    required AuthGateway authGateway,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final WidgetRepository _widgetRepository;

  Future<Result<void, DomainError>> execute(MoveWidgetInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    if (input.sourceColumnId == input.targetColumnId) {
      final adjustedIndex = input.targetIndex > input.widget.index
          ? input.targetIndex - 1
          : input.targetIndex;
      return _widgetRepository.reorder(input.widget.id, adjustedIndex);
    }
    return _widgetRepository.moveTo(
      input.widget.id,
      input.targetColumnId,
      input.targetIndex,
    );
  }
}
