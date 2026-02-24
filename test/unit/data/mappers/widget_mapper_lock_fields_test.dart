import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

void main() {
  group('WidgetMapper lock fields', () {
    group('toEntity', () {
      test('should map editingBy from DTO', () {
        final dto = WidgetDto({
          'id': 1,
          'column': {'id': 10},
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
          'editing_by': 'user-abc-123',
          'editing_since': '2025-01-15T10:30:00Z',
        });

        final entity = WidgetMapper.toEntity(dto);

        expect(entity.editingBy, 'user-abc-123');
        expect(entity.editingSince, isNotNull);
      });

      test('should map null editingBy from DTO', () {
        final dto = WidgetDto({
          'id': 1,
          'column': {'id': 10},
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
        });

        final entity = WidgetMapper.toEntity(dto);

        expect(entity.editingBy, isNull);
        expect(entity.editingSince, isNull);
      });
    });

    group('toDto', () {
      test('should map editingBy to DTO', () {
        final entity = WidgetInstance(
          id: 1,
          columnId: 10,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: const {},
          editingBy: 'user-abc-123',
          editingSince: DateTime.utc(2025, 1, 15, 10, 30),
        );

        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        expect(raw['editing_by'], 'user-abc-123');
        expect(raw['editing_since'], isNotNull);
      });

      test('should map null editingBy to DTO', () {
        const entity = WidgetInstance(
          id: 1,
          columnId: 10,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        final dto = WidgetMapper.toDto(entity);
        final raw = dto.getRawData();

        expect(raw['editing_by'], isNull);
        expect(raw['editing_since'], isNull);
      });
    });
  });
}
