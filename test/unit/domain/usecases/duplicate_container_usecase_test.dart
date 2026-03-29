import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_container_usecase.dart';

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;
  late DuplicateContainerUseCase useCase;

  setUp(() {
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();
    useCase = DuplicateContainerUseCase(
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      widgetRepository: mockWidgetRepo,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateContainerInput(pageId: 0, index: 0, direction: 'row'),
    );
    registerFallbackValue(const CreateColumnInput(containerId: 0, index: 0));
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: 0,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
  });

  const sourceContainer = Container(
    id: 1,
    pageId: 10,
    index: 0,
    name: 'Menu Section',
    layout: LayoutConfig(direction: 'row'),
  );

  const siblingContainer = Container(id: 2, pageId: 10, index: 1);

  const sourceColumn = Column(
    id: 100,
    containerId: 1,
    index: 0,
    flex: 1,
    isDroppable: true,
  );

  const sourceWidget = WidgetInstance(
    id: 200,
    columnId: 100,
    type: 'dish',
    version: '1.0',
    index: 0,
    props: {'name': 'Burger', 'price': 12.0},
  );

  const newContainer = Container(
    id: 50,
    pageId: 10,
    index: 1,
    name: 'Menu Section (copy)',
  );
  const newColumn = Column(id: 150, containerId: 50, index: 0);
  const newWidget = WidgetInstance(
    id: 250,
    columnId: 150,
    type: 'dish',
    version: '1.0',
    index: 0,
    props: {'name': 'Burger', 'price': 12.0},
  );

  group('DuplicateContainerUseCase', () {
    group('leaf container duplication', () {
      test('duplicates container with columns and widgets', () async {
        // Arrange
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(sourceContainer));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([sourceContainer, siblingContainer]),
        );
        // Shift sibling at index >= 1
        when(
          () => mockContainerRepo.reorder(2, 2),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockContainerRepo.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success([sourceColumn]));
        when(
          () => mockContainerRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Container>[]));
        when(
          () => mockColumnRepo.create(any()),
        ).thenAnswer((_) async => const Success(newColumn));
        when(
          () => mockWidgetRepo.getAllForColumn(100),
        ).thenAnswer((_) async => const Success([sourceWidget]));
        when(
          () => mockWidgetRepo.create(any()),
        ).thenAnswer((_) async => const Success(newWidget));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
          () => mockContainerRepo.create(captureAny()),
        ).captured;
        final input = captured.first as CreateContainerInput;
        expect(input.pageId, 10);
        expect(input.index, 1);
        expect(input.name, 'Menu Section (copy)');
        expect(input.direction, 'row');

        verify(() => mockColumnRepo.create(any())).called(1);
        verify(() => mockWidgetRepo.create(any())).called(1);
      });

      test('shifts sibling indices before duplicating', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(sourceContainer));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([sourceContainer, siblingContainer]),
        );
        when(
          () => mockContainerRepo.reorder(any(), any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockContainerRepo.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Column>[]));
        when(
          () => mockContainerRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Container>[]));

        await useCase.execute(1);

        // Sibling at index 1 should be shifted to index 2
        verify(() => mockContainerRepo.reorder(2, 2)).called(1);
      });

      test('appends (copy) to container name', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(sourceContainer));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([sourceContainer, siblingContainer]),
        );
        when(
          () => mockContainerRepo.reorder(any(), any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockContainerRepo.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Column>[]));
        when(
          () => mockContainerRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Container>[]));

        await useCase.execute(1);

        final captured = verify(
          () => mockContainerRepo.create(captureAny()),
        ).captured;
        final input = captured.first as CreateContainerInput;
        expect(input.name, 'Menu Section (copy)');
      });
    });

    group('nested container duplication', () {
      test('recursively duplicates child containers', () async {
        const parentContainer = Container(
          id: 5,
          pageId: 10,
          index: 0,
          name: 'Parent',
          layout: LayoutConfig(direction: 'column'),
        );
        const childContainer = Container(
          id: 6,
          pageId: 10,
          index: 0,
          parentContainerId: 5,
          name: 'Child',
          layout: LayoutConfig(direction: 'row'),
        );
        const newParent = Container(
          id: 55,
          pageId: 10,
          index: 1,
          name: 'Parent (copy)',
        );
        const newChild = Container(id: 56, pageId: 10, index: 0, name: 'Child');

        when(
          () => mockContainerRepo.getById(5),
        ).thenAnswer((_) async => const Success(parentContainer));
        when(
          () => mockContainerRepo.getAllForPage(10),
        ).thenAnswer((_) async => const Success([parentContainer]));
        when(
          () => mockColumnRepo.getAllForContainer(5),
        ).thenAnswer((_) async => const Success(<Column>[]));
        when(
          () => mockContainerRepo.getAllForContainer(5),
        ).thenAnswer((_) async => const Success([childContainer]));

        // Sequential container creates: parent first, then child
        var createCallCount = 0;
        when(() => mockContainerRepo.create(any())).thenAnswer((_) async {
          createCallCount++;
          return createCallCount == 1
              ? const Success(newParent)
              : const Success(newChild);
        });
        when(
          () => mockColumnRepo.getAllForContainer(6),
        ).thenAnswer((_) async => const Success(<Column>[]));
        when(
          () => mockContainerRepo.getAllForContainer(6),
        ).thenAnswer((_) async => const Success(<Container>[]));

        final result = await useCase.execute(5);

        expect(result.isSuccess, true);
        // Parent container + child container = 2 creates
        verify(() => mockContainerRepo.create(any())).called(2);
      });
    });

    group('error handling', () {
      test('returns error when source container not found', () async {
        when(
          () => mockContainerRepo.getById(99),
        ).thenAnswer((_) async => const Failure(NotFoundError()));

        final result = await useCase.execute(99);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('rolls back created entities on column creation failure', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(sourceContainer));
        when(
          () => mockContainerRepo.getAllForPage(10),
        ).thenAnswer((_) async => const Success([sourceContainer]));
        when(
          () => mockContainerRepo.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success([sourceColumn]));
        when(
          () => mockContainerRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Container>[]));
        when(
          () => mockColumnRepo.create(any()),
        ).thenAnswer((_) async => const Failure(ServerError()));
        // Rollback mocks
        when(
          () => mockContainerRepo.delete(any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await useCase.execute(1);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ServerError>());
        // Should rollback the created container
        verify(() => mockContainerRepo.delete(50)).called(1);
      });

      test('rolls back created entities on widget creation failure', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(sourceContainer));
        when(
          () => mockContainerRepo.getAllForPage(10),
        ).thenAnswer((_) async => const Success([sourceContainer]));
        when(
          () => mockContainerRepo.create(any()),
        ).thenAnswer((_) async => const Success(newContainer));
        when(
          () => mockColumnRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success([sourceColumn]));
        when(
          () => mockContainerRepo.getAllForContainer(1),
        ).thenAnswer((_) async => const Success(<Container>[]));
        when(
          () => mockColumnRepo.create(any()),
        ).thenAnswer((_) async => const Success(newColumn));
        when(
          () => mockWidgetRepo.getAllForColumn(100),
        ).thenAnswer((_) async => const Success([sourceWidget]));
        when(
          () => mockWidgetRepo.create(any()),
        ).thenAnswer((_) async => const Failure(ServerError()));
        // Rollback mocks
        when(
          () => mockContainerRepo.delete(any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => mockColumnRepo.delete(any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await useCase.execute(1);

        expect(result.isFailure, true);
        // Should rollback both the column and container
        verify(() => mockColumnRepo.delete(150)).called(1);
        verify(() => mockContainerRepo.delete(50)).called(1);
      });
    });
  });
}
