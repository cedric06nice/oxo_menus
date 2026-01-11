import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

// Mock classes
class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late WidgetRegistry mockWidgetRegistry;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();

    // Set up widget registry with test widgets
    mockWidgetRegistry = WidgetRegistry();
    mockWidgetRegistry.register(dishWidgetDefinition);
    mockWidgetRegistry.register(sectionWidgetDefinition);
    mockWidgetRegistry.register(textWidgetDefinition);

    // Register fallback values
    registerFallbackValue(const CreateMenuInput(name: '', version: ''));
    registerFallbackValue(const UpdateMenuInput(id: ''));
    registerFallbackValue(const CreatePageInput(menuId: '', name: '', index: 0));
    registerFallbackValue(const UpdatePageInput(id: ''));
    registerFallbackValue(const CreateContainerInput(pageId: '', index: 0));
    registerFallbackValue(const UpdateContainerInput(id: ''));
    registerFallbackValue(const CreateColumnInput(containerId: '', index: 0));
    registerFallbackValue(const UpdateColumnInput(id: ''));
    registerFallbackValue(
        const CreateWidgetInput(columnId: '', type: '', version: '', index: 0, props: {}));
    registerFallbackValue(const UpdateWidgetInput(id: ''));
  });

  Widget createWidgetUnderTest(String menuId) {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        pageRepositoryProvider.overrideWithValue(mockPageRepository),
        containerRepositoryProvider.overrideWithValue(mockContainerRepository),
        columnRepositoryProvider.overrideWithValue(mockColumnRepository),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
        widgetRegistryProvider.overrideWithValue(mockWidgetRegistry),
      ],
      child: MaterialApp(
        home: MenuEditorPage(menuId: menuId),
      ),
    );
  }

  group('MenuEditorPage - Initial Loading', () {
    testWidgets('should display loading indicator while loading',
        (tester) async {
      // Arrange
      const menuId = 'menu-1';
      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(Menu(
                id: menuId,
                name: 'Test Menu',
                status: MenuStatus.draft,
                version: '1.0.0',
              )));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => Future.delayed(
                const Duration(milliseconds: 100),
                () => const Success([]),
              ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('should display error when menu load fails', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Failure(NotFoundError('Menu not found')));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Menu not found'), findsOneWidget);
    });

    testWidgets('should display error when pages load fails', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Failure(NetworkError('Failed to load pages')));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Failed to load pages'), findsOneWidget);
    });

    testWidgets('should load and display menu successfully', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );
      const page = entity.Page(
        id: 'page-1',
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([page]));
      when(() => mockContainerRepository.getAllForPage('page-1'))
          .thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Menu'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
    });
  });

  group('MenuEditorPage - Widget Palette', () {
    testWidgets('should display all registered widget types in palette',
        (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Widget Palette'), findsOneWidget);
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });
  });

  group('MenuEditorPage - Canvas Display', () {
    testWidgets('should display pages, containers, and columns',
        (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );
      const page = entity.Page(
        id: 'page-1',
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );
      const container = entity.Container(
        id: 'container-1',
        pageId: 'page-1',
        index: 0,
        name: 'Container 1',
      );
      const column = entity.Column(
        id: 'column-1',
        containerId: 'container-1',
        index: 0,
        flex: 1,
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([page]));
      when(() => mockContainerRepository.getAllForPage('page-1'))
          .thenAnswer((_) async => const Success([container]));
      when(() => mockColumnRepository.getAllForContainer('container-1'))
          .thenAnswer((_) async => const Success([column]));
      when(() => mockWidgetRepository.getAllForColumn('column-1'))
          .thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Container 1'), findsOneWidget);
      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('should display widgets in columns', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );
      const page = entity.Page(
        id: 'page-1',
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );
      const container = entity.Container(
        id: 'container-1',
        pageId: 'page-1',
        index: 0,
      );
      const column = entity.Column(
        id: 'column-1',
        containerId: 'container-1',
        index: 0,
        flex: 1,
      );
      const widget = WidgetInstance(
        id: 'widget-1',
        columnId: 'column-1',
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {
          'name': 'Test Dish',
          'price': 10.0,
          'showPrice': true,
          'showAllergens': true,
          'allergens': [],
          'dietary': [],
        },
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([page]));
      when(() => mockContainerRepository.getAllForPage('page-1'))
          .thenAnswer((_) async => const Success([container]));
      when(() => mockColumnRepository.getAllForContainer('container-1'))
          .thenAnswer((_) async => const Success([column]));
      when(() => mockWidgetRepository.getAllForColumn('column-1'))
          .thenAnswer((_) async => const Success([widget]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      // Widget rendering tested separately in widget-specific tests
      // This test verifies the structure is loaded correctly
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });
  });

  group('MenuEditorPage - Widget Management', () {
    testWidgets('should display drop zone for empty column', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );
      const page = entity.Page(
        id: 'page-1',
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );
      const container = entity.Container(
        id: 'container-1',
        pageId: 'page-1',
        index: 0,
      );
      const column = entity.Column(
        id: 'column-1',
        containerId: 'container-1',
        index: 0,
        flex: 1,
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([page]));
      when(() => mockContainerRepository.getAllForPage('page-1'))
          .thenAnswer((_) async => const Success([container]));
      when(() => mockColumnRepository.getAllForContainer('container-1'))
          .thenAnswer((_) async => const Success([column]));
      when(() => mockWidgetRepository.getAllForColumn('column-1'))
          .thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Drop widgets here'), findsOneWidget);
      expect(find.byKey(const Key('drop_zone_column-1')), findsOneWidget);
    });

    testWidgets('should display widgets with edit capability', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );
      const page = entity.Page(
        id: 'page-1',
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );
      const container = entity.Container(
        id: 'container-1',
        pageId: 'page-1',
        index: 0,
      );
      const column = entity.Column(
        id: 'column-1',
        containerId: 'container-1',
        index: 0,
        flex: 1,
      );
      const widget = WidgetInstance(
        id: 'widget-1',
        columnId: 'column-1',
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {
          'name': 'Test Dish',
          'price': 10.0,
          'showPrice': true,
          'showAllergens': true,
          'allergens': [],
          'dietary': [],
        },
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([page]));
      when(() => mockContainerRepository.getAllForPage('page-1'))
          .thenAnswer((_) async => const Success([container]));
      when(() => mockColumnRepository.getAllForContainer('container-1'))
          .thenAnswer((_) async => const Success([column]));
      when(() => mockWidgetRepository.getAllForColumn('column-1'))
          .thenAnswer((_) async => const Success([widget]));

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - verify WidgetRenderer is used
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });
  });

  group('MenuEditorPage - Save Functionality', () {
    testWidgets('should save menu when save button tapped', (tester) async {
      // Arrange
      const menuId = 'menu-1';
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      when(() => mockMenuRepository.getById(menuId))
          .thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([]));
      when(() => mockMenuRepository.update(any()))
          .thenAnswer((_) async => const Success(menu));

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('save_menu_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.update(any())).called(1);
      expect(find.text('Menu saved'), findsOneWidget);
    });
  });
}
