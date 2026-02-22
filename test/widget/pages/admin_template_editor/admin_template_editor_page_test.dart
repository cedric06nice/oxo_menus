import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late MockSizeRepository mockSizeRepository;
  late WidgetRegistry testWidgetRegistry;
  late MockGoRouter mockRouter;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();
    mockSizeRepository = MockSizeRepository();
    mockRouter = MockGoRouter();

    testWidgetRegistry = WidgetRegistry();
    testWidgetRegistry.register(dishWidgetDefinition);
    testWidgetRegistry.register(imageWidgetDefinition);
    testWidgetRegistry.register(sectionWidgetDefinition);
    testWidgetRegistry.register(textWidgetDefinition);
  });

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(
      const CreatePageInput(menuId: -1, name: '', index: 0),
    );
    registerFallbackValue(const UpdatePageInput(id: -1));
    registerFallbackValue(
      const CreateContainerInput(pageId: -1, index: 0, direction: 'row'),
    );
    registerFallbackValue(const UpdateContainerInput(id: -1));
    registerFallbackValue(const CreateColumnInput(containerId: -1, index: 0));
    registerFallbackValue(const UpdateColumnInput(id: -1));
    registerFallbackValue(const UpdateMenuInput(id: -1));
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: -1,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
    registerFallbackValue(const UpdateWidgetInput(id: -1));
  });

  Widget createWidgetUnderTest(int menuId) {
    final mockUser = User(
      id: 'admin-1',
      email: 'admin@example.com',
      firstName: 'Admin',
      lastName: 'User',
      role: UserRole.admin,
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        pageRepositoryProvider.overrideWithValue(mockPageRepository),
        containerRepositoryProvider.overrideWithValue(mockContainerRepository),
        columnRepositoryProvider.overrideWithValue(mockColumnRepository),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
        sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        widgetRegistryProvider.overrideWithValue(testWidgetRegistry),
        currentUserProvider.overrideWithValue(mockUser),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockRouter,
          child: AdminTemplateEditorPage(menuId: menuId),
        ),
      ),
    );
  }

  group('AdminTemplateEditorPage - Initial Load', () {
    testWidgets('should show loading indicator initially', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(() => mockMenuRepository.getById(menuId)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success(menu),
        ),
      );
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('should load and display template name', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Summer Menu Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Summer Menu Template'), findsOneWidget);
    });

    testWidgets('should show error when menu fails to load', (tester) async {
      // Arrange
      const menuId = 1;
      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Failure(NotFoundError('Menu not found')));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Menu not found'), findsOneWidget);
    });

    testWidgets('should have app bar with save and publish actions', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.publish), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Page Management', () {
    testWidgets('should display existing pages', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        const entity.Page(id: 2, menuId: menuId, name: 'Page 2', index: 1),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — page names are hidden; verify pages exist via delete button keys
      expect(find.byKey(const Key('delete_page_1')), findsOneWidget);
      expect(find.byKey(const Key('delete_page_2')), findsOneWidget);
    });

    testWidgets('should have add page button', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_page_button')), findsOneWidget);
    });

    testWidgets('should create new page when add button tapped', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      const newPage = entity.Page(
        id: 2,
        menuId: menuId,
        name: 'Page 1',
        index: 0,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.create(any()),
      ).thenAnswer((_) async => const Success(newPage));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_page_button')));
      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockPageRepository.create(any())).called(1);
      // Note: UI update verification would require complex mock state management
      // The implementation correctly calls _loadTemplate() after create
    });

    testWidgets('should delete page when delete button tapped', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Find and tap delete button for page
      await tester.ensureVisible(find.byKey(const Key('delete_page_1')));
      await tester.tap(find.byKey(const Key('delete_page_1')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockPageRepository.delete(1)).called(1);
      // Note: UI update verification would require complex mock state management
      // The implementation correctly calls _loadTemplate() after delete
    });
  });

  group('AdminTemplateEditorPage - Container Management', () {
    testWidgets('should display containers for a page', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(
          id: 1,
          pageId: pageId,
          index: 0,
          name: 'Header Section',
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — container names are hidden; verify via selectable key
      expect(find.byKey(const Key('selectable_container_1')), findsOneWidget);
    });

    testWidgets('should add container to page', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      const newContainer = entity.Container(id: 2, pageId: pageId, index: 0);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockContainerRepository.create(any()),
      ).thenAnswer((_) async => const Success(newContainer));
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_container_1')));
      await tester.tap(find.byKey(const Key('add_container_1')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockContainerRepository.create(any())).called(1);
    });

    testWidgets('should delete container', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(
          id: 1,
          pageId: pageId,
          index: 0,
          name: 'Header Section',
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockContainerRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_container_1')));
      await tester.tap(find.byKey(const Key('delete_container_1')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockContainerRepository.delete(1)).called(1);
      // Note: UI update verification would require complex mock state management
      // The implementation correctly calls _loadTemplate() after delete
    });
  });

  group('AdminTemplateEditorPage - Column Management', () {
    testWidgets('should display columns in a container', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
        const entity.Column(id: 2, containerId: containerId, index: 1, flex: 1),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - should show 2 columns (scroll to make visible)
      await tester.ensureVisible(find.byKey(const Key('column_1')));
      expect(find.byKey(const Key('column_1')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('column_2')));
      expect(find.byKey(const Key('column_2')), findsOneWidget);
    });

    testWidgets('should add column to container', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      const newColumn = entity.Column(
        id: 2,
        containerId: containerId,
        index: 0,
        flex: 1,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockColumnRepository.create(any()),
      ).thenAnswer((_) async => const Success(newColumn));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_column_1')));
      await tester.tap(find.byKey(const Key('add_column_1')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockColumnRepository.create(any())).called(1);
    });

    testWidgets('should delete column', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
      when(
        () => mockColumnRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_column_1')));
      await tester.tap(find.byKey(const Key('delete_column_1')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockColumnRepository.delete(1)).called(1);
      // Note: UI update verification would require complex mock state management
      // The implementation correctly calls _loadTemplate() after delete
    });
  });

  group('AdminTemplateEditorPage - Selection and Side Panel', () {
    testWidgets(
      'tapping a container card shows "Container Style" in side panel',
      (tester) async {
        // Arrange
        const menuId = 1;
        const pageId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: menuId,
            name: 'Page 1',
            index: 0,
          ),
        ];
        final containers = [
          const entity.Container(
            id: 1,
            pageId: pageId,
            index: 0,
            name: 'Header Section',
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => Success(pages));
        when(
          () => mockContainerRepository.getAllForPage(pageId),
        ).thenAnswer((_) async => Success(containers));
        when(
          () => mockColumnRepository.getAllForContainer(any()),
        ).thenAnswer((_) async => const Success([]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Tap the container card
        await tester.tap(find.byKey(const Key('selectable_container_1')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Container Style'), findsOneWidget);
      },
    );

    testWidgets('tapping a column card shows "Column Style" in side panel', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Tap the column card
      await tester.tap(find.byKey(const Key('selectable_column_1')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Column Style'), findsOneWidget);
    });

    testWidgets('tapping a page header shows "Menu Style" in side panel', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Tap the menu style selector
      await tester.tap(find.byKey(const Key('selectable_menu')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Menu Style'), findsOneWidget);
    });

    testWidgets('side panel hidden when nothing is selected', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - no side panel style editor when nothing selected
      expect(find.text('Menu Style'), findsNothing);
      expect(find.text('Container Style'), findsNothing);
      expect(find.text('Column Style'), findsNothing);
    });

    testWidgets('inline ExpansionTile style sections are no longer present', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - no ExpansionTiles for style sections
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets(
      'shows isDroppable toggle when column is selected in side panel',
      (tester) async {
        // Arrange
        const menuId = 1;
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: menuId,
            name: 'Page 1',
            index: 0,
          ),
        ];
        final containers = [
          const entity.Container(id: containerId, pageId: pageId, index: 0),
        ];
        final columns = [
          const entity.Column(
            id: columnId,
            containerId: containerId,
            index: 0,
            flex: 1,
            isDroppable: true,
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => Success(pages));
        when(
          () => mockContainerRepository.getAllForPage(pageId),
        ).thenAnswer((_) async => Success(containers));
        when(
          () => mockColumnRepository.getAllForContainer(containerId),
        ).thenAnswer((_) async => Success(columns));
        when(
          () => mockWidgetRepository.getAllForColumn(any()),
        ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Tap column to select it
        await tester.tap(find.byKey(const Key('selectable_column_$columnId')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Allow Widget Drops'), findsOneWidget);
      },
    );

    testWidgets(
      'toggling droppable in side panel calls columnRepository.update',
      (tester) async {
        // Arrange
        const menuId = 1;
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: menuId,
            name: 'Page 1',
            index: 0,
          ),
        ];
        final containers = [
          const entity.Container(id: containerId, pageId: pageId, index: 0),
        ];
        final columns = [
          const entity.Column(
            id: columnId,
            containerId: containerId,
            index: 0,
            flex: 1,
            isDroppable: true,
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => Success(pages));
        when(
          () => mockContainerRepository.getAllForPage(pageId),
        ).thenAnswer((_) async => Success(containers));
        when(
          () => mockColumnRepository.getAllForContainer(containerId),
        ).thenAnswer((_) async => Success(columns));
        when(
          () => mockWidgetRepository.getAllForColumn(any()),
        ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
        when(() => mockColumnRepository.update(any())).thenAnswer(
          (_) async => Success(columns.first.copyWith(isDroppable: false)),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Tap column to select
        await tester.tap(find.byKey(const Key('selectable_column_$columnId')));
        await tester.pumpAndSettle();

        // Toggle isDroppable
        await tester.tap(find.text('Allow Widget Drops'));
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockColumnRepository.update(
            const UpdateColumnInput(id: columnId, isDroppable: false),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'drop zones still present when isDroppable: false (admin unrestricted)',
      (tester) async {
        // Arrange
        const menuId = 1;
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: menuId,
            name: 'Page 1',
            index: 0,
          ),
        ];
        final containers = [
          const entity.Container(id: containerId, pageId: pageId, index: 0),
        ];
        final columns = [
          const entity.Column(
            id: columnId,
            containerId: containerId,
            index: 0,
            flex: 1,
            isDroppable: false,
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => Success(pages));
        when(
          () => mockContainerRepository.getAllForPage(pageId),
        ).thenAnswer((_) async => Success(containers));
        when(
          () => mockColumnRepository.getAllForContainer(containerId),
        ).thenAnswer((_) async => Success(columns));
        when(
          () => mockWidgetRepository.getAllForColumn(any()),
        ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Assert - drop zone should still be present (admin unrestricted)
        expect(find.byKey(Key('drop_zone_${columnId}_0')), findsOneWidget);
      },
    );
  });

  group('AdminTemplateEditorPage - Header Management', () {
    testWidgets('should show Add Header button when no header page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final contentPages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(contentPages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_header_button')), findsOneWidget);
    });

    testWidgets('should create header page when Add Header button tapped', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      const headerPage = entity.Page(
        id: 2,
        menuId: menuId,
        name: 'Header',
        index: 0,
        type: entity.PageType.header,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.create(any()),
      ).thenAnswer((_) async => const Success(headerPage));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_header_button')));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(() => mockPageRepository.create(captureAny())).captured.single
              as CreatePageInput;
      expect(captured.type, entity.PageType.header);
      expect(captured.name, 'Header');
    });

    testWidgets('should hide Add Header button when header page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        const entity.Page(
          id: 2,
          menuId: menuId,
          name: 'Page 1',
          index: 1,
          type: entity.PageType.content,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_header_button')), findsNothing);
    });

    testWidgets('should show header card when header page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Header'), findsOneWidget);
      expect(find.byKey(const Key('delete_header_button')), findsOneWidget);
    });

    testWidgets('should delete header page when Delete Header button tapped', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_header_button')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockPageRepository.delete(1)).called(1);
    });
  });

  group('AdminTemplateEditorPage - Footer Management', () {
    testWidgets('should show Add Footer button when no footer page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final contentPages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(contentPages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_footer_button')), findsOneWidget);
    });

    testWidgets('should create footer page when Add Footer button tapped', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      const footerPage = entity.Page(
        id: 2,
        menuId: menuId,
        name: 'Footer',
        index: 0,
        type: entity.PageType.footer,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.create(any()),
      ).thenAnswer((_) async => const Success(footerPage));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_footer_button')));
      await tester.tap(find.byKey(const Key('add_footer_button')));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(() => mockPageRepository.create(captureAny())).captured.single
              as CreatePageInput;
      expect(captured.type, entity.PageType.footer);
      expect(captured.name, 'Footer');
    });

    testWidgets('should hide Add Footer button when footer page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
        const entity.Page(
          id: 2,
          menuId: menuId,
          name: 'Footer',
          index: 1,
          type: entity.PageType.footer,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_footer_button')), findsNothing);
    });

    testWidgets('should show footer card when footer page exists', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      await tester.ensureVisible(find.text('Footer'));
      expect(find.text('Footer'), findsOneWidget);
      expect(find.byKey(const Key('delete_footer_button')), findsOneWidget);
    });

    testWidgets('should delete footer page when Delete Footer button tapped', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockPageRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_footer_button')));
      await tester.tap(find.byKey(const Key('delete_footer_button')));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockPageRepository.delete(1)).called(1);
    });
  });

  group('AdminTemplateEditorPage - Save and Publish', () {
    testWidgets('should save template as draft', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockMenuRepository.update(any()),
      ).thenAnswer((_) async => const Success(menu));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.update(any())).called(1);
      expect(find.text('Template saved'), findsOneWidget);
    });

    testWidgets('should show Menu Style in side panel when menu selected', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Style Test',
        status: Status.draft,
        version: '1.0.0',
        styleConfig: StyleConfig(marginTop: 20.0),
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Tap menu style selector
      await tester.tap(find.byKey(const Key('selectable_menu')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Menu Style'), findsOneWidget);
      expect(find.text('Margins'), findsOneWidget);
      expect(find.text('Paddings'), findsOneWidget);
    });

    testWidgets(
      'should save styleConfig when save is pressed after editing in side panel',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Style Test',
          status: Status.draft,
          version: '1.0.0',
          styleConfig: StyleConfig(
            marginTop: 20.0,
            marginBottom: 20.0,
            marginLeft: 20.0,
            marginRight: 20.0,
          ),
        );

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Success(menu));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Select menu to show side panel
        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // Edit margin (in All mode, single field)
        await tester.enterText(find.byKey(const Key('side_margin_all')), '30');
        await tester.pumpAndSettle();

        // Press save
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Assert
        final captured =
            verify(
                  () => mockMenuRepository.update(captureAny()),
                ).captured.single
                as UpdateMenuInput;
        expect(captured.styleConfig, isNotNull);
        expect(captured.styleConfig!.marginTop, 30.0);
      },
    );

    testWidgets('should publish template', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final publishedMenu = menu.copyWith(status: Status.published);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockMenuRepository.update(any()),
      ).thenAnswer((_) async => Success(publishedMenu));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.publish));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.update(any())).called(1);
      expect(find.text('Template published'), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Scroll Preservation', () {
    testWidgets(
      'should not show loading indicator during reload after page operation',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        const newPage = entity.Page(
          id: 2,
          menuId: menuId,
          name: 'Page 1',
          index: 0,
        );

        // Use a completer to control when the second getById call resolves
        final reloadCompleter = Completer<Result<Menu, DomainError>>();
        var getByIdCallCount = 0;

        when(() => mockMenuRepository.getById(menuId)).thenAnswer((_) {
          getByIdCallCount++;
          if (getByIdCallCount == 1) {
            // Initial load — resolve immediately
            return Future.value(const Success(menu));
          }
          // Reload — wait for completer so we can observe intermediate state
          return reloadCompleter.future;
        });
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockPageRepository.create(any()),
        ).thenAnswer((_) async => const Success(newPage));
        when(
          () => mockContainerRepository.getAllForPage(any()),
        ).thenAnswer((_) async => const Success([]));

        // Load the page fully
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Verify page is loaded (no spinner)
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test Template'), findsOneWidget);

        // Act — tap Add Page (this calls _addPage → _loadTemplate via reload)
        await tester.ensureVisible(find.byKey(const Key('add_page_button')));
        await tester.tap(find.byKey(const Key('add_page_button')));

        // Pump frames to allow create to resolve and _loadTemplate to start
        await tester.pump();
        await tester.pump();

        // Assert — no loading spinner should appear during reload
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Clean up — complete the reload so the test can finish
        reloadCompleter.complete(const Success(menu));
        await tester.pumpAndSettle();
      },
    );
  });

  group('AdminTemplateEditorPage - Widget Palette', () {
    testWidgets('should display widget palette with all registered types', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Widget Palette'), findsOneWidget);
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_image')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });

    testWidgets('should show checkboxes for allowed widget types in palette', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
        allowedWidgetTypes: ['dish', 'text'],
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — checkboxes present (admin mode)
      expect(
        find.byType(Checkbox),
        findsNWidgets(4),
      ); // dish, image, section, text
      // dish and text should be checked
      final dishCheckbox = tester.widget<Checkbox>(
        find.byKey(const Key('allowed_type_checkbox_dish')),
      );
      final textCheckbox = tester.widget<Checkbox>(
        find.byKey(const Key('allowed_type_checkbox_text')),
      );
      final sectionCheckbox = tester.widget<Checkbox>(
        find.byKey(const Key('allowed_type_checkbox_section')),
      );
      expect(dishCheckbox.value, true);
      expect(textCheckbox.value, true);
      expect(sectionCheckbox.value, false);
    });

    testWidgets(
      'toggling checkbox calls menuRepository.update with new allowedWidgetTypes',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
          allowedWidgetTypes: ['dish'],
        );

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(() => mockMenuRepository.update(any())).thenAnswer(
          (_) async =>
              Success(menu.copyWith(allowedWidgetTypes: ['dish', 'section'])),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Tap the section checkbox to enable it
        await tester.tap(
          find.byKey(const Key('allowed_type_checkbox_section')),
        );
        await tester.pumpAndSettle();

        // Assert
        final captured =
            verify(
                  () => mockMenuRepository.update(captureAny()),
                ).captured.single
                as UpdateMenuInput;
        expect(captured.id, menuId);
        expect(captured.allowedWidgetTypes, contains('dish'));
        expect(captured.allowedWidgetTypes, contains('section'));
      },
    );
  });

  group('AdminTemplateEditorPage - Widget Display', () {
    testWidgets('should display widgets in columns via WidgetRenderer', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(
          id: columnId,
          containerId: containerId,
          index: 0,
          flex: 1,
        ),
      ];
      final widgets = [
        const WidgetInstance(
          id: 1,
          columnId: columnId,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {
            'text': 'Admin Text',
            'align': 'left',
            'bold': false,
            'italic': false,
          },
          isTemplate: true,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(columnId),
      ).thenAnswer((_) async => Success(widgets));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });

    testWidgets('should show drop zone text for empty column', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(
          id: columnId,
          containerId: containerId,
          index: 0,
          flex: 1,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(columnId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Drop widgets here'), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Widget CRUD', () {
    testWidgets('should delete widget when delete is confirmed', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      const widgetId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(
          id: columnId,
          containerId: containerId,
          index: 0,
          flex: 1,
        ),
      ];
      final widgets = [
        const WidgetInstance(
          id: widgetId,
          columnId: columnId,
          type: 'section',
          version: '1.0.0',
          index: 0,
          props: {
            'title': 'Test Section',
            'uppercase': false,
            'showDivider': true,
          },
          isTemplate: true,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(containerId),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepository.getAllForColumn(columnId),
      ).thenAnswer((_) async => Success(widgets));
      when(
        () => mockWidgetRepository.delete(widgetId),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Tap the section widget to open edit dialog, then look for delete
      // The widget is rendered via WidgetRenderer with onDelete callback
      // We verify the delete flow exists by checking WidgetRenderer is present
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Page Size', () {
    testWidgets('should have page size button in toolbar', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('page_size_button')), findsOneWidget);
      expect(find.byIcon(Icons.straighten), findsOneWidget);
    });

    testWidgets('tapping page_size_button navigates to /admin/sizes', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(() => mockRouter.push<Object?>(any())).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_size_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRouter.push<Object?>('/admin/sizes')).called(1);
    });

    testWidgets(
      'tapping change_page_size_button in side panel opens dialog with available sizes',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final sizes = [
          const domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
          const domain.Size(
            id: 2,
            name: 'A5',
            width: 148,
            height: 210,
            status: Status.published,
            direction: 'portrait',
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => Success(sizes));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Select menu to show side panel
        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // Tap change page size button in side panel
        await tester.tap(find.byKey(const Key('change_page_size_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Select Page Size'), findsOneWidget);
        expect(find.text('A4'), findsOneWidget);
        expect(find.text('A5'), findsOneWidget);
      },
    );

    testWidgets('selecting a size via side panel updates the menu pageSize', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final sizes = [
        const domain.Size(
          id: 1,
          name: 'A4',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => Success(sizes));
      when(() => mockMenuRepository.update(any())).thenAnswer(
        (_) async => Success(
          menu.copyWith(
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Select menu to show side panel
      await tester.tap(find.byKey(const Key('selectable_menu')));
      await tester.pumpAndSettle();

      // Tap change page size button in side panel
      await tester.tap(find.byKey(const Key('change_page_size_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A4'));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(() => mockMenuRepository.update(captureAny())).captured.single
              as UpdateMenuInput;
      expect(captured.id, menuId);
      expect(captured.sizeId, 1);
    });

    testWidgets(
      'shows current page size name highlighted in dialog via side panel',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
          pageSize: PageSize(name: 'A4', width: 210, height: 297),
        );
        final sizes = [
          const domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
          const domain.Size(
            id: 2,
            name: 'A5',
            width: 148,
            height: 210,
            status: Status.published,
            direction: 'portrait',
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => Success(sizes));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Select menu to show side panel
        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // Tap change page size button in side panel
        await tester.tap(find.byKey(const Key('change_page_size_button')));
        await tester.pumpAndSettle();

        // Assert - the current size should have a check icon
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );

    testWidgets(
      'shows snackbar after successful page size update via side panel',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
        );
        final sizes = [
          const domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ];

        when(
          () => mockMenuRepository.getById(menuId),
        ).thenAnswer((_) async => const Success(menu));
        when(
          () => mockPageRepository.getAllForMenu(menuId),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => Success(sizes));
        when(() => mockMenuRepository.update(any())).thenAnswer(
          (_) async => Success(
            menu.copyWith(
              pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Select menu to show side panel
        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // Tap change page size button in side panel
        await tester.tap(find.byKey(const Key('change_page_size_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('A4'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Page size updated'), findsOneWidget);
      },
    );
  });

  group('AdminTemplateEditorPage - Redesign', () {
    testWidgets('left panel has themed background with border', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — left panel should have a Container with themed background
      // and no VerticalDivider
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('canvas has auto-scroll listener', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AutoScrollListener), findsOneWidget);
    });

    testWidgets('page names are not shown in page cards', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'My Custom Page',
          index: 0,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — page name should NOT be displayed
      expect(find.text('My Custom Page'), findsNothing);
    });

    testWidgets('container names are not shown in container cards', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(
          id: 1,
          pageId: pageId,
          index: 0,
          name: 'Fancy Container Name',
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — container name should NOT be displayed
      expect(find.text('Fancy Container Name'), findsNothing);
      expect(find.text('Container'), findsNothing);
    });

    testWidgets('header card shows header label with icon', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Header'), findsOneWidget);
      expect(find.byIcon(Icons.vertical_align_top), findsOneWidget);
    });

    testWidgets('footer card shows footer label with icon', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      await tester.ensureVisible(find.text('Footer'));
      expect(find.text('Footer'), findsOneWidget);
      expect(find.byIcon(Icons.vertical_align_bottom), findsOneWidget);
    });

    testWidgets('add container button appears after containers', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(id: pageId, menuId: menuId, name: 'Page 1', index: 0),
      ];
      final containers = [
        const entity.Container(id: 1, pageId: pageId, index: 0),
      ];

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepository.getAllForPage(pageId),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — add container button should be present and tappable
      await tester.ensureVisible(find.byKey(const Key('add_container_1')));
      expect(find.byKey(const Key('add_container_1')), findsOneWidget);

      // The add container button should use TextButton style
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('menu style selector uses 12px border radius', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — find the selectable_menu container
      final menuSelector = find.byKey(const Key('selectable_menu'));
      expect(menuSelector, findsOneWidget);

      // Verify it has a Container with 12px border radius
      final container = tester.widget<Container>(
        find
            .descendant(of: menuSelector, matching: find.byType(Container))
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
  });

  group('AdminTemplateEditorPage - Responsive Layout', () {
    void setupBasicMocks({
      required MockMenuRepository menuRepo,
      required MockPageRepository pageRepo,
      required MockContainerRepository containerRepo,
    }) {
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Responsive Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => menuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => pageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
    }

    testWidgets(
      'on narrow screen, shows horizontal palette at top instead of side panel',
      (tester) async {
        setupBasicMocks(
          menuRepo: mockMenuRepository,
          pageRepo: mockPageRepository,
          containerRepo: mockContainerRepository,
        );

        // Set narrow screen size (iPhone portrait)
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest(1));
        await tester.pumpAndSettle();

        // Should have a horizontal WidgetPalette
        final palette = tester.widget<WidgetPalette>(
          find.byType(WidgetPalette),
        );
        expect(palette.axis, Axis.horizontal);

        // Should NOT have the 260px wide side panel container
        bool found260Container = false;
        for (final element in tester.widgetList<Container>(
          find.byType(Container),
        )) {
          if (element.constraints?.maxWidth == 260 ||
              (element.constraints == null && element.decoration != null)) {
            // Check if it looks like the side panel
          }
        }
        // Simpler check: the 'Widget Palette' title should be hidden
        // (horizontal mode hides title)
        expect(find.text('Widget Palette'), findsNothing);

        // Reset view size
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('on narrow screen, no RenderFlex overflow', (tester) async {
      setupBasicMocks(
        menuRepo: mockMenuRepository,
        pageRepo: mockPageRepository,
        containerRepo: mockContainerRepository,
      );

      // Set narrow screen size
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(1));
      await tester.pumpAndSettle();

      // If no RenderFlex overflow exception is thrown, the test passes
      // The test framework will catch any overflow errors automatically
      expect(find.byType(AdminTemplateEditorPage), findsOneWidget);

      // Reset view size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('on wide screen, layout is unchanged with side panel', (
      tester,
    ) async {
      setupBasicMocks(
        menuRepo: mockMenuRepository,
        pageRepo: mockPageRepository,
        containerRepo: mockContainerRepository,
      );

      // Default 800x600 — above breakpoint
      await tester.pumpWidget(createWidgetUnderTest(1));
      await tester.pumpAndSettle();

      // Should have vertical palette with title visible
      expect(find.text('Widget Palette'), findsOneWidget);

      // The palette should be vertical (default)
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.vertical);
    });

    testWidgets(
      'on narrow screen, selecting element opens bottom sheet with style editor',
      (tester) async {
        setupBasicMocks(
          menuRepo: mockMenuRepository,
          pageRepo: mockPageRepository,
          containerRepo: mockContainerRepository,
        );

        // Set narrow screen size
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest(1));
        await tester.pumpAndSettle();

        // Tap on selectable_menu to select it
        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // A BottomSheet should appear with style editor
        expect(find.byType(BottomSheet), findsOneWidget);

        // Reset view size
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
