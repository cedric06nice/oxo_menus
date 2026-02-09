import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/container_mapper.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('ContainerMapper', () {
    group('toEntity', () {
      test('should convert ContainerDto to Container with all fields', () {
        // Arrange
        final dto = ContainerDto({
          'id': 1,
          'index': 0,
          'status': 'published',
          'direction': 'row',
          'page': 5,
          'style_json': {
            'direction': 'row',
            'alignment': 'center',
            'spacing': 16.0,
          },
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-15T11:00:00Z',
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1);
        expect(entity.pageId, 5);
        expect(entity.index, 0);
        expect(entity.name, 'Container 1');
        expect(entity.layout, isNotNull);
        expect(entity.layout!.direction, 'row');
        expect(entity.layout!.alignment, 'center');
        expect(entity.layout!.spacing, 16.0);
        expect(entity.dateCreated, isA<DateTime>());
        expect(entity.dateUpdated, isA<DateTime>());
      });

      test('should convert ContainerDto with minimal fields', () {
        // Arrange
        final dto = ContainerDto({
          'id': 2,
          'index': 1,
          'status': 'draft',
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.id, 2);
        expect(entity.pageId, 0); // Defaults to 0
        expect(entity.index, 1);
        expect(entity.name, 'Container 2');
        expect(entity.layout, isNull);
      });

      test('should parse styleConfig from style_json', () {
        // Arrange
        final dto = ContainerDto({
          'id': 4,
          'index': 0,
          'status': 'published',
          'page': 1,
          'style_json': {
            'direction': 'row',
            'marginTop': 10.0,
            'paddingLeft': 8.0,
            'borderType': 'plain_thin',
          },
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.marginTop, 10.0);
        expect(entity.styleConfig!.paddingLeft, 8.0);
        expect(entity.styleConfig!.borderType, BorderType.plainThin);
        // Layout should still be parsed too
        expect(entity.layout, isNotNull);
        expect(entity.layout!.direction, 'row');
      });

      test('should have null styleConfig when style_json is empty', () {
        // Arrange
        final dto = ContainerDto({
          'id': 5,
          'index': 0,
          'status': 'published',
          'page': 1,
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNull);
      });

      test('should handle null layout_json', () {
        // Arrange
        final dto = ContainerDto({
          'id': 3,
          'index': 0,
          'status': 'published',
          'page': 1,
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.id, 3);
        expect(entity.layout, isNull);
      });
    });

    group('toDto', () {
      test('should convert Container to ContainerDto with all fields', () {
        // Arrange
        final entity = Container(
          id: 1,
          pageId: 5,
          index: 0,
          name: 'Main Container',
          layout: LayoutConfig(
            direction: 'row',
            alignment: 'center',
            spacing: 16.0,
          ),
          dateCreated: DateTime.parse('2025-01-15T10:00:00Z'),
          dateUpdated: DateTime.parse('2025-01-15T11:00:00Z'),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.id, '1');
        expect(dto.page?.id, '5');
        expect(dto.index, 0);
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson['direction'], 'row');
        expect(dto.styleJson['alignment'], 'center');
        expect(dto.styleJson['spacing'], 16.0);
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateUpdated, isA<DateTime>());
      });

      test('should convert Container with minimal fields', () {
        // Arrange
        final entity = Container(
          id: 2,
          pageId: 3,
          index: 1,
          name: 'Simple Container',
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.id, '2');
        expect(dto.page?.id, '3');
        expect(dto.index, 1);
        expect(dto.styleJson, isEmpty);
      });

      test('should serialize styleConfig into style_json', () {
        // Arrange
        final entity = Container(
          id: 4,
          pageId: 1,
          index: 0,
          name: 'Styled Container',
          layout: LayoutConfig(direction: 'row'),
          styleConfig: StyleConfig(
            marginTop: 10.0,
            borderType: BorderType.dropShadow,
          ),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['marginTop'], 10.0);
        expect(dto.styleJson['borderType'], 'drop_shadow');
        // Layout fields should also be present
        expect(dto.styleJson['direction'], 'row');
      });

      test('should serialize only layout when styleConfig is null', () {
        // Arrange
        final entity = Container(
          id: 5,
          pageId: 1,
          index: 0,
          name: 'Layout Only',
          layout: LayoutConfig(direction: 'column', spacing: 8.0),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['direction'], 'column');
        expect(dto.styleJson['spacing'], 8.0);
        expect(dto.styleJson.containsKey('marginTop'), false);
      });

      test('should handle null layout', () {
        // Arrange
        final entity = Container(
          id: 3,
          pageId: 1,
          index: 0,
          name: 'No Layout Container',
          layout: null,
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.id, '3');
        expect(dto.styleJson, isEmpty);
      });
    });

    group('layoutConfigToJson', () {
      test('should convert LayoutConfig to JSON with all fields', () {
        // Arrange
        final config = LayoutConfig(
          direction: 'column',
          alignment: 'start',
          spacing: 8.0,
        );

        // Act
        final json = ContainerMapper.layoutConfigToJson(config);

        // Assert
        expect(json['direction'], 'column');
        expect(json['alignment'], 'start');
        expect(json['spacing'], 8.0);
      });

      test('should handle partial LayoutConfig', () {
        // Arrange
        final config = LayoutConfig(
          direction: 'row',
        );

        // Act
        final json = ContainerMapper.layoutConfigToJson(config);

        // Assert
        expect(json['direction'], 'row');
        expect(json.containsKey('alignment'), false);
        expect(json.containsKey('spacing'), false);
      });
    });
  });
}
