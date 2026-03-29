import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart' show ServerError;
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late EditorTreeLoader loader;
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;

  final testMenu = Menu(
    id: 1,
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0',
  );

  final testPages = [
    const entity.Page(id: 10, menuId: 1, name: 'Page 1', index: 1),
    const entity.Page(id: 11, menuId: 1, name: 'Page 0', index: 0),
  ];

  final testContainers = [const entity.Container(id: 20, pageId: 11, index: 0)];

  final testColumns = [const entity.Column(id: 30, containerId: 20, index: 0)];

  final testWidgets = [
    const WidgetInstance(
      id: 40,
      columnId: 30,
      type: 'text',
      version: '1.0',
      index: 0,
      props: {'text': 'Hello'},
    ),
  ];

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();

    loader = EditorTreeLoader(
      menuRepository: mockMenuRepo,
      pageRepository: mockPageRepo,
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      widgetRepository: mockWidgetRepo,
    );

    // Default stub: containers have no children unless overridden
    when(
      () => mockContainerRepo.getAllForContainer(any()),
    ).thenAnswer((_) async => const Success(<entity.Container>[]));
  });

  group('EditorTreeLoader', () {
    test('loads full tree successfully', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => Success(testContainers));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => Success(testColumns));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => Success(testWidgets));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final tree = result.valueOrNull!;
      expect(tree.menu, equals(testMenu));
      expect(tree.pages, hasLength(2));
      // Pages should be sorted by index
      expect(tree.pages.first.id, 11);
      expect(tree.pages.last.id, 10);
      expect(tree.containers[11], hasLength(1));
      expect(tree.columns[20], hasLength(1));
      expect(tree.widgets[30], hasLength(1));
    });

    test('returns failure when menu loading fails', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => const Failure(ServerError('Menu not found')));

      final result = await loader.loadTree(1);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.message, 'Menu not found');
    });

    test('returns failure when pages loading fails', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => const Failure(ServerError('Pages error')));

      final result = await loader.loadTree(1);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.message, 'Pages error');
    });

    test('sorts pages by index', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => const Success(<entity.Container>[]));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final pages = result.valueOrNull!.pages;
      expect(pages[0].index, lessThanOrEqualTo(pages[1].index));
    });

    test('sorts containers by index', () async {
      final unsortedContainers = [
        const entity.Container(id: 21, pageId: 11, index: 1),
        const entity.Container(id: 20, pageId: 11, index: 0),
      ];

      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => Success(unsortedContainers));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => const Success(<entity.Column>[]));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final containers = result.valueOrNull!.containers[11]!;
      expect(containers[0].index, lessThanOrEqualTo(containers[1].index));
    });

    test('sorts columns by index', () async {
      final unsortedColumns = [
        const entity.Column(id: 31, containerId: 20, index: 1),
        const entity.Column(id: 30, containerId: 20, index: 0),
      ];

      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => Success(testContainers));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => Success(unsortedColumns));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final columns = result.valueOrNull!.columns[20]!;
      expect(columns[0].index, lessThanOrEqualTo(columns[1].index));
    });

    test('sorts widgets by index', () async {
      final unsortedWidgets = [
        const WidgetInstance(
          id: 41,
          columnId: 30,
          type: 'text',
          version: '1.0',
          index: 1,
          props: {},
        ),
        const WidgetInstance(
          id: 40,
          columnId: 30,
          type: 'text',
          version: '1.0',
          index: 0,
          props: {},
        ),
      ];

      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(
        () => mockContainerRepo.getAllForPage(any()),
      ).thenAnswer((_) async => Success(testContainers));
      when(
        () => mockColumnRepo.getAllForContainer(any()),
      ).thenAnswer((_) async => Success(testColumns));
      when(
        () => mockWidgetRepo.getAllForColumn(any()),
      ).thenAnswer((_) async => Success(unsortedWidgets));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final widgets = result.valueOrNull!.widgets[30]!;
      expect(widgets[0].index, lessThanOrEqualTo(widgets[1].index));
    });

    test('handles empty pages gracefully', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => const Success(<entity.Page>[]));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final tree = result.valueOrNull!;
      expect(tree.pages, isEmpty);
      expect(tree.containers, isEmpty);
      expect(tree.columns, isEmpty);
      expect(tree.widgets, isEmpty);
    });

    test('loads child containers recursively', () async {
      const parentContainer = entity.Container(id: 20, pageId: 11, index: 0);
      const childContainer = entity.Container(
        id: 25,
        pageId: 11,
        index: 0,
        parentContainerId: 20,
      );
      const childColumn = entity.Column(id: 35, containerId: 25, index: 0);

      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(
        () => mockPageRepo.getAllForMenu(1),
      ).thenAnswer((_) async => Success(testPages));
      when(() => mockContainerRepo.getAllForPage(any())).thenAnswer((
        invocation,
      ) async {
        final pageId = invocation.positionalArguments[0] as int;
        if (pageId == 11) return const Success([parentContainer]);
        return const Success(<entity.Container>[]);
      });
      when(
        () => mockContainerRepo.getAllForContainer(20),
      ).thenAnswer((_) async => const Success([childContainer]));
      when(
        () => mockContainerRepo.getAllForContainer(25),
      ).thenAnswer((_) async => const Success(<entity.Container>[]));
      when(
        () => mockColumnRepo.getAllForContainer(20),
      ).thenAnswer((_) async => const Success(<entity.Column>[]));
      when(
        () => mockColumnRepo.getAllForContainer(25),
      ).thenAnswer((_) async => const Success([childColumn]));
      when(
        () => mockWidgetRepo.getAllForColumn(35),
      ).thenAnswer((_) async => const Success(<WidgetInstance>[]));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final tree = result.valueOrNull!;
      // Page 11 has parent container
      expect(tree.containers[11], hasLength(1));
      // Parent has child container
      expect(tree.childContainers[20], hasLength(1));
      expect(tree.childContainers[20]!.first.id, 25);
      // Child container has columns
      expect(tree.columns[25], hasLength(1));
    });

    test('continues loading when container fetch fails for one page', () async {
      when(
        () => mockMenuRepo.getById(1),
      ).thenAnswer((_) async => Success(testMenu));
      when(() => mockPageRepo.getAllForMenu(1)).thenAnswer(
        (_) async => const Success([
          entity.Page(id: 11, menuId: 1, name: 'Page 0', index: 0),
        ]),
      );
      when(
        () => mockContainerRepo.getAllForPage(11),
      ).thenAnswer((_) async => const Failure(ServerError('Container error')));

      final result = await loader.loadTree(1);

      expect(result.isSuccess, isTrue);
      final tree = result.valueOrNull!;
      expect(tree.containers[11], isNull);
    });
  });
}
