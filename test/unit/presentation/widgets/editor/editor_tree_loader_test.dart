import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';

import '../../../../fakes/fake_column_repository.dart';
import '../../../../fakes/fake_container_repository.dart';
import '../../../../fakes/fake_menu_repository.dart';
import '../../../../fakes/fake_page_repository.dart';
import '../../../../fakes/fake_widget_repository.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test fixtures
  // ---------------------------------------------------------------------------

  const testMenu = Menu(
    id: 1,
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0',
  );

  const pageA = entity.Page(id: 10, menuId: 1, name: 'Page A', index: 1);
  const pageB = entity.Page(id: 11, menuId: 1, name: 'Page B', index: 0);

  const containerOnPageB = entity.Container(id: 20, pageId: 11, index: 0);

  const columnInContainer20 = entity.Column(id: 30, containerId: 20, index: 0);

  const widgetInColumn30 = WidgetInstance(
    id: 40,
    columnId: 30,
    type: 'text',
    version: '1.0',
    index: 0,
    props: {'text': 'Hello'},
  );

  // ---------------------------------------------------------------------------
  // SUT helpers
  // ---------------------------------------------------------------------------

  EditorTreeLoader makeLoader({
    required FakeMenuRepository menuRepo,
    required FakePageRepository pageRepo,
    required FakeContainerRepository containerRepo,
    required FakeColumnRepository columnRepo,
    required FakeWidgetRepository widgetRepo,
  }) {
    return EditorTreeLoader(
      menuRepository: menuRepo,
      pageRepository: pageRepo,
      containerRepository: containerRepo,
      columnRepository: columnRepo,
      widgetRepository: widgetRepo,
    );
  }

  // ---------------------------------------------------------------------------
  // Groups
  // ---------------------------------------------------------------------------

  group('EditorTreeLoader', () {
    late FakeMenuRepository fakeMenuRepo;
    late FakePageRepository fakePageRepo;
    late FakeContainerRepository fakeContainerRepo;
    late FakeColumnRepository fakeColumnRepo;
    late FakeWidgetRepository fakeWidgetRepo;
    late EditorTreeLoader loader;

    setUp(() {
      fakeMenuRepo = FakeMenuRepository();
      fakePageRepo = FakePageRepository();
      fakeContainerRepo = FakeContainerRepository();
      fakeColumnRepo = FakeColumnRepository();
      fakeWidgetRepo = FakeWidgetRepository();

      loader = makeLoader(
        menuRepo: fakeMenuRepo,
        pageRepo: fakePageRepo,
        containerRepo: fakeContainerRepo,
        columnRepo: fakeColumnRepo,
        widgetRepo: fakeWidgetRepo,
      );
    });

    // -------------------------------------------------------------------------
    // Success path — full tree
    // -------------------------------------------------------------------------

    group('loadTree — success paths', () {
      test(
        'should return a successful EditorTree when all repositories return data',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageA, pageB]));
          fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success([columnInContainer20]));
          fakeWidgetRepo.whenGetAllForColumn(success([widgetInColumn30]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final tree = result.valueOrNull!;
          expect(tree.menu, equals(testMenu));
          expect(tree.pages, hasLength(2));
          expect(tree.containers, isNotEmpty);
          expect(tree.columns, isNotEmpty);
          expect(tree.widgets, isNotEmpty);
        },
      );

      test(
        'should sort pages ascending by index when repository returns them unsorted',
        () async {
          // Arrange — pageA has index 1, pageB has index 0: repo returns [pageA, pageB]
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageA, pageB]));
          fakeContainerRepo.whenGetAllForPage(success(<entity.Container>[]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final pages = result.valueOrNull!.pages;
          expect(pages[0].index, lessThanOrEqualTo(pages[1].index));
          expect(pages.first.id, pageB.id); // pageB has index 0
        },
      );

      test(
        'should sort containers ascending by index when repository returns them unsorted',
        () async {
          // Arrange
          const containerHigh = entity.Container(id: 21, pageId: 11, index: 2);
          const containerLow = entity.Container(id: 22, pageId: 11, index: 1);

          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(
            success([containerHigh, containerLow]),
          );
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success(<entity.Column>[]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final containers = result.valueOrNull!.containers[pageB.id]!;
          expect(containers[0].index, lessThanOrEqualTo(containers[1].index));
        },
      );

      test(
        'should sort columns ascending by index when repository returns them unsorted',
        () async {
          // Arrange
          const colHigh = entity.Column(id: 31, containerId: 20, index: 3);
          const colLow = entity.Column(id: 32, containerId: 20, index: 1);

          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success([colHigh, colLow]));
          fakeWidgetRepo.whenGetAllForColumn(success(<WidgetInstance>[]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final columns = result.valueOrNull!.columns[containerOnPageB.id]!;
          expect(columns[0].index, lessThanOrEqualTo(columns[1].index));
        },
      );

      test(
        'should sort widgets ascending by index when repository returns them unsorted',
        () async {
          // Arrange
          const widgetHigh = WidgetInstance(
            id: 41,
            columnId: 30,
            type: 'text',
            version: '1.0',
            index: 5,
            props: {},
          );
          const widgetLow = WidgetInstance(
            id: 42,
            columnId: 30,
            type: 'text',
            version: '1.0',
            index: 2,
            props: {},
          );

          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success([columnInContainer20]));
          fakeWidgetRepo.whenGetAllForColumn(success([widgetHigh, widgetLow]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final widgets = result.valueOrNull!.widgets[columnInContainer20.id]!;
          expect(widgets[0].index, lessThanOrEqualTo(widgets[1].index));
        },
      );

      test('should return empty collections when there are no pages', () async {
        // Arrange
        fakeMenuRepo.whenGetById(success(testMenu));
        fakePageRepo.whenGetAllForMenu(success(<entity.Page>[]));

        // Act
        final result = await loader.loadTree(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final tree = result.valueOrNull!;
        expect(tree.pages, isEmpty);
        expect(tree.containers, isEmpty);
        expect(tree.columns, isEmpty);
        expect(tree.widgets, isEmpty);
      });

      test('should populate containers keyed by page id', () async {
        // Arrange
        fakeMenuRepo.whenGetById(success(testMenu));
        fakePageRepo.whenGetAllForMenu(success([pageB]));
        fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
        fakeContainerRepo.whenGetAllForContainer(success(<entity.Container>[]));
        fakeColumnRepo.whenGetAllForContainer(success(<entity.Column>[]));

        // Act
        final result = await loader.loadTree(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.containers[pageB.id], hasLength(1));
        expect(
          result.valueOrNull!.containers[pageB.id]!.first.id,
          containerOnPageB.id,
        );
      });

      test('should populate columns keyed by container id', () async {
        // Arrange
        fakeMenuRepo.whenGetById(success(testMenu));
        fakePageRepo.whenGetAllForMenu(success([pageB]));
        fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
        fakeContainerRepo.whenGetAllForContainer(success(<entity.Container>[]));
        fakeColumnRepo.whenGetAllForContainer(success([columnInContainer20]));
        fakeWidgetRepo.whenGetAllForColumn(success(<WidgetInstance>[]));

        // Act
        final result = await loader.loadTree(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.columns[containerOnPageB.id], hasLength(1));
        expect(
          result.valueOrNull!.columns[containerOnPageB.id]!.first.id,
          columnInContainer20.id,
        );
      });

      test('should populate widgets keyed by column id', () async {
        // Arrange
        fakeMenuRepo.whenGetById(success(testMenu));
        fakePageRepo.whenGetAllForMenu(success([pageB]));
        fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
        fakeContainerRepo.whenGetAllForContainer(success(<entity.Container>[]));
        fakeColumnRepo.whenGetAllForContainer(success([columnInContainer20]));
        fakeWidgetRepo.whenGetAllForColumn(success([widgetInColumn30]));

        // Act
        final result = await loader.loadTree(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(
          result.valueOrNull!.widgets[columnInContainer20.id],
          hasLength(1),
        );
        expect(
          result.valueOrNull!.widgets[columnInContainer20.id]!.first.id,
          widgetInColumn30.id,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Failure at menu level
    // -------------------------------------------------------------------------

    group('loadTree — failure at menu level', () {
      test(
        'should return Failure when menu repository returns a ServerError',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(
            failure<Menu>(const ServerError('Menu not found')),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
          expect(result.errorOrNull!.message, 'Menu not found');
        },
      );

      test(
        'should return Failure when menu repository returns a NotFoundError',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(
            failure<Menu>(const NotFoundError('menu 99 not found')),
          );

          // Act
          final result = await loader.loadTree(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Failure at pages level
    // -------------------------------------------------------------------------

    group('loadTree — failure at pages level', () {
      test(
        'should return Failure when page repository returns a ServerError',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(
            failure<List<entity.Page>>(const ServerError('Pages error')),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull!.message, 'Pages error');
        },
      );

      test(
        'should return Failure when page repository returns a NetworkError',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(
            failure<List<entity.Page>>(const NetworkError('offline')),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Container fetch failure is skipped (soft failure)
    // -------------------------------------------------------------------------

    group('loadTree — container fetch failure is skipped', () {
      test(
        'should still succeed with no containers when getAllForPage fails',
        () async {
          // Arrange
          const singlePage = entity.Page(
            id: 11,
            menuId: 1,
            name: 'Page B',
            index: 0,
          );
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([singlePage]));
          fakeContainerRepo.whenGetAllForPage(
            failure<List<entity.Container>>(
              const ServerError('Container error'),
            ),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.containers[singlePage.id], isNull);
        },
      );

      test(
        'should still return columns for a second page when the first page containers fail',
        () async {
          // Arrange
          const page1 = entity.Page(id: 11, menuId: 1, name: 'P1', index: 0);
          const page2 = entity.Page(id: 12, menuId: 1, name: 'P2', index: 1);
          const containerPage2 = entity.Container(id: 21, pageId: 12, index: 0);
          const columnPage2 = entity.Column(id: 31, containerId: 21, index: 0);

          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([page1, page2]));
          // Per-page stubs
          fakeContainerRepo.whenGetAllForPageForId(
            page1.id,
            failure<List<entity.Container>>(const ServerError('fail')),
          );
          fakeContainerRepo.whenGetAllForPageForId(
            page2.id,
            success([containerPage2]),
          );
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success([columnPage2]));
          fakeWidgetRepo.whenGetAllForColumn(success(<WidgetInstance>[]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.containers[page2.id], hasLength(1));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Widget fetch failure is skipped
    // -------------------------------------------------------------------------

    group('loadTree — widget fetch failure is skipped', () {
      test(
        'should succeed with no widgets when getAllForColumn fails',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success([columnInContainer20]));
          fakeWidgetRepo.whenGetAllForColumn(
            failure<List<WidgetInstance>>(const ServerError('widget error')),
          );

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.widgets[columnInContainer20.id], isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Child containers (nested)
    // -------------------------------------------------------------------------

    group('loadTree — nested child containers', () {
      test(
        'should populate childContainers when getAllForContainer returns children',
        () async {
          // Arrange
          const parentContainer = entity.Container(
            id: 20,
            pageId: 11,
            index: 0,
          );
          const childContainer = entity.Container(
            id: 25,
            pageId: 11,
            index: 0,
            parentContainerId: 20,
          );
          const childColumn = entity.Column(id: 35, containerId: 25, index: 0);

          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(success([parentContainer]));
          // Parent container has one child; child has no children
          fakeContainerRepo.whenGetAllForContainerForId(
            parentContainer.id,
            success([childContainer]),
          );
          fakeContainerRepo.whenGetAllForContainerForId(
            childContainer.id,
            success(<entity.Container>[]),
          );
          // Columns: none for parent, one for child
          fakeColumnRepo.whenGetAllForContainerForId(
            parentContainer.id,
            success(<entity.Column>[]),
          );
          fakeColumnRepo.whenGetAllForContainerForId(
            childContainer.id,
            success([childColumn]),
          );
          fakeWidgetRepo.whenGetAllForColumn(success(<WidgetInstance>[]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final tree = result.valueOrNull!;
          expect(tree.containers[pageB.id], hasLength(1));
          expect(tree.childContainers[parentContainer.id], hasLength(1));
          expect(
            tree.childContainers[parentContainer.id]!.first.id,
            childContainer.id,
          );
          expect(tree.columns[childContainer.id], hasLength(1));
        },
      );

      test(
        'should not add an entry to childContainers when getAllForContainer returns empty list',
        () async {
          // Arrange
          fakeMenuRepo.whenGetById(success(testMenu));
          fakePageRepo.whenGetAllForMenu(success([pageB]));
          fakeContainerRepo.whenGetAllForPage(success([containerOnPageB]));
          fakeContainerRepo.whenGetAllForContainer(
            success(<entity.Container>[]),
          );
          fakeColumnRepo.whenGetAllForContainer(success(<entity.Column>[]));

          // Act
          final result = await loader.loadTree(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.childContainers, isEmpty);
        },
      );

      test('should recurse into grandchild containers', () async {
        // Arrange
        const parent = entity.Container(id: 20, pageId: 11, index: 0);
        const child = entity.Container(
          id: 25,
          pageId: 11,
          index: 0,
          parentContainerId: 20,
        );
        const grandchild = entity.Container(
          id: 30,
          pageId: 11,
          index: 0,
          parentContainerId: 25,
        );

        fakeMenuRepo.whenGetById(success(testMenu));
        fakePageRepo.whenGetAllForMenu(success([pageB]));
        fakeContainerRepo.whenGetAllForPage(success([parent]));
        fakeContainerRepo.whenGetAllForContainerForId(
          parent.id,
          success([child]),
        );
        fakeContainerRepo.whenGetAllForContainerForId(
          child.id,
          success([grandchild]),
        );
        fakeContainerRepo.whenGetAllForContainerForId(
          grandchild.id,
          success(<entity.Container>[]),
        );
        fakeColumnRepo.whenGetAllForContainer(success(<entity.Column>[]));

        // Act
        final result = await loader.loadTree(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final tree = result.valueOrNull!;
        expect(tree.childContainers[parent.id], hasLength(1));
        expect(tree.childContainers[child.id], hasLength(1));
        expect(tree.childContainers[child.id]!.first.id, grandchild.id);
      });
    });
  });
}
