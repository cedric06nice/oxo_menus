import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';

import 'builders/column_builder.dart';
import 'fake_column_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeColumnRepository', () {
    late FakeColumnRepository fake;

    setUp(() {
      fake = FakeColumnRepository();
    });

    // -------------------------------------------------------------------------
    // Default state — unconfigured methods throw StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test('should throw StateError when create is called without configuration',
          () async {
        // Arrange
        const input = CreateColumnInput(containerId: 1, index: 0);

        // Act / Assert
        await expectLater(
          fake.create(input),
          throwsStateError,
        );
      });

      test(
          'should throw StateError when getAllForContainer is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.getAllForContainer(1),
          throwsStateError,
        );
      });

      test(
          'should throw StateError when getById is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.getById(1),
          throwsStateError,
        );
      });

      test('should throw StateError when update is called without configuration',
          () async {
        // Arrange
        const input = UpdateColumnInput(id: 1);

        // Act / Assert
        await expectLater(
          fake.update(input),
          throwsStateError,
        );
      });

      test('should throw StateError when delete is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.delete(1),
          throwsStateError,
        );
      });

      test(
          'should throw StateError when reorder is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.reorder(1, 0),
          throwsStateError,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Preset responses — canned value returned, call recorded
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured success result from create()', () async {
        // Arrange
        final column = buildColumn(id: 10, containerId: 5);
        fake.whenCreate(success(column));
        const input = CreateColumnInput(containerId: 5, index: 0, flex: 2);

        // Act
        final result = await fake.create(input);

        // Assert
        expect(result, isA<Success<Column, dynamic>>());
        expect((result as Success).value.id, equals(10));
      });

      test('should return configured success result from getAllForContainer()',
          () async {
        // Arrange
        final columns = [buildColumn(id: 1), buildColumn(id: 2)];
        fake.whenGetAllForContainer(success(columns));

        // Act
        final result = await fake.getAllForContainer(3);

        // Assert
        expect(result, isA<Success<List<Column>, dynamic>>());
        expect((result as Success).value, hasLength(2));
      });

      test('should return configured failure result from getById()', () async {
        // Arrange
        fake.whenGetById(failureNotFound());

        // Act
        final result = await fake.getById(999);

        // Assert
        expect(result, isA<Failure>());
      });

      test('should return configured success result from update()', () async {
        // Arrange
        final updated = buildColumn(id: 6, flex: 3);
        fake.whenUpdate(success(updated));
        const input = UpdateColumnInput(id: 6, flex: 3);

        // Act
        final result = await fake.update(input);

        // Assert
        expect(result, isA<Success<Column, dynamic>>());
        expect((result as Success).value.flex, equals(3));
      });

      test('should complete successfully from delete() when configured',
          () async {
        // Arrange
        fake.whenDelete(success(null));

        // Act / Assert
        await expectLater(fake.delete(4), completes);
      });

      test('should complete successfully from reorder() when configured',
          () async {
        // Arrange
        fake.whenReorder(success(null));

        // Act / Assert
        await expectLater(fake.reorder(2, 1), completes);
      });
    });

    // -------------------------------------------------------------------------
    // Call recording — arguments are captured correctly
    // -------------------------------------------------------------------------

    group('call recording', () {
      test(
          'should record a ColumnCreateCall with containerId and index when create() is called',
          () async {
        // Arrange
        fake.whenCreate(success(buildColumn()));
        const input = CreateColumnInput(
          containerId: 9,
          index: 1,
          flex: 1,
          isDroppable: false,
        );

        // Act
        await fake.create(input);

        // Assert
        expect(fake.createCalls, hasLength(1));
        expect(fake.createCalls.first.input.containerId, equals(9));
        expect(fake.createCalls.first.input.index, equals(1));
        expect(fake.createCalls.first.input.flex, equals(1));
        expect(fake.createCalls.first.input.isDroppable, isFalse);
      });

      test(
          'should record a ColumnGetAllForContainerCall with correct containerId',
          () async {
        // Arrange
        fake.whenGetAllForContainer(success([]));

        // Act
        await fake.getAllForContainer(25);

        // Assert
        expect(fake.getAllForContainerCalls, hasLength(1));
        expect(fake.getAllForContainerCalls.first.containerId, equals(25));
      });

      test('should record a ColumnGetByIdCall with correct id', () async {
        // Arrange
        fake.whenGetById(success(buildColumn(id: 88)));

        // Act
        await fake.getById(88);

        // Assert
        expect(fake.getByIdCalls, hasLength(1));
        expect(fake.getByIdCalls.first.id, equals(88));
      });

      test(
          'should record a ColumnReorderCall with columnId and newIndex when reorder() is called',
          () async {
        // Arrange
        fake.whenReorder(success(null));

        // Act
        await fake.reorder(11, 3);

        // Assert
        expect(fake.reorderCalls, hasLength(1));
        expect(fake.reorderCalls.first.columnId, equals(11));
        expect(fake.reorderCalls.first.newIndex, equals(3));
      });

      test(
          'should record a ColumnUpdateCall with correct input when update() is called',
          () async {
        // Arrange
        fake.whenUpdate(success(buildColumn(id: 20)));
        const input = UpdateColumnInput(id: 20, flex: 2, width: 150.0);

        // Act
        await fake.update(input);

        // Assert
        expect(fake.updateCalls, hasLength(1));
        expect(fake.updateCalls.first.input.id, equals(20));
        expect(fake.updateCalls.first.input.flex, equals(2));
        expect(fake.updateCalls.first.input.width, equals(150.0));
      });

      test('should accumulate multiple calls in insertion order', () async {
        // Arrange
        fake.whenGetAllForContainer(success([]));
        fake.whenCreate(success(buildColumn()));

        // Act
        await fake.getAllForContainer(1);
        await fake.create(const CreateColumnInput(containerId: 1, index: 0));

        // Assert
        expect(fake.calls, hasLength(2));
        expect(fake.calls[0], isA<ColumnGetAllForContainerCall>());
        expect(fake.calls[1], isA<ColumnCreateCall>());
      });
    });
  });
}
