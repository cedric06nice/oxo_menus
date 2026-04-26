import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeContainerRepository].
sealed class ContainerRepositoryCall {
  const ContainerRepositoryCall();
}

final class ContainerCreateCall extends ContainerRepositoryCall {
  final CreateContainerInput input;
  const ContainerCreateCall(this.input);
}

final class ContainerGetAllForPageCall extends ContainerRepositoryCall {
  final int pageId;
  const ContainerGetAllForPageCall(this.pageId);
}

final class ContainerGetAllForContainerCall extends ContainerRepositoryCall {
  final int containerId;
  const ContainerGetAllForContainerCall(this.containerId);
}

final class ContainerGetByIdCall extends ContainerRepositoryCall {
  final int id;
  const ContainerGetByIdCall(this.id);
}

final class ContainerUpdateCall extends ContainerRepositoryCall {
  final UpdateContainerInput input;
  const ContainerUpdateCall(this.input);
}

final class ContainerDeleteCall extends ContainerRepositoryCall {
  final int id;
  const ContainerDeleteCall(this.id);
}

final class ContainerReorderCall extends ContainerRepositoryCall {
  final int containerId;
  final int newIndex;
  const ContainerReorderCall({required this.containerId, required this.newIndex});
}

final class ContainerMoveToCall extends ContainerRepositoryCall {
  final int containerId;
  final int newPageId;
  final int index;
  const ContainerMoveToCall({
    required this.containerId,
    required this.newPageId,
    required this.index,
  });
}

// ---------------------------------------------------------------------------
// FakeContainerRepository
// ---------------------------------------------------------------------------

/// Manual fake implementing [ContainerRepository].
///
/// - All calls are appended to [calls] as typed [ContainerRepositoryCall] records.
/// - Return values are preset via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately.
///
/// Usage:
/// ```dart
/// final fake = FakeContainerRepository();
/// fake.whenCreate(success(buildContainer()));
/// ```
class FakeContainerRepository implements ContainerRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ContainerRepositoryCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<Container, DomainError>? _createResponse;
  Result<List<Container>, DomainError>? _getAllForPageResponse;
  Result<List<Container>, DomainError>? _getAllForContainerResponse;
  final Map<int, Result<List<Container>, DomainError>>
  _getAllForContainerByIdResponses = {};
  Result<Container, DomainError>? _getByIdResponse;
  Result<Container, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;
  Result<void, DomainError>? _reorderResponse;
  Result<void, DomainError>? _moveToResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCreate(Result<Container, DomainError> response) {
    _createResponse = response;
  }

  void whenGetAllForPage(Result<List<Container>, DomainError> response) {
    _getAllForPageResponse = response;
  }

  void whenGetAllForContainer(Result<List<Container>, DomainError> response) {
    _getAllForContainerResponse = response;
  }

  /// Registers a per-[containerId] response for [getAllForContainer].
  ///
  /// When a call is made with a [containerId] that has a per-id entry,
  /// that entry takes precedence over the global [whenGetAllForContainer] stub.
  void whenGetAllForContainerForId(
    int containerId,
    Result<List<Container>, DomainError> response,
  ) {
    _getAllForContainerByIdResponses[containerId] = response;
  }

  void whenGetById(Result<Container, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenUpdate(Result<Container, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  void whenReorder(Result<void, DomainError> response) {
    _reorderResponse = response;
  }

  void whenMoveTo(Result<void, DomainError> response) {
    _moveToResponse = response;
  }

  // -------------------------------------------------------------------------
  // ContainerRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<Container, DomainError>> create(
    CreateContainerInput input,
  ) async {
    calls.add(ContainerCreateCall(input));
    if (_createResponse != null) return _createResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for create()',
    );
  }

  @override
  Future<Result<List<Container>, DomainError>> getAllForPage(
    int pageId,
  ) async {
    calls.add(ContainerGetAllForPageCall(pageId));
    if (_getAllForPageResponse != null) return _getAllForPageResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for getAllForPage()',
    );
  }

  @override
  Future<Result<List<Container>, DomainError>> getAllForContainer(
    int containerId,
  ) async {
    calls.add(ContainerGetAllForContainerCall(containerId));
    if (_getAllForContainerByIdResponses.containsKey(containerId)) {
      return _getAllForContainerByIdResponses[containerId]!;
    }
    if (_getAllForContainerResponse != null) return _getAllForContainerResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for getAllForContainer()',
    );
  }

  @override
  Future<Result<Container, DomainError>> getById(int id) async {
    calls.add(ContainerGetByIdCall(id));
    if (_getByIdResponse != null) return _getByIdResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<Container, DomainError>> update(
    UpdateContainerInput input,
  ) async {
    calls.add(ContainerUpdateCall(input));
    if (_updateResponse != null) return _updateResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for update()',
    );
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(ContainerDeleteCall(id));
    if (_deleteResponse != null) return _deleteResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for delete()',
    );
  }

  @override
  Future<Result<void, DomainError>> reorder(
    int containerId,
    int newIndex,
  ) async {
    calls.add(ContainerReorderCall(containerId: containerId, newIndex: newIndex));
    if (_reorderResponse != null) return _reorderResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for reorder()',
    );
  }

  @override
  Future<Result<void, DomainError>> moveTo(
    int containerId,
    int newPageId,
    int index,
  ) async {
    calls.add(
      ContainerMoveToCall(
        containerId: containerId,
        newPageId: newPageId,
        index: index,
      ),
    );
    if (_moveToResponse != null) return _moveToResponse!;
    throw StateError(
      'FakeContainerRepository: no response configured for moveTo()',
    );
  }

  // -------------------------------------------------------------------------
  // Typed call accessors
  // -------------------------------------------------------------------------

  List<ContainerCreateCall> get createCalls =>
      calls.whereType<ContainerCreateCall>().toList();

  List<ContainerGetAllForPageCall> get getAllForPageCalls =>
      calls.whereType<ContainerGetAllForPageCall>().toList();

  List<ContainerGetAllForContainerCall> get getAllForContainerCalls =>
      calls.whereType<ContainerGetAllForContainerCall>().toList();

  List<ContainerGetByIdCall> get getByIdCalls =>
      calls.whereType<ContainerGetByIdCall>().toList();

  List<ContainerUpdateCall> get updateCalls =>
      calls.whereType<ContainerUpdateCall>().toList();

  List<ContainerDeleteCall> get deleteCalls =>
      calls.whereType<ContainerDeleteCall>().toList();

  List<ContainerReorderCall> get reorderCalls =>
      calls.whereType<ContainerReorderCall>().toList();

  List<ContainerMoveToCall> get moveToCalls =>
      calls.whereType<ContainerMoveToCall>().toList();
}
