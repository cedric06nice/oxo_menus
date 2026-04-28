import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

void main() {
  group('Area', () {
    group('construction', () {
      test(
        'should create area with correct fields when id and name are provided',
        () {
          // Arrange & Act
          const area = Area(id: 1, name: 'Dining');

          // Assert
          expect(area.id, 1);
          expect(area.name, 'Dining');
        },
      );

      test('should accept zero as id when id is zero', () {
        // Arrange & Act
        const area = Area(id: 0, name: 'Lobby');

        // Assert
        expect(area.id, 0);
      });

      test('should accept a negative id when id is negative', () {
        // Arrange & Act
        const area = Area(id: -1, name: 'Underground');

        // Assert
        expect(area.id, -1);
      });

      test('should accept an empty name when name is empty string', () {
        // Arrange & Act
        const area = Area(id: 1, name: '');

        // Assert
        expect(area.name, '');
      });
    });

    group('equality', () {
      test('should be equal when both fields have the same values', () {
        // Arrange
        const a = Area(id: 1, name: 'Dining');
        const b = Area(id: 1, name: 'Dining');

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Area(id: 1, name: 'Dining');
        const b = Area(id: 1, name: 'Dining');

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Area(id: 1, name: 'Dining');
        const b = Area(id: 2, name: 'Dining');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const a = Area(id: 1, name: 'Dining');
        const b = Area(id: 1, name: 'Bar');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update id when copyWith is called with a new id', () {
        // Arrange
        const area = Area(id: 1, name: 'Dining');

        // Act
        final updated = area.copyWith(id: 99);

        // Assert
        expect(updated.id, 99);
        expect(updated.name, 'Dining');
      });

      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const area = Area(id: 1, name: 'Dining');

        // Act
        final updated = area.copyWith(name: 'Terrace');

        // Assert
        expect(updated.id, 1);
        expect(updated.name, 'Terrace');
      });

      test(
        'should preserve all fields when copyWith is called with no arguments',
        () {
          // Arrange
          const area = Area(id: 5, name: 'Bar');

          // Act
          final copy = area.copyWith();

          // Assert
          expect(copy, equals(area));
        },
      );
    });

    group('toString', () {
      test(
        'should produce a non-empty descriptive string containing field values',
        () {
          // Arrange
          const area = Area(id: 1, name: 'Dining');

          // Act
          final result = area.toString();

          // Assert
          expect(result, isNotEmpty);
          expect(result, contains('Dining'));
        },
      );
    });

    group('JSON serialization', () {
      test('should serialize id and name to JSON', () {
        // Arrange
        const area = Area(id: 1, name: 'Dining');

        // Act
        final json = area.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Dining');
      });

      test('should deserialize area from JSON with correct field values', () {
        // Arrange
        final json = {'id': 7, 'name': 'Terrace'};

        // Act
        final area = Area.fromJson(json);

        // Assert
        expect(area.id, 7);
        expect(area.name, 'Terrace');
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = Area(id: 42, name: 'Rooftop');

        // Act
        final restored = Area.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
