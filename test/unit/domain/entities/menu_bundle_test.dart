import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import '../../../fakes/builders/menu_bundle_builder.dart';

void main() {
  group('MenuBundle', () {
    group('construction', () {
      test('should create bundle with correct required fields when id and name are provided', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Weekend Specials');

        // Assert
        expect(bundle.id, 1);
        expect(bundle.name, 'Weekend Specials');
      });

      test('should default menuIds to empty list when not specified', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Assert
        expect(bundle.menuIds, isEmpty);
      });

      test('should default pdfFileId to null when not specified', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Assert
        expect(bundle.pdfFileId, isNull);
      });

      test('should default dateCreated to null when not specified', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Assert
        expect(bundle.dateCreated, isNull);
      });

      test('should default dateUpdated to null when not specified', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Assert
        expect(bundle.dateUpdated, isNull);
      });

      test('should store menuIds when a non-empty list is provided', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle', menuIds: [10, 20, 30]);

        // Assert
        expect(bundle.menuIds, [10, 20, 30]);
      });

      test('should store pdfFileId when pdfFileId is provided', () {
        // Arrange & Act
        const bundle = MenuBundle(id: 1, name: 'Bundle', pdfFileId: 'file-uuid-abc');

        // Assert
        expect(bundle.pdfFileId, 'file-uuid-abc');
      });

      test('should store all optional fields when fully specified', () {
        // Arrange
        final created = DateTime(2026, 4, 20);
        final updated = DateTime(2026, 4, 21);

        // Act
        final bundle = MenuBundle(
          id: 5,
          name: 'Full Bundle',
          menuIds: const [1, 2],
          pdfFileId: 'file-xyz',
          dateCreated: created,
          dateUpdated: updated,
        );

        // Assert
        expect(bundle.menuIds, [1, 2]);
        expect(bundle.pdfFileId, 'file-xyz');
        expect(bundle.dateCreated, created);
        expect(bundle.dateUpdated, updated);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
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

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        final a = MenuBundle(
          id: 1,
          name: 'A',
          menuIds: const [10],
          dateCreated: DateTime.utc(2026, 4, 20),
        );
        final b = MenuBundle(
          id: 1,
          name: 'A',
          menuIds: const [10],
          dateCreated: DateTime.utc(2026, 4, 20),
        );

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = MenuBundle(id: 1, name: 'A');
        const b = MenuBundle(id: 2, name: 'A');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const a = MenuBundle(id: 1, name: 'Alpha');
        const b = MenuBundle(id: 1, name: 'Beta');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when menuIds differ', () {
        // Arrange
        const a = MenuBundle(id: 1, name: 'Bundle', menuIds: [1, 2]);
        const b = MenuBundle(id: 1, name: 'Bundle', menuIds: [1, 3]);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update pdfFileId when copyWith is called with a new pdfFileId', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'A', menuIds: [10]);

        // Act
        final updated = bundle.copyWith(pdfFileId: 'abc');

        // Assert
        expect(updated.pdfFileId, 'abc');
        expect(updated.id, 1);
        expect(updated.name, 'A');
        expect(updated.menuIds, [10]);
      });

      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'Old Name');

        // Act
        final updated = bundle.copyWith(name: 'New Name');

        // Assert
        expect(updated.name, 'New Name');
        expect(updated.id, 1);
      });

      test('should update menuIds when copyWith is called with a new list', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'Bundle', menuIds: [1]);

        // Act
        final updated = bundle.copyWith(menuIds: [1, 2, 3]);

        // Assert
        expect(updated.menuIds, [1, 2, 3]);
      });

      test('should preserve all fields when copyWith is called with no arguments', () {
        // Arrange
        final bundle = buildMenuBundle(name: 'Stable', menuIds: [5, 6]);

        // Act
        final copy = bundle.copyWith();

        // Assert
        expect(copy, equals(bundle));
      });
    });

    group('collection isolation', () {
      test('should return a new list reference on copyWith so mutation does not affect original', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'Bundle', menuIds: [1, 2]);

        // Act
        final updated = bundle.copyWith(menuIds: [1, 2, 3]);

        // Assert
        expect(bundle.menuIds, hasLength(2));
        expect(updated.menuIds, hasLength(3));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Act
        final result = bundle.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        const bundle = MenuBundle(id: 1, name: 'Bundle');

        // Act
        final json = bundle.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Bundle');
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = MenuBundle(
          id: 3,
          name: 'Round-trip',
          menuIds: [10, 20],
          pdfFileId: 'file-abc',
        );

        // Act
        final restored = MenuBundle.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });

  group('CreateMenuBundleInput', () {
    group('construction', () {
      test('should create input with name and menuIds when both are provided', () {
        // Arrange & Act
        const input = CreateMenuBundleInput(name: 'Bundle', menuIds: [10, 20]);

        // Assert
        expect(input.name, 'Bundle');
        expect(input.menuIds, [10, 20]);
      });

      test('should default menuIds to empty list when not specified', () {
        // Arrange & Act
        const input = CreateMenuBundleInput(name: 'Bundle');

        // Assert
        expect(input.menuIds, isEmpty);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = CreateMenuBundleInput(name: 'Bundle', menuIds: [1]);
        const b = CreateMenuBundleInput(name: 'Bundle', menuIds: [1]);

        // Assert
        expect(a, equals(b));
      });
    });
  });

  group('UpdateMenuBundleInput', () {
    group('construction', () {
      test('should create input with only id when all optional fields are omitted', () {
        // Arrange & Act
        const input = UpdateMenuBundleInput(id: 1);

        // Assert
        expect(input.id, 1);
        expect(input.name, isNull);
        expect(input.menuIds, isNull);
        expect(input.pdfFileId, isNull);
      });

      test('should store name when name is provided', () {
        // Arrange & Act
        const input = UpdateMenuBundleInput(id: 1, name: 'Renamed');

        // Assert
        expect(input.name, 'Renamed');
      });

      test('should store all fields when all fields are provided', () {
        // Arrange & Act
        const input = UpdateMenuBundleInput(
          id: 1,
          name: 'Renamed',
          menuIds: [1, 2, 3],
          pdfFileId: 'file-xyz',
        );

        // Assert
        expect(input.id, 1);
        expect(input.name, 'Renamed');
        expect(input.menuIds, [1, 2, 3]);
        expect(input.pdfFileId, 'file-xyz');
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = UpdateMenuBundleInput(id: 1, name: 'A');
        const b = UpdateMenuBundleInput(id: 1, name: 'A');

        // Assert
        expect(a, equals(b));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = UpdateMenuBundleInput(id: 1, name: 'Bundle');
        const b = UpdateMenuBundleInput(id: 2, name: 'Bundle');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });
  });
}
