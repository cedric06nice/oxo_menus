import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart'
    show DomainError, ServerError, ValidationError;
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader_provider.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';

// ---------------------------------------------------------------------------
// Fake EditorTreeLoader
// ---------------------------------------------------------------------------

class _FakeEditorTreeLoader extends EditorTreeLoader {
  _FakeEditorTreeLoader({
    required super.menuRepository,
    required super.pageRepository,
    required super.containerRepository,
    required super.columnRepository,
    required super.widgetRepository,
  });

  Result<EditorTree, DomainError>? _stubResult;
  int loadTreeCallCount = 0;

  void stubLoadTree(Result<EditorTree, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<EditorTree, DomainError>> loadTree(int menuId) async {
    loadTreeCallCount++;
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      '_FakeEditorTreeLoader: no stub configured — call stubLoadTree() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Fake PresentableWidgetRegistry
// ---------------------------------------------------------------------------

class _FakePresentableWidgetRegistry extends PresentableWidgetRegistry {
  final Map<String, PresentableWidgetDefinition> _fakeMap = {};

  void registerFake(String type, PresentableWidgetDefinition def) {
    _fakeMap[type] = def;
  }

  @override
  PresentableWidgetDefinition? getDefinition(String type) => _fakeMap[type];
}

// ---------------------------------------------------------------------------
// Fake PresentableWidgetDefinition for text widget
// ---------------------------------------------------------------------------

class _FakeTextProps {
  Map<String, dynamic> toJson() => {'text': 'Default'};
}

/// A concrete [PresentableWidgetDefinition] for the 'text' type, created via
/// the constructor (fields are final — overriding them is not possible).
final _fakeTextWidgetDefinition = PresentableWidgetDefinition<_FakeTextProps>(
  type: 'text',
  version: '1.0',
  defaultProps: _FakeTextProps(),
  parseProps: (_) => _FakeTextProps(),
  render: (_, _) => const SizedBox.shrink(),
);

// ---------------------------------------------------------------------------
// Fake ReorderContainerUseCase
// ---------------------------------------------------------------------------

class _FakeReorderContainerUseCase extends ReorderContainerUseCase {
  _FakeReorderContainerUseCase()
    : super(containerRepository: _NeverCalledContainerRepo());

  final List<(int containerId, ReorderDirection direction)> calls = [];
  Result<void, DomainError>? _stubResult;

  void stubExecute(Result<void, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<void, DomainError>> execute(
    int containerId,
    ReorderDirection direction,
  ) async {
    calls.add((containerId, direction));
    if (_stubResult != null) return _stubResult!;
    throw StateError('_FakeReorderContainerUseCase: not stubbed');
  }
}

// ---------------------------------------------------------------------------
// Fake DuplicateContainerUseCase
// ---------------------------------------------------------------------------

class _FakeDuplicateContainerUseCase extends DuplicateContainerUseCase {
  _FakeDuplicateContainerUseCase()
    : super(
        containerRepository: _NeverCalledContainerRepo(),
        columnRepository: _NeverCalledColumnRepo(),
        widgetRepository: _NeverCalledWidgetRepo(),
      );

  final List<int> calls = [];
  Result<entity.Container, DomainError>? _stubResult;

  void stubExecute(Result<entity.Container, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<entity.Container, DomainError>> execute(int containerId) async {
    calls.add(containerId);
    if (_stubResult != null) return _stubResult!;
    throw StateError('_FakeDuplicateContainerUseCase: not stubbed');
  }
}

// ---------------------------------------------------------------------------
// Never-called stubs for use-case constructors
// ---------------------------------------------------------------------------

class _NeverCalledContainerRepo implements ContainerRepository {
  @override
  dynamic noSuchMethod(Invocation inv) =>
      throw StateError('_NeverCalledContainerRepo should not be called');
}

class _NeverCalledColumnRepo implements ColumnRepository {
  @override
  dynamic noSuchMethod(Invocation inv) =>
      throw StateError('_NeverCalledColumnRepo should not be called');
}

class _NeverCalledWidgetRepo implements WidgetRepository {
  @override
  dynamic noSuchMethod(Invocation inv) =>
      throw StateError('_NeverCalledWidgetRepo should not be called');
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const menuId = 1;

final _testMenu = Menu(
  id: menuId,
  name: 'Test Menu',
  status: Status.draft,
  version: '1.0',
);

const _testPages = [
  entity.Page(id: 10, menuId: menuId, name: 'Page 1', index: 0),
  entity.Page(id: 11, menuId: menuId, name: 'Page 2', index: 1),
];

const _testContainers = [entity.Container(id: 20, pageId: 10, index: 0)];
const _testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];
const _testWidgets = [
  WidgetInstance(
    id: 40,
    columnId: 30,
    type: 'text',
    version: '1.0',
    index: 0,
    props: {'text': 'Hello'},
  ),
];

EditorTree _defaultTree({
  Menu? menu,
  List<entity.Page>? pages,
  Map<int, List<entity.Container>>? containers,
  Map<int, List<entity.Column>>? columns,
  Map<int, List<WidgetInstance>>? widgets,
}) {
  return EditorTree(
    menu: menu ?? _testMenu,
    pages: pages ?? _testPages,
    containers: containers ?? {10: _testContainers},
    columns: columns ?? {20: _testColumns},
    widgets: widgets ?? {30: _testWidgets},
  );
}

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeContainerRepository fakeContainerRepo;
  late FakeColumnRepository fakeColumnRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late _FakePresentableWidgetRegistry fakeRegistry;
  late _FakeReorderContainerUseCase fakeReorderUseCase;
  late _FakeDuplicateContainerUseCase fakeDuplicateUseCase;
  late _FakeEditorTreeLoader fakeTreeLoader;

  ProviderContainer makeContainer() {
    fakeTreeLoader = _FakeEditorTreeLoader(
      menuRepository: fakeMenuRepo,
      pageRepository: fakePageRepo,
      containerRepository: fakeContainerRepo,
      columnRepository: fakeColumnRepo,
      widgetRepository: fakeWidgetRepo,
    );
    return ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        widgetRegistryProvider.overrideWithValue(fakeRegistry),
        reorderContainerUseCaseProvider.overrideWithValue(fakeReorderUseCase),
        duplicateContainerUseCaseProvider.overrideWithValue(
          fakeDuplicateUseCase,
        ),
        editorTreeLoaderProvider.overrideWithValue(fakeTreeLoader),
      ],
    );
  }

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakePageRepo = FakePageRepository();
    fakeContainerRepo = FakeContainerRepository();
    fakeColumnRepo = FakeColumnRepository();
    fakeWidgetRepo = FakeWidgetRepository();
    fakeRegistry = _FakePresentableWidgetRegistry();
    fakeReorderUseCase = _FakeReorderContainerUseCase();
    fakeDuplicateUseCase = _FakeDuplicateContainerUseCase();
  });

