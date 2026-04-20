import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

void main() {
  group('MenuBundle', () {
    test('should construct with required fields and optional nulls', () {
      const bundle = MenuBundle(
        id: 1,
        name: 'SampleRestaurantMenu',
        menuIds: [10, 20],
      );

      expect(bundle.id, 1);
      expect(bundle.name, 'SampleRestaurantMenu');
      expect(bundle.menuIds, [10, 20]);
      expect(bundle.pdfFileId, isNull);
      expect(bundle.dateCreated, isNull);
      expect(bundle.dateUpdated, isNull);
    });

    test('should treat two bundles with the same fields as equal', () {
      final a = MenuBundle(
        id: 1,
        name: 'A',
        menuIds: const [10],
        pdfFileId: 'file-1',
        dateCreated: DateTime.utc(2026, 4, 20),
      );
      final b = MenuBundle(
        id: 1,
        name: 'A',
        menuIds: const [10],
        pdfFileId: 'file-1',
        dateCreated: DateTime.utc(2026, 4, 20),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith should override only provided fields', () {
      const bundle = MenuBundle(id: 1, name: 'A', menuIds: [10]);

      final updated = bundle.copyWith(pdfFileId: 'abc');

      expect(updated.id, 1);
      expect(updated.name, 'A');
      expect(updated.menuIds, [10]);
      expect(updated.pdfFileId, 'abc');
    });
  });

  group('CreateMenuBundleInput', () {
    test('should construct with required fields', () {
      const input = CreateMenuBundleInput(
        name: 'SampleRestaurantMenu',
        menuIds: [10, 20],
      );

      expect(input.name, 'SampleRestaurantMenu');
      expect(input.menuIds, [10, 20]);
    });
  });

  group('UpdateMenuBundleInput', () {
    test('should allow partial updates with nullable fields', () {
      const input = UpdateMenuBundleInput(id: 1, name: 'Renamed');

      expect(input.id, 1);
      expect(input.name, 'Renamed');
      expect(input.menuIds, isNull);
      expect(input.pdfFileId, isNull);
    });

    test('should carry all fields when provided', () {
      const input = UpdateMenuBundleInput(
        id: 1,
        name: 'Renamed',
        menuIds: [1, 2, 3],
        pdfFileId: 'file-xyz',
      );

      expect(input.name, 'Renamed');
      expect(input.menuIds, [1, 2, 3]);
      expect(input.pdfFileId, 'file-xyz');
    });
  });
}
