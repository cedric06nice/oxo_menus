import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/data/models/container_dto.dart';

void main() {
  group('ContainerDto', () {
    group('fromJson', () {
      test('should deserialize with minimal fields', () {
        // Arrange
        final json = {'id': 2, 'index': 1, 'status': 'draft'};

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.index, 1);
        expect(dto.status, 'draft');
        expect(dto.direction, isNull);
        expect(dto.dateCreated, isNull);
        expect(dto.dateUpdated, isNull);
        expect(dto.userUpdated, isNull);
        expect(dto.styleJson, isEmpty);
        expect(dto.page, isNull);
        expect(dto.columns, isNull);
      });

      test('should deserialize from JSON with additional fields', () {
        // Arrange
        final json = {
          'id': 1,
          'index': 0,
          'status': 'published',
          'direction': 'row',
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-15T11:00:00Z',
          'user_updated': 'user-uuid',
          'style_json': {'spacing': 16.0, 'alignment': 'center'},
        };

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.index, 0);
        expect(dto.status, 'published');
        expect(dto.direction, 'row');
        expect(dto.dateCreated, DateTime.parse('2025-01-15T10:00:00Z'));
        expect(dto.dateUpdated, DateTime.parse('2025-01-15T11:00:00Z'));
        expect(dto.userUpdated, 'user-uuid');
        expect(dto.styleJson, isNotNull);
        expect(dto.styleJson['spacing'], 16.0);
        expect(dto.styleJson['alignment'], 'center');
      });

      test('should handle different direction values', () {
        // Arrange
        final directions = ['row', 'column', 'row-reverse', 'column-reverse'];

        // Act & Assert
        for (var i = 0; i < directions.length; i++) {
          final json = {
            'id': i + 1,
            'index': i,
            'status': 'published',
            'direction': directions[i],
          };
          final dto = ContainerDto(json);
          expect(dto.direction, directions[i]);
        }
      });

      test('should handle empty columns list', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'columns': <int>[],
        };

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.columns, isNotNull);
        expect(dto.columns!.isEmpty, true);
      });

      test('should handle page as integer id', () {
        // Arrange
        final json = {'id': 3, 'index': 0, 'status': 'published', 'page': 1};

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.page, isNotNull);
        expect(dto.page!.id, '1');
      });

      test('should handle page as PageDto', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'page': {'id': 1, 'status': 'published'},
        };

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.page, isNotNull);
        expect(dto.page!.id, '1');
        expect(dto.page!.status, 'published');
      });

      test('should handle columns list of integer ids', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'columns': [1, 2, 3],
        };

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.columns, isNotNull);
        expect(dto.columns!.length, 3);
        expect(dto.columns![0].id, '1');
        expect(dto.columns![1].id, '2');
        expect(dto.columns![2].id, '3');
      });

      test('should handle columns list of ColumnDto', () {
        // Arrange
        final json = {
          'id': 3,
          'index': 0,
          'status': 'published',
          'columns': [
            {'id': 1, 'index': 0},
            {'id': 2, 'index': 1},
            {'id': 3, 'index': 2},
          ],
        };

        // Act
        final dto = ContainerDto(json);

        // Assert
        expect(dto.columns, isNotNull);
        expect(dto.columns!.length, 3);
        expect(dto.columns![0].id, '1');
        expect(dto.columns![0].index, 0);
        expect(dto.columns![1].id, '2');
        expect(dto.columns![1].index, 1);
        expect(dto.columns![2].id, '3');
        expect(dto.columns![2].index, 2);
      });
    });
  });
}
