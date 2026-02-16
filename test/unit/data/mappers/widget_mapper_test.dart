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

      test('should map is_template true to isTemplate true', () {
        // Arrange
        final dto = WidgetDto({
          'id': 3,
          'column': 5,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
          'is_template': true,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.isTemplate, true);
      });

      test('should default isTemplate to false when field absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': 4,
          'column': 6,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.isTemplate, false);
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

    group('toDto', () {
      test('should map isTemplate true to is_template true', () {
        // Arrange
        const entity = WidgetInstance(
          id: 1,
          columnId: 3,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {'text': 'Hello'},
          isTemplate: true,
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert
        expect(dto.isTemplate, true);
      });

      test('should map isTemplate false to is_template false', () {
        // Arrange
        const entity = WidgetInstance(
          id: 2,
          columnId: 4,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert
        expect(dto.isTemplate, false);
      });

      test('should convert WidgetInstance with style to WidgetDto', () {
        const entity = WidgetInstance(
          id: 5,
          columnId: 10,
          type: 'dish',
          version: '2.0.0',
          index: 3,
          props: {'name': 'Test Dish'},
          style: WidgetStyle(
            fontFamily: 'Arial',
            fontSize: 14.0,
            color: '#FF0000',
            backgroundColor: '#FFFFFF',
            border: 'solid',
            padding: 8.0,
          ),
        );

        final dto = WidgetMapper.toDto(entity);

        expect(dto.id, '5');
        expect(dto.typeKey, 'dish');
        expect(dto.version, '2.0.0');
        expect(dto.index, 3);
        expect(dto.propsJson['name'], 'Test Dish');

        final styleJson = dto.styleJson;
        expect(styleJson['fontFamily'], 'Arial');
        expect(styleJson['fontSize'], 14.0);
        expect(styleJson['color'], '#FF0000');
        expect(styleJson['backgroundColor'], '#FFFFFF');
        expect(styleJson['border'], 'solid');
        expect(styleJson['padding'], 8.0);
      });

      test('should convert WidgetInstance with null style to WidgetDto', () {
        const entity = WidgetInstance(
          id: 6,
          columnId: 11,
          type: 'section',
          version: '1.0.0',
          index: 0,
          props: {'title': 'Test'},
        );

        final dto = WidgetMapper.toDto(entity);

        expect(dto.styleJson, isEmpty);
      });

      test('should convert WidgetInstance with partial style', () {
        const entity = WidgetInstance(
          id: 7,
          columnId: 12,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
          style: WidgetStyle(fontSize: 16.0),
        );

        final dto = WidgetMapper.toDto(entity);

        final styleJson = dto.styleJson;
        expect(styleJson['fontSize'], 16.0);
        expect(styleJson.containsKey('fontFamily'), false);
        expect(styleJson.containsKey('color'), false);
      });
    });

    group('widgetStyleToJson', () {
      test('should only include non-null fields', () {
        const style = WidgetStyle(
          color: '#000000',
          padding: 4.0,
        );

        final json = WidgetMapper.widgetStyleToJson(style);

        expect(json, hasLength(2));
        expect(json['color'], '#000000');
        expect(json['padding'], 4.0);
      });

      test('should return empty map for empty style', () {
        const style = WidgetStyle();

        final json = WidgetMapper.widgetStyleToJson(style);

        expect(json, isEmpty);
      });
    });
  });
}
