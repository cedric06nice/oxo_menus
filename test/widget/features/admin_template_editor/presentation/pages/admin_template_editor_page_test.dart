import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/pages/admin_template_editor_page.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/image_widget/image_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/auto_scroll_listener.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_palette.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../../../../fakes/reflectable_bootstrap.dart';

void main() {
  late FakeMenuRepository fakeMenuRepository;
  late FakePageRepository fakePageRepository;
  late FakeContainerRepository fakeContainerRepository;
  late FakeColumnRepository fakeColumnRepository;
  late FakeWidgetRepository fakeWidgetRepository;
  late FakeSizeRepository fakeSizeRepository;
  late FakeAreaRepository fakeAreaRepository;
  late PresentableWidgetRegistry testRegistry;

  setUpAll(() {
    initializeReflectableForTests();
  });

  setUp(() {
    fakeMenuRepository = FakeMenuRepository();
    fakePageRepository = FakePageRepository();
    fakeContainerRepository = FakeContainerRepository();
    fakeColumnRepository = FakeColumnRepository();
    fakeWidgetRepository = FakeWidgetRepository();
    fakeSizeRepository = FakeSizeRepository();
    fakeAreaRepository = FakeAreaRepository();

    testRegistry = PresentableWidgetRegistry();
    testRegistry.register(dishWidgetDefinition);
    testRegistry.register(imageWidgetDefinition);
    testRegistry.register(sectionWidgetDefinition);
    testRegistry.register(textWidgetDefinition);

    // Default stub for nested container loading
    fakeContainerRepository.whenGetAllForContainer(
      const Success(<entity.Container>[]),
    );
  });

  const testUser = User(
    id: 'admin-1',
    email: 'admin@example.com',
    firstName: 'Admin',
    lastName: 'User',
    role: UserRole.admin,
  );

  Widget createWidgetUnderTest(int menuId) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => AdminTemplateEditorPage(menuId: menuId),
        ),
        GoRoute(
          path: '/admin/sizes',
          builder: (_, _) => const Scaffold(body: Text('Sizes Page')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepository),
        pageRepositoryProvider.overrideWithValue(fakePageRepository),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepository),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepository),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepository),
        sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        areaRepositoryProvider.overrideWithValue(fakeAreaRepository),
        widgetRegistryProvider.overrideWithValue(testRegistry),
        currentUserProvider.overrideWithValue(testUser),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  // ---------------------------------------------------------------------------
  // Common test data helpers
  // ---------------------------------------------------------------------------

  const kMenuId = 1;
  const kMenu = Menu(
    id: kMenuId,
    name: 'Test Template',
    status: Status.draft,
    version: '1.0.0',
  );

  void stubMenuAndPages({List<entity.Page> pages = const []}) {
    fakeMenuRepository.whenGetById(const Success(kMenu));
    fakePageRepository.whenGetAllForMenu(Success(pages));
  }

  group('AdminTemplateEditorPage - Initial Load', () {
    testWidgets('should show loading indicator initially', (tester) async {
      // Arrange — use a slow repo wired through ProviderScope directly
      final completer = Completer<Result<Menu, DomainError>>();
      final slowRepo = _SlowFakeMenuRepository(completer.future);
      fakePageRepository.whenGetAllForMenu(const Success([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(slowRepo),
            pageRepositoryProvider.overrideWithValue(fakePageRepository),
            containerRepositoryProvider.overrideWithValue(
              fakeContainerRepository,
            ),
            columnRepositoryProvider.overrideWithValue(fakeColumnRepository),
            widgetRepositoryProvider.overrideWithValue(fakeWidgetRepository),
            sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
            areaRepositoryProvider.overrideWithValue(fakeAreaRepository),
            widgetRegistryProvider.overrideWithValue(testRegistry),
            currentUserProvider.overrideWithValue(testUser),
          ],
          child: MaterialApp(home: AdminTemplateEditorPage(menuId: kMenuId)),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Success(kMenu));
      await tester.pumpAndSettle();
    });

    testWidgets('should load and display template name', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Template'), findsOneWidget);
    });

    testWidgets('should show error when menu fails to load', (tester) async {
      // Arrange
      fakeMenuRepository.whenGetById(
        const Failure(NotFoundError('Menu not found')),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Menu not found'), findsOneWidget);
    });

    testWidgets('should have app bar with save and publish actions', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.publish), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Page Management', () {
    testWidgets('should display existing pages', (tester) async {
      // Arrange
      final pages = [
        const entity.Page(id: 1, menuId: kMenuId, name: 'Page 1', index: 0),
        const entity.Page(id: 2, menuId: kMenuId, name: 'Page 2', index: 1),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — page names are hidden; verify pages exist via delete button keys
      expect(find.byKey(const Key('delete_page_1')), findsOneWidget);
      expect(find.byKey(const Key('delete_page_2')), findsOneWidget);
    });

    testWidgets('should have add page button', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_page_button')), findsOneWidget);
    });

    testWidgets('should create new page when add button tapped', (
      tester,
    ) async {
      // Arrange
      const newPage = entity.Page(
        id: 2,
        menuId: kMenuId,
        name: 'Page 1',
        index: 0,
      );
      stubMenuAndPages();
      fakePageRepository.whenCreate(const Success(newPage));
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_page_button')));
      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakePageRepository.createCalls, hasLength(1));
    });

    testWidgets('should delete page when delete button tapped', (tester) async {
      // Arrange
      final pages = [
        const entity.Page(id: 1, menuId: kMenuId, name: 'Page 1', index: 0),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));
      fakePageRepository.whenDelete(const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_page_1')));
      await tester.tap(find.byKey(const Key('delete_page_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakePageRepository.deleteCalls.where((c) => c.id == 1),
        hasLength(1),
      );
    });
  });

  group('AdminTemplateEditorPage - Container Management', () {
    testWidgets('should display containers for a page', (tester) async {
      // Arrange
      const pageId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
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
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — container names are hidden; verify via selectable key
      expect(find.byKey(const Key('selectable_container_1')), findsOneWidget);
    });

    testWidgets('should add container to page', (tester) async {
      // Arrange
      const pageId = 1;
      const newContainer = entity.Container(id: 2, pageId: pageId, index: 0);
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));
      fakeContainerRepository.whenCreate(const Success(newContainer));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('add_container_$pageId')),
      );
      await tester.tap(find.byKey(const Key('add_container_$pageId')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeContainerRepository.createCalls, hasLength(1));
    });

    testWidgets('should delete container', (tester) async {
      // Arrange
      const pageId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
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
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));
      fakeContainerRepository.whenDelete(const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_container_1')));
      await tester.tap(find.byKey(const Key('delete_container_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakeContainerRepository.deleteCalls.where((c) => c.id == 1),
        hasLength(1),
      );
    });
  });

  group('AdminTemplateEditorPage - Column Management', () {
    testWidgets('should display columns in a container', (tester) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
        const entity.Column(id: 2, containerId: containerId, index: 1, flex: 1),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumn(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      await tester.ensureVisible(find.byKey(const Key('column_1')));
      expect(find.byKey(const Key('column_1')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('column_2')));
      expect(find.byKey(const Key('column_2')), findsOneWidget);
    });

    testWidgets('should add column to container', (tester) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      const newColumn = entity.Column(
        id: 2,
        containerId: containerId,
        index: 0,
        flex: 1,
      );
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));
      fakeColumnRepository.whenCreate(const Success(newColumn));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('add_column_$containerId')),
      );
      await tester.tap(find.byKey(const Key('add_column_$containerId')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeColumnRepository.createCalls, hasLength(1));
    });

    testWidgets('should delete column', (tester) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumn(const Success([]));
      fakeColumnRepository.whenDelete(const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_column_1')));
      await tester.tap(find.byKey(const Key('delete_column_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakeColumnRepository.deleteCalls.where((c) => c.id == 1),
        hasLength(1),
      );
    });
  });

  group('AdminTemplateEditorPage - Selection and Side Panel', () {
    testWidgets(
      'tapping a container card shows "Container Style" in side panel',
      (tester) async {
        // Arrange
        const pageId = 1;
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: kMenuId,
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
        stubMenuAndPages(pages: pages);
        fakeContainerRepository.whenGetAllForPage(Success(containers));
        fakeColumnRepository.whenGetAllForContainer(const Success([]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

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
      const pageId = 1;
      const containerId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumn(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('selectable_column_1')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Column Style'), findsOneWidget);
    });

    testWidgets('tapping a page header shows "Menu Style" in side panel', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('selectable_menu')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Menu Style'), findsOneWidget);
    });

    testWidgets('side panel hidden when nothing is selected', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — no side panel style editor when nothing selected
      expect(find.text('Menu Style'), findsNothing);
      expect(find.text('Container Style'), findsNothing);
      expect(find.text('Column Style'), findsNothing);
    });

    testWidgets('inline ExpansionTile style sections are no longer present', (
      tester,
    ) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: containerId, pageId: pageId, index: 0),
      ];
      final columns = [
        const entity.Column(id: 1, containerId: containerId, index: 0, flex: 1),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumn(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets(
      'shows isDroppable toggle when column is selected in side panel',
      (tester) async {
        // Arrange
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: kMenuId,
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
        stubMenuAndPages(pages: pages);
        fakeContainerRepository.whenGetAllForPage(Success(containers));
        fakeColumnRepository.whenGetAllForContainer(Success(columns));
        fakeWidgetRepository.whenGetAllForColumn(const Success([]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

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
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: kMenuId,
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
        stubMenuAndPages(pages: pages);
        fakeContainerRepository.whenGetAllForPage(Success(containers));
        fakeColumnRepository.whenGetAllForContainer(Success(columns));
        fakeWidgetRepository.whenGetAllForColumn(const Success([]));
        fakeColumnRepository.whenUpdate(
          Success(columns.first.copyWith(isDroppable: false)),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_column_$columnId')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Allow Widget Drops'));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeColumnRepository.updateCalls, hasLength(1));
        expect(
          fakeColumnRepository.updateCalls.first.input,
          const UpdateColumnInput(id: columnId, isDroppable: false),
        );
      },
    );

    testWidgets(
      'drop zones still present when isDroppable: false (admin unrestricted)',
      (tester) async {
        // Arrange
        const pageId = 1;
        const containerId = 1;
        const columnId = 1;
        final pages = [
          const entity.Page(
            id: pageId,
            menuId: kMenuId,
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
        stubMenuAndPages(pages: pages);
        fakeContainerRepository.whenGetAllForPage(Success(containers));
        fakeColumnRepository.whenGetAllForContainer(Success(columns));
        fakeWidgetRepository.whenGetAllForColumn(const Success([]));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        // Assert — drop zone should still be present (admin unrestricted)
        expect(find.byKey(Key('drop_zone_${columnId}_0')), findsOneWidget);
      },
    );
  });

  group('AdminTemplateEditorPage - Header Management', () {
    testWidgets('should show Add Header button when no header page exists', (
      tester,
    ) async {
      // Arrange
      final contentPages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
      ];
      stubMenuAndPages(pages: contentPages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_header_button')), findsOneWidget);
    });

    testWidgets('should create header page when Add Header button tapped', (
      tester,
    ) async {
      // Arrange
      const headerPage = entity.Page(
        id: 2,
        menuId: kMenuId,
        name: 'Header',
        index: 0,
        type: entity.PageType.header,
      );
      stubMenuAndPages();
      fakePageRepository.whenCreate(const Success(headerPage));
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_header_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakePageRepository.createCalls, hasLength(1));
      expect(
        fakePageRepository.createCalls.first.input.type,
        entity.PageType.header,
      );
      expect(fakePageRepository.createCalls.first.input.name, 'Header');
    });

    testWidgets('should hide Add Header button when header page exists', (
      tester,
    ) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        const entity.Page(
          id: 2,
          menuId: kMenuId,
          name: 'Page 1',
          index: 1,
          type: entity.PageType.content,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_header_button')), findsNothing);
    });

    testWidgets('should show header card when header page exists', (
      tester,
    ) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Header'), findsOneWidget);
      expect(find.byKey(const Key('delete_header_button')), findsOneWidget);
    });

    testWidgets('should delete header page when Delete Header button tapped', (
      tester,
    ) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));
      fakePageRepository.whenDelete(const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_header_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakePageRepository.deleteCalls.where((c) => c.id == 1),
        hasLength(1),
      );
    });
  });

  group('AdminTemplateEditorPage - Footer Management', () {
    testWidgets('should show Add Footer button when no footer page exists', (
      tester,
    ) async {
      // Arrange
      final contentPages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
      ];
      stubMenuAndPages(pages: contentPages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_footer_button')), findsOneWidget);
    });

    testWidgets('should create footer page when Add Footer button tapped', (
      tester,
    ) async {
      // Arrange
      const footerPage = entity.Page(
        id: 2,
        menuId: kMenuId,
        name: 'Footer',
        index: 0,
        type: entity.PageType.footer,
      );
      stubMenuAndPages();
      fakePageRepository.whenCreate(const Success(footerPage));
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add_footer_button')));
      await tester.tap(find.byKey(const Key('add_footer_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakePageRepository.createCalls, hasLength(1));
      expect(
        fakePageRepository.createCalls.first.input.type,
        entity.PageType.footer,
      );
      expect(fakePageRepository.createCalls.first.input.name, 'Footer');
    });

    testWidgets('should hide Add Footer button when footer page exists', (
      tester,
    ) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
          type: entity.PageType.content,
        ),
        const entity.Page(
          id: 2,
          menuId: kMenuId,
          name: 'Footer',
          index: 1,
          type: entity.PageType.footer,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('add_footer_button')), findsNothing);
    });

    testWidgets('should show footer card when footer page exists', (
      tester,
    ) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
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
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));
      fakePageRepository.whenDelete(const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('delete_footer_button')));
      await tester.tap(find.byKey(const Key('delete_footer_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakePageRepository.deleteCalls.where((c) => c.id == 1),
        hasLength(1),
      );
    });
  });

  group('AdminTemplateEditorPage - Save and Publish', () {
    testWidgets('should save template as draft', (tester) async {
      // Arrange
      stubMenuAndPages();
      fakeMenuRepository.whenUpdate(const Success(kMenu));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepository.updateCalls, hasLength(1));
      expect(find.text('Template saved'), findsOneWidget);
    });

    testWidgets('should show Menu Style in side panel when menu selected', (
      tester,
    ) async {
      // Arrange
      const menuWithStyle = Menu(
        id: kMenuId,
        name: 'Style Test',
        status: Status.draft,
        version: '1.0.0',
        styleConfig: StyleConfig(marginTop: 20.0),
      );
      fakeMenuRepository.whenGetById(const Success(menuWithStyle));
      fakePageRepository.whenGetAllForMenu(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

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
        const menuWithStyle = Menu(
          id: kMenuId,
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
        fakeMenuRepository.whenGetById(const Success(menuWithStyle));
        fakePageRepository.whenGetAllForMenu(const Success([]));
        fakeMenuRepository.whenUpdate(const Success(menuWithStyle));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('side_margin_all')), '30');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeMenuRepository.updateCalls, hasLength(1));
        expect(
          fakeMenuRepository.updateCalls.first.input.styleConfig?.marginTop,
          30.0,
        );
      },
    );

    testWidgets('should publish template', (tester) async {
      // Arrange
      final publishedMenu = kMenu.copyWith(status: Status.published);
      stubMenuAndPages();
      fakeMenuRepository.whenUpdate(Success(publishedMenu));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.publish));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepository.updateCalls, hasLength(1));
      expect(find.text('Template published'), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Scroll Preservation', () {
    testWidgets(
      'should not show loading indicator during reload after page operation',
      (tester) async {
        // Arrange
        const newPage = entity.Page(
          id: 2,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        );
        final reloadCompleter = Completer<Result<Menu, DomainError>>();
        var getByIdCallCount = 0;

        final countingRepo = _CountingFakeMenuRepository(
          onGetById: (_) {
            getByIdCallCount++;
            if (getByIdCallCount == 1) {
              return Future.value(const Success(kMenu));
            }
            return reloadCompleter.future;
          },
        );
        fakePageRepository.whenGetAllForMenu(const Success([]));
        fakePageRepository.whenCreate(const Success(newPage));
        fakeContainerRepository.whenGetAllForPage(const Success([]));

        // Act — load the page fully using the counting repo directly
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              menuRepositoryProvider.overrideWithValue(countingRepo),
              pageRepositoryProvider.overrideWithValue(fakePageRepository),
              containerRepositoryProvider.overrideWithValue(
                fakeContainerRepository,
              ),
              columnRepositoryProvider.overrideWithValue(fakeColumnRepository),
              widgetRepositoryProvider.overrideWithValue(fakeWidgetRepository),
              sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
              areaRepositoryProvider.overrideWithValue(fakeAreaRepository),
              widgetRegistryProvider.overrideWithValue(testRegistry),
              currentUserProvider.overrideWithValue(testUser),
            ],
            child: MaterialApp(home: AdminTemplateEditorPage(menuId: kMenuId)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test Template'), findsOneWidget);

        await tester.ensureVisible(find.byKey(const Key('add_page_button')));
        await tester.tap(find.byKey(const Key('add_page_button')));

        await tester.pump();
        await tester.pump();

        // Assert — no loading spinner during reload
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Clean up
        reloadCompleter.complete(const Success(kMenu));
        await tester.pumpAndSettle();
      },
    );
  });

  group('AdminTemplateEditorPage - Widget Palette', () {
    testWidgets('should display widget palette with all registered types', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
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
      const menuWithAllowedWidgets = Menu(
        id: kMenuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
        allowedWidgets: [
          WidgetTypeConfig(type: 'dish'),
          WidgetTypeConfig(type: 'text'),
        ],
      );
      fakeMenuRepository.whenGetById(const Success(menuWithAllowedWidgets));
      fakePageRepository.whenGetAllForMenu(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — checkboxes present (admin mode)
      expect(find.byType(Checkbox), findsNWidgets(4));

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
        const menuWithAllowedWidgets = Menu(
          id: kMenuId,
          name: 'Test Template',
          status: Status.draft,
          version: '1.0.0',
          allowedWidgets: [WidgetTypeConfig(type: 'dish')],
        );
        fakeMenuRepository.whenGetById(const Success(menuWithAllowedWidgets));
        fakePageRepository.whenGetAllForMenu(const Success([]));
        fakeMenuRepository.whenUpdate(
          Success(
            menuWithAllowedWidgets.copyWith(
              allowedWidgets: const [
                WidgetTypeConfig(type: 'dish'),
                WidgetTypeConfig(type: 'section'),
              ],
            ),
          ),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('allowed_type_checkbox_section')),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(fakeMenuRepository.updateCalls, hasLength(1));
        final input = fakeMenuRepository.updateCalls.first.input;
        expect(input.id, kMenuId);
        final section = input.allowedWidgets!.firstWhere(
          (c) => c.type == 'section',
        );
        expect(section.enabled, isTrue);
      },
    );
  });

  group('AdminTemplateEditorPage - Widget Display', () {
    testWidgets('should display widgets in columns via WidgetRenderer', (
      tester,
    ) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
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
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumnForId(columnId, Success(widgets));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WidgetRenderer), findsOneWidget);
    });

    testWidgets('should show drop zone text for empty column', (tester) async {
      // Arrange
      const pageId = 1;
      const containerId = 1;
      const columnId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
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
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(Success(columns));
      fakeWidgetRepository.whenGetAllForColumnForId(
        columnId,
        const Success([]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Drop widgets here'), findsOneWidget);
    });
  });

  group('AdminTemplateEditorPage - Page Size', () {
    testWidgets('should have page size button in toolbar', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('page_size_button')), findsOneWidget);
      expect(find.byIcon(Icons.straighten), findsOneWidget);
    });

    testWidgets('tapping page_size_button navigates to /admin/sizes', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_size_button')));
      await tester.pumpAndSettle();

      // Assert — the real router navigated to Sizes Page
      expect(find.text('Sizes Page'), findsOneWidget);
    });

    testWidgets(
      'tapping change_page_size_button in side panel opens dialog with available sizes',
      (tester) async {
        // Arrange
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
        stubMenuAndPages();
        fakeSizeRepository.whenGetAll(Success(sizes));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

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
      stubMenuAndPages();
      fakeSizeRepository.whenGetAll(Success(sizes));
      fakeMenuRepository.whenUpdate(
        Success(
          kMenu.copyWith(
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('selectable_menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_page_size_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A4'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepository.updateCalls, hasLength(1));
      expect(fakeMenuRepository.updateCalls.first.input.id, kMenuId);
      expect(fakeMenuRepository.updateCalls.first.input.sizeId, 1);
    });

    testWidgets(
      'shows current page size name highlighted in dialog via side panel',
      (tester) async {
        // Arrange
        const menuWithSize = Menu(
          id: kMenuId,
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
        fakeMenuRepository.whenGetById(const Success(menuWithSize));
        fakePageRepository.whenGetAllForMenu(const Success([]));
        fakeSizeRepository.whenGetAll(Success(sizes));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('change_page_size_button')));
        await tester.pumpAndSettle();

        // Assert — the current size should have a check icon
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );

    testWidgets(
      'shows snackbar after successful page size update via side panel',
      (tester) async {
        // Arrange
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
        stubMenuAndPages();
        fakeSizeRepository.whenGetAll(Success(sizes));
        fakeMenuRepository.whenUpdate(
          Success(
            kMenu.copyWith(
              pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

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
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — left panel should NOT have a VerticalDivider
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('canvas has auto-scroll listener', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AutoScrollListener), findsOneWidget);
    });

    testWidgets('page names are not shown in page cards', (tester) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'My Custom Page',
          index: 0,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — page name should NOT be displayed
      expect(find.text('My Custom Page'), findsNothing);
    });

    testWidgets('container names are not shown in container cards', (
      tester,
    ) async {
      // Arrange
      const pageId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(
          id: 1,
          pageId: pageId,
          index: 0,
          name: 'Fancy Container Name',
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — container name should NOT be displayed
      expect(find.text('Fancy Container Name'), findsNothing);
      expect(find.text('Container'), findsNothing);
    });

    testWidgets('header card shows header label with icon', (tester) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Header'), findsOneWidget);
      expect(find.byIcon(Icons.vertical_align_top), findsOneWidget);
    });

    testWidgets('footer card shows footer label with icon', (tester) async {
      // Arrange
      final pages = [
        const entity.Page(
          id: 1,
          menuId: kMenuId,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
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
      const pageId = 1;
      final pages = [
        const entity.Page(
          id: pageId,
          menuId: kMenuId,
          name: 'Page 1',
          index: 0,
        ),
      ];
      final containers = [
        const entity.Container(id: 1, pageId: pageId, index: 0),
      ];
      stubMenuAndPages(pages: pages);
      fakeContainerRepository.whenGetAllForPage(Success(containers));
      fakeColumnRepository.whenGetAllForContainer(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      await tester.ensureVisible(
        find.byKey(const Key('add_container_$pageId')),
      );
      expect(find.byKey(const Key('add_container_$pageId')), findsOneWidget);
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('menu style selector uses 12px border radius', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert — find the selectable_menu container
      final menuSelector = find.byKey(const Key('selectable_menu'));
      expect(menuSelector, findsOneWidget);

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
    testWidgets(
      'on narrow screen, shows horizontal palette at top instead of side panel',
      (tester) async {
        // Arrange
        stubMenuAndPages();

        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        // Assert — horizontal palette hides the title
        final palette = tester.widget<WidgetPalette>(
          find.byType(WidgetPalette),
        );
        expect(palette.axis, Axis.horizontal);
        expect(find.text('Widget Palette'), findsNothing);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('on narrow screen, no RenderFlex overflow', (tester) async {
      // Arrange
      stubMenuAndPages();

      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AdminTemplateEditorPage), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('on wide screen, layout is unchanged with side panel', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();

      // Act — default 800x600 is above breakpoint
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Widget Palette'), findsOneWidget);
      final palette = tester.widget<WidgetPalette>(find.byType(WidgetPalette));
      expect(palette.axis, Axis.vertical);
    });

    testWidgets(
      'on narrow screen, selecting element opens bottom sheet with style editor',
      (tester) async {
        // Arrange
        stubMenuAndPages();

        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;

        // Act
        await tester.pumpWidget(createWidgetUnderTest(kMenuId));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('selectable_menu')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(BottomSheet), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });

  group('AdminTemplateEditorPage - Area Picker', () {
    testWidgets('should show area button in toolbar', (tester) async {
      // Arrange
      stubMenuAndPages();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('area_button')), findsOneWidget);
    });

    testWidgets('tapping area button opens dialog with loaded areas', (
      tester,
    ) async {
      // Arrange
      stubMenuAndPages();
      fakeAreaRepository.whenGetAll(
        const Success([Area(id: 1, name: 'Dining'), Area(id: 2, name: 'Bar')]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('area_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Select Area'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
    });

    testWidgets('selecting area updates menu via repository', (tester) async {
      // Arrange
      stubMenuAndPages();
      fakeAreaRepository.whenGetAll(
        const Success([Area(id: 1, name: 'Dining'), Area(id: 2, name: 'Bar')]),
      );
      fakeMenuRepository.whenUpdate(
        const Success(
          Menu(
            id: kMenuId,
            name: 'Test Template',
            status: Status.draft,
            version: '1.0.0',
            area: Area(id: 1, name: 'Dining'),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('area_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dining'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepository.updateCalls, isNotEmpty);
      expect(fakeMenuRepository.updateCalls.last.input.areaId, 1);
    });

    testWidgets('shows current area name on button tooltip', (tester) async {
      // Arrange
      const menuWithArea = Menu(
        id: kMenuId,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
        area: Area(id: 1, name: 'Dining'),
      );
      fakeMenuRepository.whenGetById(const Success(menuWithArea));
      fakePageRepository.whenGetAllForMenu(const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(kMenuId));
      await tester.pumpAndSettle();

      // Assert
      final button = tester.widget<IconButton>(
        find.byKey(const Key('area_button')),
      );
      expect(button.tooltip, 'Area: Dining');
    });
  });

  group('AdminTemplateEditorPage - Widget lock-for-edition toggle', () {
    const lockMenuId = 1;
    const lockPageId = 1;
    const lockContainerId = 1;
    const lockColumnId = 1;
    const lockWidgetId = 42;

    void stubTreeWithSingleWidget({required bool locked}) {
      final widgets = [
        WidgetInstance(
          id: lockWidgetId,
          columnId: lockColumnId,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: const {
            'text': 'Admin Text',
            'align': 'left',
            'bold': false,
            'italic': false,
          },
          isTemplate: true,
          lockedForEdition: locked,
        ),
      ];
      fakeMenuRepository.whenGetById(const Success(kMenu));
      fakePageRepository.whenGetAllForMenu(
        Success([
          const entity.Page(
            id: lockPageId,
            menuId: lockMenuId,
            name: 'Page 1',
            index: 0,
          ),
        ]),
      );
      fakeContainerRepository.whenGetAllForPage(
        Success([
          const entity.Container(
            id: lockContainerId,
            pageId: lockPageId,
            index: 0,
          ),
        ]),
      );
      fakeColumnRepository.whenGetAllForContainer(
        Success([
          const entity.Column(
            id: lockColumnId,
            containerId: lockContainerId,
            index: 0,
            flex: 1,
          ),
        ]),
      );
      fakeWidgetRepository.whenGetAllForColumnForId(
        lockColumnId,
        Success(widgets),
      );
    }

    testWidgets('renders an open padlock for an unlocked template widget', (
      tester,
    ) async {
      // Arrange
      stubTreeWithSingleWidget(locked: false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(lockMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.byKey(const Key('widget_lock_toggle_$lockWidgetId')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('renders a closed padlock for a locked template widget', (
      tester,
    ) async {
      // Arrange
      stubTreeWithSingleWidget(locked: true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(lockMenuId));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.byKey(const Key('widget_lock_toggle_$lockWidgetId')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets(
      'tapping the toggle sends UpdateWidgetInput(lockedForEdition: true)',
      (tester) async {
        // Arrange
        stubTreeWithSingleWidget(locked: false);
        fakeWidgetRepository.whenUpdate(
          const Success(
            WidgetInstance(
              id: lockWidgetId,
              columnId: lockColumnId,
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
              lockedForEdition: true,
            ),
          ),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(lockMenuId));
        await tester.pumpAndSettle();

        final toggleFinder = find.byKey(
          const Key('widget_lock_toggle_$lockWidgetId'),
        );
        final button = tester.widget<IconButton>(toggleFinder);
        button.onPressed!();
        await tester.pumpAndSettle();

        // Assert
        expect(fakeWidgetRepository.updateCalls, hasLength(1));
        expect(fakeWidgetRepository.updateCalls.first.input.id, lockWidgetId);
        expect(
          fakeWidgetRepository.updateCalls.first.input.lockedForEdition,
          true,
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Helper fakes for controlled async behaviour
// ---------------------------------------------------------------------------

class _SlowFakeMenuRepository extends FakeMenuRepository {
  final Future<Result<Menu, DomainError>> _future;

  _SlowFakeMenuRepository(this._future);

  @override
  Future<Result<Menu, DomainError>> getById(int id) async {
    calls.add(MenuGetByIdCall(id));
    return _future;
  }
}

class _CountingFakeMenuRepository extends FakeMenuRepository {
  final Future<Result<Menu, DomainError>> Function(int id) onGetById;

  _CountingFakeMenuRepository({required this.onGetById});

  @override
  Future<Result<Menu, DomainError>> getById(int id) {
    calls.add(MenuGetByIdCall(id));
    return onGetById(id);
  }

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async {
    calls.add(MenuListAllCall(onlyPublished: onlyPublished, areaIds: areaIds));
    throw StateError('listAll not expected in editor test');
  }
}
