import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeWidgetRepository].
sealed class WidgetRepositoryCall {
  const WidgetRepositoryCall();
}

final class WidgetCreateCall extends WidgetRepositoryCall {
  final CreateWidgetInput input;
  const WidgetCreateCall(this.input);
}

final class WidgetGetAllForColumnCall extends WidgetRepositoryCall {
  final int columnId;
  const WidgetGetAllForColumnCall(this.columnId);
}

final class WidgetGetByIdCall extends WidgetRepositoryCall {
  final int id;
  const WidgetGetByIdCall(this.id);
}

final class WidgetUpdateCall extends WidgetRepositoryCall {
  final UpdateWidgetInput input;
  const WidgetUpdateCall(this.input);
}

final class WidgetDeleteCall extends WidgetRepositoryCall {
  final int id;
  const WidgetDeleteCall(this.id);
}

final class WidgetReorderCall extends WidgetRepositoryCall {
  final int widgetId;
  final int newIndex;
  const WidgetReorderCall({required this.widgetId, required this.newIndex});
}

final class WidgetMoveToCall extends WidgetRepositoryCall {
  final int widgetId;
  final int newColumnId;
  final int index;
  const WidgetMoveToCall({
    required this.widgetId,
    required this.newColumnId,
    required this.index,
  });
}

final class WidgetLockForEditingCall extends WidgetRepositoryCall {
  final int widgetId;
  final String userId;
  const WidgetLockForEditingCall({required this.widgetId, required this.userId});
}

final class WidgetUnlockEditingCall extends WidgetRepositoryCall {
  final int widgetId;
  const WidgetUnlockEditingCall(this.widgetId);
}

// ---------------------------------------------------------------------------
// FakeWidgetRepository
// ---------------------------------------------------------------------------

/// Manual fake implementing [WidgetRepository].
///
/// - All calls are appended to [calls] as typed [WidgetRepositoryCall] records.
/// - Return values are preset via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately.
///
/// Usage:
/// ```dart
/// final fake = FakeWidgetRepository();
/// fake.whenCreate(success(buildWidgetInstance()));
/// ```
class FakeWidgetRepository implements WidgetRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<WidgetRepositoryCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<WidgetInstance, DomainError>? _createResponse;
  Result<List<WidgetInstance>, DomainError>? _getAllForColumnResponse;
  Result<WidgetInstance, DomainError>? _getByIdResponse;
  Result<WidgetInstance, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;
  Future<Result<void, DomainError>>? _deleteFutureResponse;
  Result<void, DomainError>? _reorderResponse;
  Result<void, DomainError>? _moveToResponse;
  Result<void, DomainError>? _lockForEditingResponse;
  Result<void, DomainError>? _unlockEditingResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCreate(Result<WidgetInstance, DomainError> response) {
    _createResponse = response;
  }

  void whenGetAllForColumn(Result<List<WidgetInstance>, DomainError> response) {
    _getAllForColumnResponse = response;
  }

  void whenGetById(Result<WidgetInstance, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenUpdate(Result<WidgetInstance, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
    _deleteFutureResponse = null;
  }

  /// Configures delete to return a controlled [Future], allowing tests to
  /// inspect optimistic state updates before the async operation completes.
  void whenDeleteWithFuture(Future<Result<void, DomainError>> future) {
    _deleteFutureResponse = future;
    _deleteResponse = null;
  }

  void whenReorder(Result<void, DomainError> response) {
    _reorderResponse = response;
  }

  void whenMoveTo(Result<void, DomainError> response) {
    _moveToResponse = response;
  }

  void whenLockForEditing(Result<void, DomainError> response) {
    _lockForEditingResponse = response;
  }

  void whenUnlockEditing(Result<void, DomainError> response) {
    _unlockEditingResponse = response;
  }

  // -------------------------------------------------------------------------
  // WidgetRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<WidgetInstance, DomainError>> create(
    CreateWidgetInput input,
  ) async {
    calls.add(WidgetCreateCall(input));
    if (_createResponse != null) return _createResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for create()',
    );
  }

  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  ) async {
    calls.add(WidgetGetAllForColumnCall(columnId));
    if (_getAllForColumnResponse != null) return _getAllForColumnResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for getAllForColumn()',
    );
  }

  @override
  Future<Result<WidgetInstance, DomainError>> getById(int id) async {
    calls.add(WidgetGetByIdCall(id));
    if (_getByIdResponse != null) return _getByIdResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<WidgetInstance, DomainError>> update(
    UpdateWidgetInput input,
  ) async {
    calls.add(WidgetUpdateCall(input));
    if (_updateResponse != null) return _updateResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for update()',
    );
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(WidgetDeleteCall(id));
    if (_deleteFutureResponse != null) return _deleteFutureResponse!;
    if (_deleteResponse != null) return _deleteResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for delete()',
    );
  }

  @override
  Future<Result<void, DomainError>> reorder(
    int widgetId,
    int newIndex,
  ) async {
    calls.add(WidgetReorderCall(widgetId: widgetId, newIndex: newIndex));
    if (_reorderResponse != null) return _reorderResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for reorder()',
    );
  }

  @override
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  ) async {
    calls.add(
      WidgetMoveToCall(
        widgetId: widgetId,
        newColumnId: newColumnId,
        index: index,
      ),
    );
    if (_moveToResponse != null) return _moveToResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for moveTo()',
    );
  }

  @override
  Future<Result<void, DomainError>> lockForEditing(
    int widgetId,
    String userId,
  ) async {
    calls.add(WidgetLockForEditingCall(widgetId: widgetId, userId: userId));
    if (_lockForEditingResponse != null) return _lockForEditingResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for lockForEditing()',
    );
  }

  @override
  Future<Result<void, DomainError>> unlockEditing(int widgetId) async {
    calls.add(WidgetUnlockEditingCall(widgetId));
    if (_unlockEditingResponse != null) return _unlockEditingResponse!;
    throw StateError(
      'FakeWidgetRepository: no response configured for unlockEditing()',
    );
  }

  // -------------------------------------------------------------------------
  // Typed call accessors
  // -------------------------------------------------------------------------

  List<WidgetCreateCall> get createCalls =>
      calls.whereType<WidgetCreateCall>().toList();

  List<WidgetGetAllForColumnCall> get getAllForColumnCalls =>
      calls.whereType<WidgetGetAllForColumnCall>().toList();

  List<WidgetGetByIdCall> get getByIdCalls =>
      calls.whereType<WidgetGetByIdCall>().toList();

  List<WidgetUpdateCall> get updateCalls =>
      calls.whereType<WidgetUpdateCall>().toList();

  List<WidgetDeleteCall> get deleteCalls =>
      calls.whereType<WidgetDeleteCall>().toList();

  List<WidgetReorderCall> get reorderCalls =>
      calls.whereType<WidgetReorderCall>().toList();

  List<WidgetMoveToCall> get moveToCalls =>
      calls.whereType<WidgetMoveToCall>().toList();

  List<WidgetLockForEditingCall> get lockForEditingCalls =>
      calls.whereType<WidgetLockForEditingCall>().toList();

  List<WidgetUnlockEditingCall> get unlockEditingCalls =>
      calls.whereType<WidgetUnlockEditingCall>().toList();
}
