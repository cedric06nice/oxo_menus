import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

void main() {
  group('WidgetMapper', () {
    group('toEntity', () {
      test('should convert WidgetDto to Widget with all fields', () {
        // Arrange
        final dto = WidgetDto({
          'id': 1,
          "status": "published",
          'date_created': '2025-01-15T10:00:00.000Z',
          'date_updated': '2025-01-15T11:00:00.000Z',
          "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "user_updated": null,
          'type_key': 'text',
          'version': "1.0.0",
          'index': 0,
          'props_json': {"text": "Hello"},
          'style_json': {"color": "red", "fontSize": 14, "test": "value"},
          'column': 3,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1);
        expect(entity.columnId, 3);
        expect(entity.type, 'text');
        expect(entity.version, '1.0.0');
        expect(entity.index, 0);
        expect(entity.props, {'text': 'Hello'});
        expect(entity.style, WidgetStyle(color: 'red', fontSize: 14));
        expect(entity.dateCreated, isA<DateTime>());
        expect(entity.dateUpdated, isA<DateTime>());
      });

      test('should convert WidgetDto with minimal fields', () {
        // Arrange
        final dto = WidgetDto({
          'id': 2,
          'column': 4,
          'type_key': 'image',
          'version': '1.0.0',
          'index': 1,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.id, 2);
        expect(entity.columnId, 4);
        expect(entity.type, 'image');
        expect(entity.version, '1.0.0');
        expect(entity.index, 1);
        expect(entity.props, isEmpty);
        expect(entity.style, isNull);
      });
    });
  });
}
