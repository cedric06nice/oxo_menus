import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeMenuRepository].
sealed class MenuRepositoryCall {
  const MenuRepositoryCall();
}

final class MenuCreateCall extends MenuRepositoryCall {
  final CreateMenuInput input;
  const MenuCreateCall(this.input);
}

final class MenuListAllCall extends MenuRepositoryCall {
  final bool onlyPublished;
  final List<int>? areaIds;
  const MenuListAllCall({required this.onlyPublished, this.areaIds});
}

final class MenuGetByIdCall extends MenuRepositoryCall {
  final int id;
  const MenuGetByIdCall(this.id);
}

final class MenuUpdateCall extends MenuRepositoryCall {
  final UpdateMenuInput input;
  const MenuUpdateCall(this.input);
}

final class MenuDeleteCall extends MenuRepositoryCall {
  final int id;
  const MenuDeleteCall(this.id);
}

// ---------------------------------------------------------------------------
// FakeMenuRepository
// ---------------------------------------------------------------------------

/// Manual fake implementing [MenuRepository].
///
/// - All calls are appended to [calls] as typed [MenuRepositoryCall] records.
/// - Return values are preset via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately.
///
/// Usage:
/// ```dart
/// final fake = FakeMenuRepository();
/// fake.whenCreate(success(buildMenu()));
/// ```
class FakeMenuRepository implements MenuRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<MenuRepositoryCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<Menu, DomainError>? _createResponse;
  Result<List<Menu>, DomainError>? _listAllResponse;
  Result<Menu, DomainError>? _getByIdResponse;
  Result<Menu, DomainError>? _updateResponse;
  Future<Result<Menu, DomainError>>? _updateFutureResponse;
  Result<void, DomainError>? _deleteResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCreate(Result<Menu, DomainError> response) {
    _createResponse = response;
  }

  void whenListAll(Result<List<Menu>, DomainError> response) {
    _listAllResponse = response;
  }

  void whenGetById(Result<Menu, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenUpdate(Result<Menu, DomainError> response) {
    _updateResponse = response;
    _updateFutureResponse = null;
  }

  /// Configures update to return a controlled [Future], allowing tests to
  /// inspect optimistic state updates before the async operation completes.
  void whenUpdateWithFuture(Future<Result<Menu, DomainError>> future) {
    _updateFutureResponse = future;
    _updateResponse = null;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  // -------------------------------------------------------------------------
  // MenuRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async {
    calls.add(MenuCreateCall(input));
    if (_createResponse != null) return _createResponse!;
    throw StateError('FakeMenuRepository: no response configured for create()');
  }

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async {
    calls.add(MenuListAllCall(onlyPublished: onlyPublished, areaIds: areaIds));
    if (_listAllResponse != null) return _listAllResponse!;
    throw StateError(
      'FakeMenuRepository: no response configured for listAll()',
    );
  }

  @override
  Future<Result<Menu, DomainError>> getById(int id) async {
    calls.add(MenuGetByIdCall(id));
    if (_getByIdResponse != null) return _getByIdResponse!;
    throw StateError(
      'FakeMenuRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async {
    calls.add(MenuUpdateCall(input));
    if (_updateFutureResponse != null) return _updateFutureResponse!;
    if (_updateResponse != null) return _updateResponse!;
    throw StateError('FakeMenuRepository: no response configured for update()');
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(MenuDeleteCall(id));
    if (_deleteResponse != null) return _deleteResponse!;
    throw StateError('FakeMenuRepository: no response configured for delete()');
  }

  // -------------------------------------------------------------------------
  // Typed call accessors
  // -------------------------------------------------------------------------

  List<MenuCreateCall> get createCalls =>
      calls.whereType<MenuCreateCall>().toList();

  List<MenuListAllCall> get listAllCalls =>
      calls.whereType<MenuListAllCall>().toList();

  List<MenuGetByIdCall> get getByIdCalls =>
      calls.whereType<MenuGetByIdCall>().toList();

  List<MenuUpdateCall> get updateCalls =>
      calls.whereType<MenuUpdateCall>().toList();

  List<MenuDeleteCall> get deleteCalls =>
      calls.whereType<MenuDeleteCall>().toList();
}
