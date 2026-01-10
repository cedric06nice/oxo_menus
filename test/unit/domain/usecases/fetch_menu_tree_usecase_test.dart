import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart';
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
    const menuId = 'menu-1';
    const mockMenu = Menu(
      id: menuId,
      name: 'Test Menu',
      status: MenuStatus.published,
      version: '1.0.0',
    );

    test('should return menu tree when all fetches succeed', () async {
      // Arrange
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([]));

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
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Failure(error));

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
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => const Failure(error));

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
        const Page(id: 'p2', menuId: menuId, name: 'Page 2', index: 2),
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
        const Page(id: 'p3', menuId: menuId, name: 'Page 3', index: 3),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage(any()))
          .thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedPages = result.valueOrNull!.pages.map((p) => p.page).toList();
      expect(sortedPages[0].id, 'p1');
      expect(sortedPages[1].id, 'p2');
      expect(sortedPages[2].id, 'p3');
    });

    test('should return failure when containers fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      const error = ServerError('Server error');

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort containers by index', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c2', pageId: 'p1', index: 2, name: 'Container 2'),
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer(any()))
          .thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedContainers =
          result.valueOrNull!.pages[0].containers.map((c) => c.container).toList();
      expect(sortedContainers[0].id, 'c1');
      expect(sortedContainers[1].id, 'c2');
    });

    test('should return failure when columns fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];
      const error = ValidationError('Invalid column data');

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer('c1'))
          .thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort columns by index', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];
      final columns = [
        const Column(id: 'col3', containerId: 'c1', index: 3, flex: 1),
        const Column(id: 'col1', containerId: 'c1', index: 1, flex: 1),
        const Column(id: 'col2', containerId: 'c1', index: 2, flex: 1),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer('c1'))
          .thenAnswer((_) async => Success(columns));
      when(() => mockWidgetRepo.getAllForColumn(any()))
          .thenAnswer((_) async => const Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedColumns = result
          .valueOrNull!.pages[0].containers[0].columns
          .map((c) => c.column)
          .toList();
      expect(sortedColumns[0].id, 'col1');
      expect(sortedColumns[1].id, 'col2');
      expect(sortedColumns[2].id, 'col3');
    });

    test('should return failure when widgets fetch fails', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];
      final columns = [
        const Column(id: 'col1', containerId: 'c1', index: 1, flex: 1),
      ];
      const error = UnknownError('Unknown error');

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer('c1'))
          .thenAnswer((_) async => Success(columns));
      when(() => mockWidgetRepo.getAllForColumn('col1'))
          .thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
    });

    test('should sort widgets by index', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];
      final columns = [
        const Column(id: 'col1', containerId: 'c1', index: 1, flex: 1),
      ];
      final widgets = [
        const WidgetInstance(
          id: 'w2',
          columnId: 'col1',
          type: 'text',
          version: '1.0.0',
          index: 2,
          props: {},
        ),
        const WidgetInstance(
          id: 'w1',
          columnId: 'col1',
          type: 'text',
          version: '1.0.0',
          index: 1,
          props: {},
        ),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer('c1'))
          .thenAnswer((_) async => Success(columns));
      when(() => mockWidgetRepo.getAllForColumn('col1'))
          .thenAnswer((_) async => Success(widgets));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedWidgets =
          result.valueOrNull!.pages[0].containers[0].columns[0].widgets;
      expect(sortedWidgets[0].id, 'w1');
      expect(sortedWidgets[1].id, 'w2');
    });

    test('should fetch complete tree with all levels', () async {
      // Arrange
      final pages = [
        const Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
      ];
      final containers = [
        const Container(id: 'c1', pageId: 'p1', index: 1, name: 'Container 1'),
      ];
      final columns = [
        const Column(id: 'col1', containerId: 'c1', index: 1, flex: 1),
      ];
      final widgets = [
        const WidgetInstance(
          id: 'w1',
          columnId: 'col1',
          type: 'text',
          version: '1.0.0',
          index: 1,
          props: {'text': 'Hello'},
        ),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage('p1'))
          .thenAnswer((_) async => Success(containers));
      when(() => mockColumnRepo.getAllForContainer('c1'))
          .thenAnswer((_) async => Success(columns));
      when(() => mockWidgetRepo.getAllForColumn('col1'))
          .thenAnswer((_) async => Success(widgets));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final tree = result.valueOrNull!;

      // Verify menu level
      expect(tree.menu.id, menuId);

      // Verify page level
      expect(tree.pages.length, 1);
      expect(tree.pages[0].page.id, 'p1');

      // Verify container level
      expect(tree.pages[0].containers.length, 1);
      expect(tree.pages[0].containers[0].container.id, 'c1');

      // Verify column level
      expect(tree.pages[0].containers[0].columns.length, 1);
      expect(tree.pages[0].containers[0].columns[0].column.id, 'col1');

      // Verify widget level
      expect(tree.pages[0].containers[0].columns[0].widgets.length, 1);
      expect(tree.pages[0].containers[0].columns[0].widgets[0].id, 'w1');
      expect(
        tree.pages[0].containers[0].columns[0].widgets[0].props['text'],
        'Hello',
      );
    });

    test('should handle empty collections at each level', () async {
      // Arrange
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => const Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => const Success([]));

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
