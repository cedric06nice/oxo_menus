import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import '../../../fakes/builders/widget_instance_builder.dart';

void main() {
  group('WidgetInstance lock semantics', () {
    group('default state', () {
      test('should default editingBy to null when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.editingBy, isNull);
      });

      test('should default editingSince to null when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.editingSince, isNull);
      });
    });

    group('acquiring a lock', () {
      test('should store editingBy when editingBy is set to a user id', () {
        // Arrange & Act
        final instance = buildWidgetInstance(editingBy: 'user-abc-123');

        // Assert
        expect(instance.editingBy, 'user-abc-123');
      });

      test(
        'should store editingSince when editingSince is set to a timestamp',
        () {
          // Arrange
          final lockTime = DateTime(2025, 1, 15, 10, 30);

          // Act
          final instance = buildWidgetInstance(editingSince: lockTime);

          // Assert
          expect(instance.editingSince, lockTime);
        },
      );

      test(
        'should store both editingBy and editingSince when both lock fields are set',
        () {
          // Arrange
          final lockTime = DateTime(2025, 6, 1, 9, 0);

          // Act
          final instance = buildWidgetInstance(
            editingBy: 'user-xyz',
            editingSince: lockTime,
          );

          // Assert
          expect(instance.editingBy, 'user-xyz');
          expect(instance.editingSince, lockTime);
        },
      );
    });

    group('acquiring a lock via copyWith', () {
      test(
        'should set editingBy via copyWith when transitioning from unlocked to locked',
        () {
          // Arrange
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 0,
            props: {},
          );

          // Act
          final locked = instance.copyWith(
            editingBy: 'user-xyz',
            editingSince: DateTime(2025, 1, 15),
          );

          // Assert
          expect(locked.editingBy, 'user-xyz');
          expect(locked.editingSince, DateTime(2025, 1, 15));
        },
      );

      test('should preserve id when lock fields are set via copyWith', () {
        // Arrange
        const instance = WidgetInstance(
          id: 7,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );

        // Act
        final locked = instance.copyWith(
          editingBy: 'user-xyz',
          editingSince: DateTime(2025, 1, 15),
        );

        // Assert
        expect(locked.id, 7);
      });

      test('should preserve type when lock fields are set via copyWith', () {
        // Arrange
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'section',
          version: '1',
          index: 0,
          props: {},
        );

        // Act
        final locked = instance.copyWith(editingBy: 'user-xyz');

        // Assert
        expect(locked.type, 'section');
      });

      test('should preserve index when lock fields are set via copyWith', () {
        // Arrange
        final instance = buildWidgetInstance(index: 3);

        // Act
        final locked = instance.copyWith(editingBy: 'user-abc');

        // Assert
        expect(locked.index, 3);
      });
    });

    group('releasing a lock via copyWith', () {
      test(
        'should clear editingBy when copyWith is called with editingBy null',
        () {
          // Arrange
          final locked = buildWidgetInstance(
            editingBy: 'user-abc',
            editingSince: DateTime(2025, 1, 1),
          );

          // Act
          final released = locked.copyWith(editingBy: null, editingSince: null);

          // Assert
          expect(released.editingBy, isNull);
          expect(released.editingSince, isNull);
        },
      );
    });

    group('lock transfer', () {
      test(
        'should update editingBy when a different user acquires the lock via copyWith',
        () {
          // Arrange
          final locked = buildWidgetInstance(
            editingBy: 'user-alpha',
            editingSince: DateTime(2025, 1, 1, 8, 0),
          );

          // Act
          final transferred = locked.copyWith(
            editingBy: 'user-beta',
            editingSince: DateTime(2025, 1, 1, 9, 0),
          );

          // Assert
          expect(transferred.editingBy, 'user-beta');
          expect(transferred.editingSince, DateTime(2025, 1, 1, 9, 0));
        },
      );
    });

    group('equality', () {
      test('should not be equal when editingBy differs', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
          editingBy: 'user-1',
        );
        const b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
          editingBy: 'user-2',
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when editingSince differs', () {
        // Arrange
        final a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: const {},
          editingSince: DateTime(2025, 1, 1),
        );
        final b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: const {},
          editingSince: DateTime(2025, 1, 2),
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should be equal when both lock fields are null', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );
        const b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(a, equals(b));
      });
    });

    group('JSON round-trip for lock fields', () {
      test('should serialize editingBy to JSON when set', () {
        // Arrange
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
          editingBy: 'user-abc',
        );

        // Act
        final json = instance.toJson();

        // Assert
        expect(json['editingBy'], 'user-abc');
      });

      test(
        'should round-trip lock fields through JSON preserving equality',
        () {
          // Arrange
          final lockTime = DateTime.utc(2025, 1, 15, 10, 30);
          final instance = buildWidgetInstance(
            editingBy: 'user-xyz',
            editingSince: lockTime,
          );

          // Act
          final restored = WidgetInstance.fromJson(instance.toJson());

          // Assert
          expect(restored.editingBy, 'user-xyz');
          expect(restored.editingSince, lockTime);
        },
      );
    });
  });
}
