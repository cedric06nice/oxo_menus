import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

import 'builders/widget_instance_builder.dart';
import 'fake_widget_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeWidgetRepository', () {
    late FakeWidgetRepository fake;

    setUp(() {
      fake = FakeWidgetRepository();
    });

    // -------------------------------------------------------------------------
    // Default state — unconfigured methods throw StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test(
        'should throw StateError when create is called without configuration',
        () async {
          // Arrange
          const input = CreateWidgetInput(
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 0,
            props: {},
          );

          // Act / Assert
          await expectLater(fake.create(input), throwsStateError);
        },
      );

      test(
        'should throw StateError when getAllForColumn is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getAllForColumn(1), throwsStateError);
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
          const input = UpdateWidgetInput(id: 1);

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
          await expectLater(fake.reorder(1, 0), throwsStateError);
        },
      );

      test(
        'should throw StateError when moveTo is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.moveTo(1, 2, 0), throwsStateError);
        },
      );

      test(
        'should throw StateError when lockForEditing is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.lockForEditing(1, 'user-uuid'),
            throwsStateError,
          );
        },
      );

      test(
        'should throw StateError when unlockEditing is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.unlockEditing(1), throwsStateError);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Preset responses — canned value returned, call recorded
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured success result from create()', () async {
        // Arrange
        final widget = buildWidgetInstance(id: 10, type: 'dish');
        fake.whenCreate(success(widget));
        const input = CreateWidgetInput(
          columnId: 3,
          type: 'dish',
          version: '1',
          index: 0,
          props: {'name': 'Soup'},
        );

        // Act
        final result = await fake.create(input);

        // Assert
        expect(result, isA<Success<WidgetInstance, dynamic>>());
        expect((result as Success).value.type, equals('dish'));
      });

      test(
        'should return configured success result from getAllForColumn()',
        () async {
          // Arrange
          final widgets = [
            buildWidgetInstance(id: 1),
            buildWidgetInstance(id: 2),
          ];
          fake.whenGetAllForColumn(success(widgets));

          // Act
          final result = await fake.getAllForColumn(5);

          // Assert
          expect(result, isA<Success<List<WidgetInstance>, dynamic>>());
          expect((result as Success).value, hasLength(2));
        },
      );

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
        final updated = buildWidgetInstance(id: 4, type: 'text');
        fake.whenUpdate(success(updated));
        const input = UpdateWidgetInput(id: 4, type: 'text');

        // Act
        final result = await fake.update(input);

        // Assert
        expect(result, isA<Success<WidgetInstance, dynamic>>());
        expect((result as Success).value.type, equals('text'));
      });

      test(
        'should complete successfully from delete() when configured',
        () async {
          // Arrange
          fake.whenDelete(success(null));

          // Act / Assert
          await expectLater(fake.delete(6), completes);
        },
      );

      test(
        'should complete successfully from reorder() when configured',
        () async {
          // Arrange
          fake.whenReorder(success(null));

          // Act / Assert
          await expectLater(fake.reorder(3, 1), completes);
        },
      );

      test(
        'should complete successfully from moveTo() when configured',
        () async {
          // Arrange
          fake.whenMoveTo(success(null));

          // Act / Assert
          await expectLater(fake.moveTo(2, 7, 0), completes);
        },
      );

      test(
        'should complete successfully from lockForEditing() when configured',
        () async {
          // Arrange
          fake.whenLockForEditing(success(null));

          // Act / Assert
          await expectLater(fake.lockForEditing(1, 'user-uuid-123'), completes);
        },
      );

      test(
        'should complete successfully from unlockEditing() when configured',
        () async {
          // Arrange
          fake.whenUnlockEditing(success(null));

          // Act / Assert
          await expectLater(fake.unlockEditing(1), completes);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Call recording — arguments are captured correctly
    // -------------------------------------------------------------------------

    group('call recording', () {
      test(
        'should record a WidgetCreateCall with columnId, type, and props when create() is called',
        () async {
          // Arrange
          fake.whenCreate(success(buildWidgetInstance()));
          const input = CreateWidgetInput(
            columnId: 5,
            type: 'wine',
            version: '2',
            index: 1,
            props: {'name': 'Chardonnay', 'price': 8.50},
            isTemplate: true,
          );

          // Act
          await fake.create(input);

          // Assert
          expect(fake.createCalls, hasLength(1));
          expect(fake.createCalls.first.input.columnId, equals(5));
          expect(fake.createCalls.first.input.type, equals('wine'));
          expect(fake.createCalls.first.input.version, equals('2'));
          expect(fake.createCalls.first.input.index, equals(1));
          expect(
            fake.createCalls.first.input.props['name'],
            equals('Chardonnay'),
          );
          expect(fake.createCalls.first.input.isTemplate, isTrue);
        },
      );

      test(
        'should record a WidgetGetAllForColumnCall with correct columnId',
        () async {
          // Arrange
          fake.whenGetAllForColumn(success([]));

          // Act
          await fake.getAllForColumn(18);

          // Assert
          expect(fake.getAllForColumnCalls, hasLength(1));
          expect(fake.getAllForColumnCalls.first.columnId, equals(18));
        },
      );

      test('should record a WidgetGetByIdCall with correct id', () async {
        // Arrange
        fake.whenGetById(success(buildWidgetInstance(id: 77)));

        // Act
        await fake.getById(77);

        // Assert
        expect(fake.getByIdCalls, hasLength(1));
        expect(fake.getByIdCalls.first.id, equals(77));
      });

      test(
        'should record a WidgetUpdateCall with correct input when update() is called',
        () async {
          // Arrange
          fake.whenUpdate(success(buildWidgetInstance(id: 30)));
          const input = UpdateWidgetInput(
            id: 30,
            type: 'section',
            props: {'title': 'Starters'},
          );

          // Act
          await fake.update(input);

          // Assert
          expect(fake.updateCalls, hasLength(1));
          expect(fake.updateCalls.first.input.id, equals(30));
          expect(fake.updateCalls.first.input.type, equals('section'));
          expect(
            fake.updateCalls.first.input.props?['title'],
            equals('Starters'),
          );
        },
      );

      test(
        'should record a WidgetReorderCall with widgetId and newIndex when reorder() is called',
        () async {
          // Arrange
          fake.whenReorder(success(null));

          // Act
          await fake.reorder(15, 4);

          // Assert
          expect(fake.reorderCalls, hasLength(1));
          expect(fake.reorderCalls.first.widgetId, equals(15));
          expect(fake.reorderCalls.first.newIndex, equals(4));
        },
      );

      test(
        'should record a WidgetMoveToCall with widgetId, newColumnId and index when moveTo() is called',
        () async {
          // Arrange
          fake.whenMoveTo(success(null));

          // Act
          await fake.moveTo(8, 12, 2);

          // Assert
          expect(fake.moveToCalls, hasLength(1));
          expect(fake.moveToCalls.first.widgetId, equals(8));
          expect(fake.moveToCalls.first.newColumnId, equals(12));
          expect(fake.moveToCalls.first.index, equals(2));
        },
      );

      test(
        'should record a WidgetLockForEditingCall with widgetId and userId',
        () async {
          // Arrange
          fake.whenLockForEditing(success(null));

          // Act
          await fake.lockForEditing(50, 'user-abc-123');

          // Assert
          expect(fake.lockForEditingCalls, hasLength(1));
          expect(fake.lockForEditingCalls.first.widgetId, equals(50));
          expect(fake.lockForEditingCalls.first.userId, equals('user-abc-123'));
        },
      );

      test(
        'should record a WidgetUnlockEditingCall with correct widgetId when unlockEditing() is called',
        () async {
          // Arrange
          fake.whenUnlockEditing(success(null));

          // Act
          await fake.unlockEditing(60);

          // Assert
          expect(fake.unlockEditingCalls, hasLength(1));
          expect(fake.unlockEditingCalls.first.widgetId, equals(60));
        },
      );

      test(
        'should record a WidgetDeleteCall with correct id when delete() is called',
        () async {
          // Arrange
          fake.whenDelete(success(null));

          // Act
          await fake.delete(35);

          // Assert
          expect(fake.deleteCalls, hasLength(1));
          expect(fake.deleteCalls.first.id, equals(35));
        },
      );

      test('should accumulate multiple calls in insertion order', () async {
        // Arrange
        fake.whenGetAllForColumn(success([]));
        fake.whenCreate(success(buildWidgetInstance()));
        fake.whenLockForEditing(success(null));

        // Act
        await fake.getAllForColumn(1);
        await fake.create(
          const CreateWidgetInput(
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 0,
            props: {},
          ),
        );
        await fake.lockForEditing(1, 'chef-id');

        // Assert
        expect(fake.calls, hasLength(3));
        expect(fake.calls[0], isA<WidgetGetAllForColumnCall>());
        expect(fake.calls[1], isA<WidgetCreateCall>());
        expect(fake.calls[2], isA<WidgetLockForEditingCall>());
      });
    });
  });
}