  group('EditorTreeNotifier - initial state', () {
    test('should have default initial state with isLoading true', () {
      final c = makeContainer();
      addTearDown(c.dispose);

      final state = c.read(editorTreeProvider(menuId));

      expect(state, const EditorTreeState());
      expect(state.isLoading, isTrue);
    });

    test('should have null menu on initial build', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      expect(c.read(editorTreeProvider(menuId)).menu, isNull);
    });

    test('should have empty pages on initial build', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      expect(c.read(editorTreeProvider(menuId)).pages, isEmpty);
    });

    test('should have null headerPage and footerPage on initial build', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      final state = c.read(editorTreeProvider(menuId));
      expect(state.headerPage, isNull);
      expect(state.footerPage, isNull);
    });
  });

  group('EditorTreeNotifier - loadTree success', () {
    test('should populate menu, pages, containers, columns, widgets', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      final state = c.read(editorTreeProvider(menuId));
      expect(state.isLoading, isFalse);
      expect(state.menu, _testMenu);
      expect(state.pages, hasLength(2));
      expect(state.containers[10], hasLength(1));
      expect(state.columns[20], hasLength(1));
      expect(state.widgets[30], hasLength(1));
      expect(state.errorMessage, isNull);
    });

    test('should set isLoading to false after successful load', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      expect(c.read(editorTreeProvider(menuId)).isLoading, isFalse);
    });

    test(
      'should not set isLoading to true on reload when menu already loaded',
      () async {
        final c = makeContainer();
        addTearDown(c.dispose);

        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        final notifier = c.read(editorTreeProvider(menuId).notifier);
        await notifier.loadTree();

        // State list for second load — isLoading should NOT go true
        final states = <EditorTreeState>[];
        c.listen<EditorTreeState>(editorTreeProvider(menuId), (_, next) {
          states.add(next);
        });

        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        await notifier.loadTree();

        final loadingStates = states.where((s) => s.isLoading).toList();
        expect(loadingStates, isEmpty);
      },
    );
  });

  group('EditorTreeNotifier - loadTree failure', () {
    test('should set errorMessage on failure and clear isLoading', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(const Failure(ServerError('Menu not found')));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      final state = c.read(editorTreeProvider(menuId));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Menu not found');
    });
  });

  group('EditorTreeNotifier - loadTree with header/footer separation', () {
    test('should separate header, footer, and content pages', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      const mixed = [
        entity.Page(
          id: 10,
          menuId: menuId,
          name: 'Content',
          index: 0,
          type: entity.PageType.content,
        ),
        entity.Page(
          id: 11,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        entity.Page(
          id: 12,
          menuId: menuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];

      fakeTreeLoader.stubLoadTree(
        Success(_defaultTree(pages: mixed, containers: {})),
      );
      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      final state = c.read(editorTreeProvider(menuId));
      expect(state.pages, hasLength(1));
      expect(state.pages.first.name, 'Content');
      expect(state.headerPage?.name, 'Header');
      expect(state.footerPage?.name, 'Footer');
    });

    test('should put all pages in pages list when not separating', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      const mixed = [
        entity.Page(
          id: 10,
          menuId: menuId,
          name: 'Content',
          index: 0,
          type: entity.PageType.content,
        ),
        entity.Page(
          id: 11,
          menuId: menuId,
          name: 'Header',
          index: 1,
          type: entity.PageType.header,
        ),
      ];

      fakeTreeLoader.stubLoadTree(
        Success(_defaultTree(pages: mixed, containers: {})),
      );
      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: false);

      final state = c.read(editorTreeProvider(menuId));
      expect(state.pages, hasLength(2));
      expect(state.headerPage, isNull);
      expect(state.footerPage, isNull);
    });
  });

  group('EditorTreeNotifier - local updates', () {
    test('should update hover index map', () {
      final c = makeContainer();
      addTearDown(c.dispose);

      c.read(editorTreeProvider(menuId).notifier).updateHoverIndex(30, 2);

      expect(c.read(editorTreeProvider(menuId)).hoverIndex[30], 2);
    });

    test('should update menu locally', () {
      final c = makeContainer();
      addTearDown(c.dispose);

      c
          .read(editorTreeProvider(menuId).notifier)
          .updateMenuLocally(_testMenu.copyWith(name: 'Updated'));

      expect(c.read(editorTreeProvider(menuId)).menu?.name, 'Updated');
    });

    test('should update container style locally', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      const newStyle = StyleConfig(marginTop: 20);
      c
          .read(editorTreeProvider(menuId).notifier)
          .updateContainerStyleLocally(20, newStyle);

      expect(
        c.read(editorTreeProvider(menuId)).containers[10]!.first.styleConfig,
        newStyle,
      );
    });

    test('should update column style locally', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      const newStyle = StyleConfig(paddingLeft: 10);
      c
          .read(editorTreeProvider(menuId).notifier)
          .updateColumnStyleLocally(30, newStyle);

      expect(
        c.read(editorTreeProvider(menuId)).columns[20]!.first.styleConfig,
        newStyle,
      );
    });

    test('should update column droppable flag locally', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      c
          .read(editorTreeProvider(menuId).notifier)
          .updateColumnDroppableLocally(30, false);

      expect(
        c.read(editorTreeProvider(menuId)).columns[20]!.first.isDroppable,
        isFalse,
      );
    });
  });

  group('EditorTreeNotifier - widget CRUD', () {
    test('should create widget and reload on success', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      fakeRegistry.registerFake('text', _fakeTextWidgetDefinition);
      fakeWidgetRepo.whenCreate(
        const Success(
          WidgetInstance(
            id: 50,
            columnId: 30,
            type: 'text',
            version: '1.0',
            index: 1,
            props: {},
          ),
        ),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .createWidget('text', 30, 1);

      expect(fakeWidgetRepo.createCalls, hasLength(1));
      expect(result?.isSuccess, isTrue);
    });

    test('should return null when widget type is unknown', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .createWidget('unknown', 30, 0);

      expect(fakeWidgetRepo.createCalls, isEmpty);
      expect(result, isNull);
    });

    test('should return failure on widget create error', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      fakeRegistry.registerFake('text', _fakeTextWidgetDefinition);
      fakeWidgetRepo.whenCreate(const Failure(ServerError('Create failed')));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .createWidget('text', 30, 1);

      expect(result?.isFailure, isTrue);
    });

    test('should remove widget from state optimistically on delete', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      expect(c.read(editorTreeProvider(menuId)).widgets[30], hasLength(1));

      // Use a Completer to control timing
      final completer = Completer<Result<void, DomainError>>();
      fakeWidgetRepo.whenDeleteWithFuture(completer.future);

      final deleteFuture = c
          .read(editorTreeProvider(menuId).notifier)
          .deleteWidget(40);

      // Immediate removal before async completes
      expect(c.read(editorTreeProvider(menuId)).widgets[30], isEmpty);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      completer.complete(const Success(null));
      await deleteFuture;
    });

    test('should reload tree after successful delete', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final countAfterLoad = fakeTreeLoader.loadTreeCallCount;

      fakeWidgetRepo.whenDelete(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(editorTreeProvider(menuId).notifier).deleteWidget(40);

      expect(fakeTreeLoader.loadTreeCallCount, greaterThan(countAfterLoad));
    });

    test('should reload tree after failed delete to rollback', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final countAfterLoad = fakeTreeLoader.loadTreeCallCount;

      fakeWidgetRepo.whenDelete(const Failure(ServerError('Delete failed')));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .deleteWidget(40);

      expect(result.isFailure, isTrue);
      expect(fakeTreeLoader.loadTreeCallCount, greaterThan(countAfterLoad));
    });

    test('should call reorder when moving within same column', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      const widget = WidgetInstance(
        id: 40,
        columnId: 30,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      fakeWidgetRepo.whenReorder(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .moveWidget(widget, 30, 30, 2);

      // index 2 > widget.index 0 => adjustedIndex = 2 - 1 = 1
      expect(fakeWidgetRepo.reorderCalls, hasLength(1));
      expect(fakeWidgetRepo.reorderCalls.first.newIndex, 1);
      expect(result.isSuccess, isTrue);
    });

    test('should call moveTo when moving to a different column', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      const widget = WidgetInstance(
        id: 40,
        columnId: 30,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      fakeWidgetRepo.whenMoveTo(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .moveWidget(widget, 30, 31, 0);

      expect(fakeWidgetRepo.moveToCalls, hasLength(1));
      expect(fakeWidgetRepo.moveToCalls.first.newColumnId, 31);
      expect(result.isSuccess, isTrue);
    });

    test('should update widget props and reload tree on success', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();

      fakeWidgetRepo.whenUpdate(
        const Success(
          WidgetInstance(
            id: 40,
            columnId: 30,
            type: 'text',
            version: '1.0',
            index: 0,
            props: {'text': 'Updated'},
          ),
        ),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .updateWidgetProps(40, {'text': 'Updated'});

      expect(fakeWidgetRepo.updateCalls, hasLength(1));
      expect(result.isSuccess, isTrue);
    });

    test('should return failure when updateWidgetProps fails', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeWidgetRepo.whenUpdate(const Failure(ServerError('Update failed')));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .updateWidgetProps(40, {'text': 'x'});

      expect(result.isFailure, isTrue);
    });

    test(
      'should patch widget lock state locally after successful lock',
      () async {
        final c = makeContainer();
        addTearDown(c.dispose);

        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        await c.read(editorTreeProvider(menuId).notifier).loadTree();

        fakeWidgetRepo.whenUpdate(
          const Success(
            WidgetInstance(
              id: 40,
              columnId: 30,
              type: 'text',
              version: '1.0',
              index: 0,
              props: {'text': 'Hello'},
              lockedForEdition: true,
            ),
          ),
        );

        await c
            .read(editorTreeProvider(menuId).notifier)
            .updateWidgetLockForEdition(40, true);

        final updateCall = fakeWidgetRepo.updateCalls.single;
        expect(updateCall.input.id, 40);
        expect(updateCall.input.lockedForEdition, isTrue);

        final widget = c
            .read(editorTreeProvider(menuId))
            .widgets[30]!
            .firstWhere((w) => w.id == 40);
        expect(widget.lockedForEdition, isTrue);
      },
    );
  });

  group('EditorTreeNotifier - widget locking', () {
    test('should call lockForEditing with widget id and user id', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeWidgetRepo.whenLockForEditing(const Success(null));
      await c
          .read(editorTreeProvider(menuId).notifier)
          .lockWidget(40, 'user-1');

      expect(fakeWidgetRepo.lockForEditingCalls, hasLength(1));
      expect(fakeWidgetRepo.lockForEditingCalls.first.widgetId, 40);
      expect(fakeWidgetRepo.lockForEditingCalls.first.userId, 'user-1');
    });

    test('should call unlockEditing with widget id', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeWidgetRepo.whenUnlockEditing(const Success(null));
      await c.read(editorTreeProvider(menuId).notifier).unlockWidget(40);

      expect(fakeWidgetRepo.unlockEditingCalls, hasLength(1));
      expect(fakeWidgetRepo.unlockEditingCalls.first.widgetId, 40);
    });
  });

  group('EditorTreeNotifier - reorderContainer', () {
    test('should call use case and reload tree on success', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final callCount = fakeTreeLoader.loadTreeCallCount;

      fakeReorderUseCase.stubExecute(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .reorderContainer(20, ReorderDirection.up);

      expect(result.isSuccess, isTrue);
      expect(fakeReorderUseCase.calls, hasLength(1));
      expect(fakeReorderUseCase.calls.first.$1, 20);
      expect(fakeTreeLoader.loadTreeCallCount, greaterThan(callCount));
    });

    test('should not reload tree on failure', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final callCount = fakeTreeLoader.loadTreeCallCount;

      fakeReorderUseCase.stubExecute(
        const Failure(ValidationError('Already at first position')),
      );

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .reorderContainer(20, ReorderDirection.up);

      expect(result.isFailure, isTrue);
      expect(fakeTreeLoader.loadTreeCallCount, callCount);
    });
  });

  group('EditorTreeNotifier - duplicateContainer', () {
    test('should call use case and reload tree on success', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final callCount = fakeTreeLoader.loadTreeCallCount;

      fakeDuplicateUseCase.stubExecute(
        const Success(entity.Container(id: 99, pageId: 10, index: 1)),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .duplicateContainer(20);

      expect(result.isSuccess, isTrue);
      expect(fakeDuplicateUseCase.calls, hasLength(1));
      expect(fakeDuplicateUseCase.calls.first, 20);
      expect(fakeTreeLoader.loadTreeCallCount, greaterThan(callCount));
    });

    test('should not reload tree on failure', () async {
      final c = makeContainer();
      addTearDown(c.dispose);

      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      await c.read(editorTreeProvider(menuId).notifier).loadTree();
      final callCount = fakeTreeLoader.loadTreeCallCount;

      fakeDuplicateUseCase.stubExecute(
        const Failure(ServerError('Copy failed')),
      );

      final result = await c
          .read(editorTreeProvider(menuId).notifier)
          .duplicateContainer(20);

      expect(result.isFailure, isTrue);
      expect(fakeTreeLoader.loadTreeCallCount, callCount);
    });
  });
}
