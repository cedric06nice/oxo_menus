import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/page_dto.dart';

void main() {
  group('PageDto', () {
    group('fromJson', () {
      test('should deserialise with only required fields', () {
        // Arrange
        final json = {'id': 2, 'index': 1, 'status': 'draft'};

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.index, 1);
        expect(dto.status, 'draft');
        expect(dto.userCreated, isNull);
        expect(dto.dateCreated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.menu, isNull);
        expect(dto.containers, isNull);
      });

      test('should deserialize from JSON with additional fields', () {
        // Arrange
        final json = {
          'id': 1,
          'index': 0,
          'status': 'published',
          "user_created": 'f8205fcc-3816-4a93-9010-76df1a1f4a90',
          'date_created': '2025-01-15T10:00:00.000Z',
          'user_updated': null,
          'date_updated': null,
        };
        final json2 = {
          'id': 1,
          'index': 0,
          'status': 'published',
          "user_created": 'f8205fcc-3816-4a93-9010-76df1a1f4a90',
          'date_created': '2025-01-15T10:00:00.000Z',
          'user_updated': 'user-uuid',
          'date_updated': '2025-01-15T10:00:00.000Z',
        };

        // Act
        final dto = PageDto(json);
        final dto2 = PageDto(json2);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.status, 'published');
        expect(dto.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateCreated!.toIso8601String(), '2025-01-15T10:00:00.000Z');
        expect(dto.userUpdated, isNull);
        expect(dto.dateUpdated, isNull);

        expect(dto2.id, '1');
        expect(dto2.index, 0);
        expect(dto2.status, 'published');
        expect(dto2.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(dto2.dateCreated, isA<DateTime>());
        expect(dto2.dateCreated!.toIso8601String(), '2025-01-15T10:00:00.000Z');
        expect(dto2.userUpdated, 'user-uuid');
        expect(dto2.dateUpdated, isA<DateTime>());
        expect(dto2.dateUpdated!.toIso8601String(), '2025-01-15T10:00:00.000Z');
      });

      test('should deserialise menu as integer id', () {
        // Arrange
        final json = {'id': 2, 'index': 1, 'status': 'draft', 'menu': 123};

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.menu, isNotNull);
        expect(dto.menu?.id, '123');
      });

      test('should deserialise menu as MenuDto', () {
        // Arrange
        final json = {
          'id': 2,
          'index': 1,
          'status': 'draft',
          'menu': {
            "id": 123,
            "status": "published",
            "name": "Restaurant A La Carte",
          },
        };

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.menu, isNotNull);
        expect(dto.menu?.id, '123');
        expect(dto.menu?.name, 'Restaurant A La Carte');
        expect(dto.menu?.status, 'published');
      });

      test('should handle empty containers list', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'containers': <int>[],
        };

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.containers, isNotNull);
        expect(dto.containers!.isEmpty, true);
      });

      test('should deserialise containers as list of integer id', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'containers': [1, 2],
        };

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.containers, isNotNull);
        expect(dto.containers![0].id, '1');
        expect(dto.containers![1].id, '2');
      });

      test('should deserialise containers as list of VersionDto', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'containers': [
            {
              "id": 1,
              "index": 0,
              "direction": "landscape",
              "style_json": {},
            },
          ],
        };

        // Act
        final dto = PageDto(json);

        // Assert
        expect(dto.containers, isNotNull);
        expect(dto.containers![0].id, '1');
        expect(dto.containers![0].index, 0);
        expect(dto.containers![0].direction, 'landscape');
      });
    });
  });
}
