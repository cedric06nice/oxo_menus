import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';

void main() {
  group('WidgetDto', () {
    group('fromJson', () {
      test('should deserialize with minimal fields', () {
        // Arrange
        final json = {
          'id': 2,
          'index': 1,
          'type_key': 'text',
          'version': '1.0.0',
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.index, 1);
        expect(dto.typeKey, 'text');
        expect(dto.version, '1.0.0');
        expect(dto.status, isNull);
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.propsJson, isEmpty);
        expect(dto.styleJson, isEmpty);
        expect(dto.column, isNull);
      });

      test('should deserialize from JSON with additional fields', () {
        // Arrange
        final json = {
          'id': 1,
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'status': 'published',
          'date_created': '2025-01-15T10:00:00Z',
          'user_created': 'user-uuid',
          'date_updated': '2025-01-15T11:00:00Z',
          'user_updated': 'user-uuid',
          'props_json': {
            'name': 'Pasta Carbonara',
            'price': 12.50,
            'description': 'Classic Italian pasta',
          },
          'style_json': {'fontSize': 14.0, 'fontWeight': 'bold'},
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.typeKey, 'dish');
        expect(dto.version, '1.0.0');
        expect(dto.status, 'published');
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateCreated, DateTime.parse('2025-01-15T10:00:00Z'));
        expect(dto.userCreated, 'user-uuid');
        expect(dto.dateUpdated, isA<DateTime>());
        expect(dto.dateUpdated, DateTime.parse('2025-01-15T11:00:00Z'));
        expect(dto.userUpdated, 'user-uuid');
        expect(dto.propsJson, isNotNull);
        expect(dto.propsJson['name'], 'Pasta Carbonara');
        expect(dto.propsJson['price'], 12.50);
        expect(dto.propsJson['description'], 'Classic Italian pasta');
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson['fontSize'], 14.0);
        expect(dto.styleJson['fontWeight'], 'bold');
      });

      test('should deserialize column with integer value', () {
        // Arrange
        final json = {
          'id': 2,
          'index': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'column': 5,
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.column?.id, '5');
      });

      test('should deserialize column with ColumnDto', () {
        // Arrange
        final json = {
          'id': 2,
          'index': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'column': {'id': 5, 'width': 300},
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.column?.id, '5');
        expect(dto.column?.width, 300);
      });

      test('should handle different widget types', () {
        // Arrange
        final widgetTypes = ['dish', 'section', 'text', 'image', 'separator'];

        // Act & Assert
        for (var i = 0; i < widgetTypes.length; i++) {
          final json = {
            'id': i + 1,
            'index': i,
            'type_key': widgetTypes[i],
            'version': '1.0.0',
          };
          final dto = WidgetDto(json);
          expect(dto.typeKey, widgetTypes[i]);
        }
      });

      test('should handle empty propsJson and styleJson', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'props_json': <String, dynamic>{},
          'style_json': <String, dynamic>{},
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.propsJson, isNotNull);
        expect(dto.propsJson.isEmpty, true);
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson.isEmpty, true);
      });

      test('should handle complex propsJson structure', () {
        // Arrange
        final json = {
          'id': 4,
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'props_json': {
            'name': 'Pizza Margherita',
            'price': 10.0,
            'allergens': ['gluten', 'dairy'],
            'dietary': ['vegetarian'],
            'showPrice': true,
          },
        };

        // Act
        final dto = WidgetDto(json);

        // Assert
        expect(dto.propsJson, isNotNull);
        expect(dto.propsJson['name'], 'Pizza Margherita');
        expect(dto.propsJson['allergens'], isA<List>());
        expect(dto.propsJson['allergens'].length, 2);
        expect(dto.propsJson['showPrice'], true);
      });
    });
  });
}
