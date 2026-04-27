import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/data/mappers/file_mapper.dart';

void main() {
  group('FileMapper', () {
    group('toEntity', () {
      test(
        'should map id, title, and type from a fully-populated data map',
        () {
          // Arrange
          final data = {
            'id': 'abc-123',
            'title': 'Menu Banner',
            'type': 'image/jpeg',
          };

          // Act
          final entity = FileMapper.toEntity(data);

          // Assert
          expect(entity.id, 'abc-123');
          expect(entity.title, 'Menu Banner');
          expect(entity.type, 'image/jpeg');
        },
      );

      test('should map null title as null', () {
        // Arrange
        final data = {'id': 'file-001', 'title': null, 'type': 'image/png'};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.title, isNull);
      });

      test('should map null type as null', () {
        // Arrange
        final data = {'id': 'file-002', 'title': 'Some Image', 'type': null};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.type, isNull);
      });

      test('should map when both title and type are absent', () {
        // Arrange
        final data = <String, dynamic>{'id': 'file-003'};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.id, 'file-003');
        expect(entity.title, isNull);
        expect(entity.type, isNull);
      });

      test('should preserve id exactly as provided', () {
        // Arrange
        final data = {
          'id': 'f8205fcc-3816-4a93-9010-76df1a1f4a90',
          'title': null,
          'type': null,
        };

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.id, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
      });

      test('should map image/jpeg type correctly', () {
        // Arrange
        final data = {'id': 'img-1', 'title': null, 'type': 'image/jpeg'};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.type, 'image/jpeg');
      });

      test('should map image/png type correctly', () {
        // Arrange
        final data = {'id': 'img-2', 'title': null, 'type': 'image/png'};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.type, 'image/png');
      });

      test('should map image/webp type correctly', () {
        // Arrange
        final data = {'id': 'img-3', 'title': null, 'type': 'image/webp'};

        // Act
        final entity = FileMapper.toEntity(data);

        // Assert
        expect(entity.type, 'image/webp');
      });
    });
  });
}
