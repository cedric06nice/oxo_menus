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
    });
  });
}
