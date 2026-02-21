import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

class MockFetchMenuTreeUseCase extends Mock implements FetchMenuTreeUseCase {}

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

void main() {
  late DuplicateMenuUseCase useCase;
  late MockFetchMenuTreeUseCase mockFetchMenuTreeUseCase;
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late MockSizeRepository mockSizeRepository;

  setUp(() {
    mockFetchMenuTreeUseCase = MockFetchMenuTreeUseCase();
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();
    mockSizeRepository = MockSizeRepository();

    useCase = DuplicateMenuUseCase(
      fetchMenuTreeUseCase: mockFetchMenuTreeUseCase,
      menuRepository: mockMenuRepository,
      pageRepository: mockPageRepository,
      containerRepository: mockContainerRepository,
      columnRepository: mockColumnRepository,
      widgetRepository: mockWidgetRepository,
      sizeRepository: mockSizeRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateMenuInput(name: 'fallback', version: '1.0.0'),
    );
    registerFallbackValue(
      const CreatePageInput(menuId: 0, name: 'fallback', index: 0),
    );
    registerFallbackValue(
      const CreateContainerInput(pageId: 0, index: 0, direction: 'row'),
    );
    registerFallbackValue(const CreateColumnInput(containerId: 0, index: 0));
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: 0,
        type: 'fallback',
        version: '1.0.0',
        index: 0,
        props: {},
      ),
    );
  });

  group('DuplicateMenuUseCase', () {
    test('should return failure when fetch tree fails', () async {
      // Arrange
      const error = NotFoundError('Menu not found');
      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
      verify(() => mockFetchMenuTreeUseCase.execute(1)).called(1);
    });

    test(
      'should create menu with " (copy)" name and draft status when pageSize is null',
      () async {
        // Arrange
        const sourceMenu = Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
          pageSize: null,
        );
        const menuTree = MenuTree(menu: sourceMenu, pages: []);
        const newMenu = Menu(
          id: 2,
          name: 'Summer Menu (copy)',
          status: Status.draft,
          version: '1.0.0',
        );

        when(
          () => mockFetchMenuTreeUseCase.execute(1),
        ).thenAnswer((_) async => const Success(menuTree));
        when(
          () => mockMenuRepository.create(any()),
        ).thenAnswer((_) async => const Success(newMenu));

        // Act
        await useCase.execute(1);

        // Assert
        final captured =
            verify(
                  () => mockMenuRepository.create(captureAny()),
                ).captured.single
                as CreateMenuInput;

        expect(captured.name, 'Summer Menu (copy)');
        expect(captured.status, Status.draft);
        expect(captured.version, '1.0.0');
        expect(captured.sizeId, null);
        verifyNever(() => mockSizeRepository.getAll());
      },
    );

    test('should resolve sizeId when pageSize is present', () async {
      // Arrange
      const sourceMenu = Menu(
        id: 1,
        name: 'Summer Menu',
        status: Status.published,
        version: '1.0.0',
        pageSize: PageSize(name: 'A4', width: 210, height: 297),
      );
      const menuTree = MenuTree(menu: sourceMenu, pages: []);
      const matchingSize = Size(
        id: 5,
        name: 'A4',
        width: 210,
        height: 297,
        status: Status.published,
        direction: 'portrait',
      );
      const newMenu = Menu(
        id: 2,
        name: 'Summer Menu (copy)',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Success(menuTree));
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success([matchingSize]));
      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(newMenu));

      // Act
      await useCase.execute(1);

      // Assert
      final captured =
          verify(() => mockMenuRepository.create(captureAny())).captured.single
              as CreateMenuInput;

      expect(captured.sizeId, 5);
      verify(() => mockSizeRepository.getAll()).called(1);
    });

    test('should return failure when sizeRepository.getAll fails', () async {
      // Arrange
      const sourceMenu = Menu(
        id: 1,
        name: 'Summer Menu',
        status: Status.published,
        version: '1.0.0',
        pageSize: PageSize(name: 'A4', width: 210, height: 297),
      );
      const menuTree = MenuTree(menu: sourceMenu, pages: []);
      const error = ServerError('Failed to fetch sizes');

      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Success(menuTree));
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
      verify(() => mockSizeRepository.getAll()).called(1);
      verifyNever(() => mockMenuRepository.create(any()));
    });

    test('should return failure when menuRepository.create fails', () async {
      // Arrange
      const sourceMenu = Menu(
        id: 1,
        name: 'Summer Menu',
        status: Status.published,
        version: '1.0.0',
      );
      const menuTree = MenuTree(menu: sourceMenu, pages: []);
      const error = ValidationError('Menu name already exists');

      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Success(menuTree));
      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Failure(error));

      // Act
      final result = await useCase.execute(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
      verify(() => mockMenuRepository.create(any())).called(1);
    });

    test('should copy pages with new menuId', () async {
      // Arrange
      const sourceMenu = Menu(
        id: 1,
        name: 'Summer Menu',
        status: Status.published,
        version: '1.0.0',
      );
      const page1 = Page(
        id: 10,
        menuId: 1,
        name: 'Page 1',
        index: 0,
        type: PageType.content,
      );
      const page2 = Page(
        id: 11,
        menuId: 1,
        name: 'Page 2',
        index: 1,
        type: PageType.content,
      );
      const menuTree = MenuTree(
        menu: sourceMenu,
        pages: [
          PageWithContainers(page: page1, containers: []),
          PageWithContainers(page: page2, containers: []),
        ],
      );
      const newMenu = Menu(
        id: 2,
        name: 'Summer Menu (copy)',
        status: Status.draft,
        version: '1.0.0',
      );
      const newPage1 = Page(
        id: 20,
        menuId: 2,
        name: 'Page 1',
        index: 0,
        type: PageType.content,
      );
      const newPage2 = Page(
        id: 21,
        menuId: 2,
        name: 'Page 2',
        index: 1,
        type: PageType.content,
      );

      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Success(menuTree));
      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(newMenu));
      when(() => mockPageRepository.create(any())).thenAnswer((
        invocation,
      ) async {
        final input = invocation.positionalArguments[0] as CreatePageInput;
        if (input.name == 'Page 1') {
          return const Success(newPage1);
        } else {
          return const Success(newPage2);
        }
      });

      // Act
      await useCase.execute(1);

      // Assert
      final capturedPages = verify(
        () => mockPageRepository.create(captureAny()),
      ).captured;

      expect(capturedPages.length, 2);

      final input1 = capturedPages[0] as CreatePageInput;
      expect(input1.menuId, 2);
      expect(input1.name, 'Page 1');
      expect(input1.index, 0);
      expect(input1.type, PageType.content);

      final input2 = capturedPages[1] as CreatePageInput;
      expect(input2.menuId, 2);
      expect(input2.name, 'Page 2');
      expect(input2.index, 1);
      expect(input2.type, PageType.content);
    });

    test('should rollback menu when page creation fails', () async {
      // Arrange
      const sourceMenu = Menu(
        id: 1,
        name: 'Summer Menu',
        status: Status.published,
        version: '1.0.0',
      );
      const page1 = Page(
        id: 10,
        menuId: 1,
        name: 'Page 1',
        index: 0,
        type: PageType.content,
      );
      const page2 = Page(
        id: 11,
        menuId: 1,
        name: 'Page 2',
        index: 1,
        type: PageType.content,
      );
      const menuTree = MenuTree(
        menu: sourceMenu,
        pages: [
          PageWithContainers(page: page1, containers: []),
          PageWithContainers(page: page2, containers: []),
        ],
      );
      const newMenu = Menu(
        id: 2,
        name: 'Summer Menu (copy)',
        status: Status.draft,
        version: '1.0.0',
      );
      const newPage1 = Page(
        id: 20,
        menuId: 2,
        name: 'Page 1',
        index: 0,
        type: PageType.content,
      );
      const error = ServerError('Failed to create page');

      when(
        () => mockFetchMenuTreeUseCase.execute(1),
      ).thenAnswer((_) async => const Success(menuTree));
      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(newMenu));
      when(() => mockPageRepository.create(any())).thenAnswer((
        invocation,
      ) async {
        final input = invocation.positionalArguments[0] as CreatePageInput;
        if (input.name == 'Page 1') {
          return const Success(newPage1);
        } else {
          return const Failure(error);
        }
      });
      when(
        () => mockMenuRepository.delete(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockPageRepository.delete(any()),
      ).thenAnswer((_) async => const Success(null));

      // Act
      final result = await useCase.execute(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);
      verify(() => mockPageRepository.delete(20)).called(1);
      verify(() => mockMenuRepository.delete(2)).called(1);
    });

    test(
      'should copy full tree with containers, columns, and widgets',
      () async {
        // Arrange: Build a comprehensive menu tree
        const sourceMenu = Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        );

        // Page with containers, columns, and widgets
        const page = Page(
          id: 10,
          menuId: 1,
          name: 'Page 1',
          index: 0,
          type: PageType.content,
        );

        final menuTree = MenuTree(
          menu: sourceMenu,
          pages: [
            PageWithContainers(
              page: page,
              containers: [
                ContainerWithColumns(
                  container: const Container(
                    id: 100,
                    pageId: 10,
                    index: 0,
                    name: 'Container 1',
                  ),
                  columns: [
                    ColumnWithWidgets(
                      column: const Column(
                        id: 1000,
                        containerId: 100,
                        index: 0,
                      ),
                      widgets: const [
                        WidgetInstance(
                          id: 10000,
                          columnId: 1000,
                          type: 'dish',
                          version: '1.0.0',
                          index: 0,
                          props: {'name': 'Pasta'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        const newMenu = Menu(
          id: 2,
          name: 'Summer Menu (copy)',
          status: Status.draft,
          version: '1.0.0',
        );
        const newPage = Page(
          id: 20,
          menuId: 2,
          name: 'Page 1',
          index: 0,
          type: PageType.content,
        );
        const newContainer = Container(
          id: 200,
          pageId: 20,
          index: 0,
          name: 'Container 1',
        );
        const newColumn = Column(id: 2000, containerId: 200, index: 0);
        const newWidget = WidgetInstance(
          id: 20000,
          columnId: 2000,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {'name': 'Pasta'},
        );

        when(
          () => mockFetchMenuTreeUseCase.execute(1),
        ).thenAnswer((_) async => Success(menuTree));
        when(
          () => mockMenuRepository.create(any()),
        ).thenAnswer((_) async => const Success(newMenu));
        when(
          () => mockPageRepository.create(any()),
        ).thenAnswer((_) async => const Success(newPage));
        when(
          () => mockContainerRepository.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepository.create(any()),
        ).thenAnswer((_) async => const Success(newColumn));
        when(
          () => mockWidgetRepository.create(any()),
        ).thenAnswer((_) async => const Success(newWidget));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull, newMenu);

        // Verify all entities were created
        verify(() => mockMenuRepository.create(any())).called(1);
        verify(() => mockPageRepository.create(any())).called(1);
        verify(() => mockContainerRepository.create(any())).called(1);
        verify(() => mockColumnRepository.create(any())).called(1);

        // Verify widget props were deep-copied
        final capturedWidget =
            verify(
                  () => mockWidgetRepository.create(captureAny()),
                ).captured.single
                as CreateWidgetInput;
        expect(capturedWidget.columnId, 2000);
        expect(capturedWidget.type, 'dish');
        expect(capturedWidget.props, {'name': 'Pasta'});
        expect(capturedWidget.isTemplate, false);
      },
    );
  });
}
