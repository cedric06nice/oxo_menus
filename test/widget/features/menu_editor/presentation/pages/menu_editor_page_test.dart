import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu_editor/presentation/pages/menu_editor_page.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/auto_scroll_listener.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_drop_zone.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_drag_data.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_palette.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/text_widget/text_widget_definition.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Fake repository that introduces an artificial delay to expose loading state
// ---------------------------------------------------------------------------

class _SlowMenuRepository implements MenuRepository {
  final Duration delay;
  final Menu menu;

  const _SlowMenuRepository({required this.delay, required this.menu});

  @override
  Future<Result<Menu, DomainError>> getById(int id) async {
    await Future<void>.delayed(delay);
    return Success(menu);
  }

  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async =>
      throw StateError('not used');

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async => throw StateError('not used');

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async =>
      throw StateError('not used');

  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
}

// ---------------------------------------------------------------------------
// Fake repository that delegates getById via a provided callback
// ---------------------------------------------------------------------------

class _ControllableMenuRepository implements MenuRepository {
  final Future<Result<Menu, DomainError>> Function(int) onGetById;

  const _ControllableMenuRepository({required this.onGetById});

  @override
  Future<Result<Menu, DomainError>> getById(int id) => onGetById(id);

  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async =>
      throw StateError('not used');

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async => throw StateError('not used');

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async =>
      throw StateError('not used');

  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _testUser = User(
  id: 'user-1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  role: UserRole.user,
);

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeContainerRepository fakeContainerRepo;
  late FakeColumnRepository fakeColumnRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late FakeMenuSubscriptionRepository fakeSubRepo;
  late FakePresenceRepository fakePresenceRepo;
  late PresentableWidgetRegistry registry;

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakePageRepo = FakePageRepository();
    fakeContainerRepo = FakeContainerRepository();
    fakeColumnRepo = FakeColumnRepository();
    fakeWidgetRepo = FakeWidgetRepository();
    fakeSubRepo = FakeMenuSubscriptionRepository();
    fakePresenceRepo = FakePresenceRepository();

    fakePresenceRepo.whenJoinMenu(success(null));
    fakePresenceRepo.whenLeaveMenu(success(null));
    fakePresenceRepo.whenHeartbeat(success(null));
    fakePresenceRepo.whenGetActiveUsersDefault(success([]));

    // Default: nested containers return empty
    fakeContainerRepo.whenGetAllForContainer(success([]));

