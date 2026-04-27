import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

import 'builders/menu_bundle_builder.dart';
import 'fake_menu_bundle_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeMenuBundleRepository', () {
    late FakeMenuBundleRepository fake;

    setUp(() {
      fake = FakeMenuBundleRepository();
    });

    // -------------------------------------------------------------------------
    // Default state — unconfigured methods throw StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test(
        'should throw StateError when getAll is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getAll(), throwsStateError);
        },
      );

      test(
        'should throw StateError when getById is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.getById(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when findByIncludedMenu is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.findByIncludedMenu(1), throwsStateError);
        },
      );

      test(
        'should throw StateError when create is called without configuration',
        () async {
          // Arrange
          const input = CreateMenuBundleInput(name: 'Bundle');

          // Act / Assert
          await expectLater(fake.create(input), throwsStateError);
        },
      );

      test(
        'should throw StateError when update is called without configuration',
        () async {
          // Arrange
          const input = UpdateMenuBundleInput(id: 1, name: 'Updated');

          // Act / Assert
          await expectLater(fake.update(input), throwsStateError);
        },
      );

      test(
        'should throw StateError when delete is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.delete(1), throwsStateError);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Preset responses — canned value returned, call recorded
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured success result from getAll()', () async {
        // Arrange
        final bundles = [buildMenuBundle(id: 1), buildMenuBundle(id: 2)];
        fake.whenGetAll(success(bundles));

        // Act
        final result = await fake.getAll();

        // Assert
        expect(result, isA<Success<List<MenuBundle>, dynamic>>());
        expect((result as Success).value, hasLength(2));
      });

      test('should return configured success result from getById()', () async {
        // Arrange
        final bundle = buildMenuBundle(id: 3, name: 'Weekend Specials');
        fake.whenGetById(success(bundle));

        // Act
        final result = await fake.getById(3);

        // Assert
        expect(result, isA<Success<MenuBundle, dynamic>>());
        expect((result as Success).value.name, equals('Weekend Specials'));
      });

      test(
        'should return configured success result from findByIncludedMenu()',
        () async {
          // Arrange
          final bundles = [
            buildMenuBundle(menuIds: [10, 20]),
          ];
          fake.whenFindByIncludedMenu(success(bundles));

          // Act
          final result = await fake.findByIncludedMenu(10);

          // Assert
          expect(result, isA<Success<List<MenuBundle>, dynamic>>());
          expect((result as Success).value.first.menuIds, contains(10));
        },
      );

      test('should return configured failure result from create()', () async {
        // Arrange
        fake.whenCreate(failureServer());

        // Act
        final result = await fake.create(
          const CreateMenuBundleInput(name: 'X'),
        );

        // Assert
        expect(result, isA<Failure>());
      });

      test('should return configured success result from update()', () async {
        // Arrange
        final updated = buildMenuBundle(id: 5, name: 'Updated Bundle');
        fake.whenUpdate(success(updated));
        const input = UpdateMenuBundleInput(id: 5, name: 'Updated Bundle');

        // Act
        final result = await fake.update(input);

        // Assert
        expect(result, isA<Success<MenuBundle, dynamic>>());
        expect((result as Success).value.name, equals('Updated Bundle'));
      });

      test(
        'should complete successfully from delete() when configured',
        () async {
          // Arrange
          fake.whenDelete(success(null));

          // Act / Assert
          await expectLater(fake.delete(9), completes);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Call recording — arguments are captured correctly
    // -------------------------------------------------------------------------

    group('call recording', () {
      test(
        'should record a MenuBundleGetAllCall when getAll() is called',
        () async {
          // Arrange
          fake.whenGetAll(success([]));

          // Act
          await fake.getAll();

          // Assert
          expect(fake.getAllCalls, hasLength(1));
        },
      );

      test(
        'should record a MenuBundleGetByIdCall with correct id when getById() is called',
        () async {
          // Arrange
          fake.whenGetById(success(buildMenuBundle(id: 15)));

          // Act
          await fake.getById(15);

          // Assert
          expect(fake.getByIdCalls, hasLength(1));
          expect(fake.getByIdCalls.first.id, equals(15));
        },
      );

      test(
        'should record a MenuBundleFindByIncludedMenuCall with correct menuId',
        () async {
          // Arrange
          fake.whenFindByIncludedMenu(success([]));

          // Act
          await fake.findByIncludedMenu(42);

          // Assert
          expect(fake.findByIncludedMenuCalls, hasLength(1));
          expect(fake.findByIncludedMenuCalls.first.menuId, equals(42));
        },
      );

      test(
        'should record a MenuBundleCreateCall with correct name and menuIds',
        () async {
          // Arrange
          fake.whenCreate(success(buildMenuBundle()));
          const input = CreateMenuBundleInput(
            name: 'Dinner Bundle',
            menuIds: [1, 2, 3],
          );

          // Act
          await fake.create(input);

          // Assert
          expect(fake.createCalls, hasLength(1));
          expect(fake.createCalls.first.input.name, equals('Dinner Bundle'));
          expect(fake.createCalls.first.input.menuIds, equals([1, 2, 3]));
        },
      );

      test(
        'should record a MenuBundleUpdateCall with correct input when update() is called',
        () async {
          // Arrange
          fake.whenUpdate(success(buildMenuBundle(id: 7)));
          const input = UpdateMenuBundleInput(
            id: 7,
            name: 'New Name',
            pdfFileId: 'file-uuid-abc',
          );

          // Act
          await fake.update(input);

          // Assert
          expect(fake.updateCalls, hasLength(1));
          expect(fake.updateCalls.first.input.id, equals(7));
          expect(fake.updateCalls.first.input.name, equals('New Name'));
          expect(
            fake.updateCalls.first.input.pdfFileId,
            equals('file-uuid-abc'),
          );
        },
      );

      test(
        'should record a MenuBundleDeleteCall with correct id when delete() is called',
        () async {
          // Arrange
          fake.whenDelete(success(null));

          // Act
          await fake.delete(55);

          // Assert
          expect(fake.deleteCalls, hasLength(1));
          expect(fake.deleteCalls.first.id, equals(55));
        },
      );

      test('should accumulate multiple calls in insertion order', () async {
        // Arrange
        fake.whenGetAll(success([]));
        fake.whenDelete(success(null));

        // Act
        await fake.getAll();
        await fake.delete(1);

        // Assert
        expect(fake.calls, hasLength(2));
        expect(fake.calls[0], isA<MenuBundleGetAllCall>());
        expect(fake.calls[1], isA<MenuBundleDeleteCall>());
      });
    });
  });
}
