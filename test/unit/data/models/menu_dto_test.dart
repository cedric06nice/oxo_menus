import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';

void main() {
  group('MenuDto', () {
    group('fromJson', () {
      test('should deserialise with only required fields', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.userCreated, isNull);
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.styleJson, {});
        expect(dto.area, isNull);
        expect(dto.size, isNull);
        expect(dto.versions, isNull);
        expect(dto.pages, isNull);
      });

      test('should deserialise optional fileds', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "user_updated": null,
          "date_created": "2025-11-13T10:25:31.922Z",
          "date_updated": null,
        };
        final json2 = {
          "id": 2,
          "name": "Brasserie A La Carte",
          "version": "1.0.0",
          "status": "published",
          "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "user_updated": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "date_created": "2025-11-13T15:48:01.962Z",
          "date_updated": "2025-12-15T15:17:57.075Z",
        };

        // Act
        final dto = MenuDto(json);
        final dto2 = MenuDto(json2);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateCreated!.toIso8601String(), '2025-11-13T10:25:31.922Z');
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);

        expect(dto2.id, '2');
        expect(dto2.name, 'Brasserie A La Carte');
        expect(dto2.version, '1.0.0');
        expect(dto2.status, 'published');
        expect(dto2.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(dto2.dateCreated, isA<DateTime>());
        expect(dto2.dateCreated!.toIso8601String(), '2025-11-13T15:48:01.962Z');
        expect(dto2.dateUpdated, isA<DateTime>());
        expect(dto2.dateUpdated!.toIso8601String(), '2025-12-15T15:17:57.075Z');
        expect(dto2.userUpdated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
      });

      test('should deserialize StyleJson', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "style_json": {
            'fontFamily': 'Arial',
            'fontSize': 14.0,
            'primaryColor': '#000000',
          },
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.styleJson['fontFamily'], 'Arial');
        expect(dto.styleJson['fontSize'], 14.0);
        expect(dto.styleJson['primaryColor'], '#000000');
      });

      test('should deserialise area as integer id', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "area": 1,
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.area, isNotNull);
        expect(dto.area!.id, '1');
      });

      test('should deserialise area AreaDto', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "area": {
            "id": 1,
            "date_created": "2025-11-13T10:25:31.830Z",
            "date_updated": null,
            "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
            "user_updated": null,
            "name": "Restaurant",
            "menus": [1],
          },
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.area, isNotNull);
        expect(dto.area!.id, '1');
        expect(dto.area!.name, 'Restaurant');
      });

      test('should deserialise versions as list of integer id', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "versions": [1, 2, 3],
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.versions, isNotNull);
        expect(dto.versions!.length, 3);
        expect(dto.versions![0].id, '1');
        expect(dto.versions![1].id, '2');
        expect(dto.versions![2].id, '3');
      });

      test('should deserialise versions as list of VersionDto', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "versions": [
            {
              "id": 1,
              "snapshot_json": {'someKey': 'someValue'},
              "date_created": "2025-11-13T10:25:31.830Z",
              "date_updated": null,
              "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
              "user_updated": null,
              "menu": 1,
            },
          ],
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.versions, isNotNull);
        expect(dto.versions!.length, 1);
        expect(dto.versions![0].id, '1');
        expect(dto.versions![0].snapshotJson['someKey'], 'someValue');
        expect(dto.versions![0].menu, isNotNull);
        expect(dto.versions![0].menu!.id, '1');
      });

      test('should deserialise pages as list of integer id', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "pages": [1, 2, 3],
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.pages, isNotNull);
        expect(dto.pages!.length, 3);
        expect(dto.pages![0].id, '1');
        expect(dto.pages![1].id, '2');
        expect(dto.pages![2].id, '3');
      });

      test('should deserialise pages as list of PageDto', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "pages": [
            {
              "id": 1,
              "status": "published",
              "date_created": "2025-11-13T10:25:31.926Z",
              "date_updated": null,
              "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
              "user_updated": null,
              "index": 0,
              "menu": 1,
              "containers": [1, 2],
            },
          ],
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.pages, isNotNull);
        expect(dto.pages!.length, 1);
        expect(dto.pages![0].id, '1');
        expect(dto.pages![0].status, 'published');
        expect(dto.pages![0].index, 0);
        expect(dto.pages![0].menu, isNotNull);
        expect(dto.pages![0].menu!.id, '1');
      });

      test('should deserialise size as list of integer id', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "size": 1,
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.size, isNotNull);
        expect(dto.size!.id, '1');
      });

      test('should deserialise size as list of SizeDto', () {
        // Arrange
        final json = {
          "id": 1,
          "name": "Restaurant A La Carte",
          "version": "1.0.0",
          "status": "published",
          "size": {
            "id": 1,
            "status": "published",
            "date_created": "2025-11-13T10:25:31.884Z",
            "date_updated": null,
            "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
            "user_updated": null,
            "name": "A4 (Portrait)",
            "width": 210,
            "height": 297,
            "direction": "portrait",
            "menus": [1],
          },
        };

        // Act
        final dto = MenuDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant A La Carte');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.size, isNotNull);
        expect(dto.size!.id, '1');
        expect(dto.size!.name, 'A4 (Portrait)');
        expect(dto.size!.width, 210);
        expect(dto.size!.height, 297);
      });
    });
  });
}
