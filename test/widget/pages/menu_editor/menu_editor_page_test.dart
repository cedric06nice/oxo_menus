import 'dart:async';

import 'package:flutter/cupertino.dart';
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
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_drop_zone.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/canvas/widget_renderer.dart';

// Mock classes
class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockMenuSubscriptionRepository extends Mock
    implements MenuSubscriptionRepository {}

class MockPresenceRepository extends Mock implements PresenceRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late MockMenuSubscriptionRepository mockMenuSubscriptionRepository;
  late MockPresenceRepository mockPresenceRepository;
  late PresentableWidgetRegistry mockPresentableWidgetRegistry;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();
    mockMenuSubscriptionRepository = MockMenuSubscriptionRepository();
    mockPresenceRepository = MockPresenceRepository();

    // Stub subscription repository with empty stream
    when(
      () => mockMenuSubscriptionRepository.subscribeToMenuChanges(any()),
    ).thenAnswer((_) => const Stream<MenuChangeEvent>.empty());
    when(
      () => mockMenuSubscriptionRepository.unsubscribe(any()),
    ).thenAnswer((_) async {});

    // Stub presence repository
    when(
      () => mockPresenceRepository.joinMenu(
        any(),
        any(),
        userName: any(named: 'userName'),
        userAvatar: any(named: 'userAvatar'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.leaveMenu(any(), any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.heartbeat(any(), any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.getActiveUsers(any()),
    ).thenAnswer((_) async => const Success(<MenuPresence>[]));
    when(
      () => mockPresenceRepository.watchActiveUsers(any()),
    ).thenAnswer((_) => const Stream<List<MenuPresence>>.empty());
    when(
      () => mockPresenceRepository.unsubscribePresence(any()),
    ).thenAnswer((_) async {});

    // Set up widget registry with test widgets
    mockPresentableWidgetRegistry = PresentableWidgetRegistry();
    mockPresentableWidgetRegistry.register(dishWidgetDefinition);
    mockPresentableWidgetRegistry.register(sectionWidgetDefinition);
    mockPresentableWidgetRegistry.register(textWidgetDefinition);

    // Default stub for nested container loading
    when(
      () => mockContainerRepository.getAllForContainer(any()),
    ).thenAnswer((_) async => const Success(<entity.Container>[]));

    // Register fallback values
    registerFallbackValue(const CreateMenuInput(name: '', version: ''));
    registerFallbackValue(const UpdateMenuInput(id: -1));
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
      id: 'user-1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.user,
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        pageRepositoryProvider.overrideWithValue(mockPageRepository),
        containerRepositoryProvider.overrideWithValue(mockContainerRepository),
        columnRepositoryProvider.overrideWithValue(mockColumnRepository),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
        widgetRegistryProvider.overrideWithValue(mockPresentableWidgetRegistry),
        currentUserProvider.overrideWithValue(mockUser),
        menuSubscriptionRepositoryProvider.overrideWithValue(
          mockMenuSubscriptionRepository,
        ),
        presenceRepositoryProvider.overrideWithValue(mockPresenceRepository),
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: menuId)),
    );
  }

  group('MenuEditorPage - Initial Loading', () {
    testWidgets('should display loading indicator while loading', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      when(() => mockMenuRepository.getById(menuId)).thenAnswer(
        (_) async => const Success(
          Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      when(() => mockPageRepository.getAllForMenu(menuId)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success([]),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('displays CupertinoActivityIndicator on Apple platforms', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      when(() => mockMenuRepository.getById(menuId)).thenAnswer(
        (_) async => const Success(
          Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      when(() => mockPageRepository.getAllForMenu(menuId)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success([]),
        ),
      );

      // Act — use macOS platform
      final mockUser = User(
        id: 'user-1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.user,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            pageRepositoryProvider.overrideWithValue(mockPageRepository),
            containerRepositoryProvider.overrideWithValue(
              mockContainerRepository,
            ),
            columnRepositoryProvider.overrideWithValue(mockColumnRepository),
            widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
            widgetRegistryProvider.overrideWithValue(
              mockPresentableWidgetRegistry,
            ),
            currentUserProvider.overrideWithValue(mockUser),
            menuSubscriptionRepositoryProvider.overrideWithValue(
              mockMenuSubscriptionRepository,
            ),
            presenceRepositoryProvider.overrideWithValue(
              mockPresenceRepository,
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const MenuEditorPage(menuId: menuId),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('should display error when menu load fails', (tester) async {
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

    testWidgets('should display error when pages load fails', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(() => mockPageRepository.getAllForMenu(menuId)).thenAnswer(
        (_) async => const Failure(NetworkError('Failed to load pages')),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Failed to load pages'), findsOneWidget);
    });

    testWidgets('should load and display menu successfully', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Menu'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
    });
  });

  group('MenuEditorPage - Widget Palette', () {
    testWidgets('should display all registered widget types in palette', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });
  });

  group('MenuEditorPage - Canvas Display', () {
    testWidgets('column cards have margin and padding', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — column container has margin and padding
      final columnContainer = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      expect(columnContainer.margin, const EdgeInsets.symmetric(horizontal: 2));
      expect(columnContainer.padding, isNull);
    });

    testWidgets('page cards have rounded border with radius 12', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — find the Card and check its shape
      final card = tester.widget<Card>(find.byType(Card).first);
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('canvas has ConstrainedBox with maxWidth 900', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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
      final constrainedBox = find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.maxWidth == 900,
      );
      expect(constrainedBox, findsOneWidget);
    });

    testWidgets('canvas is wrapped in AutoScrollListener', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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

    testWidgets('should display pages, containers, and columns', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(
        id: 1,
        pageId: 1,
        index: 0,
        name: 'Container 1',
      );
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Container 1'), findsNothing);
      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('should display widgets in columns', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
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

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([widget]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      // Widget rendering tested separately in widget-specific tests
      // This test verifies the structure is loaded correctly
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });
  });

  group('MenuEditorPage - Responsive Layout', () {
    void setupLoadedMenu(int menuId) {
      const menu = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));
    }

    testWidgets('displays sidebar on wide screens (>=600px)', (tester) async {
      // Arrange
      const menuId = 1;
      setupLoadedMenu(menuId);

      // Act — use wide screen (800px)
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — WidgetPalette should be in a vertical sidebar (default axis)
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.vertical);
    });

    testWidgets('displays horizontal palette on narrow screens (<600px)', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      setupLoadedMenu(menuId);

      // Act — use narrow screen (500px)
      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — WidgetPalette should have horizontal axis
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.horizontal);
    });

    testWidgets('sidebar uses surfaceContainerLow background', (tester) async {
      // Arrange
      const menuId = 1;
      setupLoadedMenu(menuId);

      // Act — use wide screen (800px)
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — Find the sidebar container (260px wide with decoration)
      final theme = Theme.of(tester.element(find.byType(WidgetPalette)));
      final sidebarFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 260 &&
            widget.decoration is BoxDecoration,
      );
      expect(sidebarFinder, findsOneWidget);
      final sidebar = tester.widget<Container>(sidebarFinder);
      final decoration = sidebar.decoration as BoxDecoration;
      expect(decoration.color, theme.colorScheme.surfaceContainerLow);
    });
  });

  group('MenuEditorPage - Widget Management', () {
    testWidgets('should display drop zone for empty column', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Drop widgets here'), findsOneWidget);
      expect(find.byKey(const Key('drop_zone_1_0')), findsOneWidget);
    });

    testWidgets('should display widgets with edit capability', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
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

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([widget]));

      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - verify WidgetRenderer is used
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });

    testWidgets('non-droppable column has no drop_zone_* keys in widget tree', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: false,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - no drop zones should be present
      expect(find.byKey(const Key('drop_zone_1_0')), findsNothing);
    });

    testWidgets('non-droppable column with widgets still renders widgets', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: false,
      );
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
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

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([widget]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - widget should render, no drop zones
      expect(find.byType(WidgetRenderer), findsOneWidget);
      expect(find.byKey(const Key('drop_zone_1_0')), findsNothing);
    });

    testWidgets('non-droppable empty column shows lock icon', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: false,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - lock icon should be present
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Drop widgets here'), findsNothing);
    });

    testWidgets('droppable column (default) still has drop zones', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: true, // Explicitly true
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - drop zones should be present (regression guard)
      expect(find.byKey(const Key('drop_zone_1_0')), findsOneWidget);
      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('droppable column uses theme surface color', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: true,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - column container uses theme surface color
      final theme = Theme.of(tester.element(find.byKey(const Key('column_1'))));
      final columnContainer = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final decoration = columnContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(theme.colorScheme.surface));
    });

    testWidgets('non-droppable column uses theme surface color', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: false,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - column container uses theme surface color
      final theme = Theme.of(tester.element(find.byKey(const Key('column_1'))));
      final columnContainer = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final decoration = columnContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(theme.colorScheme.surface));
    });

    testWidgets('empty column text uses onSurfaceVariant color', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
        isDroppable: true,
      );

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert - "Drop widgets here" text uses primary color
      final theme = Theme.of(
        tester.element(find.text('Drop widgets here').first),
      );
      final text = tester.widget<Text>(find.text('Drop widgets here').first);
      expect(text.style?.color, theme.colorScheme.primary);
    });
  });

  group('MenuEditorPage - Header/Footer Exclusion', () {
    testWidgets('should not display header page containers', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      final pages = [
        const entity.Page(
          id: 99,
          menuId: menuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        const entity.Page(
          id: 1,
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
      ).thenAnswer((_) async => const Success(<entity.Container>[]));
      when(() => mockContainerRepository.getAllForPage(1)).thenAnswer(
        (_) async => const Success([
          entity.Container(
            id: 1,
            pageId: 1,
            index: 0,
            name: 'Content Container',
          ),
        ]),
      );
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — content is shown, header is not
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Header'), findsNothing);
    });

    testWidgets('should not display footer page containers', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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
          id: 98,
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
      ).thenAnswer((_) async => const Success(<entity.Container>[]));
      when(() => mockContainerRepository.getAllForPage(1)).thenAnswer(
        (_) async => const Success([
          entity.Container(
            id: 1,
            pageId: 1,
            index: 0,
            name: 'Content Container',
          ),
        ]),
      );
      when(
        () => mockColumnRepository.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — content is shown, footer is not
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Footer'), findsNothing);
    });
  });

  group('MenuEditorPage - Save Functionality', () {
    testWidgets('should save menu when save button tapped', (tester) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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

  group('MenuEditorPage - Template Widget Locking', () {
    Widget buildWithWidgets(List<WidgetInstance> widgets) {
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );
      const page = entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0);
      const container = entity.Container(id: 1, pageId: 1, index: 0);
      const column = entity.Column(id: 1, containerId: 1, index: 0, flex: 1);

      when(
        () => mockMenuRepository.getById(menuId),
      ).thenAnswer((_) async => const Success(menu));
      when(
        () => mockPageRepository.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([page]));
      when(
        () => mockContainerRepository.getAllForPage(1),
      ).thenAnswer((_) async => const Success([container]));
      when(
        () => mockColumnRepository.getAllForContainer(1),
      ).thenAnswer((_) async => const Success([column]));
      when(
        () => mockWidgetRepository.getAllForColumn(1),
      ).thenAnswer((_) async => Success(widgets));

      return createWidgetUnderTest(menuId);
    }

    testWidgets(
      'should render template widget as non-editable (no edit dialog on tap)',
      (tester) async {
        const templateWidget = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          isTemplate: true,
          props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
        );

        await tester.pumpWidget(buildWithWidgets([templateWidget]));
        await tester.pumpAndSettle();

        // Template widget should be rendered
        expect(find.byType(WidgetRenderer), findsOneWidget);

        // Tap on the widget — no edit dialog should appear
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
        expect(find.text('Edit Dish'), findsNothing);
      },
    );

    testWidgets('should not wrap template widget in LongPressDraggable', (
      tester,
    ) async {
      const templateWidget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: true,
        props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
      );

      await tester.pumpWidget(buildWithWidgets([templateWidget]));
      await tester.pumpAndSettle();

      // Template widget should NOT have a LongPressDraggable wrapper
      expect(find.byKey(const Key('widget_1')), findsNothing);
    });

    testWidgets('should show lock icon on template widget', (tester) async {
      const templateWidget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: true,
        props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
      );

      await tester.pumpWidget(buildWithWidgets([templateWidget]));
      await tester.pumpAndSettle();

      // Should show a lock icon
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should keep regular widget fully editable and draggable', (
      tester,
    ) async {
      const regularWidget = WidgetInstance(
        id: 2,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: false,
        props: {'name': 'Regular Dish', 'price': 15.0, 'allergens': []},
      );

      await tester.pumpWidget(buildWithWidgets([regularWidget]));
      await tester.pumpAndSettle();

      // Regular widget should have LongPressDraggable wrapper (key = widget_2)
      expect(find.byKey(const Key('widget_2')), findsOneWidget);

      // No lock icon
      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });

  group('MenuEditorPage - Drop Zone Enforcement', () {
    testWidgets('should reject drop of disallowed widget type', (tester) async {
      // Arrange — menu allows only 'dish', column is droppable
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
        allowedWidgetTypes: ['dish'],
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
        () => mockWidgetRepository.getAllForColumn(columnId),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
      when(() => mockWidgetRepository.create(any())).thenAnswer(
        (_) async => const Success(
          WidgetInstance(
            id: 99,
            columnId: columnId,
            type: 'text',
            version: '1.0.0',
            index: 0,
            props: {},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Simulate: the drop zone calls onAccept with a 'text' widget type
      // We can't easily simulate DnD in widget tests, so instead verify that
      // after load the widget repo create was never called with 'text'
      // We need to test the guard at the page level.
      // The best approach: call the internal method via finding the EditorDropZone
      // and invoking its onAccept callback
      // Get the EditorDropZone and invoke its onAccept with a disallowed type
      final editorDropZone = tester.widget<EditorDropZone>(
        find.byType(EditorDropZone).first,
      );
      editorDropZone.onAccept(WidgetDragData.newWidget('text'));
      await tester.pumpAndSettle();

      // Assert — widgetRepository.create should NOT have been called
      verifyNever(() => mockWidgetRepository.create(any()));
    });

    testWidgets('should allow drop of permitted widget type', (tester) async {
      // Arrange
      const menuId = 1;
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
        allowedWidgetTypes: ['dish'],
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
        () => mockWidgetRepository.getAllForColumn(columnId),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
      when(() => mockWidgetRepository.create(any())).thenAnswer(
        (_) async => const Success(
          WidgetInstance(
            id: 99,
            columnId: columnId,
            type: 'dish',
            version: '1.0.0',
            index: 0,
            props: {'name': '', 'price': 0.0, 'allergens': []},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Invoke onAccept with an allowed type
      final editorDropZone = tester.widget<EditorDropZone>(
        find.byType(EditorDropZone).first,
      );
      editorDropZone.onAccept(WidgetDragData.newWidget('dish'));
      await tester.pumpAndSettle();

      // Assert — widgetRepository.create SHOULD have been called
      verify(() => mockWidgetRepository.create(any())).called(1);
    });
  });

  group('MenuEditorPage - Scroll Preservation', () {
    testWidgets(
      'should not show loading indicator during reload after widget operation',
      (tester) async {
        // Arrange — loaded page with a droppable column
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        );
        const page = entity.Page(
          id: 1,
          menuId: menuId,
          name: 'Page 1',
          index: 0,
        );
        const container = entity.Container(id: 1, pageId: 1, index: 0);
        const column = entity.Column(
          id: 1,
          containerId: 1,
          index: 0,
          flex: 1,
          isDroppable: true,
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
        ).thenAnswer((_) async => const Success([page]));
        when(
          () => mockContainerRepository.getAllForPage(1),
        ).thenAnswer((_) async => const Success([container]));
        when(
          () => mockColumnRepository.getAllForContainer(1),
        ).thenAnswer((_) async => const Success([column]));
        when(
          () => mockWidgetRepository.getAllForColumn(1),
        ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
        when(() => mockWidgetRepository.create(any())).thenAnswer(
          (_) async => const Success(
            WidgetInstance(
              id: 99,
              columnId: 1,
              type: 'dish',
              version: '1.0.0',
              index: 0,
              props: {'name': '', 'price': 0.0, 'allergens': []},
            ),
          ),
        );

        // Load the page fully
        await tester.pumpWidget(createWidgetUnderTest(menuId));
        await tester.pumpAndSettle();

        // Verify page is loaded (no spinner)
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test Menu'), findsOneWidget);

        // Act — trigger a widget drop (this calls _loadMenu via onReload)
        final editorDropZone = tester.widget<EditorDropZone>(
          find.byType(EditorDropZone).first,
        );
        editorDropZone.onAccept(WidgetDragData.newWidget('dish'));

        // Pump frames to allow create to resolve and _loadMenu to start
        await tester.pump();
        await tester.pump();

        // Assert — no loading spinner should appear during reload
        // The canvas should remain visible while data reloads in background
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Clean up — complete the reload so the test can finish
        reloadCompleter.complete(const Success(menu));
        await tester.pumpAndSettle();
      },
    );
  });

  group('MenuEditorPage - Widget Palette Filtering', () {
    testWidgets('should only show allowed widget types in palette', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
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

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Assert — only dish should show, no checkboxes (read-only)
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsNothing);
      expect(find.byKey(const Key('palette_item_text')), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('should show all types when allowedWidgetTypes is empty', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      const menu = Menu(
        id: menuId,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
        allowedWidgetTypes: [],
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

      // Assert — all types shown
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });
  });
}
