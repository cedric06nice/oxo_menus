import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/column_mapper.dart';
import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';

void main() {
  group('ColumnMapper', () {
    group('toEntity', () {
      test('should map all core fields from a fully-populated DTO', () {
        // Arrange
        final dto = ColumnDto({
          'id': '10',
          'index': 2,
          'width': 300,
          'container': {'id': '5'},
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-16T12:00:00Z',
          'is_droppable': true,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.id, 10);
        expect(entity.containerId, 5);
        expect(entity.index, 2);
        expect(entity.width, 300.0);
        expect(entity.flex, isNull);
        expect(entity.isDroppable, true);
        expect(entity.dateCreated, DateTime.parse('2025-01-15T10:00:00Z'));
        expect(entity.dateUpdated, DateTime.parse('2025-01-16T12:00:00Z'));
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = ColumnDto({'id': '99', 'index': 0, 'width': 100});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.id, 99);
      });

      test('should parse integer id stored as an integer (non-string form)', () {
        // Arrange
        final dto = ColumnDto({'id': 20, 'index': 0, 'width': 100});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.id, 20);
      });

      test('should default containerId to 0 when container is null', () {
        // Arrange
        final dto = ColumnDto({'id': '3', 'index': 0, 'width': 100});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.containerId, 0);
      });

      test('should resolve container id when container is an int reference', () {
        // Arrange
        final dto = ColumnDto({'id': '1', 'index': 0, 'width': 100, 'container': 7});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.containerId, 7);
      });

      test('should resolve container id when container is an expanded map', () {
        // Arrange
        final dto = ColumnDto({
          'id': '1',
          'index': 0,
          'width': 100,
          'container': {'id': '12'},
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.containerId, 12);
      });

      test('should convert integer width to double', () {
        // Arrange
        final dto = ColumnDto({'id': '1', 'index': 0, 'width': 200, 'container': 1});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.width, isA<double>());
        expect(entity.width, 200.0);
      });

      test('should preserve fractional width', () {
        // Arrange
        final dto = ColumnDto({'id': '1', 'index': 0, 'width': 175.5, 'container': 1});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.width, 175.5);
      });

      test('should never populate flex (always null)', () {
        // Arrange
        final dto = ColumnDto({'id': '1', 'index': 0, 'width': 100, 'container': 1});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.flex, isNull);
      });

      test('should parse styleConfig from non-empty style_json', () {
        // Arrange
        final dto = ColumnDto({
          'id': '4',
          'index': 0,
          'width': 100,
          'container': 1,
          'style_json': {
            'marginTop': 10.0,
            'paddingLeft': 8.0,
            'borderType': 'drop_shadow',
          },
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.marginTop, 10.0);
        expect(entity.styleConfig!.paddingLeft, 8.0);
        expect(entity.styleConfig!.borderType, BorderType.dropShadow);
      });

      test('should set styleConfig to null when style_json is absent', () {
        // Arrange
        final dto = ColumnDto({'id': '5', 'index': 0, 'width': 100, 'container': 1});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNull);
      });

      test('should parse verticalAlignment from style_json', () {
        // Arrange
        final dto = ColumnDto({
          'id': '6',
          'index': 0,
          'width': 100,
          'container': 1,
          'style_json': {'verticalAlignment': 'center'},
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig!.verticalAlignment, VerticalAlignment.center);
      });

      test('should map is_droppable false to isDroppable false', () {
        // Arrange
        final dto = ColumnDto({
          'id': '7',
          'index': 0,
          'width': 100,
          'container': 1,
          'is_droppable': false,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.isDroppable, false);
      });

      test('should default isDroppable to true when field is absent', () {
        // Arrange
        final dto = ColumnDto({'id': '8', 'index': 0, 'width': 100, 'container': 1});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.isDroppable, true);
      });

      test('should map null dateCreated to null', () {
        // Arrange
        final dto = ColumnDto({'id': '9', 'index': 0, 'width': 100});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.dateCreated, isNull);
        expect(entity.dateUpdated, isNull);
      });
    });

    group('toDto', () {
      test('should map all fields from a fully-populated Column entity', () {
        // Arrange
        final entity = Column(
          id: 1,
          containerId: 5,
          index: 0,
          width: 200.0,
          dateCreated: DateTime.parse('2025-01-15T10:00:00Z'),
          dateUpdated: DateTime.parse('2025-01-16T12:00:00Z'),
        );

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.id, '1');
        expect(dto.container?.id, '5');
        expect(dto.index, 0);
        expect(dto.width, 200);
        expect(dto.dateCreated, isNotNull);
        expect(dto.dateUpdated, isNotNull);
      });

      test('should truncate fractional width to int', () {
        // Arrange
        final entity = Column(id: 2, containerId: 1, index: 0, width: 175.7);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.width, 175);
      });

      test('should default width to 0 when entity width is null', () {
        // Arrange
        final entity = Column(id: 3, containerId: 1, index: 0, width: null);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.width, 0);
      });

      test('should not include flex in DTO (field not supported)', () {
        // Arrange
        final entity = Column(id: 4, containerId: 1, index: 0, width: 100.0, flex: 3);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert — width still maps normally; flex is silently ignored
        expect(dto.width, 100);
      });

      test('should serialize styleConfig into style_json', () {
        // Arrange
        final entity = Column(
          id: 5,
          containerId: 1,
          index: 0,
          width: 100.0,
          styleConfig: const StyleConfig(
            marginTop: 10.0,
            borderType: BorderType.plainThick,
          ),
        );

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.styleJson['marginTop'], 10.0);
        expect(dto.styleJson['borderType'], 'plain_thick');
      });

      test('should produce empty style_json when styleConfig is null', () {
        // Arrange
        final entity = Column(id: 6, containerId: 1, index: 0, width: 100.0);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.styleJson, isEmpty);
      });

      test('should map isDroppable false to is_droppable false', () {
        // Arrange
        final entity = Column(id: 7, containerId: 1, index: 0, width: 150.0, isDroppable: false);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.isDroppable, false);
      });

      test('should map isDroppable true to is_droppable true', () {
        // Arrange
        final entity = Column(id: 8, containerId: 1, index: 0, width: 150.0);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.isDroppable, true);
      });

      test('should round-trip through toDto then re-read id correctly', () {
        // Arrange
        final entity = Column(id: 42, containerId: 10, index: 3, width: 250.0);

        // Act
        final dto = ColumnMapper.toDto(entity);
        final rawData = dto.getRawData();

        // Assert
        expect(rawData['id'], 42);
        expect(rawData['container'], 10);
      });
    });
  });
}
