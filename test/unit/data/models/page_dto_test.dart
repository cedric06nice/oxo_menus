import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/page_dto.dart';

void main() {
  group('PageDto', () {
    group('fromJson', () {
      test('should deserialize from JSON with snake_case field names', () {
        // Arrange
        final json = {
          'id': 'page-1',
          'date_created': '2024-01-15T10:30:00Z',
          'date_updated': '2024-01-16T15:45:00Z',
          'menu_id': 'menu-1',
          'name': 'First Page',
          'index': 1,
        };

        // Act
        final dto = PageDto.fromJson(json);

        // Assert
        expect(dto.id, 'page-1');
        expect(dto.menuId, 'menu-1');
        expect(dto.name, 'First Page');
        expect(dto.index, 1);
        expect(dto.dateCreated, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(dto.dateUpdated, DateTime.parse('2024-01-16T15:45:00Z'));
      });

      test('should deserialize with only required fields', () {
        // Arrange
        final json = {
          'id': 'page-2',
          'menu_id': 'menu-1',
          'name': 'Second Page',
          'index': 2,
        };

        // Act
        final dto = PageDto.fromJson(json);

        // Assert
        expect(dto.id, 'page-2');
        expect(dto.menuId, 'menu-1');
        expect(dto.name, 'Second Page');
        expect(dto.index, 2);
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON with snake_case field names', () {
        // Arrange
        final dto = PageDto(
          id: 'page-1',
          dateCreated: DateTime.parse('2024-01-15T10:30:00Z'),
          dateUpdated: DateTime.parse('2024-01-16T15:45:00Z'),
          menuId: 'menu-1',
          name: 'First Page',
          index: 1,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], 'page-1');
        expect(json['menu_id'], 'menu-1');
        expect(json['name'], 'First Page');
        expect(json['index'], 1);
        expect(json['date_created'], '2024-01-15T10:30:00.000Z');
        expect(json['date_updated'], '2024-01-16T15:45:00.000Z');
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        const dto = PageDto(
          id: 'page-1',
          menuId: 'menu-1',
          name: 'First Page',
          index: 1,
        );

        // Act
        final updated = dto.copyWith(name: 'Updated Page', index: 2);

        // Assert
        expect(updated.id, dto.id);
        expect(updated.menuId, dto.menuId);
        expect(updated.name, 'Updated Page');
        expect(updated.index, 2);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        const dto1 = PageDto(
          id: 'page-1',
          menuId: 'menu-1',
          name: 'First Page',
          index: 1,
        );

        const dto2 = PageDto(
          id: 'page-1',
          menuId: 'menu-1',
          name: 'First Page',
          index: 1,
        );

        // Assert
        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });
    });
  });
}
