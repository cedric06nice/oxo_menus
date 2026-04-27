import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/widget_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

void main() {
  group('WidgetMapper', () {
    group('toEntity', () {
      test('should map all fields from a fully-populated DTO', () {
        // Arrange
        final dto = WidgetDto({
          'id': '5',
          'column': {'id': '3'},
          'type_key': 'dish',
          'version': '2.0.0',
          'index': 1,
          'props_json': {'name': 'Burger', 'price': 12.5},
          'style_json': {
            'fontFamily': 'Arial',
            'fontSize': 14.0,
            'color': '#000000',
            'backgroundColor': '#FFFFFF',
            'border': 'solid',
            'padding': 8.0,
          },
          'is_template': false,
          'locked_for_edition': false,
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-16T11:00:00Z',
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.id, 5);
        expect(entity.columnId, 3);
        expect(entity.type, 'dish');
        expect(entity.version, '2.0.0');
        expect(entity.index, 1);
        expect(entity.props, {'name': 'Burger', 'price': 12.5});
        expect(entity.style, isNotNull);
        expect(entity.style!.fontFamily, 'Arial');
        expect(entity.style!.fontSize, 14.0);
        expect(entity.style!.color, '#000000');
        expect(entity.style!.backgroundColor, '#FFFFFF');
        expect(entity.style!.border, 'solid');
        expect(entity.style!.padding, 8.0);
        expect(entity.isTemplate, false);
        expect(entity.lockedForEdition, false);
        expect(entity.dateCreated, DateTime.parse('2025-01-15T10:00:00Z'));
        expect(entity.dateUpdated, DateTime.parse('2025-01-16T11:00:00Z'));
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = WidgetDto({
          'id': '42',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.id, 42);
      });

      test('should parse a large integer id correctly', () {
        // Arrange
        final dto = WidgetDto({
          'id': '9999',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.id, 9999);
      });

      test('should default columnId to 0 when column is null', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.columnId, 0);
      });

      test('should resolve columnId when column is an int reference', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'column': 9,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.columnId, 9);
      });

      test('should resolve columnId when column is an expanded map', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'column': {'id': '15'},
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.columnId, 15);
      });

      test('should default props to empty map when props_json is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.props, isEmpty);
      });

      test('should set style to null when style_json is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.style, isNull);
      });

      test('should map is_template true to isTemplate true', () {
        // Arrange
        final dto = WidgetDto({
          'id': '2',
          'column': 1,
          'type_key': 'image',
          'version': '1.0.0',
          'index': 0,
          'is_template': true,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.isTemplate, true);
      });

      test('should default isTemplate to false when field is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '3',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.isTemplate, false);
      });

      test('should map locked_for_edition true to lockedForEdition true', () {
        // Arrange
        final dto = WidgetDto({
          'id': '4',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
          'locked_for_edition': true,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.lockedForEdition, true);
      });

      test('should default lockedForEdition to false when field is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '5',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.lockedForEdition, false);
      });

      test('should map null dateCreated and dateUpdated to null', () {
        // Arrange
        final dto = WidgetDto({
          'id': '6',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.dateCreated, isNull);
        expect(entity.dateUpdated, isNull);
      });

      test('should parse partial style_json with only color field', () {
        // Arrange
        final dto = WidgetDto({
          'id': '7',
          'column': 1,
          'type_key': 'section',
          'version': '1.0.0',
          'index': 0,
          'style_json': {'color': '#FF0000'},
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.style, isNotNull);
        expect(entity.style!.color, '#FF0000');
        expect(entity.style!.fontFamily, isNull);
        expect(entity.style!.fontSize, isNull);
      });

      test('should coerce integer fontSize in style_json to double', () {
        // Arrange
        final dto = WidgetDto({
          'id': '8',
          'column': 1,
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
          'style_json': {'fontSize': 16},
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.style!.fontSize, isA<double>());
        expect(entity.style!.fontSize, 16.0);
      });
    });

    group('toDto', () {
      test(
        'should map all fields from a fully-populated WidgetInstance entity',
        () {
          // Arrange
          const entity = WidgetInstance(
            id: 10,
            columnId: 4,
            type: 'wine',
            version: '3.0.0',
            index: 2,
            props: {'name': 'Merlot', 'price': 8.5},
            style: WidgetStyle(
              fontFamily: 'Georgia',
              fontSize: 12.0,
              color: '#333333',
              backgroundColor: '#FAFAFA',
              border: 'none',
              padding: 4.0,
            ),
            isTemplate: true,
            lockedForEdition: false,
          );

          // Act
          final dto = WidgetMapper.toDto(entity);

          // Assert
          expect(dto.id, '10');
          expect(dto.column?.id, '4');
          expect(dto.typeKey, 'wine');
          expect(dto.version, '3.0.0');
          expect(dto.index, 2);
          expect(dto.propsJson, {'name': 'Merlot', 'price': 8.5});
          expect(dto.isTemplate, true);
          expect(dto.lockedForEdition, false);
          final styleJson = dto.styleJson;
          expect(styleJson['fontFamily'], 'Georgia');
          expect(styleJson['fontSize'], 12.0);
          expect(styleJson['color'], '#333333');
          expect(styleJson['backgroundColor'], '#FAFAFA');
          expect(styleJson['border'], 'none');
          expect(styleJson['padding'], 4.0);
        },
      );

      test('should produce empty style_json when style is null', () {
        // Arrange
        const entity = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert
        expect(dto.styleJson, isEmpty);
      });

      test('should include only non-null style fields', () {
        // Arrange
        const entity = WidgetInstance(
          id: 2,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
          style: WidgetStyle(fontSize: 18.0),
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert
        final styleJson = dto.styleJson;
        expect(styleJson, hasLength(1));
        expect(styleJson['fontSize'], 18.0);
      });

      test('should map isTemplate false to is_template false', () {
        // Arrange
        const entity = WidgetInstance(
          id: 3,
          columnId: 1,
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

      test('should map lockedForEdition true to locked_for_edition true', () {
        // Arrange
        const entity = WidgetInstance(
          id: 4,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
          lockedForEdition: true,
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert
        expect(dto.lockedForEdition, true);
      });

      test('should serialize null editingBy as null in raw data', () {
        // Arrange
        const entity = WidgetInstance(
          id: 5,
          columnId: 1,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['editing_by'], isNull);
        expect(raw['editing_since'], isNull);
      });
    });

    group('widgetStyleToJson', () {
      test('should return empty map when all style fields are null', () {
        // Arrange
        const style = WidgetStyle();

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json, isEmpty);
      });

      test('should include only non-null fields', () {
        // Arrange
        const style = WidgetStyle(color: '#000000', padding: 4.0);

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json, hasLength(2));
        expect(json['color'], '#000000');
        expect(json['padding'], 4.0);
      });

      test('should include fontFamily when set', () {
        // Arrange
        const style = WidgetStyle(fontFamily: 'Courier');

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json['fontFamily'], 'Courier');
      });

      test('should include fontSize when set', () {
        // Arrange
        const style = WidgetStyle(fontSize: 20.0);

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json['fontSize'], 20.0);
      });

      test('should include backgroundColor when set', () {
        // Arrange
        const style = WidgetStyle(backgroundColor: '#CCCCCC');

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json['backgroundColor'], '#CCCCCC');
      });

      test('should include border when set', () {
        // Arrange
        const style = WidgetStyle(border: 'dashed');

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json['border'], 'dashed');
      });

      test('should include all six fields when all are set', () {
        // Arrange
        const style = WidgetStyle(
          fontFamily: 'Verdana',
          fontSize: 11.0,
          color: '#AAAAAA',
          backgroundColor: '#BBBBBB',
          border: 'solid',
          padding: 2.0,
        );

        // Act
        final json = WidgetMapper.widgetStyleToJson(style);

        // Assert
        expect(json, hasLength(6));
      });
    });
  });
}
