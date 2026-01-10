import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';

void main() {
  group('MenuDto', () {
    const testMenuDto = MenuDto(
      id: 'menu-1',
      status: 'published',
      name: 'Test Menu',
      version: '1.0.0',
      dateCreated: null,
      dateUpdated: null,
      userCreated: null,
      userUpdated: null,
      styleJson: null,
      area: null,
      size: null,
    );

    group('fromJson', () {
      test('should deserialize from JSON with snake_case field names', () {
        // Arrange
        final json = {
          'id': 'menu-1',
          'status': 'published',
          'date_created': '2024-01-15T10:30:00Z',
          'date_updated': '2024-01-16T15:45:00Z',
          'user_created': 'user-123',
          'user_updated': 'user-456',
          'name': 'Test Menu',
          'version': '1.0.0',
          'style_json': {
            'fontFamily': 'Arial',
            'fontSize': 14.0,
            'primaryColor': '#000000',
          },
          'area': 'dining',
          'size': {
            'name': 'A4',
            'width': 210.0,
            'height': 297.0,
          },
        };

        // Act
        final dto = MenuDto.fromJson(json);

        // Assert
        expect(dto.id, 'menu-1');
        expect(dto.status, 'published');
        expect(dto.name, 'Test Menu');
        expect(dto.version, '1.0.0');
        expect(dto.dateCreated, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(dto.dateUpdated, DateTime.parse('2024-01-16T15:45:00Z'));
        expect(dto.userCreated, 'user-123');
        expect(dto.userUpdated, 'user-456');
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson!['fontFamily'], 'Arial');
        expect(dto.area, 'dining');
        expect(dto.size, isNotNull);
        expect(dto.size!['name'], 'A4');
      });

      test('should deserialize with only required fields', () {
        // Arrange
        final json = {
          'id': 'menu-2',
          'status': 'draft',
          'name': 'Minimal Menu',
          'version': '1.0.0',
        };

        // Act
        final dto = MenuDto.fromJson(json);

        // Assert
        expect(dto.id, 'menu-2');
        expect(dto.status, 'draft');
        expect(dto.name, 'Minimal Menu');
        expect(dto.version, '1.0.0');
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.userCreated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.styleJson, isNull);
        expect(dto.area, isNull);
        expect(dto.size, isNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON with snake_case field names', () {
        // Arrange
        final dto = MenuDto(
          id: 'menu-1',
          status: 'published',
          dateCreated: DateTime.parse('2024-01-15T10:30:00Z'),
          dateUpdated: DateTime.parse('2024-01-16T15:45:00Z'),
          userCreated: 'user-123',
          userUpdated: 'user-456',
          name: 'Test Menu',
          version: '1.0.0',
          styleJson: const {
            'fontFamily': 'Arial',
            'fontSize': 14.0,
          },
          area: 'dining',
          size: const {
            'name': 'A4',
            'width': 210.0,
            'height': 297.0,
          },
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], 'menu-1');
        expect(json['status'], 'published');
        expect(json['date_created'], '2024-01-15T10:30:00.000Z');
        expect(json['date_updated'], '2024-01-16T15:45:00.000Z');
        expect(json['user_created'], 'user-123');
        expect(json['user_updated'], 'user-456');
        expect(json['name'], 'Test Menu');
        expect(json['version'], '1.0.0');
        expect(json['style_json'], isNotNull);
        expect(json['area'], 'dining');
        expect(json['size'], isNotNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange & Act
        final updated = testMenuDto.copyWith(
          name: 'Updated Menu',
          status: 'archived',
        );

        // Assert
        expect(updated.id, testMenuDto.id);
        expect(updated.name, 'Updated Menu');
        expect(updated.status, 'archived');
        expect(updated.version, testMenuDto.version);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        const dto1 = MenuDto(
          id: 'menu-1',
          status: 'published',
          name: 'Test Menu',
          version: '1.0.0',
        );

        const dto2 = MenuDto(
          id: 'menu-1',
          status: 'published',
          name: 'Test Menu',
          version: '1.0.0',
        );

        // Assert
        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });

      test('should not be equal for different values', () {
        // Arrange
        const dto1 = MenuDto(
          id: 'menu-1',
          status: 'published',
          name: 'Test Menu',
          version: '1.0.0',
        );

        const dto2 = MenuDto(
          id: 'menu-2',
          status: 'published',
          name: 'Test Menu',
          version: '1.0.0',
        );

        // Assert
        expect(dto1, isNot(equals(dto2)));
      });
    });
  });
}
