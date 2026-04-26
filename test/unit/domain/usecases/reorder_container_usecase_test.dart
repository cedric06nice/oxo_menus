import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/usecases/reorder_container_usecase.dart';

import '../../../fakes/builders/container_builder.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('ReorderContainerUseCase', () {
    late FakeContainerRepository containerRepo;
    late ReorderContainerUseCase useCase;

    setUp(() {
      containerRepo = FakeContainerRepository();
      useCase = ReorderContainerUseCase(containerRepository: containerRepo);
    });

    // -------------------------------------------------------------------------
    // Container fetch failure
    // -------------------------------------------------------------------------

    group('container fetch failure', () {
      test('should return Failure when getById fails', () async {
        // Arrange
        containerRepo.whenGetById(failure(notFound()));

        // Act
        final result = await useCase.execute(1, ReorderDirection.up);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    // -------------------------------------------------------------------------
    // Siblings fetch failure
    // -------------------------------------------------------------------------

    group('siblings fetch failure', () {
      test(
        'should return Failure when getAllForPage fails for root-level container',
        () async {
          // Arrange
          final container = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForPage(failure(network()));

          // Act
          final result = await useCase.execute(1, ReorderDirection.up);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test(
        'should return Failure when getAllForContainer fails for nested container',
        () async {
          // Arrange
          final container = buildContainer(
            id: 1,
            pageId: 10,
            index: 0,
            parentContainerId: 5,
          );
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForContainer(failure(network()));

          // Act
          final result = await useCase.execute(1, ReorderDirection.up);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Boundary validation
    // -------------------------------------------------------------------------

    group('boundary validation', () {
      test(
        'should return ValidationError when moving up from the first position',
        () async {
          // Arrange
          final container = buildContainer(id: 1, pageId: 10, index: 0);
          final sibling = buildContainer(id: 2, pageId: 10, index: 1);
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForPage(success([container, sibling]));

          // Act
          final result = await useCase.execute(1, ReorderDirection.up);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test(
        'should return ValidationError when moving down from the last position',
        () async {
          // Arrange
          final container = buildContainer(id: 2, pageId: 10, index: 1);
          final sibling = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForPage(success([sibling, container]));

          // Act
          final result = await useCase.execute(2, ReorderDirection.down);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test(
        'should return ValidationError when only one container exists and moving up',
        () async {
          // Arrange
          final container = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForPage(success([container]));

          // Act
          final result = await useCase.execute(1, ReorderDirection.up);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test(
        'should return ValidationError when only one container exists and moving down',
        () async {
          // Arrange
          final container = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForPage(success([container]));

          // Act
          final result = await useCase.execute(1, ReorderDirection.down);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Reorder call failure propagation
    // -------------------------------------------------------------------------

    group('reorder failure propagation', () {
      test('should return Failure when the first reorder call fails', () async {
        // Arrange
        final container = buildContainer(id: 1, pageId: 10, index: 0);
        final sibling = buildContainer(id: 2, pageId: 10, index: 1);
        containerRepo.whenGetById(success(container));
        containerRepo.whenGetAllForPage(success([container, sibling]));
        containerRepo.whenReorder(failure(server()));

        // Act
        final result = await useCase.execute(1, ReorderDirection.down);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });
    });

    // -------------------------------------------------------------------------
    // Move up
    // -------------------------------------------------------------------------

    group('move up', () {
      test(
        'should swap indices when moving a container up from a middle position',
        () async {
          // Arrange
          final first = buildContainer(id: 1, pageId: 10, index: 0);
          final second = buildContainer(id: 2, pageId: 10, index: 1);
          final third = buildContainer(id: 3, pageId: 10, index: 2);
          containerRepo.whenGetById(success(second));
          containerRepo.whenGetAllForPage(success([first, second, third]));
          containerRepo.whenReorder(success(null));

          // Act
          final result = await useCase.execute(2, ReorderDirection.up);

          // Assert
          expect(result.isSuccess, isTrue);
          final calls = containerRepo.reorderCalls;
          expect(calls.length, equals(2));
          expect(calls[0].containerId, equals(2));
          expect(calls[0].newIndex, equals(0));
          expect(calls[1].containerId, equals(1));
          expect(calls[1].newIndex, equals(1));
        },
      );

      test(
        'should succeed when moving a container from second to first position',
        () async {
          // Arrange
          final first = buildContainer(id: 1, pageId: 10, index: 0);
          final second = buildContainer(id: 2, pageId: 10, index: 1);
          containerRepo.whenGetById(success(second));
          containerRepo.whenGetAllForPage(success([first, second]));
          containerRepo.whenReorder(success(null));

          // Act
          final result = await useCase.execute(2, ReorderDirection.up);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Move down
    // -------------------------------------------------------------------------

    group('move down', () {
      test(
        'should swap indices when moving a container down from a middle position',
        () async {
          // Arrange
          final first = buildContainer(id: 1, pageId: 10, index: 0);
          final second = buildContainer(id: 2, pageId: 10, index: 1);
          final third = buildContainer(id: 3, pageId: 10, index: 2);
          containerRepo.whenGetById(success(second));
          containerRepo.whenGetAllForPage(success([first, second, third]));
          containerRepo.whenReorder(success(null));

          // Act
          final result = await useCase.execute(2, ReorderDirection.down);

          // Assert
          expect(result.isSuccess, isTrue);
          final calls = containerRepo.reorderCalls;
          expect(calls.length, equals(2));
          expect(calls[0].containerId, equals(2));
          expect(calls[0].newIndex, equals(2));
          expect(calls[1].containerId, equals(3));
          expect(calls[1].newIndex, equals(1));
        },
      );

      test(
        'should succeed when moving a container from first to second position',
        () async {
          // Arrange
          final first = buildContainer(id: 1, pageId: 10, index: 0);
          final second = buildContainer(id: 2, pageId: 10, index: 1);
          containerRepo.whenGetById(success(first));
          containerRepo.whenGetAllForPage(success([first, second]));
          containerRepo.whenReorder(success(null));

          // Act
          final result = await useCase.execute(1, ReorderDirection.down);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Nested containers (parent container)
    // -------------------------------------------------------------------------

    group('nested containers', () {
      test(
        'should use getAllForContainer when container has a parentContainerId',
        () async {
          // Arrange
          final container = buildContainer(
            id: 1,
            pageId: 10,
            index: 1,
            parentContainerId: 5,
          );
          final sibling = buildContainer(
            id: 2,
            pageId: 10,
            index: 0,
            parentContainerId: 5,
          );
          containerRepo.whenGetById(success(container));
          containerRepo.whenGetAllForContainer(success([sibling, container]));
          containerRepo.whenReorder(success(null));

          // Act
          final result = await useCase.execute(1, ReorderDirection.up);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(
            containerRepo.getAllForContainerCalls.single.containerId,
            equals(5),
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // Sorting of unsorted siblings
    // -------------------------------------------------------------------------

    group('sorting of unsorted siblings', () {
      test(
        'should correctly identify position when siblings are provided out of index order',
        () async {
          // Arrange — siblings provided in reverse order
          final first = buildContainer(id: 1, pageId: 10, index: 0);
          final second = buildContainer(id: 2, pageId: 10, index: 1);
          final third = buildContainer(id: 3, pageId: 10, index: 2);
          containerRepo.whenGetById(success(first));
          containerRepo.whenGetAllForPage(success([third, first, second]));
          containerRepo.whenReorder(success(null));

          // Act — move container at index 0 down
          final result = await useCase.execute(1, ReorderDirection.down);

          // Assert
          expect(result.isSuccess, isTrue);
          final calls = containerRepo.reorderCalls;
          // container 1 should acquire index 1 (second's index)
          expect(calls.first.containerId, equals(1));
          expect(calls.first.newIndex, equals(1));
          // container 2 should acquire index 0 (first's index)
          expect(calls[1].containerId, equals(2));
          expect(calls[1].newIndex, equals(0));
        },
      );
    });
  });
}
