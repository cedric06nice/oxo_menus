import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakeFetchMenuTreeUseCase.execute] call.
final class FetchMenuTreeCall {
  final int menuId;
  const FetchMenuTreeCall({required this.menuId});
}

// ---------------------------------------------------------------------------
// FakeFetchMenuTreeUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [FetchMenuTreeUseCase] and intercepts [execute].
///
/// Constructors of the real use case require five repository arguments.  This
/// fake satisfies them with private no-op stubs so callers only need to
/// instantiate [FakeFetchMenuTreeUseCase] without any dependencies.
///
/// Usage:
/// ```dart
/// final fake = FakeFetchMenuTreeUseCase();
/// fake.stubExecute(Success(menuTree));
/// final result = await fake.execute(42);
/// expect(fake.calls.single.menuId, equals(42));
/// ```
class FakeFetchMenuTreeUseCase extends FetchMenuTreeUseCase {
  FakeFetchMenuTreeUseCase()
    : super(
        menuRepository: _ThrowMenuRepository(),
        pageRepository: _ThrowPageRepository(),
        containerRepository: _ThrowContainerRepository(),
        columnRepository: _ThrowColumnRepository(),
        widgetRepository: _ThrowWidgetRepository(),
      );

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<FetchMenuTreeCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<MenuTree, DomainError>? _stubResult;

  /// Configures the next (and all subsequent) [execute] calls to return [result].
  void stubExecute(Result<MenuTree, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<MenuTree, DomainError>> execute(int menuId) async {
    calls.add(FetchMenuTreeCall(menuId: menuId));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeFetchMenuTreeUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stub repositories (satisfy the super constructor; never called)
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

class _ThrowPageRepository implements PageRepository {
  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<List<Page>, DomainError>> getAllForMenu(int menuId) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<Page, DomainError>> getById(int id) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<Page, DomainError>> update(UpdatePageInput input) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int pageId, int newIndex) =>
      throw StateError('_ThrowPageRepository should not be called');
}

class _ThrowContainerRepository implements ContainerRepository {
  @override
  Future<Result<Container, DomainError>> create(CreateContainerInput input) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<List<Container>, DomainError>> getAllForPage(int pageId) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<List<Container>, DomainError>> getAllForContainer(
    int containerId,
  ) => throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<Container, DomainError>> getById(int id) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<Container, DomainError>> update(UpdateContainerInput input) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int containerId, int newIndex) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> moveTo(
    int containerId,
    int newPageId,
    int index,
  ) => throw StateError('_ThrowContainerRepository should not be called');
}

class _ThrowColumnRepository implements ColumnRepository {
  @override
  Future<Result<Column, DomainError>> create(CreateColumnInput input) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<List<Column>, DomainError>> getAllForContainer(
    int containerId,
  ) => throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<Column, DomainError>> getById(int id) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<Column, DomainError>> update(UpdateColumnInput input) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int columnId, int newIndex) =>
      throw StateError('_ThrowColumnRepository should not be called');
}

class _ThrowWidgetRepository implements WidgetRepository {
  @override
  Future<Result<WidgetInstance, DomainError>> create(CreateWidgetInput input) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<WidgetInstance, DomainError>> getById(int id) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<WidgetInstance, DomainError>> update(UpdateWidgetInput input) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int widgetId, int newIndex) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> lockForEditing(
    int widgetId,
    String userId,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> unlockEditing(int widgetId) =>
      throw StateError('_ThrowWidgetRepository should not be called');
}
