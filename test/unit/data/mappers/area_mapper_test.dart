import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/area_mapper.dart';
import 'package:oxo_menus/data/models/area_dto.dart';

void main() {
  group('AreaMapper', () {
    group('toEntity', () {
      test('should map id and name when dto has both fields', () {
        // Arrange
        final dto = AreaDto({'id': '7', 'name': 'Dining Room'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.id, 7);
        expect(area.name, 'Dining Room');
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = AreaDto({'id': '42', 'name': 'Terrace'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.id, 42);
      });

      test('should parse integer id directly', () {
        // Arrange
        final dto = AreaDto({'id': 5, 'name': 'Bar'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.id, 5);
      });

      test('should map area with a large id correctly', () {
        // Arrange
        final dto = AreaDto({'id': '999', 'name': 'Garden'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.id, 999);
        expect(area.name, 'Garden');
      });

      test('should preserve name exactly as provided', () {
        // Arrange
        final dto = AreaDto({'id': '1', 'name': 'Private Dining & Events'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.name, 'Private Dining & Events');
      });

      test('should handle id of 1 (boundary: lowest meaningful id)', () {
        // Arrange
        final dto = AreaDto({'id': '1', 'name': 'Room 1'});

        // Act
        final area = AreaMapper.toEntity(dto);

        // Assert
        expect(area.id, 1);
      });
    });
  });
}
