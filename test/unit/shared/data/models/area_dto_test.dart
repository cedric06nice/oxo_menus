import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/data/models/area_dto.dart';

void main() {
  group('AreaDto', () {
    group('fromJson', () {
      test('should deserialise from JSON the minimum fields', () {
        // Arrange
        final json = {"id": 1, "name": "Restaurant"};

        // Act
        final dto = AreaDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'Restaurant');
      });

      test('should deserialise from JSON all fields', () {
        // Arrange
        final json = {
          "id": 2,
          "name": "Bar",
          "date_created": "2023-10-01T12:00:00Z",
          "date_updated": "2023-10-02T12:00:00Z",
          "user_created": "system",
          "user_updated": "admin",
        };

        // Act
        final dto = AreaDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.name, 'Bar');
        expect(dto.dateCreated, DateTime.parse("2023-10-01T12:00:00Z"));
        expect(dto.dateUpdated, DateTime.parse("2023-10-02T12:00:00Z"));
        expect(dto.userCreated, 'system');
        expect(dto.userUpdated, 'admin');
      });

      test('should deserialise from JSON menus as list of integer id', () {
        // Arrange
        final json = {
          "id": 3,
          "name": "Brasserie",
          "menus": [1],
        };

        // Act
        final dto = AreaDto(json);

        // Assert
        expect(dto.id, '3');
        expect(dto.name, 'Brasserie');
        expect(dto.menus, isNotNull);
        expect(dto.menus!.length, 1);
        expect(dto.menus!.first.id, '1');
      });

      test('should deserialise from JSON menus as list of MenuDto', () {
        // Arrange
        final json = {
          "id": 3,
          "name": "Brasserie",
          "menus": [
            {
              "id": 1,
              "status": "published",
              "name": "Restaurant A La Carte",
              "style_json": {},
              "version": "1.0.0",
            },
          ],
        };

        // Act
        final dto = AreaDto(json);

        // Assert
        expect(dto.id, '3');
        expect(dto.name, 'Brasserie');
        expect(dto.menus, isNotNull);
        expect(dto.menus!.length, 1);
        expect(dto.menus!.first.id, '1');
        expect(dto.menus!.first.name, 'Restaurant A La Carte');
        expect(dto.menus!.first.status, 'published');
        expect(dto.menus!.first.styleJson, isEmpty);
        expect(dto.menus!.first.version, '1.0.0');
      });
    });
  });
}
