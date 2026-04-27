import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeMenuBundleRepository].
sealed class MenuBundleRepositoryCall {
  const MenuBundleRepositoryCall();
}

final class MenuBundleGetAllCall extends MenuBundleRepositoryCall {
  const MenuBundleGetAllCall();
}

final class MenuBundleGetByIdCall extends MenuBundleRepositoryCall {
  final int id;
  const MenuBundleGetByIdCall(this.id);
}

final class MenuBundleFindByIncludedMenuCall extends MenuBundleRepositoryCall {
  final int menuId;
  const MenuBundleFindByIncludedMenuCall(this.menuId);
}

final class MenuBundleCreateCall extends MenuBundleRepositoryCall {
  final CreateMenuBundleInput input;
  const MenuBundleCreateCall(this.input);
}

final class MenuBundleUpdateCall extends MenuBundleRepositoryCall {
  final UpdateMenuBundleInput input;
  const MenuBundleUpdateCall(this.input);
}

final class MenuBundleDeleteCall extends MenuBundleRepositoryCall {
  final int id;
  const MenuBundleDeleteCall(this.id);
}

// ---------------------------------------------------------------------------
// FakeMenuBundleRepository
// ---------------------------------------------------------------------------

/// Manual fake implementing [MenuBundleRepository].
///
/// - All calls are appended to [calls] as typed [MenuBundleRepositoryCall] records.
/// - Return values are preset via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately.
///
/// Usage:
/// ```dart
/// final fake = FakeMenuBundleRepository();
/// fake.whenGetAll(success([buildMenuBundle()]));
/// ```
class FakeMenuBundleRepository implements MenuBundleRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<MenuBundleRepositoryCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<List<MenuBundle>, DomainError>? _getAllResponse;
  Result<MenuBundle, DomainError>? _getByIdResponse;
  Result<List<MenuBundle>, DomainError>? _findByIncludedMenuResponse;
  Result<MenuBundle, DomainError>? _createResponse;
  Result<MenuBundle, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenGetAll(Result<List<MenuBundle>, DomainError> response) {
    _getAllResponse = response;
  }

  void whenGetById(Result<MenuBundle, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenFindByIncludedMenu(Result<List<MenuBundle>, DomainError> response) {
    _findByIncludedMenuResponse = response;
  }

  void whenCreate(Result<MenuBundle, DomainError> response) {
    _createResponse = response;
  }

  void whenUpdate(Result<MenuBundle, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  // -------------------------------------------------------------------------
  // MenuBundleRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<MenuBundle>, DomainError>> getAll() async {
    calls.add(const MenuBundleGetAllCall());
    if (_getAllResponse != null) return _getAllResponse!;
    throw StateError(
      'FakeMenuBundleRepository: no response configured for getAll()',
    );
  }

  @override
  Future<Result<MenuBundle, DomainError>> getById(int id) async {
    calls.add(MenuBundleGetByIdCall(id));
    if (_getByIdResponse != null) return _getByIdResponse!;
    throw StateError(
      'FakeMenuBundleRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(
    int menuId,
  ) async {
    calls.add(MenuBundleFindByIncludedMenuCall(menuId));
    if (_findByIncludedMenuResponse != null) {
      return _findByIncludedMenuResponse!;
    }
    throw StateError(
      'FakeMenuBundleRepository: no response configured for findByIncludedMenu()',
    );
  }

  @override
  Future<Result<MenuBundle, DomainError>> create(
    CreateMenuBundleInput input,
  ) async {
    calls.add(MenuBundleCreateCall(input));
    if (_createResponse != null) return _createResponse!;
    throw StateError(
      'FakeMenuBundleRepository: no response configured for create()',
    );
  }

  @override
  Future<Result<MenuBundle, DomainError>> update(
    UpdateMenuBundleInput input,
  ) async {
    calls.add(MenuBundleUpdateCall(input));
    if (_updateResponse != null) return _updateResponse!;
    throw StateError(
      'FakeMenuBundleRepository: no response configured for update()',
    );
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(MenuBundleDeleteCall(id));
    if (_deleteResponse != null) return _deleteResponse!;
    throw StateError(
      'FakeMenuBundleRepository: no response configured for delete()',
    );
  }

  // -------------------------------------------------------------------------
  // Typed call accessors
  // -------------------------------------------------------------------------

  List<MenuBundleGetAllCall> get getAllCalls =>
      calls.whereType<MenuBundleGetAllCall>().toList();

  List<MenuBundleGetByIdCall> get getByIdCalls =>
      calls.whereType<MenuBundleGetByIdCall>().toList();

  List<MenuBundleFindByIncludedMenuCall> get findByIncludedMenuCalls =>
      calls.whereType<MenuBundleFindByIncludedMenuCall>().toList();

  List<MenuBundleCreateCall> get createCalls =>
      calls.whereType<MenuBundleCreateCall>().toList();

  List<MenuBundleUpdateCall> get updateCalls =>
      calls.whereType<MenuBundleUpdateCall>().toList();

  List<MenuBundleDeleteCall> get deleteCalls =>
      calls.whereType<MenuBundleDeleteCall>().toList();
}
