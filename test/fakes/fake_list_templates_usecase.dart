import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_templates_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakeListTemplatesUseCase.execute] call.
final class ListTemplatesCall {
  final String? statusFilter;
  const ListTemplatesCall({this.statusFilter});
}

// ---------------------------------------------------------------------------
// FakeListTemplatesUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [ListTemplatesUseCase] and intercepts [execute].
///
/// Usage:
/// ```dart
/// final fake = FakeListTemplatesUseCase();
/// fake.stubExecute(Success([menu1, menu2]));
/// await fake.execute(statusFilter: 'all');
/// expect(fake.calls.single.statusFilter, 'all');
/// ```
class FakeListTemplatesUseCase extends ListTemplatesUseCase {
  FakeListTemplatesUseCase() : super(menuRepository: _ThrowMenuRepository());

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ListTemplatesCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<List<Menu>, DomainError>? _stubResult;

  /// Configures all subsequent [execute] calls to return [result].
  void stubExecute(Result<List<Menu>, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Menu>, DomainError>> execute({
    String? statusFilter,
  }) async {
    calls.add(ListTemplatesCall(statusFilter: statusFilter));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeListTemplatesUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stub repository (satisfies super constructor; never called)
// ---------------------------------------------------------------------------

class _ThrowMenuRepository implements MenuRepository {
  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) => throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<Menu, DomainError>> getById(int id) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuRepository should not be called');
}
