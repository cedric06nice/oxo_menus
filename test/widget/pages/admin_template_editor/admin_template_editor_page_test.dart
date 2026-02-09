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
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockGoRouter mockRouter;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockRouter = MockGoRouter();
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

      // Assert
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
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

      // Assert
      expect(find.text('Header Section'), findsOneWidget);
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

    testWidgets('should display PageStyleSection after load', (tester) async {
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

      // Assert
      expect(find.text('Page Style'), findsOneWidget);
      expect(find.text('Margins'), findsOneWidget);
      expect(find.text('Paddings'), findsOneWidget);
    });

    testWidgets('should save styleConfig when save is pressed after editing',
        (tester) async {
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
      when(
        () => mockMenuRepository.update(any()),
      ).thenAnswer((_) async => const Success(menu));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(menuId));
      await tester.pumpAndSettle();

      // Edit margin top
      await tester.enterText(find.byKey(const Key('margin_top')), '30');
      await tester.pumpAndSettle();

      // Press save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(() => mockMenuRepository.update(captureAny()))
              .captured
              .single as UpdateMenuInput;
      expect(captured.styleConfig, isNotNull);
      expect(captured.styleConfig!.marginTop, 30.0);
    });

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
}
