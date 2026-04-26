import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/list_menu_bundles_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakeListMenuBundlesUseCase.execute] call.
final class ListMenuBundlesCall {
  const ListMenuBundlesCall();
}

// ---------------------------------------------------------------------------
// FakeListMenuBundlesUseCase
// ---------------------------------------------------------------------------

/// A manual fake that wraps [ListMenuBundlesUseCase] and intercepts [execute].
///
/// Usage:
/// ```dart
/// final fake = FakeListMenuBundlesUseCase();
/// fake.stubExecute(Success([bundle]));
/// await fake.execute();
/// expect(fake.calls, hasLength(1));
/// ```
class FakeListMenuBundlesUseCase extends ListMenuBundlesUseCase {
  FakeListMenuBundlesUseCase()
      : super(repository: _ThrowMenuBundleRepository());

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ListMenuBundlesCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<List<MenuBundle>, DomainError>? _stubResult;

  /// Configures all subsequent [execute] calls to return [result].
  void stubExecute(Result<List<MenuBundle>, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<MenuBundle>, DomainError>> execute() async {
    calls.add(const ListMenuBundlesCall());
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeListMenuBundlesUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stub (satisfies super constructor; never called)
// ---------------------------------------------------------------------------

class _ThrowMenuBundleRepository implements MenuBundleRepository {
  @override
  Future<Result<List<MenuBundle>, DomainError>> getAll() =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> getById(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(int menuId) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> create(
    CreateMenuBundleInput input,
  ) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> update(
    UpdateMenuBundleInput input,
  ) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');
}