    registry = PresentableWidgetRegistry();
    registry.register(dishWidgetDefinition);
    registry.register(sectionWidgetDefinition);
    registry.register(textWidgetDefinition);
  });

  tearDown(() {
    fakeSubRepo.dispose();
    fakePresenceRepo.dispose();
  });

  Widget buildPage(int menuId, {MenuRepository? menuRepoOverride}) {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(
          menuRepoOverride ?? fakeMenuRepo,
        ),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        widgetRegistryProvider.overrideWithValue(registry),
        currentUserProvider.overrideWithValue(_testUser),
        menuSubscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        presenceRepositoryProvider.overrideWithValue(fakePresenceRepo),
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: menuId)),
    );
  }

  // --------------------------------------------------------------------------
  // Initial Loading
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Initial Loading', () {
    testWidgets('should display loading indicator while loading', (
      tester,
    ) async {
      // Arrange — slow menu repo delays visibility of loading spinner
      const menuId = 1;
      final slowRepo = _SlowMenuRepository(
        delay: const Duration(milliseconds: 100),
        menu: const Menu(
          id: menuId,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId, menuRepoOverride: slowRepo));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('displays CupertinoActivityIndicator on Apple platforms', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      final slowRepo = _SlowMenuRepository(
        delay: const Duration(milliseconds: 100),
        menu: const Menu(
          id: menuId,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(slowRepo),
            pageRepositoryProvider.overrideWithValue(fakePageRepo),
            containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
            columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
            widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
            widgetRegistryProvider.overrideWithValue(registry),
            currentUserProvider.overrideWithValue(_testUser),
            menuSubscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
            presenceRepositoryProvider.overrideWithValue(fakePresenceRepo),
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

      await tester.pumpAndSettle();
    });

    testWidgets('should display error when menu load fails', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(failure(const NotFoundError('Menu not found')));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Menu not found'), findsOneWidget);
    });

    testWidgets('should display error when pages load fails', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        failure(const NetworkError('Failed to load pages')),
      );

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Failed to load pages'), findsOneWidget);
    });

    testWidgets('should load and display menu successfully', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Menu'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Widget Palette
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Widget Palette', () {
    testWidgets('should display all registered widget types in palette', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Widget Palette'), findsOneWidget);
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Canvas Display
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Canvas Display', () {
    testWidgets('column cards have margin and padding', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([const entity.Container(id: 1, pageId: 1, index: 0)]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          const entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
        ]),
      );
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
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
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      final card = tester.widget<Card>(find.byType(Card).first);
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('canvas has ConstrainedBox with maxWidth 900', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
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
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AutoScrollListener), findsOneWidget);
    });

    testWidgets('should display pages, containers, and columns', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([
          const entity.Container(
            id: 1,
            pageId: 1,
            index: 0,
            name: 'Container 1',
          ),
        ]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          const entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
        ]),
      );
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Container 1'), findsNothing);
      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('should display widgets in columns', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([const entity.Container(id: 1, pageId: 1, index: 0)]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          const entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
        ]),
      );
      fakeWidgetRepo.whenGetAllForColumn(
        success([
          const WidgetInstance(
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
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Responsive Layout
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Responsive Layout', () {
    void stubMinimalLoad(int menuId) {
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));
    }

    testWidgets('displays sidebar on wide screens (>=600px)', (tester) async {
      // Arrange
      const menuId = 1;
      stubMinimalLoad(menuId);

      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.vertical);
    });

    testWidgets('displays horizontal palette on narrow screens (<600px)', (
      tester,
    ) async {
      // Arrange
      const menuId = 1;
      stubMinimalLoad(menuId);

      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.horizontal);
    });

    testWidgets('sidebar uses surfaceContainerLow background', (tester) async {
      // Arrange
      const menuId = 1;
      stubMinimalLoad(menuId);

      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
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

  // --------------------------------------------------------------------------
  // Widget Management
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Widget Management', () {
    void stubFullTree({bool droppable = true}) {
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([const entity.Container(id: 1, pageId: 1, index: 0)]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          entity.Column(
            id: 1,
            containerId: 1,
            index: 0,
            flex: 1,
            isDroppable: droppable,
          ),
        ]),
      );
    }

    testWidgets('should display drop zone for empty column', (tester) async {
      // Arrange
      stubFullTree();
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Drop widgets here'), findsOneWidget);
      expect(find.byKey(const Key('drop_zone_1_0')), findsOneWidget);
    });

    testWidgets('should display widgets with edit capability', (tester) async {
      // Arrange
      stubFullTree();
      fakeWidgetRepo.whenGetAllForColumn(
        success([
          const WidgetInstance(
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
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });

    testWidgets('non-droppable column has no drop_zone_* keys in widget tree', (
      tester,
    ) async {
      // Arrange
      stubFullTree(droppable: false);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('drop_zone_1_0')), findsNothing);
    });

    testWidgets('non-droppable column with widgets still renders widgets', (
      tester,
    ) async {
      // Arrange
      stubFullTree(droppable: false);
      fakeWidgetRepo.whenGetAllForColumn(
        success([
          const WidgetInstance(
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
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WidgetRenderer), findsOneWidget);
      expect(find.byKey(const Key('drop_zone_1_0')), findsNothing);
    });

    testWidgets('non-droppable empty column shows lock icon', (tester) async {
      // Arrange
      stubFullTree(droppable: false);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Drop widgets here'), findsNothing);
    });

    testWidgets('droppable column (default) still has drop zones', (
      tester,
    ) async {
      // Arrange
      stubFullTree(droppable: true);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('drop_zone_1_0')), findsOneWidget);
      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('droppable column uses theme surface color', (tester) async {
      // Arrange
      stubFullTree(droppable: true);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
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
      stubFullTree(droppable: false);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      final theme = Theme.of(tester.element(find.byKey(const Key('column_1'))));
      final columnContainer = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final decoration = columnContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(theme.colorScheme.surface));
    });

    testWidgets('empty column text uses primary color', (tester) async {
      // Arrange
      stubFullTree(droppable: true);
      fakeWidgetRepo.whenGetAllForColumn(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      final theme = Theme.of(
        tester.element(find.text('Drop widgets here').first),
      );
      final text = tester.widget<Text>(find.text('Drop widgets here').first);
      expect(text.style?.color, theme.colorScheme.primary);
    });
  });

  // --------------------------------------------------------------------------
  // Header/Footer Exclusion
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Header/Footer Exclusion', () {
    testWidgets('should not display header page containers', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
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
        ]),
      );
      // Stub both page ids to return empty containers (header filtered out)
      fakeContainerRepo.whenGetAllForPage(success([]));
      fakeColumnRepo.whenGetAllForContainer(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Header'), findsNothing);
    });

    testWidgets('should not display footer page containers', (tester) async {
      // Arrange
      const menuId = 1;
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: menuId,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
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
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(success([]));
      fakeColumnRepo.whenGetAllForContainer(success([]));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Footer'), findsNothing);
    });
  });

  // --------------------------------------------------------------------------
  // Save Functionality
  // --------------------------------------------------------------------------

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
      fakeMenuRepo.whenGetById(success(menu));
      fakePageRepo.whenGetAllForMenu(success([]));
      fakeMenuRepo.whenUpdate(success(menu));

      // Act
      await tester.pumpWidget(buildPage(menuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_menu_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepo.updateCalls, hasLength(1));
      expect(find.text('Menu saved'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Template Widget Locking
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Template Widget Locking', () {
    void stubWithWidgets(List<WidgetInstance> widgets) {
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([const entity.Container(id: 1, pageId: 1, index: 0)]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          const entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
        ]),
      );
      fakeWidgetRepo.whenGetAllForColumn(success(widgets));
    }

    testWidgets(
      'should render locked widget as non-editable (no edit dialog on tap)',
      (tester) async {
        // Arrange
        const lockedWidget = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          isTemplate: true,
          lockedForEdition: true,
          props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
        );
        stubWithWidgets([lockedWidget]);

        // Act
        await tester.pumpWidget(buildPage(1));
        await tester.pumpAndSettle();

        expect(find.byType(WidgetRenderer), findsOneWidget);
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Edit Dish'), findsNothing);
      },
    );

    testWidgets('should not wrap locked widget in LongPressDraggable', (
      tester,
    ) async {
      // Arrange
      const lockedWidget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: true,
        lockedForEdition: true,
        props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
      );
      stubWithWidgets([lockedWidget]);

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('widget_1')), findsNothing);
    });

    testWidgets('should show lock icon on locked widget', (tester) async {
      // Arrange
      const lockedWidget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: true,
        lockedForEdition: true,
        props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
      );
      stubWithWidgets([lockedWidget]);

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('template widget without lockedForEdition is fully editable', (
      tester,
    ) async {
      // Arrange
      const templateWidget = WidgetInstance(
        id: 3,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: true,
        props: {'name': 'Template Dish', 'price': 10.0, 'allergens': []},
      );
      stubWithWidgets([templateWidget]);

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('widget_3')), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('should keep regular widget fully editable and draggable', (
      tester,
    ) async {
      // Arrange
      const regularWidget = WidgetInstance(
        id: 2,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        isTemplate: false,
        props: {'name': 'Regular Dish', 'price': 15.0, 'allergens': []},
      );
      stubWithWidgets([regularWidget]);

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('widget_2')), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });

  // --------------------------------------------------------------------------
  // Drop Zone Enforcement
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Drop Zone Enforcement', () {
    void stubWithAllowedWidgets({required String allowedType}) {
      fakeMenuRepo.whenGetById(
        success(
          Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
            allowedWidgets: [WidgetTypeConfig(type: allowedType)],
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(
        success([
          const entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
        ]),
      );
      fakeContainerRepo.whenGetAllForPage(
        success([const entity.Container(id: 1, pageId: 1, index: 0)]),
      );
      fakeColumnRepo.whenGetAllForContainer(
        success([
          const entity.Column(
            id: 1,
            containerId: 1,
            index: 0,
            flex: 1,
            isDroppable: true,
          ),
        ]),
      );
      fakeWidgetRepo.whenGetAllForColumn(success([]));
    }

    testWidgets('should reject drop of disallowed widget type', (tester) async {
      // Arrange
      stubWithAllowedWidgets(allowedType: 'dish');

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      final editorDropZone = tester.widget<EditorDropZone>(
        find.byType(EditorDropZone).first,
      );
      editorDropZone.onAccept(WidgetDragData.newWidget('text'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeWidgetRepo.createCalls, isEmpty);
    });

    testWidgets('should allow drop of permitted widget type', (tester) async {
      // Arrange
      stubWithAllowedWidgets(allowedType: 'dish');
      fakeWidgetRepo.whenCreate(
        success(
          const WidgetInstance(
            id: 99,
            columnId: 1,
            type: 'dish',
            version: '1.0.0',
            index: 0,
            props: {'name': '', 'price': 0.0, 'allergens': []},
          ),
        ),
      );

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      final editorDropZone = tester.widget<EditorDropZone>(
        find.byType(EditorDropZone).first,
      );
      editorDropZone.onAccept(WidgetDragData.newWidget('dish'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeWidgetRepo.createCalls, hasLength(1));
    });
  });

  // --------------------------------------------------------------------------
  // Scroll Preservation
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Scroll Preservation', () {
    testWidgets(
      'should not show loading indicator during reload after widget operation',
      (tester) async {
        // Arrange
        const menuId = 1;
        const menu = Menu(
          id: menuId,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        );

        var getByIdCallCount = 0;
        final reloadCompleter = Completer<Result<Menu, DomainError>>();
        final controlledRepo = _ControllableMenuRepository(
          onGetById: (_) {
            getByIdCallCount++;
            if (getByIdCallCount == 1) {
              return Future.value(const Success(menu));
            }
            return reloadCompleter.future;
          },
        );

        fakePageRepo.whenGetAllForMenu(
          success([
            const entity.Page(id: 1, menuId: menuId, name: 'Page 1', index: 0),
          ]),
        );
        fakeContainerRepo.whenGetAllForPage(
          success([const entity.Container(id: 1, pageId: 1, index: 0)]),
        );
        fakeColumnRepo.whenGetAllForContainer(
          success([
            const entity.Column(
              id: 1,
              containerId: 1,
              index: 0,
              flex: 1,
              isDroppable: true,
            ),
          ]),
        );
        fakeWidgetRepo.whenGetAllForColumn(success([]));
        fakeWidgetRepo.whenCreate(
          success(
            const WidgetInstance(
              id: 99,
              columnId: 1,
              type: 'dish',
              version: '1.0.0',
              index: 0,
              props: {'name': '', 'price': 0.0, 'allergens': []},
            ),
          ),
        );

        // Act — load the page
        await tester.pumpWidget(
          buildPage(menuId, menuRepoOverride: controlledRepo),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test Menu'), findsOneWidget);

        // Trigger widget drop
        final editorDropZone = tester.widget<EditorDropZone>(
          find.byType(EditorDropZone).first,
        );
        editorDropZone.onAccept(WidgetDragData.newWidget('dish'));
        await tester.pump();
        await tester.pump();

        // Assert — no loading spinner during background reload
        expect(find.byType(CircularProgressIndicator), findsNothing);

        reloadCompleter.complete(const Success(menu));
        await tester.pumpAndSettle();
      },
    );
  });

  // --------------------------------------------------------------------------
  // Widget Palette Filtering
  // --------------------------------------------------------------------------

  group('MenuEditorPage - Widget Palette Filtering', () {
    testWidgets('should only show allowed widget types in palette', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
            allowedWidgets: [WidgetTypeConfig(type: 'dish')],
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsNothing);
      expect(find.byKey(const Key('palette_item_text')), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('should show all types when allowedWidgetTypes is empty', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenGetById(
        success(
          const Menu(
            id: 1,
            name: 'Test Menu',
            status: Status.draft,
            version: '1.0.0',
            allowedWidgets: [],
          ),
        ),
      );
      fakePageRepo.whenGetAllForMenu(success([]));

      // Act
      await tester.pumpWidget(buildPage(1));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });
  });
}
