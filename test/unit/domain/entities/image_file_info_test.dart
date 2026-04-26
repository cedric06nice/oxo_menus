import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';

void main() {
  group('ImageFileInfo', () {
    group('construction', () {
      test('should create ImageFileInfo with only id when title and type are omitted', () {
        // Arrange & Act
        const info = ImageFileInfo(id: 'abc-123');

        // Assert
        expect(info.id, 'abc-123');
        expect(info.title, isNull);
        expect(info.type, isNull);
      });

      test('should store title when title is provided', () {
        // Arrange & Act
        const info = ImageFileInfo(id: 'abc-123', title: 'photo.jpg');

        // Assert
        expect(info.title, 'photo.jpg');
      });

      test('should store type when type is provided', () {
        // Arrange & Act
        const info = ImageFileInfo(id: 'abc-123', type: 'image/jpeg');

        // Assert
        expect(info.type, 'image/jpeg');
      });

      test('should store all fields when id, title and type are all provided', () {
        // Arrange & Act
        const info = ImageFileInfo(
          id: 'abc-123',
          title: 'photo.jpg',
          type: 'image/jpeg',
        );

        // Assert
        expect(info.id, 'abc-123');
        expect(info.title, 'photo.jpg');
        expect(info.type, 'image/jpeg');
      });

      test('should accept an empty string as id', () {
        // Arrange & Act
        const info = ImageFileInfo(id: '');

        // Assert
        expect(info.id, '');
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');
        const b = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');
        const b = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = ImageFileInfo(id: 'abc');
        const b = ImageFileInfo(id: 'xyz');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when title differs', () {
        // Arrange
        const a = ImageFileInfo(id: 'abc', title: 'photo.jpg');
        const b = ImageFileInfo(id: 'abc', title: 'banner.png');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when type differs', () {
        // Arrange
        const a = ImageFileInfo(id: 'abc', type: 'image/jpeg');
        const b = ImageFileInfo(id: 'abc', type: 'image/png');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update title when copyWith is called with a new title', () {
        // Arrange
        const info = ImageFileInfo(id: 'abc-123', title: 'old.jpg');

        // Act
        final updated = info.copyWith(title: 'new.jpg');

        // Assert
        expect(updated.title, 'new.jpg');
        expect(updated.id, 'abc-123');
      });

      test('should update type when copyWith is called with a new type', () {
        // Arrange
        const info = ImageFileInfo(id: 'abc-123', type: 'image/jpeg');

        // Act
        final updated = info.copyWith(type: 'image/png');

        // Assert
        expect(updated.type, 'image/png');
        expect(updated.id, 'abc-123');
      });

      test('should preserve all fields when copyWith is called with no arguments', () {
        // Arrange
        const info = ImageFileInfo(id: 'abc-123', title: 'photo.jpg', type: 'image/jpeg');

        // Act
        final copy = info.copyWith();

        // Assert
        expect(copy, equals(info));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const info = ImageFileInfo(id: 'abc-123', title: 'photo.jpg');

        // Act
        final result = info.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize id, title and type to JSON', () {
        // Arrange
        const info = ImageFileInfo(
          id: 'abc-123',
          title: 'photo.jpg',
          type: 'image/jpeg',
        );

        // Act
        final json = info.toJson();

        // Assert
        expect(json['id'], 'abc-123');
        expect(json['title'], 'photo.jpg');
        expect(json['type'], 'image/jpeg');
      });

      test('should deserialize ImageFileInfo from JSON with correct field values', () {
        // Arrange
        final json = {'id': 'xyz-456', 'title': 'logo.png', 'type': 'image/png'};

        // Act
        final info = ImageFileInfo.fromJson(json);

        // Assert
        expect(info.id, 'xyz-456');
        expect(info.title, 'logo.png');
        expect(info.type, 'image/png');
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = ImageFileInfo(
          id: 'abc-123',
          title: 'photo.jpg',
          type: 'image/jpeg',
        );

        // Act
        final restored = ImageFileInfo.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should round-trip with null optional fields through JSON', () {
        // Arrange
        const original = ImageFileInfo(id: 'no-meta');

        // Act
        final restored = ImageFileInfo.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
