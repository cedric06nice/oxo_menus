import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/template_editor_provider.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader_provider.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';

// ---------------------------------------------------------------------------
// Fake EditorTreeLoader (same pattern as editor_tree_notifier_test)
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

  void stubLoadTree(Result<EditorTree, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<EditorTree, DomainError>> loadTree(int menuId) async {
    if (_stubResult != null) return _stubResult!;
    throw StateError(
      '_FakeEditorTreeLoader: no stub configured — call stubLoadTree() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Test constants
// ---------------------------------------------------------------------------

const menuId = 1;

final _testMenu = Menu(
  id: menuId,
  name: 'Test Template',
  status: Status.draft,
  version: '1.0',
);

const _testPages = [
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
];

const _testContainers = [entity.Container(id: 20, pageId: 10, index: 0)];
const _testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];

EditorTree _defaultTree({Menu? menu}) {
  return EditorTree(
    menu: menu ?? _testMenu,
    pages: _testPages,
    containers: {10: _testContainers},
    columns: {20: _testColumns},
    widgets: {30: const []},
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeContainerRepository fakeContainerRepo;
  late FakeColumnRepository fakeColumnRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late _FakeEditorTreeLoader fakeTreeLoader;

  /// Creates a [ProviderContainer] wired with all fakes.
  ///
  /// The [fakeTreeLoader] is created in [setUp] so that stubs may be
  /// configured on it BEFORE calling [makeContainer] — the container
  /// captures the same instance via [editorTreeLoaderProvider.overrideWithValue].
  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        widgetRegistryProvider.overrideWithValue(PresentableWidgetRegistry()),
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
    fakeTreeLoader = _FakeEditorTreeLoader(
      menuRepository: fakeMenuRepo,
      pageRepository: fakePageRepo,
      containerRepository: fakeContainerRepo,
      columnRepository: fakeColumnRepo,
      widgetRepository: fakeWidgetRepo,
    );
  });

  group('TemplateEditorNotifier - initial state', () {
    test('should have isSaving false', () {
      final c = makeContainer();
      addTearDown(c.dispose);

      final state = c.read(templateEditorProvider(menuId));

      expect(state.isSaving, isFalse);
    });
  });

  group('TemplateEditorNotifier - structure CRUD', () {
    test('should create page with correct parameters', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakePageRepo.whenCreate(
        const Success(
          entity.Page(id: 12, menuId: menuId, name: 'Page 2', index: 1),
        ),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).addPage(1);

      expect(fakePageRepo.createCalls, hasLength(1));
      expect(fakePageRepo.createCalls.first.input.menuId, menuId);
    });

    test('should delete page by id', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakePageRepo.whenDelete(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).deletePage(10);

      expect(fakePageRepo.deleteCalls, hasLength(1));
      expect(fakePageRepo.deleteCalls.first.id, 10);
    });

    test('should add header page with header type', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakePageRepo.whenCreate(
        const Success(
          entity.Page(
            id: 13,
            menuId: menuId,
            name: 'Header',
            index: 0,
            type: entity.PageType.header,
          ),
        ),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).addHeader();

      expect(fakePageRepo.createCalls, hasLength(1));
      expect(fakePageRepo.createCalls.first.input.type, entity.PageType.header);
    });

    test('should add footer page with footer type', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakePageRepo.whenCreate(
        const Success(
          entity.Page(
            id: 14,
            menuId: menuId,
            name: 'Footer',
            index: 0,
            type: entity.PageType.footer,
          ),
        ),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).addFooter();

      expect(fakePageRepo.createCalls, hasLength(1));
      expect(fakePageRepo.createCalls.first.input.type, entity.PageType.footer);
    });

    test('should create container with correct page id', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeContainerRepo.whenCreate(
        const Success(entity.Container(id: 21, pageId: 10, index: 1)),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).addContainer(10, 1);

      expect(fakeContainerRepo.createCalls, hasLength(1));
      expect(fakeContainerRepo.createCalls.first.input.pageId, 10);
    });

    test('should create column with correct container id', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeColumnRepo.whenCreate(
        const Success(entity.Column(id: 31, containerId: 20, index: 1)),
      );
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).addColumn(20, 1);

      expect(fakeColumnRepo.createCalls, hasLength(1));
      expect(fakeColumnRepo.createCalls.first.input.containerId, 20);
    });

    test('should delete column by id', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeColumnRepo.whenDelete(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).deleteColumn(30);

      expect(fakeColumnRepo.deleteCalls, hasLength(1));
      expect(fakeColumnRepo.deleteCalls.first.id, 30);
    });

    test('should delete container by id', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeContainerRepo.whenDelete(const Success(null));
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

      await c.read(templateEditorProvider(menuId).notifier).deleteContainer(20);

      expect(fakeContainerRepo.deleteCalls, hasLength(1));
      expect(fakeContainerRepo.deleteCalls.first.id, 20);
    });
  });

  group('TemplateEditorNotifier - style management', () {
    test('should update menu style locally when menu selection', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      const newStyle = StyleConfig(marginTop: 20);
      c
          .read(templateEditorProvider(menuId).notifier)
          .onSidePanelStyleChanged(
            newStyle,
            const EditorSelection(type: EditorElementType.menu, id: 0),
          );

      expect(c.read(editorTreeProvider(menuId)).menu?.styleConfig, newStyle);
    });

    test(
      'should update container style locally when container selection',
      () async {
        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        final c = makeContainer();
        addTearDown(c.dispose);

        await c
            .read(editorTreeProvider(menuId).notifier)
            .loadTree(separateHeaderFooter: true);

        const newStyle = StyleConfig(paddingLeft: 10);
        c
            .read(templateEditorProvider(menuId).notifier)
            .onSidePanelStyleChanged(
              newStyle,
              const EditorSelection(type: EditorElementType.container, id: 20),
            );

        expect(
          c.read(editorTreeProvider(menuId)).containers[10]!.first.styleConfig,
          newStyle,
        );
      },
    );

    test('should update column style locally when column selection', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      const newStyle = StyleConfig(fontSize: 14);
      c
          .read(templateEditorProvider(menuId).notifier)
          .onSidePanelStyleChanged(
            newStyle,
            const EditorSelection(type: EditorElementType.column, id: 30),
          );

      expect(
        c.read(editorTreeProvider(menuId)).columns[20]!.first.styleConfig,
        newStyle,
      );
    });

    test(
      'should not persist immediately when style changes via debounce',
      () async {
        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        final c = makeContainer();
        addTearDown(c.dispose);

        await c
            .read(editorTreeProvider(menuId).notifier)
            .loadTree(separateHeaderFooter: true);

        const newStyle = StyleConfig(paddingLeft: 5);
        c
            .read(templateEditorProvider(menuId).notifier)
            .onSidePanelStyleChanged(
              newStyle,
              const EditorSelection(type: EditorElementType.container, id: 20),
            );

        // No API call yet — debounce timer is pending
        expect(fakeContainerRepo.updateCalls, isEmpty);
      },
    );
  });

  group('TemplateEditorNotifier - template operations', () {
    test('should set isSaving false after saveTemplate', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeMenuRepo.whenUpdate(Success(_testMenu));

      await c.read(templateEditorProvider(menuId).notifier).saveTemplate();

      expect(c.read(templateEditorProvider(menuId)).isSaving, isFalse);
    });

    test('should call menu repository update on saveTemplate', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeMenuRepo.whenUpdate(Success(_testMenu));

      await c.read(templateEditorProvider(menuId).notifier).saveTemplate();

      expect(fakeMenuRepo.updateCalls, hasLength(1));
    });

    test(
      'should call update with published status on publishTemplate',
      () async {
        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        final c = makeContainer();
        addTearDown(c.dispose);

        await c
            .read(editorTreeProvider(menuId).notifier)
            .loadTree(separateHeaderFooter: true);

        fakeMenuRepo.whenUpdate(
          Success(_testMenu.copyWith(status: Status.published)),
        );
        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));

        await c.read(templateEditorProvider(menuId).notifier).publishTemplate();

        expect(fakeMenuRepo.updateCalls, hasLength(1));
        expect(fakeMenuRepo.updateCalls.first.input.status, Status.published);
      },
    );

    test(
      'should update allowedWidgets locally before repo call completes',
      () async {
        fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
        final c = makeContainer();
        addTearDown(c.dispose);

        await c
            .read(editorTreeProvider(menuId).notifier)
            .loadTree(separateHeaderFooter: true);

        final completer = Completer<Result<Menu, DomainError>>();
        fakeMenuRepo.whenUpdateWithFuture(completer.future);

        const newConfigs = [
          WidgetTypeConfig(type: 'dish', alignment: WidgetAlignment.center),
        ];

        final future = c
            .read(templateEditorProvider(menuId).notifier)
            .updateAllowedWidgets(newConfigs);

        // Yield to allow synchronous optimistic update
        await Future<void>.delayed(Duration.zero);

        expect(
          c.read(editorTreeProvider(menuId)).menu?.allowedWidgets,
          newConfigs,
        );

        completer.complete(Success(_testMenu));
        await future;
      },
    );

    test('should roll back allowedWidgets on repo failure', () async {
      final initialConfigs = [
        const WidgetTypeConfig(type: 'dish', alignment: WidgetAlignment.end),
      ];
      final seededMenu = _testMenu.copyWith(allowedWidgets: initialConfigs);
      fakeTreeLoader.stubLoadTree(Success(_defaultTree(menu: seededMenu)));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeMenuRepo.whenUpdate(const Failure(ServerError('nope')));

      await c
          .read(templateEditorProvider(menuId).notifier)
          .updateAllowedWidgets(const [
            WidgetTypeConfig(type: 'text', alignment: WidgetAlignment.center),
          ]);

      expect(
        c.read(editorTreeProvider(menuId)).menu?.allowedWidgets,
        initialConfigs,
      );
    });

    test('should update column droppable locally', () async {
      fakeTreeLoader.stubLoadTree(Success(_defaultTree()));
      final c = makeContainer();
      addTearDown(c.dispose);

      await c
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      fakeColumnRepo.whenUpdate(
        const Success(
          entity.Column(id: 30, containerId: 20, index: 0, isDroppable: false),
        ),
      );

      await c
          .read(templateEditorProvider(menuId).notifier)
          .updateColumnDroppable(30, false);

      expect(
        c.read(editorTreeProvider(menuId)).columns[20]!.first.isDroppable,
        isFalse,
      );
    });
  });
}
