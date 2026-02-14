import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/column_mapper.dart';
import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('ColumnMapper', () {
    group('toEntity', () {
      test('should convert ColumnDto to Column with proper types', () {
        // Arrange
        final dto = ColumnDto({
          'id': 1,
          'index': 0,
          'width': 200,
          'container': 5,
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-15T11:00:00Z',
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1);
        expect(entity.containerId, 5);
        expect(entity.index, 0);
        expect(entity.width, 200.0);
        expect(entity.flex, isNull);
        expect(entity.dateCreated, isA<DateTime>());
        expect(entity.dateUpdated, isA<DateTime>());
      });

      test('should handle null container field', () {
        // Arrange
        final dto = ColumnDto({'id': 2, 'index': 1, 'width': 150});

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.id, 2);
        expect(entity.containerId, 0); // Defaults to 0 when null
        expect(entity.flex, isNull);
      });

      test('should parse styleConfig from style_json', () {
        // Arrange
        final dto = ColumnDto({
          'id': 4,
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

      test('should have null styleConfig when style_json is empty', () {
        // Arrange
        final dto = ColumnDto({
          'id': 5,
          'index': 0,
          'width': 100,
          'container': 1,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNull);
      });

      test('should convert width to double', () {
        // Arrange
        final dto = ColumnDto({
          'id': 3,
          'index': 0,
          'width': 175.5,
          'container': 1,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.width, 175.5);
        expect(entity.width, isA<double>());
      });

      test('toEntity maps is_droppable: false → isDroppable: false', () {
        // Arrange
        final dto = ColumnDto({
          'id': 6,
          'index': 0,
          'width': 150,
          'container': 1,
          'is_droppable': false,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.isDroppable, false);
      });

      test('toEntity defaults to true when field absent', () {
        // Arrange
        final dto = ColumnDto({
          'id': 7,
          'index': 0,
          'width': 150,
          'container': 1,
        });

        // Act
        final entity = ColumnMapper.toEntity(dto);

        // Assert
        expect(entity.isDroppable, true);
      });
    });

    group('toDto', () {
      test('should convert Column to ColumnDto', () {
        // Arrange
        final entity = Column(
          id: 1,
          containerId: 5,
          index: 0,
          width: 200.0,
          flex: 2, // Should be ignored since DTO doesn't support it
          dateCreated: DateTime.parse('2025-01-15T10:00:00Z'),
          dateUpdated: DateTime.parse('2025-01-15T11:00:00Z'),
        );

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.id, '1');
        expect(dto.container?.id, '5');
        expect(dto.index, 0);
        expect(dto.width, 200); // Converted to int
        expect(dto.dateCreated, isNotNull);
        expect(dto.dateUpdated, isNotNull);
      });

      test('should handle null width by converting to 0', () {
        // Arrange
        final entity = Column(id: 2, containerId: 3, index: 1, width: null);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.id, '2');
        expect(dto.width, 0); // null converted to 0
      });

      test('should serialize styleConfig into style_json', () {
        // Arrange
        final entity = Column(
          id: 4,
          containerId: 1,
          index: 0,
          width: 100.0,
          styleConfig: StyleConfig(
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

      test('should have empty style_json when styleConfig is null', () {
        // Arrange
        final entity = Column(id: 5, containerId: 1, index: 0, width: 100.0);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.styleJson, isEmpty);
      });

      test('should round double width to int', () {
        // Arrange
        final entity = Column(id: 3, containerId: 1, index: 0, width: 175.7);

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.width, 175); // Rounded down
      });

      test('toDto maps isDroppable: false → is_droppable: false', () {
        // Arrange
        final entity = Column(
          id: 6,
          containerId: 1,
          index: 0,
          width: 150.0,
          isDroppable: false,
        );

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.isDroppable, false);
      });

      test('toDto maps default true correctly', () {
        // Arrange
        final entity = Column(
          id: 7,
          containerId: 1,
          index: 0,
          width: 150.0,
          // isDroppable defaults to true
        );

        // Act
        final dto = ColumnMapper.toDto(entity);

        // Assert
        expect(dto.isDroppable, true);
      });
    });
  });
}
