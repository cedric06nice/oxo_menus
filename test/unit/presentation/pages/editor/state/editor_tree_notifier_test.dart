import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart' show ServerError;
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
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockWidgetRegistry extends Mock implements WidgetRegistry {}

class MockWidgetDefinition extends Mock implements WidgetDefinition {}

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
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0',
  );

  const testPages = [
    entity.Page(id: 10, menuId: menuId, name: 'Page 1', index: 0),
    entity.Page(id: 11, menuId: menuId, name: 'Page 2', index: 1),
  ];

  const testContainers = [entity.Container(id: 20, pageId: 10, index: 0)];

  const testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];

  const testWidgets = [
    WidgetInstance(
      id: 40,
      columnId: 30,
      type: 'text',
      version: '1.0',
      index: 0,
      props: {'text': 'Hello'},
    ),
  ];

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();
    mockWidgetRegistry = MockWidgetRegistry();
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: 0,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
    registerFallbackValue(const UpdateWidgetInput(id: 0, props: {}));
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
    ).thenAnswer((_) async => const Success(testWidgets));
  }

  group('EditorTreeNotifier - initial state', () {
    test('has default initial state', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(editorTreeProvider(menuId));

      expect(state, const EditorTreeState());
      expect(state.isLoading, isTrue);
      expect(state.menu, isNull);
      expect(state.pages, isEmpty);
      expect(state.headerPage, isNull);
      expect(state.footerPage, isNull);
      expect(state.containers, isEmpty);
      expect(state.columns, isEmpty);
      expect(state.widgets, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.hoverIndex, isEmpty);
    });
  });

  group('EditorTreeNotifier - loadTree success', () {
    test('loads tree and populates state', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      final state = container.read(editorTreeProvider(menuId));
      expect(state.isLoading, isFalse);
      expect(state.menu, testMenu);
      expect(state.pages, hasLength(2));
      expect(state.containers[10], hasLength(1));
      expect(state.columns[20], hasLength(1));
      expect(state.widgets[30], hasLength(1));
      expect(state.errorMessage, isNull);
    });

    test('sets isLoading false after successful load', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      // Initial state has isLoading: true
      expect(container.read(editorTreeProvider(menuId)).isLoading, isTrue);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      // After load completes, isLoading should be false
      expect(container.read(editorTreeProvider(menuId)).isLoading, isFalse);
    });
  });

  group('EditorTreeNotifier - loadTree failure', () {
    test('sets errorMessage on menu fetch failure', () async {
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Failure(ServerError('Menu not found')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      final state = container.read(editorTreeProvider(menuId));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Menu not found');
    });

    test('sets errorMessage on page fetch failure', () async {
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Failure(ServerError('Pages not found')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      final state = container.read(editorTreeProvider(menuId));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Pages not found');
    });
  });

  group('EditorTreeNotifier - loadTree with header/footer separation', () {
    test('separates header, footer, and content pages', () async {
      const pagesWithHeaderFooter = [
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

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success(pagesWithHeaderFooter));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => const Success(<entity.Container>[]));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success(<entity.Column>[]));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree(separateHeaderFooter: true);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.pages, hasLength(1));
      expect(state.pages.first.name, 'Content');
      expect(state.headerPage?.name, 'Header');
      expect(state.footerPage?.name, 'Footer');
    });

    test('without separation puts all pages in pages list', () async {
      const pagesWithHeaderFooter = [
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

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success(pagesWithHeaderFooter));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => const Success(<entity.Container>[]));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success(<entity.Column>[]));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree(separateHeaderFooter: false);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.pages, hasLength(2));
      expect(state.headerPage, isNull);
      expect(state.footerPage, isNull);
    });
  });

  group('EditorTreeNotifier - local updates', () {
    test('updateHoverIndex updates the hover index map', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      notifier.updateHoverIndex(30, 2);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.hoverIndex[30], 2);
    });

    test('updateMenuLocally updates the menu', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      final updatedMenu = testMenu.copyWith(name: 'Updated');
      notifier.updateMenuLocally(updatedMenu);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.menu?.name, 'Updated');
    });

    test('updateContainerStyleLocally updates the container style', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      const newStyle = StyleConfig(marginTop: 20);
      notifier.updateContainerStyleLocally(20, newStyle);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.containers[10]!.first.styleConfig, newStyle);
    });

    test('updateColumnStyleLocally updates the column style', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      const newStyle = StyleConfig(paddingLeft: 10);
      notifier.updateColumnStyleLocally(30, newStyle);

      final state = container.read(editorTreeProvider(menuId));
      expect(state.columns[20]!.first.styleConfig, newStyle);
    });

    test(
      'updateColumnDroppableLocally updates the column droppable flag',
      () async {
        stubSuccessfulTreeLoad();
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(editorTreeProvider(menuId).notifier);
        await notifier.loadTree();

        notifier.updateColumnDroppableLocally(30, false);

        final state = container.read(editorTreeProvider(menuId));
        expect(state.columns[20]!.first.isDroppable, isFalse);
      },
    );
  });

  group('EditorTreeNotifier - widget CRUD', () {
    test('createWidget calls repository and reloads', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      final mockDef = MockWidgetDefinition();
      when(() => mockWidgetRegistry.getDefinition('text')).thenReturn(mockDef);
      when(() => mockDef.defaultProps).thenReturn(_FakeProps());
      when(() => mockDef.version).thenReturn('1.0');
      when(() => mockWidgetRepo.create(any())).thenAnswer(
        (_) async => const Success(
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

      await notifier.createWidget('text', 30, 1);

      verify(() => mockWidgetRepo.create(any())).called(1);
    });

    test('createWidget does nothing if widget type unknown', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => mockWidgetRegistry.getDefinition('unknown')).thenReturn(null);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.createWidget('unknown', 30, 0);

      verifyNever(() => mockWidgetRepo.create(any()));
    });

    test('deleteWidget calls repository and reloads', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      when(
        () => mockWidgetRepo.delete(40),
      ).thenAnswer((_) async => const Success(null));

      await notifier.deleteWidget(40);

      verify(() => mockWidgetRepo.delete(40)).called(1);
    });

    test('moveWidget within same column adjusts index', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      const widget = WidgetInstance(
        id: 40,
        columnId: 30,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      when(
        () => mockWidgetRepo.reorder(40, any()),
      ).thenAnswer((_) async => const Success(null));

      await notifier.moveWidget(widget, 30, 30, 2);

      // index > widget.index => adjustedIndex = 2 - 1 = 1
      verify(() => mockWidgetRepo.reorder(40, 1)).called(1);
    });

    test('moveWidget to different column calls moveTo', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      const widget = WidgetInstance(
        id: 40,
        columnId: 30,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      when(
        () => mockWidgetRepo.moveTo(40, 31, 0),
      ).thenAnswer((_) async => const Success(null));

      await notifier.moveWidget(widget, 30, 31, 0);

      verify(() => mockWidgetRepo.moveTo(40, 31, 0)).called(1);
    });

    test('updateWidgetProps calls repository and reloads', () async {
      stubSuccessfulTreeLoad();
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(editorTreeProvider(menuId).notifier);
      await notifier.loadTree();

      when(() => mockWidgetRepo.update(any())).thenAnswer(
        (_) async => const Success(
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

      await notifier.updateWidgetProps(40, {'text': 'Updated'});

      verify(() => mockWidgetRepo.update(any())).called(1);
    });
  });
}

class _FakeProps {
  Map<String, dynamic> toJson() => {'text': 'Default'};
}
