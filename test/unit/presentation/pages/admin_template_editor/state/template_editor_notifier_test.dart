import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/template_editor_provider.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockWidgetRegistry extends Mock implements WidgetRegistry {}

void main() {
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;
  late MockWidgetRegistry mockWidgetRegistry;

  const menuId = 1;

  final testMenu = Menu(
    id: menuId,
    name: 'Test Template',
    status: Status.draft,
    version: '1.0',
  );

  const testPages = [
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

  const testContainers = [entity.Container(id: 20, pageId: 10, index: 0)];
  const testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();
    mockWidgetRegistry = MockWidgetRegistry();
  });

  setUpAll(() {
    registerFallbackValue(const CreatePageInput(menuId: 0, name: '', index: 0));
    registerFallbackValue(
      const CreateContainerInput(pageId: 0, index: 0, direction: 'portrait'),
    );
    registerFallbackValue(
      const CreateColumnInput(containerId: 0, index: 0, flex: 1),
    );
    registerFallbackValue(const UpdateMenuInput(id: 0));
    registerFallbackValue(const UpdateContainerInput(id: 0));
    registerFallbackValue(const UpdateColumnInput(id: 0));
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepo),
        pageRepositoryProvider.overrideWithValue(mockPageRepo),
        containerRepositoryProvider.overrideWithValue(mockContainerRepo),
        columnRepositoryProvider.overrideWithValue(mockColumnRepo),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepo),
        widgetRegistryProvider.overrideWithValue(mockWidgetRegistry),
      ],
    );
  }

  void stubSuccessfulTreeLoad() {
    when(
      () => mockMenuRepo.getById(menuId),
    ).thenAnswer((_) async => Success(testMenu));
    when(
      () => mockPageRepo.getAllForMenu(menuId),
    ).thenAnswer((_) async => const Success(testPages));
    when(
      () => mockContainerRepo.getAllForPage(any()),
    ).thenAnswer((_) async => const Success(testContainers));
    when(
      () => mockColumnRepo.getAllForContainer(any()),
    ).thenAnswer((_) async => const Success(testColumns));
    when(
      () => mockWidgetRepo.getAllForColumn(any()),
    ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
  }

  group('TemplateEditorNotifier - initial state', () {
    test('has default state with isSaving false', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(templateEditorProvider(menuId));
      expect(state.isSaving, isFalse);
    });
  });

  group('TemplateEditorNotifier - structure CRUD', () {
    test('addPage creates page and reloads tree', () async {
      stubSuccessfulTreeLoad();
      when(() => mockPageRepo.create(any())).thenAnswer(
        (_) async => const Success(
          entity.Page(id: 12, menuId: menuId, name: 'Page 2', index: 1),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      // Load tree first so reload works
      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container.read(templateEditorProvider(menuId).notifier).addPage(1);

      verify(() => mockPageRepo.create(any())).called(1);
    });

    test('deletePage deletes and reloads tree', () async {
      stubSuccessfulTreeLoad();
      when(
        () => mockPageRepo.delete(10),
      ).thenAnswer((_) async => const Success(null));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .deletePage(10);

      verify(() => mockPageRepo.delete(10)).called(1);
    });

    test('addHeader creates header page', () async {
      stubSuccessfulTreeLoad();
      when(() => mockPageRepo.create(any())).thenAnswer(
        (_) async => const Success(
          entity.Page(
            id: 13,
            menuId: menuId,
            name: 'Header',
            index: 0,
            type: entity.PageType.header,
          ),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container.read(templateEditorProvider(menuId).notifier).addHeader();

      final captured =
          verify(() => mockPageRepo.create(captureAny())).captured.single
              as CreatePageInput;
      expect(captured.type, entity.PageType.header);
    });

    test('addFooter creates footer page', () async {
      stubSuccessfulTreeLoad();
      when(() => mockPageRepo.create(any())).thenAnswer(
        (_) async => const Success(
          entity.Page(
            id: 14,
            menuId: menuId,
            name: 'Footer',
            index: 0,
            type: entity.PageType.footer,
          ),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container.read(templateEditorProvider(menuId).notifier).addFooter();

      final captured =
          verify(() => mockPageRepo.create(captureAny())).captured.single
              as CreatePageInput;
      expect(captured.type, entity.PageType.footer);
    });

    test('addContainer creates container and reloads', () async {
      stubSuccessfulTreeLoad();
      when(() => mockContainerRepo.create(any())).thenAnswer(
        (_) async =>
            const Success(entity.Container(id: 21, pageId: 10, index: 1)),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .addContainer(10, 1);

      verify(() => mockContainerRepo.create(any())).called(1);
    });

    test('addColumn creates column and reloads', () async {
      stubSuccessfulTreeLoad();
      when(() => mockColumnRepo.create(any())).thenAnswer(
        (_) async =>
            const Success(entity.Column(id: 31, containerId: 20, index: 1)),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .addColumn(20, 1);

      verify(() => mockColumnRepo.create(any())).called(1);
    });
  });

  group('TemplateEditorNotifier - style management', () {
    test('onSidePanelStyleChanged updates menu style locally', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      const newStyle = StyleConfig(marginTop: 20);
      container
          .read(templateEditorProvider(menuId).notifier)
          .onSidePanelStyleChanged(
            newStyle,
            const EditorSelection(type: EditorElementType.menu, id: 0),
          );

      final treeState = container.read(editorTreeProvider(menuId));
      expect(treeState.menu?.styleConfig, newStyle);
    });

    test('onSidePanelStyleChanged updates container style locally', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      const newStyle = StyleConfig(paddingLeft: 10);
      container
          .read(templateEditorProvider(menuId).notifier)
          .onSidePanelStyleChanged(
            newStyle,
            const EditorSelection(type: EditorElementType.container, id: 20),
          );

      final treeState = container.read(editorTreeProvider(menuId));
      expect(treeState.containers[10]!.first.styleConfig, newStyle);
    });

    test('onSidePanelStyleChanged updates column style locally', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      const newStyle = StyleConfig(fontSize: 14);
      container
          .read(templateEditorProvider(menuId).notifier)
          .onSidePanelStyleChanged(
            newStyle,
            const EditorSelection(type: EditorElementType.column, id: 30),
          );

      final treeState = container.read(editorTreeProvider(menuId));
      expect(treeState.columns[20]!.first.styleConfig, newStyle);
    });
  });

  group('TemplateEditorNotifier - template operations', () {
    test('saveTemplate sets isSaving and calls repository', () async {
      stubSuccessfulTreeLoad();
      when(
        () => mockMenuRepo.update(any()),
      ).thenAnswer((_) async => Success(testMenu));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .saveTemplate();

      verify(() => mockMenuRepo.update(any())).called(1);
      expect(container.read(templateEditorProvider(menuId)).isSaving, isFalse);
    });

    test('publishTemplate updates status and reloads', () async {
      stubSuccessfulTreeLoad();
      when(
        () => mockMenuRepo.update(any()),
      ).thenAnswer((_) async => Success(testMenu));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .publishTemplate();

      final captured =
          verify(() => mockMenuRepo.update(captureAny())).captured.single
              as UpdateMenuInput;
      expect(captured.status, Status.published);
    });

    test('updateAllowedWidgetTypes updates menu locally on success', () async {
      stubSuccessfulTreeLoad();
      when(
        () => mockMenuRepo.update(any()),
      ).thenAnswer((_) async => Success(testMenu));

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .updateAllowedWidgetTypes(['dish', 'text']);

      final treeState = container.read(editorTreeProvider(menuId));
      expect(treeState.menu?.allowedWidgetTypes, ['dish', 'text']);
    });

    test('updateColumnDroppable updates column locally', () async {
      stubSuccessfulTreeLoad();
      when(() => mockColumnRepo.update(any())).thenAnswer(
        (_) async => const Success(
          entity.Column(id: 30, containerId: 20, index: 0, isDroppable: false),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(editorTreeProvider(menuId).notifier)
          .loadTree(separateHeaderFooter: true);

      await container
          .read(templateEditorProvider(menuId).notifier)
          .updateColumnDroppable(30, false);

      final treeState = container.read(editorTreeProvider(menuId));
      expect(treeState.columns[20]!.first.isDroppable, isFalse);
    });
  });
}
