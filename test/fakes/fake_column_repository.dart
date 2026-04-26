import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeColumnRepository].
sealed class ColumnRepositoryCall {
  const ColumnRepositoryCall();
}

final class ColumnCreateCall extends ColumnRepositoryCall {
  final CreateColumnInput input;
  const ColumnCreateCall(this.input);
}

final class ColumnGetAllForContainerCall extends ColumnRepositoryCall {
  final int containerId;
  const ColumnGetAllForContainerCall(this.containerId);
}

final class ColumnGetByIdCall extends ColumnRepositoryCall {
  final int id;
  const ColumnGetByIdCall(this.id);
}

final class ColumnUpdateCall extends ColumnRepositoryCall {
  final UpdateColumnInput input;
  const ColumnUpdateCall(this.input);
}

final class ColumnDeleteCall extends ColumnRepositoryCall {
  final int id;
  const ColumnDeleteCall(this.id);
}

final class ColumnReorderCall extends ColumnRepositoryCall {
  final int columnId;
  final int newIndex;
  const ColumnReorderCall({required this.columnId, required this.newIndex});
}

// ---------------------------------------------------------------------------
// FakeColumnRepository
// ---------------------------------------------------------------------------

/// Manual fake implementing [ColumnRepository].
///
/// - All calls are appended to [calls] as typed [ColumnRepositoryCall] records.
/// - Return values are preset via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately.
///
/// Usage:
/// ```dart
/// final fake = FakeColumnRepository();
/// fake.whenCreate(success(buildColumn()));
/// ```
class FakeColumnRepository implements ColumnRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ColumnRepositoryCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<Column, DomainError>? _createResponse;
  Result<List<Column>, DomainError>? _getAllForContainerResponse;
  Result<Column, DomainError>? _getByIdResponse;
  Result<Column, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;
  Result<void, DomainError>? _reorderResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCreate(Result<Column, DomainError> response) {
    _createResponse = response;
  }

  void whenGetAllForContainer(Result<List<Column>, DomainError> response) {
    _getAllForContainerResponse = response;
  }

  void whenGetById(Result<Column, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenUpdate(Result<Column, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  void whenReorder(Result<void, DomainError> response) {
    _reorderResponse = response;
  }

  // -------------------------------------------------------------------------
  // ColumnRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<Column, DomainError>> create(CreateColumnInput input) async {
    calls.add(ColumnCreateCall(input));
    if (_createResponse != null) return _createResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for create()',
    );
  }

  @override
  Future<Result<List<Column>, DomainError>> getAllForContainer(
    int containerId,
  ) async {
    calls.add(ColumnGetAllForContainerCall(containerId));
    if (_getAllForContainerResponse != null) return _getAllForContainerResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for getAllForContainer()',
    );
  }

  @override
  Future<Result<Column, DomainError>> getById(int id) async {
    calls.add(ColumnGetByIdCall(id));
    if (_getByIdResponse != null) return _getByIdResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<Column, DomainError>> update(UpdateColumnInput input) async {
    calls.add(ColumnUpdateCall(input));
    if (_updateResponse != null) return _updateResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for update()',
    );
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(ColumnDeleteCall(id));
    if (_deleteResponse != null) return _deleteResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for delete()',
    );
  }

  @override
  Future<Result<void, DomainError>> reorder(
    int columnId,
    int newIndex,
  ) async {
    calls.add(ColumnReorderCall(columnId: columnId, newIndex: newIndex));
    if (_reorderResponse != null) return _reorderResponse!;
    throw StateError(
      'FakeColumnRepository: no response configured for reorder()',
    );
  }

  // -------------------------------------------------------------------------
  // Typed call accessors
  // -------------------------------------------------------------------------

  List<ColumnCreateCall> get createCalls =>
      calls.whereType<ColumnCreateCall>().toList();

  List<ColumnGetAllForContainerCall> get getAllForContainerCalls =>
      calls.whereType<ColumnGetAllForContainerCall>().toList();

  List<ColumnGetByIdCall> get getByIdCalls =>
      calls.whereType<ColumnGetByIdCall>().toList();

  List<ColumnUpdateCall> get updateCalls =>
      calls.whereType<ColumnUpdateCall>().toList();

  List<ColumnDeleteCall> get deleteCalls =>
      calls.whereType<ColumnDeleteCall>().toList();

  List<ColumnReorderCall> get reorderCalls =>
      calls.whereType<ColumnReorderCall>().toList();
}
