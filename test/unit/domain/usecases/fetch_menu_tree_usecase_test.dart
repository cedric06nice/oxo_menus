import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

import '../../../fakes/builders/column_builder.dart';
import '../../../fakes/builders/container_builder.dart';
import '../../../fakes/builders/menu_builder.dart';
import '../../../fakes/builders/page_builder.dart';
import '../../../fakes/builders/widget_instance_builder.dart';
import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_page_repository.dart';
import '../../../fakes/fake_widget_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('FetchMenuTreeUseCase', () {
    late FakeMenuRepository menuRepo;
    late FakePageRepository pageRepo;
    late FakeContainerRepository containerRepo;
    late FakeColumnRepository columnRepo;
    late FakeWidgetRepository widgetRepo;
    late FetchMenuTreeUseCase useCase;

    setUp(() {
      menuRepo = FakeMenuRepository();
      pageRepo = FakePageRepository();
      containerRepo = FakeContainerRepository();
      columnRepo = FakeColumnRepository();
      widgetRepo = FakeWidgetRepository();

      useCase = FetchMenuTreeUseCase(
        menuRepository: menuRepo,
        pageRepository: pageRepo,
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      );
    });

    // -------------------------------------------------------------------------
    // Repository failures
    // -------------------------------------------------------------------------

    group('repository failures', () {
      test('should return Failure when menuRepository.getById fails', () async {
        // Arrange
        menuRepo.whenGetById(failure(network()));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
      });

      test(
        'should return Failure when pageRepository.getAllForMenu fails',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test(
        'should return Failure when containerRepository.getAllForPage fails',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure when columnRepository.getAllForContainer fails',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure when widgetRepository.getAllForColumn fails',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(
            success([buildColumn(id: 200, containerId: 100)]),
          );
          containerRepo.whenGetAllForContainer(success([]));
          widgetRepo.whenGetAllForColumn(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure when containerRepository.getAllForContainer fails',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Empty menu (no pages)
    // -------------------------------------------------------------------------

    group('empty menu', () {
      test(
        'should return MenuTree with empty pages when menu has no pages',
        () async {
          // Arrange
          final menu = buildMenu(id: 1, name: 'Empty Menu');
          menuRepo.whenGetById(success(menu));
          pageRepo.whenGetAllForMenu(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final tree = result.valueOrNull!;
          expect(tree.menu, equals(menu));
          expect(tree.pages, isEmpty);
          expect(tree.headerPage, isNull);
          expect(tree.footerPage, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Empty containers and columns
    // -------------------------------------------------------------------------

    group('empty containers and columns', () {
      test(
        'should return page with empty containers when page has no containers',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.pages.first.containers, isEmpty);
        },
      );

      test(
        'should return ContainerWithColumns with empty columns when container has no columns',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            result.valueOrNull!.pages.first.containers.first.columns,
            isEmpty,
          );
        },
      );

      test(
        'should return ColumnWithWidgets with empty widgets when column has no widgets',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(
            success([buildColumn(id: 200, containerId: 100)]),
          );
          containerRepo.whenGetAllForContainer(success([]));
          widgetRepo.whenGetAllForColumn(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            result
                .valueOrNull!
                .pages
                .first
                .containers
                .first
                .columns
                .first
                .widgets,
            isEmpty,
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // Page type categorisation
    // -------------------------------------------------------------------------

    group('page type categorisation', () {
      test('should assign header page to headerPage field', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 1)));
        pageRepo.whenGetAllForMenu(
          success([buildPage(id: 10, menuId: 1, type: PageType.header)]),
        );
        containerRepo.whenGetAllForPage(success([]));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final tree = result.valueOrNull!;
        expect(tree.headerPage, isNotNull);
        expect(tree.headerPage!.page.type, equals(PageType.header));
        expect(tree.pages, isEmpty);
      });

      test('should assign footer page to footerPage field', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 1)));
        pageRepo.whenGetAllForMenu(
          success([buildPage(id: 10, menuId: 1, type: PageType.footer)]),
        );
        containerRepo.whenGetAllForPage(success([]));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final tree = result.valueOrNull!;
        expect(tree.footerPage, isNotNull);
        expect(tree.footerPage!.page.type, equals(PageType.footer));
        expect(tree.pages, isEmpty);
      });

      test(
        'should place content pages in pages list and leave header and footer null when only content pages exist',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([
              buildPage(id: 10, menuId: 1, type: PageType.content, index: 0),
              buildPage(id: 11, menuId: 1, type: PageType.content, index: 1),
            ]),
          );
          containerRepo.whenGetAllForPage(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.pages.length, equals(2));
          expect(result.valueOrNull!.headerPage, isNull);
          expect(result.valueOrNull!.footerPage, isNull);
        },
      );

      test(
        'should separate header, footer, and content pages when all three types are present',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([
              buildPage(id: 10, menuId: 1, type: PageType.header),
              buildPage(id: 11, menuId: 1, type: PageType.content, index: 0),
              buildPage(id: 12, menuId: 1, type: PageType.footer),
            ]),
          );
          containerRepo.whenGetAllForPage(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final tree = result.valueOrNull!;
          expect(tree.headerPage, isNotNull);
          expect(tree.footerPage, isNotNull);
          expect(tree.pages.length, equals(1));
          expect(tree.pages.first.page.id, equals(11));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Sort order
    // -------------------------------------------------------------------------

    group('sort order', () {
      test('should sort pages by index ascending', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 1)));
        pageRepo.whenGetAllForMenu(
          success([
            buildPage(id: 13, menuId: 1, index: 2, type: PageType.content),
            buildPage(id: 11, menuId: 1, index: 0, type: PageType.content),
            buildPage(id: 12, menuId: 1, index: 1, type: PageType.content),
          ]),
        );
        containerRepo.whenGetAllForPage(success([]));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final pages = result.valueOrNull!.pages;
        expect(pages[0].page.id, equals(11));
        expect(pages[1].page.id, equals(12));
        expect(pages[2].page.id, equals(13));
      });

      test('should sort containers within a page by index ascending', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 1)));
        pageRepo.whenGetAllForMenu(
          success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
        );
        containerRepo.whenGetAllForPage(
          success([
            buildContainer(id: 102, pageId: 10, index: 2),
            buildContainer(id: 100, pageId: 10, index: 0),
            buildContainer(id: 101, pageId: 10, index: 1),
          ]),
        );
        columnRepo.whenGetAllForContainer(success([]));
        containerRepo.whenGetAllForContainer(success([]));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final containers = result.valueOrNull!.pages.first.containers;
        expect(containers[0].container.id, equals(100));
        expect(containers[1].container.id, equals(101));
        expect(containers[2].container.id, equals(102));
      });

      test(
        'should sort columns within a container by index ascending',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(
            success([
              buildColumn(id: 202, containerId: 100, index: 2),
              buildColumn(id: 200, containerId: 100, index: 0),
              buildColumn(id: 201, containerId: 100, index: 1),
            ]),
          );
          containerRepo.whenGetAllForContainer(success([]));
          widgetRepo.whenGetAllForColumn(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final cols = result.valueOrNull!.pages.first.containers.first.columns;
          expect(cols[0].column.id, equals(200));
          expect(cols[1].column.id, equals(201));
          expect(cols[2].column.id, equals(202));
        },
      );

      test('should sort widgets within a column by index ascending', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 1)));
        pageRepo.whenGetAllForMenu(
          success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
        );
        containerRepo.whenGetAllForPage(
          success([buildContainer(id: 100, pageId: 10)]),
        );
        columnRepo.whenGetAllForContainer(
          success([buildColumn(id: 200, containerId: 100)]),
        );
        containerRepo.whenGetAllForContainer(success([]));
        widgetRepo.whenGetAllForColumn(
          success([
            buildWidgetInstance(id: 302, columnId: 200, index: 2),
            buildWidgetInstance(id: 300, columnId: 200, index: 0),
            buildWidgetInstance(id: 301, columnId: 200, index: 1),
          ]),
        );

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final widgets = result
            .valueOrNull!
            .pages
            .first
            .containers
            .first
            .columns
            .first
            .widgets;
        expect(widgets[0].id, equals(300));
        expect(widgets[1].id, equals(301));
        expect(widgets[2].id, equals(302));
      });
    });

    // -------------------------------------------------------------------------
    // Full tree assembly
    // -------------------------------------------------------------------------

    group('full tree assembly', () {
      test('should assemble complete tree with correct nesting', () async {
        // Arrange
        final menu = buildMenu(id: 5, name: 'Dinner');
        final page = buildPage(id: 10, menuId: 5, type: PageType.content);
        final container = buildContainer(id: 100, pageId: 10);
        final column = buildColumn(id: 200, containerId: 100);
        final widget1 = buildWidgetInstance(
          id: 300,
          columnId: 200,
          type: 'dish',
        );

        menuRepo.whenGetById(success(menu));
        pageRepo.whenGetAllForMenu(success([page]));
        containerRepo.whenGetAllForPage(success([container]));
        columnRepo.whenGetAllForContainer(success([column]));
        containerRepo.whenGetAllForContainer(success([]));
        widgetRepo.whenGetAllForColumn(success([widget1]));

        // Act
        final result = await useCase.execute(5);

        // Assert
        expect(result.isSuccess, isTrue);
        final tree = result.valueOrNull!;
        expect(tree.menu.id, equals(5));
        expect(tree.pages.length, equals(1));
        final pageWithContainers = tree.pages.first;
        expect(pageWithContainers.containers.length, equals(1));
        final containerWithColumns = pageWithContainers.containers.first;
        expect(containerWithColumns.columns.length, equals(1));
        final columnWithWidgets = containerWithColumns.columns.first;
        expect(columnWithWidgets.widgets.length, equals(1));
        expect(columnWithWidgets.widgets.first.id, equals(300));
      });

      test(
        'should include child containers in ContainerWithColumns.children',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([buildPage(id: 10, menuId: 1, type: PageType.content)]),
          );
          final parentContainer = buildContainer(id: 100, pageId: 10);
          final childContainer = buildContainer(
            id: 101,
            pageId: 10,
            parentContainerId: 100,
          );
          containerRepo.whenGetAllForPage(success([parentContainer]));
          columnRepo.whenGetAllForContainer(success([]));
          // Parent container (100) has one child; child container (101) has none.
          containerRepo.whenGetAllForContainerForId(
            100,
            success([childContainer]),
          );
          containerRepo.whenGetAllForContainerForId(101, success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final topContainer = result.valueOrNull!.pages.first.containers.first;
          expect(topContainer.children.length, equals(1));
          expect(topContainer.children.first.container.id, equals(101));
        },
      );

      test(
        'should pass correct menuId to pageRepository.getAllForMenu',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 42)));
          pageRepo.whenGetAllForMenu(success([]));

          // Act
          await useCase.execute(42);

          // Assert
          expect(pageRepo.getAllForMenuCalls.single.menuId, equals(42));
        },
      );

      test('should pass correct id to menuRepository.getById', () async {
        // Arrange
        menuRepo.whenGetById(success(buildMenu(id: 99)));
        pageRepo.whenGetAllForMenu(success([]));

        // Act
        await useCase.execute(99);

        // Assert
        expect(menuRepo.getByIdCalls.single.id, equals(99));
      });

      test(
        'should not leak containers from one page into another page',
        () async {
          // Arrange
          menuRepo.whenGetById(success(buildMenu(id: 1)));
          pageRepo.whenGetAllForMenu(
            success([
              buildPage(id: 10, menuId: 1, type: PageType.content, index: 0),
              buildPage(id: 11, menuId: 1, type: PageType.content, index: 1),
            ]),
          );
          // Single fake response shared for both pages — both get the same
          // containers list (one element each call).  This verifies the tree
          // builder calls getAllForPage once per page.
          containerRepo.whenGetAllForPage(
            success([buildContainer(id: 100, pageId: 10)]),
          );
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          // getAllForPage called once per page (2 pages)
          expect(containerRepo.getAllForPageCalls.length, equals(2));
        },
      );
    });
  });
}
