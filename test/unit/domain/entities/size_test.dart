import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import '../../../fakes/builders/size_builder.dart';

void main() {
  group('Size', () {
    group('construction', () {
      test('should create size with correct required fields when all required fields are provided', () {
        // Arrange & Act
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Assert
        expect(size.id, 1);
        expect(size.name, 'A4');
        expect(size.width, 210.0);
        expect(size.height, 297.0);
        expect(size.status, Status.published);
        expect(size.direction, 'portrait');
      });

      test('should accept draft status when status is set to draft', () {
        // Arrange & Act
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.draft,
          direction: 'portrait',
        );

        // Assert
        expect(size.status, Status.draft);
      });

      test('should accept archived status when status is set to archived', () {
        // Arrange & Act
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.archived,
          direction: 'landscape',
        );

        // Assert
        expect(size.status, Status.archived);
      });

      test('should accept landscape direction when direction is "landscape"', () {
        // Arrange & Act
        const size = Size(
          id: 2,
          name: 'A4-landscape',
          width: 297.0,
          height: 210.0,
          status: Status.published,
          direction: 'landscape',
        );

        // Assert
        expect(size.direction, 'landscape');
      });

      test('should accept zero width and height when dimensions are zero', () {
        // Arrange & Act
        const size = Size(
          id: 1,
          name: 'Zero',
          width: 0.0,
          height: 0.0,
          status: Status.draft,
          direction: 'portrait',
        );

        // Assert
        expect(size.width, 0.0);
        expect(size.height, 0.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 2,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 1,
          name: 'A5',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when status differs', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.draft,
          direction: 'portrait',
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when direction differs', () {
        // Arrange
        const a = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );
        const b = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'landscape',
        );

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        // Arrange
        final size = buildSize(name: 'A4');

        // Act
        final updated = size.copyWith(name: 'A5');

        // Assert
        expect(updated.name, 'A5');
      });

      test('should update width when copyWith is called with a new width', () {
        // Arrange
        final size = buildSize(width: 210.0);

        // Act
        final updated = size.copyWith(width: 148.0);

        // Assert
        expect(updated.width, 148.0);
      });

      test('should update height when copyWith is called with a new height', () {
        // Arrange
        final size = buildSize(height: 297.0);

        // Act
        final updated = size.copyWith(height: 210.0);

        // Assert
        expect(updated.height, 210.0);
      });

      test('should update status when copyWith is called with a new status', () {
        // Arrange
        final size = buildSize(status: Status.published);

        // Act
        final updated = size.copyWith(status: Status.archived);

        // Assert
        expect(updated.status, Status.archived);
      });

      test('should update direction when copyWith is called with a new direction', () {
        // Arrange
        final size = buildSize(direction: 'portrait');

        // Act
        final updated = size.copyWith(direction: 'landscape');

        // Assert
        expect(updated.direction, 'landscape');
      });

      test('should preserve id when only name is updated via copyWith', () {
        // Arrange
        final size = buildSize(id: 42, name: 'Old');

        // Act
        final updated = size.copyWith(name: 'New');

        // Assert
        expect(updated.id, 42);
      });

      test('should preserve all fields when copyWith is called with no arguments', () {
        // Arrange
        final size = buildSize();

        // Act
        final copy = size.copyWith();

        // Assert
        expect(copy, equals(size));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        final size = buildSize();

        // Act
        final result = size.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize all required fields to JSON', () {
        // Arrange
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Act
        final json = size.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'A4');
        expect(json['width'], 210.0);
        expect(json['height'], 297.0);
        expect(json['direction'], 'portrait');
      });

      test('should serialize status as its JSON string value', () {
        // Arrange
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.draft,
          direction: 'portrait',
        );

        // Act
        final json = size.toJson();

        // Assert
        expect(json['status'], 'draft');
      });

      test('should deserialize size from JSON with correct field values', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'A5',
          'width': 148.0,
          'height': 210.0,
          'status': 'published',
          'direction': 'landscape',
        };

        // Act
        final size = Size.fromJson(json);

        // Assert
        expect(size.id, 2);
        expect(size.name, 'A5');
        expect(size.width, 148.0);
        expect(size.height, 210.0);
        expect(size.status, Status.published);
        expect(size.direction, 'landscape');
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = Size(
          id: 5,
          name: 'Letter',
          width: 215.9,
          height: 279.4,
          status: Status.published,
          direction: 'portrait',
        );

        // Act
        final restored = Size.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should round-trip archived status through JSON', () {
        // Arrange
        const original = Size(
          id: 1,
          name: 'Deprecated',
          width: 100.0,
          height: 200.0,
          status: Status.archived,
          direction: 'portrait',
        );

        // Act
        final restored = Size.fromJson(original.toJson());

        // Assert
        expect(restored.status, Status.archived);
      });
    });
  });
}
