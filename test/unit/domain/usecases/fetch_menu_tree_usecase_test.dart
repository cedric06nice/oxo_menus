import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late FetchMenuTreeUseCase useCase;
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();

    useCase = FetchMenuTreeUseCase(
      menuRepository: mockMenuRepo,
      pageRepository: mockPageRepo,
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      widgetRepository: mockWidgetRepo,
    );
  });

  group('FetchMenuTreeUseCase', () {
    test('MenuTree should support optional headerPage and footerPage', () {
      const menu = Menu(id: 1, name: 'Test', status: Status.published, version: '1.0.0');
      const header = Page(id: 2, menuId: 1, name: 'Header', index: 0, type: PageType.header);

      final tree1 = MenuTree(menu: menu, pages: const []);
      final tree2 = MenuTree(
        menu: menu,
        pages: const [],
        headerPage: PageWithContainers(page: header, containers: const []),
      );

      expect(tree1.headerPage, isNull);
      expect(tree1.footerPage, isNull);
      expect(tree2.headerPage, isNotNull);
      expect(tree2.footerPage, isNull);
    });

    test('execute should separate pages by type', () async {
      // Arrange
      const testMenuId = 1;
      const testMenu = Menu(id: testMenuId, name: 'Test Menu', status: Status.published, version: '1.0.0');
      const headerPage = Page(id: 1, menuId: testMenuId, name: 'Header', index: 0, type: PageType.header);
      const contentPage1 = Page(id: 2, menuId: testMenuId, name: 'Page 1', index: 1, type: PageType.content);
      const contentPage2 = Page(id: 3, menuId: testMenuId, name: 'Page 2', index: 2, type: PageType.content);
      const footerPage = Page(id: 4, menuId: testMenuId, name: 'Footer', index: 3, type: PageType.footer);

      when(() => mockMenuRepo.getById(testMenuId)).thenAnswer((_) async => const Success(testMenu));
      when(() => mockPageRepo.getAllForMenu(testMenuId))
          .thenAnswer((_) async => const Success([headerPage, contentPage1, contentPage2, footerPage]));
      when(() => mockContainerRepo.getAllForPage(any())).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(testMenuId);

      // Assert
      expect(result.isSuccess, true);
      final tree = result.valueOrNull!;

      // Only content pages in main pages list
      expect(tree.pages.length, 2);
      expect(tree.pages[0].page.type, PageType.content);
      expect(tree.pages[1].page.type, PageType.content);

      // Header and footer separated
      expect(tree.headerPage, isNotNull);
      expect(tree.headerPage!.page.type, PageType.header);
      expect(tree.footerPage, isNotNull);
      expect(tree.footerPage!.page.type, PageType.footer);
    });

    const menuId = 1;
    const mockMenu = Menu(
      id: menuId,
      name: 'Test Menu',
      status: Status.published,
      version: '1.0.0',
    );

    test('should return menu tree when all fetches succeed', () async {
      // Arrange
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.menu, mockMenu);
      expect(result.valueOrNull?.pages, isEmpty);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verify(() => mockPageRepo.getAllForMenu(menuId)).called(1);
    });

    test('should return failure when menu fetch fails', () async {
      // Arrange
      const error = NotFoundError('Menu not found');
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verifyNever(() => mockPageRepo.getAllForMenu(any()));
    });

    test('should return failure when pages fetch fails', () async {
      // Arrange
      const error = NetworkError('Network error');
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verify(() => mockPageRepo.getAllForMenu(menuId)).called(1);
      verifyNever(() => mockContainerRepo.getAllForPage(any()));
    });

    test('should sort pages by index', () async {
      // Arrange
      final pages = [
        const Page(id: 2, menuId: menuId, name: 'Page 2', index: 2),
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
        const Page(id: 3, menuId: menuId, name: 'Page 3', index: 3),
      ];

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedPages = result.valueOrNull!.pages.map((p) => p.page).toList();
      expect(sortedPages[0].id, 1);
      expect(sortedPages[1].id, 2);
      expect(sortedPages[2].id, 3);
    });

    test('should return failure when containers fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      const error = ServerError('Server error');

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort containers by index', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 2, pageId: 1, index: 2, name: 'Container 2'),
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedContainers = result.valueOrNull!.pages[0].containers
          .map((c) => c.container)
          .toList();
      expect(sortedContainers[0].id, 1);
      expect(sortedContainers[1].id, 2);
    });

    test('should return failure when columns fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];
      const error = ValidationError('Invalid column data');

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(1),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort columns by index', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];
      final columns = [
        const Column(id: 3, containerId: 1, index: 3, flex: 1),
        const Column(id: 1, containerId: 1, index: 1, flex: 1),
        const Column(id: 2, containerId: 1, index: 2, flex: 1),
      ];

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(1),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedColumns = result.valueOrNull!.pages[0].containers[0].columns
          .map((c) => c.column)
          .toList();
      expect(sortedColumns[0].id, 1);
      expect(sortedColumns[1].id, 2);
      expect(sortedColumns[2].id, 3);
    });

    test('should return failure when widgets fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];
      final columns = [const Column(id: 1, containerId: 1, index: 1, flex: 1)];
      const error = UnknownError('Unknown error');

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(1),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepo.getAllForColumn(1),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort widgets by index', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];
      final columns = [const Column(id: 1, containerId: 1, index: 1, flex: 1)];
      final widgets = [
        const WidgetInstance(
          id: 2,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 2,
          props: {},
        ),
        const WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 1,
          props: {},
        ),
      ];

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(1),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepo.getAllForColumn(1),
      ).thenAnswer((_) async => Success(widgets));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedWidgets =
          result.valueOrNull!.pages[0].containers[0].columns[0].widgets;
      expect(sortedWidgets[0].id, 1);
      expect(sortedWidgets[1].id, 2);
    });

    test('should fetch complete tree with all levels', () async {
      // Arrange
      final pages = [
        const Page(id: 1, menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 1, pageId: 1, index: 1, name: 'Container 1'),
      ];
      final columns = [const Column(id: 1, containerId: 1, index: 1, flex: 1)];
      final widgets = [
        const WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 1,
          props: {'text': 'Hello'},
        ),
      ];

      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => Success(pages));
      when(
        () => mockContainerRepo.getAllForPage(1),
      ).thenAnswer((_) async => Success(containers));
      when(
        () => mockColumnRepo.getAllForContainer(1),
      ).thenAnswer((_) async => Success(columns));
      when(
        () => mockWidgetRepo.getAllForColumn(1),
      ).thenAnswer((_) async => Success(widgets));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final tree = result.valueOrNull!;

      // Verify menu level
      expect(tree.menu.id, menuId);

      // Verify page level
      expect(tree.pages.length, 1);
      expect(tree.pages[0].page.id, 1);

      // Verify container level
      expect(tree.pages[0].containers.length, 1);
      expect(tree.pages[0].containers[0].container.id, 1);

      // Verify column level
      expect(tree.pages[0].containers[0].columns.length, 1);
      expect(tree.pages[0].containers[0].columns[0].column.id, 1);

      // Verify widget level
      expect(tree.pages[0].containers[0].columns[0].widgets.length, 1);
      expect(tree.pages[0].containers[0].columns[0].widgets[0].id, 1);
      expect(
        tree.pages[0].containers[0].columns[0].widgets[0].props['text'],
        'Hello',
      );
    });

    test('should handle empty collections at each level', () async {
      // Arrange
      when(
        () => mockMenuRepo.getById(menuId),
      ).thenAnswer((_) async => const Success(mockMenu));
      when(
        () => mockPageRepo.getAllForMenu(menuId),
      ).thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.pages, isEmpty);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verify(() => mockPageRepo.getAllForMenu(menuId)).called(1);
      verifyNever(() => mockContainerRepo.getAllForPage(any()));
    });
  });
}
