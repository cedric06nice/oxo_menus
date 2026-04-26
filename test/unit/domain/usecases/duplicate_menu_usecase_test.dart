import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

import '../../../fakes/builders/column_builder.dart';
import '../../../fakes/builders/container_builder.dart';
import '../../../fakes/builders/menu_builder.dart';
import '../../../fakes/builders/page_builder.dart';
import '../../../fakes/builders/size_builder.dart';
import '../../../fakes/builders/widget_instance_builder.dart';
import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_fetch_menu_tree_usecase.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_page_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/fake_widget_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('DuplicateMenuUseCase', () {
    late FakeFetchMenuTreeUseCase fetchMenuTree;
    late FakeMenuRepository menuRepo;
    late FakePageRepository pageRepo;
    late FakeContainerRepository containerRepo;
    late FakeColumnRepository columnRepo;
    late FakeWidgetRepository widgetRepo;
    late FakeSizeRepository sizeRepo;
    late DuplicateMenuUseCase useCase;

    setUp(() {
      fetchMenuTree = FakeFetchMenuTreeUseCase();
      menuRepo = FakeMenuRepository();
      pageRepo = FakePageRepository();
      containerRepo = FakeContainerRepository();
      columnRepo = FakeColumnRepository();
      widgetRepo = FakeWidgetRepository();
      sizeRepo = FakeSizeRepository();

      useCase = DuplicateMenuUseCase(
        fetchMenuTreeUseCase: fetchMenuTree,
        menuRepository: menuRepo,
        pageRepository: pageRepo,
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
        sizeRepository: sizeRepo,
      );
    });

    MenuTree buildEmptyTree({int menuId = 1, String menuName = 'Lunch'}) {
      return MenuTree(menu: buildMenu(id: menuId, name: menuName), pages: []);
    }

    // -------------------------------------------------------------------------
    // Tree fetch failure
    // -------------------------------------------------------------------------

    group('tree fetch failure', () {
      test(
        'should return Failure when fetchMenuTreeUseCase fails',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(failure(notFound()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Size resolution failure
    // -------------------------------------------------------------------------

    group('size resolution failure', () {
      test(
        'should return Failure when sizeRepository.getAll fails',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1, pageSize: buildPageSize()),
            pages: [],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Menu creation failure
    // -------------------------------------------------------------------------

    group('menu creation failure', () {
      test(
        'should return Failure when menuRepository.create fails',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(Success(buildEmptyTree()));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Empty source menu
    // -------------------------------------------------------------------------

    group('empty source menu', () {
      test(
        'should create new menu with "(copy)" suffix when source has no pages',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(Success(buildEmptyTree(menuName: 'Lunch')));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 99, name: 'Lunch (copy)')));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, equals('Lunch (copy)'));
        },
      );

      test(
        'should create new menu with draft status regardless of source status',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(
            Success(
              MenuTree(
                menu: buildMenu(
                  id: 1,
                  name: 'Dinner',
                  status: Status.published,
                ),
                pages: [],
              ),
            ),
          );
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(menuRepo.createCalls.single.input.status, equals(Status.draft));
        },
      );

      test(
        'should not call pageRepository when source menu has no pages',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(Success(buildEmptyTree()));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(pageRepo.createCalls, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Page duplication
    // -------------------------------------------------------------------------

    group('page duplication', () {
      test(
        'should create page with the menuId of the new menu',
        () async {
          // Arrange
          final sourcePage =
              buildPage(id: 10, menuId: 1, type: PageType.content);
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [PageWithContainers(page: sourcePage, containers: [])],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(pageRepo.createCalls.single.input.menuId, equals(55));
        },
      );

      test(
        'should preserve page index from source',
        () async {
          // Arrange
          final sourcePage = buildPage(
            id: 10,
            menuId: 1,
            index: 3,
            type: PageType.content,
          );
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [PageWithContainers(page: sourcePage, containers: [])],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55, index: 3)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(pageRepo.createCalls.single.input.index, equals(3));
        },
      );

      test(
        'should copy header and footer pages alongside content pages',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 11, menuId: 1, type: PageType.content),
                containers: [],
              ),
            ],
            headerPage: PageWithContainers(
              page: buildPage(id: 10, menuId: 1, type: PageType.header),
              containers: [],
            ),
            footerPage: PageWithContainers(
              page: buildPage(id: 12, menuId: 1, type: PageType.footer),
              containers: [],
            ),
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(pageRepo.createCalls.length, equals(3));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Container duplication
    // -------------------------------------------------------------------------

    group('container duplication', () {
      test(
        'should create container with the pageId of the new page',
        () async {
          // Arrange
          final sourceContainer =
              buildContainer(id: 100, pageId: 10, index: 0);
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: sourceContainer,
                    columns: [],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 200, pageId: 20)),
          );

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(containerRepo.createCalls.single.input.pageId, equals(20));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Column duplication
    // -------------------------------------------------------------------------

    group('column duplication', () {
      test(
        'should create column linked to the new container id',
        () async {
          // Arrange
          final sourceColumn = buildColumn(id: 200, containerId: 100);
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [
                      ColumnWithWidgets(column: sourceColumn, widgets: []),
                    ],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 300, pageId: 20)),
          );
          columnRepo.whenCreate(
            success(buildColumn(id: 400, containerId: 300)),
          );

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            columnRepo.createCalls.single.input.containerId,
            equals(300),
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // Widget duplication
    // -------------------------------------------------------------------------

    group('widget duplication', () {
      test(
        'should create widget linked to the new column id',
        () async {
          // Arrange
          final sourceWidget = buildWidgetInstance(
            id: 300,
            columnId: 200,
            type: 'dish',
          );
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [
                      ColumnWithWidgets(
                        column: buildColumn(id: 200, containerId: 100),
                        widgets: [sourceWidget],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 200, pageId: 20)),
          );
          columnRepo.whenCreate(
            success(buildColumn(id: 300, containerId: 200)),
          );
          widgetRepo.whenCreate(
            success(buildWidgetInstance(id: 400, columnId: 300)),
          );

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(widgetRepo.createCalls.single.input.columnId, equals(300));
        },
      );

      test(
        'should preserve widget type from source',
        () async {
          // Arrange
          final sourceWidget = buildWidgetInstance(
            id: 300,
            columnId: 200,
            type: 'wine',
            index: 2,
          );
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [
                      ColumnWithWidgets(
                        column: buildColumn(id: 200, containerId: 100),
                        widgets: [sourceWidget],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 200, pageId: 20)),
          );
          columnRepo.whenCreate(
            success(buildColumn(id: 300, containerId: 200)),
          );
          widgetRepo.whenCreate(
            success(buildWidgetInstance(id: 400, columnId: 300)),
          );

          // Act
          await useCase.execute(1);

          // Assert
          expect(widgetRepo.createCalls.single.input.type, equals('wine'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Size resolution
    // -------------------------------------------------------------------------

    group('size resolution', () {
      test(
        'should not call sizeRepository when source menu has no pageSize',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1, pageSize: null),
            pages: [],
          );
          fetchMenuTree.stubExecute(Success(tree));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(sizeRepo.getAllCalls, isEmpty);
          expect(menuRepo.createCalls.single.input.sizeId, isNull);
        },
      );

      test(
        'should pass resolved sizeId when a matching size exists in repository',
        () async {
          // Arrange
          final pageSize = buildPageSize(name: 'A4', width: 210, height: 297);
          final matchingSize = buildSize(id: 7, name: 'A4', width: 210, height: 297);
          final tree = MenuTree(
            menu: buildMenu(id: 1, pageSize: pageSize),
            pages: [],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([matchingSize]));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(menuRepo.createCalls.single.input.sizeId, equals(7));
        },
      );

      test(
        'should pass null sizeId when no matching size exists in repository',
        () async {
          // Arrange
          final pageSize = buildPageSize(name: 'Custom', width: 100, height: 200);
          final tree = MenuTree(
            menu: buildMenu(id: 1, pageSize: pageSize),
            pages: [],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([buildSize(id: 1, name: 'A4')]));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(menuRepo.createCalls.single.input.sizeId, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on page creation failure
    // -------------------------------------------------------------------------

    group('rollback on page creation failure', () {
      test(
        'should delete the newly created menu when page creation fails',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(failure(server()));
          menuRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(menuRepo.deleteCalls.single.id, equals(55));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on container creation failure
    // -------------------------------------------------------------------------

    group('rollback on container creation failure', () {
      test(
        'should delete menu and created pages when container creation fails',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(failure(server()));
          pageRepo.whenDelete(success(null));
          menuRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(pageRepo.deleteCalls.any((c) => c.id == 20), isTrue);
          expect(menuRepo.deleteCalls.any((c) => c.id == 55), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on column creation failure
    // -------------------------------------------------------------------------

    group('rollback on column creation failure', () {
      test(
        'should delete container, page, and menu when column creation fails',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [
                      ColumnWithWidgets(
                        column: buildColumn(id: 200, containerId: 100),
                        widgets: [],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 200, pageId: 20)),
          );
          columnRepo.whenCreate(failure(server()));
          containerRepo.whenDelete(success(null));
          pageRepo.whenDelete(success(null));
          menuRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(containerRepo.deleteCalls.any((c) => c.id == 200), isTrue);
          expect(pageRepo.deleteCalls.any((c) => c.id == 20), isTrue);
          expect(menuRepo.deleteCalls.any((c) => c.id == 55), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on widget creation failure
    // -------------------------------------------------------------------------

    group('rollback on widget creation failure', () {
      test(
        'should delete column, container, page, and menu when widget creation fails',
        () async {
          // Arrange
          final tree = MenuTree(
            menu: buildMenu(id: 1),
            pages: [
              PageWithContainers(
                page: buildPage(id: 10, menuId: 1, type: PageType.content),
                containers: [
                  ContainerWithColumns(
                    container: buildContainer(id: 100, pageId: 10),
                    columns: [
                      ColumnWithWidgets(
                        column: buildColumn(id: 200, containerId: 100),
                        widgets: [buildWidgetInstance(id: 300, columnId: 200)],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
          fetchMenuTree.stubExecute(Success(tree));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 55)));
          pageRepo.whenCreate(success(buildPage(id: 20, menuId: 55)));
          containerRepo.whenCreate(
            success(buildContainer(id: 200, pageId: 20)),
          );
          columnRepo.whenCreate(
            success(buildColumn(id: 300, containerId: 200)),
          );
          widgetRepo.whenCreate(failure(server()));
          columnRepo.whenDelete(success(null));
          containerRepo.whenDelete(success(null));
          pageRepo.whenDelete(success(null));
          menuRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(columnRepo.deleteCalls.any((c) => c.id == 300), isTrue);
          expect(containerRepo.deleteCalls.any((c) => c.id == 200), isTrue);
          expect(pageRepo.deleteCalls.any((c) => c.id == 20), isTrue);
          expect(menuRepo.deleteCalls.any((c) => c.id == 55), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Multiple invocations
    // -------------------------------------------------------------------------

    group('multiple invocations', () {
      test(
        'should succeed on a second invocation after the first succeeds',
        () async {
          // Arrange
          fetchMenuTree.stubExecute(Success(buildEmptyTree()));
          sizeRepo.whenGetAll(success([]));
          menuRepo.whenCreate(success(buildMenu(id: 99)));

          // Act
          final first = await useCase.execute(1);
          menuRepo.whenCreate(success(buildMenu(id: 100)));
          final second = await useCase.execute(1);

          // Assert
          expect(first.isSuccess, isTrue);
          expect(second.isSuccess, isTrue);
          expect(menuRepo.createCalls.length, equals(2));
        },
      );
    });
  });
}
