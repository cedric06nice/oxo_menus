import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/data/mappers/container_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/container_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

void main() {
  group('ContainerMapper', () {
    group('toEntity', () {
      test('should map all core fields from a fully-populated DTO', () {
        // Arrange
        final dto = ContainerDto({
          'id': '15',
          'index': 3,
          'status': 'published',
          'page': {'id': '7'},
          'date_created': '2025-02-10T09:00:00Z',
          'date_updated': '2025-02-11T10:00:00Z',
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.id, 15);
        expect(entity.pageId, 7);
        expect(entity.index, 3);
        expect(entity.name, 'Container 15');
        expect(entity.dateCreated, DateTime.parse('2025-02-10T09:00:00Z'));
        expect(entity.dateUpdated, DateTime.parse('2025-02-11T10:00:00Z'));
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = ContainerDto({'id': '99', 'index': 0, 'status': 'draft'});

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.id, 99);
      });

      test(
        'should parse integer id from raw data when id is provided as int',
        () {
          // Arrange
          final dto = ContainerDto({'id': 500, 'index': 0, 'status': 'draft'});

          // Act
          final entity = ContainerMapper.toEntity(dto);

          // Assert
          expect(entity.id, 500);
        },
      );

      test('should default pageId to 0 when page is null', () {
        // Arrange
        final dto = ContainerDto({'id': '1', 'index': 0, 'status': 'draft'});

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.pageId, 0);
      });

      test('should resolve pageId when page is an int reference', () {
        // Arrange
        final dto = ContainerDto({
          'id': '1',
          'index': 0,
          'status': 'draft',
          'page': 8,
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.pageId, 8);
      });

      test('should resolve pageId when page is an expanded map', () {
        // Arrange
        final dto = ContainerDto({
          'id': '1',
          'index': 0,
          'status': 'draft',
          'page': {'id': '13'},
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.pageId, 13);
      });

      test('should build name as "Container {id}"', () {
        // Arrange
        final dto = ContainerDto({'id': '42', 'index': 0, 'status': 'draft'});

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.name, 'Container 42');
      });

      test('should set parentContainerId from int parent_container', () {
        // Arrange
        final dto = ContainerDto({
          'id': '2',
          'index': 0,
          'status': 'draft',
          'parent_container': 10,
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.parentContainerId, 10);
      });

      test(
        'should set parentContainerId from map parent_container with int id',
        () {
          // Arrange
          final dto = ContainerDto({
            'id': '2',
            'index': 0,
            'status': 'draft',
            'parent_container': {'id': 20},
          });

          // Act
          final entity = ContainerMapper.toEntity(dto);

          // Assert
          expect(entity.parentContainerId, 20);
        },
      );

      test('should set parentContainerId to null when absent', () {
        // Arrange
        final dto = ContainerDto({'id': '3', 'index': 0, 'status': 'draft'});

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.parentContainerId, isNull);
      });

      test('should parse layout fields from style_json', () {
        // Arrange
        final dto = ContainerDto({
          'id': '5',
          'index': 0,
          'status': 'draft',
          'style_json': {
            'direction': 'row',
            'alignment': 'start',
            'mainAxisAlignment': 'spaceBetween',
            'spacing': 8.0,
          },
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.layout, isNotNull);
        expect(entity.layout!.direction, 'row');
        expect(entity.layout!.alignment, 'start');
        expect(entity.layout!.mainAxisAlignment, 'spaceBetween');
        expect(entity.layout!.spacing, 8.0);
      });

      test('should parse styleConfig fields from style_json', () {
        // Arrange
        final dto = ContainerDto({
          'id': '6',
          'index': 0,
          'status': 'draft',
          'style_json': {'marginTop': 12.0, 'backgroundColor': '#EFEFEF'},
        });

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.marginTop, 12.0);
        expect(entity.styleConfig!.backgroundColor, '#EFEFEF');
      });

      test(
        'should set layout and styleConfig to null when style_json is absent',
        () {
          // Arrange
          final dto = ContainerDto({'id': '7', 'index': 0, 'status': 'draft'});

          // Act
          final entity = ContainerMapper.toEntity(dto);

          // Assert
          expect(entity.layout, isNull);
          expect(entity.styleConfig, isNull);
        },
      );

      test('should map null dateCreated and dateUpdated to null', () {
        // Arrange
        final dto = ContainerDto({'id': '8', 'index': 0, 'status': 'draft'});

        // Act
        final entity = ContainerMapper.toEntity(dto);

        // Assert
        expect(entity.dateCreated, isNull);
        expect(entity.dateUpdated, isNull);
      });
    });

    group('toDto', () {
      test('should map id, pageId, and index correctly', () {
        // Arrange
        final entity = Container(
          id: 10,
          pageId: 5,
          index: 2,
          name: 'My Container',
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.id, '10');
        expect(dto.page?.id, '5');
        expect(dto.index, 2);
      });

      test(
        'should produce empty style_json when layout and styleConfig are null',
        () {
          // Arrange
          final entity = Container(id: 1, pageId: 2, index: 0, name: 'Empty');

          // Act
          final dto = ContainerMapper.toDto(entity);

          // Assert
          expect(dto.styleJson, isEmpty);
        },
      );

      test('should serialize layout fields into style_json', () {
        // Arrange
        final entity = Container(
          id: 2,
          pageId: 1,
          index: 0,
          name: 'Layout Container',
          layout: const LayoutConfig(
            direction: 'row',
            alignment: 'center',
            spacing: 4.0,
          ),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['direction'], 'row');
        expect(dto.styleJson['alignment'], 'center');
        expect(dto.styleJson['spacing'], 4.0);
      });

      test('should serialize styleConfig fields into style_json', () {
        // Arrange
        final entity = Container(
          id: 3,
          pageId: 1,
          index: 0,
          name: 'Styled',
          styleConfig: const StyleConfig(fontFamily: 'Georgia', fontSize: 16.0),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['fontFamily'], 'Georgia');
        expect(dto.styleJson['fontSize'], 16.0);
      });

      test('should merge layout and styleConfig into a single style_json', () {
        // Arrange
        final entity = Container(
          id: 4,
          pageId: 1,
          index: 0,
          name: 'Merged',
          layout: const LayoutConfig(direction: 'column'),
          styleConfig: const StyleConfig(marginTop: 5.0),
        );

        // Act
        final dto = ContainerMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['direction'], 'column');
        expect(dto.styleJson['marginTop'], 5.0);
      });

      test('should serialize parentContainerId into raw data', () {
        // Arrange
        final entity = Container(
          id: 5,
          pageId: 1,
          index: 0,
          name: 'Child',
          parentContainerId: 99,
        );

        // Act
        final dto = ContainerMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['parent_container'], 99);
      });

      test(
        'should store null for parent_container when parentContainerId is null',
        () {
          // Arrange
          final entity = Container(id: 6, pageId: 1, index: 0, name: 'Root');

          // Act
          final dto = ContainerMapper.toDto(entity);
          final raw = dto.getRawData();

          // Assert
          expect(raw['parent_container'], isNull);
        },
      );
    });

    group('layoutConfigToJson', () {
      test('should only include non-null layout fields', () {
        // Arrange
        const config = LayoutConfig(direction: 'row');

        // Act
        final json = ContainerMapper.layoutConfigToJson(config);

        // Assert
        expect(json['direction'], 'row');
        expect(json.containsKey('alignment'), false);
        expect(json.containsKey('mainAxisAlignment'), false);
        expect(json.containsKey('spacing'), false);
      });

      test('should return empty map when all layout fields are null', () {
        // Arrange
        const config = LayoutConfig();

        // Act
        final json = ContainerMapper.layoutConfigToJson(config);

        // Assert
        expect(json, isEmpty);
      });

      test('should include all four fields when all are provided', () {
        // Arrange
        const config = LayoutConfig(
          direction: 'column',
          alignment: 'end',
          mainAxisAlignment: 'center',
          spacing: 12.0,
        );

        // Act
        final json = ContainerMapper.layoutConfigToJson(config);

        // Assert
        expect(json, hasLength(4));
        expect(json['direction'], 'column');
        expect(json['alignment'], 'end');
        expect(json['mainAxisAlignment'], 'center');
        expect(json['spacing'], 12.0);
      });
    });
  });
}
