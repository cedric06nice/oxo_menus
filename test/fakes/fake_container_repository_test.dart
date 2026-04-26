import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

import 'builders/container_builder.dart';
import 'fake_container_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeContainerRepository', () {
    late FakeContainerRepository fake;

    setUp(() {
      fake = FakeContainerRepository();
    });

    // -------------------------------------------------------------------------
    // Default state — unconfigured methods throw StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test(
        'should throw StateError when create is called without configuration',
        () async {
          // Arrange
          const input = CreateContainerInput(
            pageId: 1,
            index: 0,
            direction: 'row',
          );

          // Act / Assert
          await expectLater(fake.create(input), throwsStateError);
        },
      );

      test(
        'should throw StateError when getAllForPage is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getAllForPage(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when getAllForContainer is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getAllForContainer(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when getById is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getById(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when update is called without configuration',
        () async {
          // Arrange
          const input = UpdateContainerInput(id: 1);

          // Act / Assert
          await expectLater(fake.update(input), throwsStateError);
        },
      );

      test(
        'should throw StateError when delete is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.delete(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when reorder is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.reorder(1, 2), throwsStateError);
        },
      );

      test(
        'should throw StateError when moveTo is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.moveTo(1, 2, 0), throwsStateError);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Preset responses — canned value returned, call recorded
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured success result from create()', () async {
        // Arrange
        final container = buildContainer(id: 10, pageId: 3);
        fake.whenCreate(success(container));
        const input = CreateContainerInput(
          pageId: 3,
          index: 0,
          direction: 'column',
        );

        // Act
        final result = await fake.create(input);

        // Assert
        expect(result, isA<Success<Container, dynamic>>());
        expect((result as Success).value.id, equals(10));
      });

      test(
        'should return configured success result from getAllForPage()',
        () async {
          // Arrange
          final containers = [buildContainer(id: 1), buildContainer(id: 2)];
          fake.whenGetAllForPage(success(containers));

          // Act
          final result = await fake.getAllForPage(5);

          // Assert
          expect(result, isA<Success<List<Container>, dynamic>>());
          expect((result as Success).value, hasLength(2));
        },
      );

      test(
        'should return configured failure from getAllForContainer()',
        () async {
          // Arrange
          fake.whenGetAllForContainer(failureNotFound());

          // Act
          final result = await fake.getAllForContainer(99);

          // Assert
          expect(result, isA<Failure>());
        },
      );

      test('should return configured success result from getById()', () async {
        // Arrange
        final container = buildContainer(id: 7);
        fake.whenGetById(success(container));

        // Act
        final result = await fake.getById(7);

        // Assert
        expect(result, isA<Success<Container, dynamic>>());
        expect((result as Success).value.id, equals(7));
      });

      test('should return configured success result from update()', () async {
        // Arrange
        final updated = buildContainer(id: 4, name: 'Header');
        fake.whenUpdate(success(updated));
        const input = UpdateContainerInput(id: 4, name: 'Header');

        // Act
        final result = await fake.update(input);

        // Assert
        expect(result, isA<Success<Container, dynamic>>());
        expect((result as Success).value.name, equals('Header'));
      });

      test(
        'should complete successfully from delete() when configured',
        () async {
          // Arrange
          fake.whenDelete(success(null));

          // Act / Assert
          await expectLater(fake.delete(3), completes);
        },
      );

      test(
        'should complete successfully from reorder() when configured',
        () async {
          // Arrange
          fake.whenReorder(success(null));

          // Act / Assert
          await expectLater(fake.reorder(2, 4), completes);
        },
      );

      test(
        'should complete successfully from moveTo() when configured',
        () async {
          // Arrange
          fake.whenMoveTo(success(null));

          // Act / Assert
          await expectLater(fake.moveTo(1, 3, 0), completes);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Call recording — arguments are captured correctly
    // -------------------------------------------------------------------------

    group('call recording', () {
      test(
        'should record a ContainerCreateCall with pageId, index, and direction',
        () async {
          // Arrange
          fake.whenCreate(success(buildContainer()));
          const input = CreateContainerInput(
            pageId: 8,
            index: 2,
            direction: 'row',
            name: 'Main Section',
          );

          // Act
          await fake.create(input);

          // Assert
          expect(fake.createCalls, hasLength(1));
          expect(fake.createCalls.first.input.pageId, equals(8));
          expect(fake.createCalls.first.input.index, equals(2));
          expect(fake.createCalls.first.input.direction, equals('row'));
          expect(fake.createCalls.first.input.name, equals('Main Section'));
        },
      );

      test(
        'should record a ContainerGetAllForPageCall with correct pageId',
        () async {
          // Arrange
          fake.whenGetAllForPage(success([]));

          // Act
          await fake.getAllForPage(12);

          // Assert
          expect(fake.getAllForPageCalls, hasLength(1));
          expect(fake.getAllForPageCalls.first.pageId, equals(12));
        },
      );

      test(
        'should record a ContainerGetAllForContainerCall with correct containerId',
        () async {
          // Arrange
          fake.whenGetAllForContainer(success([]));

          // Act
          await fake.getAllForContainer(33);

          // Assert
          expect(fake.getAllForContainerCalls, hasLength(1));
          expect(fake.getAllForContainerCalls.first.containerId, equals(33));
        },
      );

      test(
        'should record a ContainerReorderCall with containerId and newIndex',
        () async {
          // Arrange
          fake.whenReorder(success(null));

          // Act
          await fake.reorder(5, 3);

          // Assert
          expect(fake.reorderCalls, hasLength(1));
          expect(fake.reorderCalls.first.containerId, equals(5));
          expect(fake.reorderCalls.first.newIndex, equals(3));
        },
      );

      test(
        'should record a ContainerMoveToCall with containerId, newPageId and index',
        () async {
          // Arrange
          fake.whenMoveTo(success(null));

          // Act
          await fake.moveTo(10, 20, 1);

          // Assert
          expect(fake.moveToCalls, hasLength(1));
          expect(fake.moveToCalls.first.containerId, equals(10));
          expect(fake.moveToCalls.first.newPageId, equals(20));
          expect(fake.moveToCalls.first.index, equals(1));
        },
      );

      test('should accumulate multiple calls in insertion order', () async {
        // Arrange
        fake.whenGetAllForPage(success([]));
        fake.whenDelete(success(null));

        // Act
        await fake.getAllForPage(1);
        await fake.delete(5);

        // Assert
        expect(fake.calls, hasLength(2));
        expect(fake.calls[0], isA<ContainerGetAllForPageCall>());
        expect(fake.calls[1], isA<ContainerDeleteCall>());
      });
    });
  });
}
