import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/menu_bundle_mapper.dart';
import 'package:oxo_menus/data/models/menu_bundle_dto.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

void main() {
  group('MenuBundleMapper', () {
    group('toEntity', () {
      test('converts full DTO (with list of int menu_ids)', () {
        final dto = MenuBundleDto({
          'id': 7,
          'name': 'SampleRestaurantMenu',
          'menu_ids': [10, 20, 30],
          'pdf_file_id': 'file-xyz',
          'date_created': '2026-04-20T12:00:00Z',
          'date_updated': '2026-04-20T13:00:00Z',
        });

        final entity = MenuBundleMapper.toEntity(dto);

        expect(entity.id, 7);
        expect(entity.name, 'SampleRestaurantMenu');
        expect(entity.menuIds, [10, 20, 30]);
        expect(entity.pdfFileId, 'file-xyz');
        expect(entity.dateCreated, DateTime.utc(2026, 4, 20, 12));
        expect(entity.dateUpdated, DateTime.utc(2026, 4, 20, 13));
      });

      test('defaults to empty menu_ids when missing or null', () {
        final dto = MenuBundleDto({'id': 7, 'name': 'Empty'});

        final entity = MenuBundleMapper.toEntity(dto);

        expect(entity.menuIds, isEmpty);
        expect(entity.pdfFileId, isNull);
      });

      test('coerces menu_ids stored as strings or doubles into int', () {
        final dto = MenuBundleDto({
          'id': 7,
          'name': 'Mixed',
          'menu_ids': ['10', 20.0, 30],
        });

        final entity = MenuBundleMapper.toEntity(dto);

        expect(entity.menuIds, [10, 20, 30]);
      });
    });

    group('toCreatePayload', () {
      test('emits name and menu_ids', () {
        const input = CreateMenuBundleInput(name: 'Sample', menuIds: [1, 2]);

        final map = MenuBundleMapper.toCreatePayload(input);

        expect(map['name'], 'Sample');
        expect(map['menu_ids'], [1, 2]);
      });
    });

    group('toUpdatePayload', () {
      test('only includes non-null fields', () {
        const input = UpdateMenuBundleInput(id: 1, name: 'Renamed');

        final map = MenuBundleMapper.toUpdatePayload(input);

        expect(map['name'], 'Renamed');
        expect(map.containsKey('menu_ids'), false);
        expect(map.containsKey('pdf_file_id'), false);
      });

      test('includes all fields when provided', () {
        const input = UpdateMenuBundleInput(
          id: 1,
          name: 'Renamed',
          menuIds: [5, 6],
          pdfFileId: 'file-abc',
        );

        final map = MenuBundleMapper.toUpdatePayload(input);

        expect(map['name'], 'Renamed');
        expect(map['menu_ids'], [5, 6]);
        expect(map['pdf_file_id'], 'file-abc');
      });

      test('returns empty map when only id is provided', () {
        const input = UpdateMenuBundleInput(id: 1);

        final map = MenuBundleMapper.toUpdatePayload(input);

        expect(map, isEmpty);
      });
    });
  });
}
