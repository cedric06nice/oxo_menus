import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/version_dto.dart';

void main() {
  group('VersionDto', () {
    group('fromJson', () {
      test('should deserialize from JSON with all fields', () {
        // Arrange
        final json = {
          'id': 1,
          'snapshot_json': {'someKey': 'someValue'},
          'date_created': '2025-01-15T10:00:00Z',
        };

        // Act
        final dto = VersionDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.snapshotJson['someKey'], 'someValue');
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateCreated!.toIso8601String(), '2025-01-15T10:00:00.000Z');
      });

      test('should handle optional dateCreated field', () {
        // Arrange
        final json = {
          'id': 2,
          'snapshot_json': {'someKey': 'someValue'},
        };

        // Act
        final dto = VersionDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.snapshotJson['someKey'], 'someValue');
        expect(dto.dateCreated, isNull);
      });

      test('should handle dateUpdated field', () {
        final json = {
          'id': 3,
          'snapshot_json': {},
          'date_updated': '2025-06-01T12:00:00Z',
        };

        final dto = VersionDto(json);

        expect(dto.dateUpdated, isA<DateTime>());
        expect(dto.dateUpdated!.month, 6);
      });

      test('should handle null dateUpdated', () {
        final json = {'id': 4, 'snapshot_json': {}};

        final dto = VersionDto(json);

        expect(dto.dateUpdated, isNull);
      });

      test('should handle userUpdated field', () {
        final json = {'id': 5, 'snapshot_json': {}, 'user_updated': 'user-abc'};

        final dto = VersionDto(json);

        expect(dto.userUpdated, 'user-abc');
      });

      test('should return null snapshotJson when not present', () {
        final json = {'id': 6};

        final dto = VersionDto(json);

        expect(dto.snapshotJson, isEmpty);
      });
    });

    group('menu', () {
      test('should return MenuDto when menu is int (id)', () {
        final json = {'id': 1, 'snapshot_json': {}, 'menu': 42};

        final dto = VersionDto(json);

        expect(dto.menu, isNotNull);
        expect(dto.menu!.id, '42');
      });

      test('should return MenuDto when menu is Map', () {
        final json = {
          'id': 1,
          'snapshot_json': {},
          'menu': {
            'id': 10,
            'name': 'Test Menu',
            'status': 'draft',
            'version': '1.0.0',
          },
        };

        final dto = VersionDto(json);

        expect(dto.menu, isNotNull);
        expect(dto.menu!.id, '10');
      });

      test('should return null when menu is null', () {
        final json = {'id': 1, 'snapshot_json': {}, 'menu': null};

        final dto = VersionDto(json);

        expect(dto.menu, isNull);
      });

      test('should return null when menu key is missing', () {
        final json = {'id': 1, 'snapshot_json': {}};

        final dto = VersionDto(json);

        expect(dto.menu, isNull);
      });

      test('should return null when menu is an unexpected type', () {
        final json = {'id': 1, 'snapshot_json': {}, 'menu': 'not-a-valid-type'};

        final dto = VersionDto(json);

        expect(dto.menu, isNull);
      });
    });
  });
}
