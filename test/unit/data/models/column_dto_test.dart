import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/column_dto.dart';

void main() {
  group('ColumnDto', () {
    group('fromJson', () {
      test('should deserialize with minimal fields', () {
        // Arrange
        final json = {"id": 1, "index": 0, "width": 150, "style_json": {}};

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.styleJson, isEmpty);
        expect(dto.container, isNull);
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.widgets, isNull);
      });

      test('should handle width as double', () {
        // Arrange
        final json = {'id': 3, 'index': 0, 'width': 150.5};

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '3');
        expect(dto.index, 0);
        expect(dto.width, 150.5);
      });

      test('should deserialize from JSON with all fields', () {
        // Arrange
        final json = {
          "id": 1,
          "index": 0,
          "width": 150,
          "date_created": "2025-11-13T10:25:31.932Z",
          "date_updated": null,
          "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "user_updated": null,
          "style_json": {'color': '#000000'},
        };

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.dateCreated, DateTime.parse("2025-11-13T10:25:31.932Z"));
        expect(dto.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson['color'], '#000000');
      });

      test('should deserialize from JSON container as integer id', () {
        // Arrange
        final json = {"id": 1, "index": 0, "width": 150, "container": 5};

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.styleJson, isEmpty);
        expect(dto.container, isNotNull);
        expect(dto.container!.id, '5');
      });

      test('should deserialize from JSON container as ContainerDto', () {
        // Arrange
        final json = {
          "id": 1,
          "index": 0,
          "width": 150,
          "container": {"id": 1, "index": 0},
        };

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.styleJson, isEmpty);
        expect(dto.container, isNotNull);
        expect(dto.container!.id, '1');
        expect(dto.container!.index, 0);
      });

      test('should deserialize widgets as list of integer id', () {
        // Arrange
        final json = {
          "id": 1,
          "index": 0,
          "width": 150,
          "widgets": [10, 20, 30],
        };

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.styleJson, isEmpty);
        expect(dto.widgets, isNotNull);
        expect(dto.widgets!.length, 3);
        expect(dto.widgets![0].id, '10');
        expect(dto.widgets![1].id, '20');
        expect(dto.widgets![2].id, '30');
      });

      test('should deserialize widgets as list of WidgetDto', () {
        // Arrange
        final json = {
          "id": 1,
          "index": 0,
          "width": 150,
          "widgets": [
            {"id": 10, "type": "text"},
            {"id": 20, "type": "dish"},
            {"id": 30, "type": "image"},
          ],
        };

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.width, 150);
        expect(dto.styleJson, isEmpty);
        expect(dto.widgets, isNotNull);
        expect(dto.widgets!.length, 3);
        expect(dto.widgets![0].id, '10');
        expect(dto.widgets![1].id, '20');
        expect(dto.widgets![2].id, '30');
      });
    });

    group('isDroppable', () {
      test('isDroppable defaults to true when field absent', () {
        // Arrange
        final json = {"id": 1, "index": 0, "width": 150};

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.isDroppable, true);
      });

      test('reads false when is_droppable: false in JSON', () {
        // Arrange
        final json = {"id": 1, "index": 0, "width": 150, "is_droppable": false};

        // Act
        final dto = ColumnDto(json);

        // Assert
        expect(dto.isDroppable, false);
      });

      test('newItem(isDroppable: false) round-trips correctly', () {
        // Arrange & Act
        final dto = ColumnDto.newItem(index: 0, width: 150, isDroppable: false);

        // Assert
        expect(dto.isDroppable, false);
      });
    });
  });
}
