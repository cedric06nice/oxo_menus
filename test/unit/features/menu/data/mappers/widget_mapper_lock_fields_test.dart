import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/widget_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

void main() {
  group('WidgetMapper lock fields', () {
    group('toEntity', () {
      test('should map editingBy and editingSince when both are present', () {
        // Arrange
        final dto = WidgetDto({
          'id': '1',
          'column': {'id': '10'},
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
          'editing_by': 'user-abc-123',
          'editing_since': '2025-01-15T10:30:00Z',
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.editingBy, 'user-abc-123');
        expect(entity.editingSince, DateTime.parse('2025-01-15T10:30:00Z'));
      });

      test('should map editingBy as null when editing_by is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '2',
          'column': {'id': '10'},
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.editingBy, isNull);
      });

      test('should map editingSince as null when editing_since is absent', () {
        // Arrange
        final dto = WidgetDto({
          'id': '3',
          'column': {'id': '10'},
          'type_key': 'text',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.editingSince, isNull);
      });

      test(
        'should represent unlocked widget when both lock fields are absent',
        () {
          // Arrange
          final dto = WidgetDto({
            'id': '4',
            'column': 5,
            'type_key': 'section',
            'version': '1.0.0',
            'index': 0,
          });

          // Act
          final entity = WidgetMapper.toEntity(dto);

          // Assert — no lock state
          expect(entity.editingBy, isNull);
          expect(entity.editingSince, isNull);
        },
      );

      test('should map editingBy set to null explicitly as null', () {
        // Arrange
        final dto = WidgetDto({
          'id': '5',
          'column': 5,
          'type_key': 'wine',
          'version': '1.0.0',
          'index': 0,
          'editing_by': null,
          'editing_since': null,
        });

        // Act
        final entity = WidgetMapper.toEntity(dto);

        // Assert
        expect(entity.editingBy, isNull);
        expect(entity.editingSince, isNull);
      });
    });

    group('toDto', () {
      test('should map editingBy and editingSince to DTO raw data', () {
        // Arrange
        final editingSince = DateTime.utc(2025, 1, 15, 10, 30);
        final entity = WidgetInstance(
          id: 1,
          columnId: 10,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: const {},
          editingBy: 'user-abc-123',
          editingSince: editingSince,
        );

        // Act
        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['editing_by'], 'user-abc-123');
        expect(raw['editing_since'], editingSince.toIso8601String());
      });

      test('should map null editingBy to null in DTO raw data', () {
        // Arrange
        const entity = WidgetInstance(
          id: 2,
          columnId: 10,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['editing_by'], isNull);
      });

      test('should map null editingSince to null in DTO raw data', () {
        // Arrange
        const entity = WidgetInstance(
          id: 3,
          columnId: 10,
          type: 'text',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['editing_since'], isNull);
      });

      test('should represent unlocked state when editingBy is null', () {
        // Arrange — entity that has never been locked
        const entity = WidgetInstance(
          id: 4,
          columnId: 7,
          type: 'section',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final dto = WidgetMapper.toDto(entity);

        // Assert — re-read from DTO to confirm no lock data survives
        expect(dto.editingBy, isNull);
        expect(dto.editingSince, isNull);
      });

      test('should round-trip editingBy value through toDto then toEntity', () {
        // Arrange
        final original = WidgetInstance(
          id: 5,
          columnId: 3,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: const {},
          editingBy: 'round-trip-user',
          editingSince: DateTime.utc(2025, 6, 1, 9, 0),
        );

        // Act
        final dto = WidgetMapper.toDto(original);
        final restored = WidgetMapper.toEntity(dto);

        // Assert
        expect(restored.editingBy, 'round-trip-user');
        expect(restored.editingSince, isNotNull);
      });
    });
  });
}
