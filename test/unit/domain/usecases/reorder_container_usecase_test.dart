import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/usecases/reorder_container_usecase.dart';

class MockContainerRepository extends Mock implements ContainerRepository {}

void main() {
  late MockContainerRepository mockContainerRepo;
  late ReorderContainerUseCase useCase;

  setUp(() {
    mockContainerRepo = MockContainerRepository();
    useCase = ReorderContainerUseCase(containerRepository: mockContainerRepo);
  });

  const container1 = Container(id: 1, pageId: 10, index: 0, name: 'First');
  const container2 = Container(id: 2, pageId: 10, index: 1, name: 'Second');
  const container3 = Container(id: 3, pageId: 10, index: 2, name: 'Third');

  const nestedContainer1 = Container(
    id: 11,
    pageId: 10,
    index: 0,
    parentContainerId: 100,
  );
  const nestedContainer2 = Container(
    id: 12,
    pageId: 10,
    index: 1,
    parentContainerId: 100,
  );

  group('ReorderContainerUseCase', () {
    group('move up', () {
      test('swaps indices with the previous sibling', () async {
        when(
          () => mockContainerRepo.getById(2),
        ).thenAnswer((_) async => const Success(container2));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([container1, container2, container3]),
        );
        when(
          () => mockContainerRepo.reorder(any(), any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await useCase.execute(2, ReorderDirection.up);

        expect(result.isSuccess, true);
        verify(() => mockContainerRepo.reorder(2, 0)).called(1);
        verify(() => mockContainerRepo.reorder(1, 1)).called(1);
      });

      test('returns ValidationError when already first', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Success(container1));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([container1, container2, container3]),
        );

        final result = await useCase.execute(1, ReorderDirection.up);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        verifyNever(() => mockContainerRepo.reorder(any(), any()));
      });
    });

    group('move down', () {
      test('swaps indices with the next sibling', () async {
        when(
          () => mockContainerRepo.getById(2),
        ).thenAnswer((_) async => const Success(container2));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([container1, container2, container3]),
        );
        when(
          () => mockContainerRepo.reorder(any(), any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await useCase.execute(2, ReorderDirection.down);

        expect(result.isSuccess, true);
        verify(() => mockContainerRepo.reorder(2, 2)).called(1);
        verify(() => mockContainerRepo.reorder(3, 1)).called(1);
      });

      test('returns ValidationError when already last', () async {
        when(
          () => mockContainerRepo.getById(3),
        ).thenAnswer((_) async => const Success(container3));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([container1, container2, container3]),
        );

        final result = await useCase.execute(3, ReorderDirection.down);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        verifyNever(() => mockContainerRepo.reorder(any(), any()));
      });
    });

    group('nested containers', () {
      test('fetches siblings from parent container instead of page', () async {
        when(
          () => mockContainerRepo.getById(12),
        ).thenAnswer((_) async => const Success(nestedContainer2));
        when(() => mockContainerRepo.getAllForContainer(100)).thenAnswer(
          (_) async => const Success([nestedContainer1, nestedContainer2]),
        );
        when(
          () => mockContainerRepo.reorder(any(), any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await useCase.execute(12, ReorderDirection.up);

        expect(result.isSuccess, true);
        verify(() => mockContainerRepo.getAllForContainer(100)).called(1);
        verifyNever(() => mockContainerRepo.getAllForPage(any()));
        verify(() => mockContainerRepo.reorder(12, 0)).called(1);
        verify(() => mockContainerRepo.reorder(11, 1)).called(1);
      });
    });

    group('error handling', () {
      test('propagates error when getById fails', () async {
        when(
          () => mockContainerRepo.getById(1),
        ).thenAnswer((_) async => const Failure(NotFoundError()));

        final result = await useCase.execute(1, ReorderDirection.up);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('propagates error when fetching siblings fails', () async {
        when(
          () => mockContainerRepo.getById(2),
        ).thenAnswer((_) async => const Success(container2));
        when(
          () => mockContainerRepo.getAllForPage(10),
        ).thenAnswer((_) async => const Failure(ServerError()));

        final result = await useCase.execute(2, ReorderDirection.up);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ServerError>());
      });

      test('propagates error when first reorder call fails', () async {
        when(
          () => mockContainerRepo.getById(2),
        ).thenAnswer((_) async => const Success(container2));
        when(() => mockContainerRepo.getAllForPage(10)).thenAnswer(
          (_) async => const Success([container1, container2, container3]),
        );
        when(
          () => mockContainerRepo.reorder(2, any()),
        ).thenAnswer((_) async => const Failure(ServerError()));

        final result = await useCase.execute(2, ReorderDirection.up);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ServerError>());
      });
    });
  });
}
