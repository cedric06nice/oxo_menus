import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/create_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/delete_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/get_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/list_menu_bundles_usecase.dart';
import 'package:oxo_menus/domain/usecases/update_menu_bundle_usecase.dart';

import '../../../fakes/builders/menu_bundle_builder.dart';
import '../../../fakes/fake_menu_bundle_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('MenuBundle CRUD UseCases', () {
    late FakeMenuBundleRepository repo;

    setUp(() {
      repo = FakeMenuBundleRepository();
    });

    // =========================================================================
    // CreateMenuBundleUseCase
    // =========================================================================

    group('CreateMenuBundleUseCase', () {
      late CreateMenuBundleUseCase useCase;

      setUp(() {
        useCase = CreateMenuBundleUseCase(repository: repo);
      });

      test(
        'should return new bundle when repository creates it successfully',
        () async {
          // Arrange
          const input = CreateMenuBundleInput(name: 'Lunch Set');
          final bundle = buildMenuBundle(id: 1, name: 'Lunch Set');
          repo.whenCreate(success(bundle));

          // Act
          final result = await useCase.execute(input);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, equals('Lunch Set'));
        },
      );

      test('should return ValidationError when bundle name is empty', () async {
        // Arrange
        const input = CreateMenuBundleInput(name: '');

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ValidationError>());
      });

      test(
        'should return ValidationError when bundle name is whitespace only',
        () async {
          // Arrange
          const input = CreateMenuBundleInput(name: '   ');

          // Act
          final result = await useCase.execute(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test('should not call repository when name validation fails', () async {
        // Arrange
        const input = CreateMenuBundleInput(name: '');

        // Act
        await useCase.execute(input);

        // Assert
        expect(repo.createCalls, isEmpty);
      });

      test('should return Failure when repository.create fails', () async {
        // Arrange
        const input = CreateMenuBundleInput(name: 'Weekend Specials');
        repo.whenCreate(failure(server()));

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });

      test('should pass input to repository.create', () async {
        // Arrange
        const input = CreateMenuBundleInput(name: 'Dinner', menuIds: [1, 2]);
        repo.whenCreate(success(buildMenuBundle(id: 1)));

        // Act
        await useCase.execute(input);

        // Assert
        expect(repo.createCalls.single.input.name, equals('Dinner'));
        expect(repo.createCalls.single.input.menuIds, equals([1, 2]));
      });
    });

    // =========================================================================
    // GetMenuBundleUseCase
    // =========================================================================

    group('GetMenuBundleUseCase', () {
      late GetMenuBundleUseCase useCase;

      setUp(() {
        useCase = GetMenuBundleUseCase(repository: repo);
      });

      test('should return bundle when repository finds it', () async {
        // Arrange
        final bundle = buildMenuBundle(id: 7, name: 'Sunday Bundle');
        repo.whenGetById(success(bundle));

        // Act
        final result = await useCase.execute(7);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.id, equals(7));
      });

      test('should return Failure when repository.getById fails', () async {
        // Arrange
        repo.whenGetById(failure(notFound()));

        // Act
        final result = await useCase.execute(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('should pass correct id to repository.getById', () async {
        // Arrange
        repo.whenGetById(success(buildMenuBundle(id: 42)));

        // Act
        await useCase.execute(42);

        // Assert
        expect(repo.getByIdCalls.single.id, equals(42));
      });
    });

    // =========================================================================
    // UpdateMenuBundleUseCase
    // =========================================================================

    group('UpdateMenuBundleUseCase', () {
      late UpdateMenuBundleUseCase useCase;

      setUp(() {
        useCase = UpdateMenuBundleUseCase(repository: repo);
      });

      test('should return updated bundle when repository succeeds', () async {
        // Arrange
        final updated = buildMenuBundle(id: 3, name: 'Updated');
        final input = UpdateMenuBundleInput(id: 3, name: 'Updated');
        repo.whenUpdate(success(updated));

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.name, equals('Updated'));
      });

      test('should return Failure when repository.update fails', () async {
        // Arrange
        final input = UpdateMenuBundleInput(id: 3, name: 'Updated');
        repo.whenUpdate(failure(server()));

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });

      test(
        'should pass input through to repository.update unchanged',
        () async {
          // Arrange
          final input = UpdateMenuBundleInput(
            id: 5,
            name: 'New Name',
            menuIds: [10, 20],
          );
          repo.whenUpdate(success(buildMenuBundle(id: 5)));

          // Act
          await useCase.execute(input);

          // Assert
          expect(repo.updateCalls.single.input.id, equals(5));
          expect(repo.updateCalls.single.input.name, equals('New Name'));
          expect(repo.updateCalls.single.input.menuIds, equals([10, 20]));
        },
      );
    });

    // =========================================================================
    // DeleteMenuBundleUseCase
    // =========================================================================

    group('DeleteMenuBundleUseCase', () {
      late DeleteMenuBundleUseCase useCase;

      setUp(() {
        useCase = DeleteMenuBundleUseCase(repository: repo);
      });

      test(
        'should return Success when repository deletes the bundle',
        () async {
          // Arrange
          repo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(4);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should return Failure when repository.delete fails', () async {
        // Arrange
        repo.whenDelete(failure(notFound()));

        // Act
        final result = await useCase.execute(4);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('should pass correct id to repository.delete', () async {
        // Arrange
        repo.whenDelete(success(null));

        // Act
        await useCase.execute(55);

        // Assert
        expect(repo.deleteCalls.single.id, equals(55));
      });
    });

    // =========================================================================
    // ListMenuBundlesUseCase
    // =========================================================================

    group('ListMenuBundlesUseCase', () {
      late ListMenuBundlesUseCase useCase;

      setUp(() {
        useCase = ListMenuBundlesUseCase(repository: repo);
      });

      test(
        'should return all bundles when repository returns a list',
        () async {
          // Arrange
          final bundles = [
            buildMenuBundle(id: 1, name: 'Bundle A'),
            buildMenuBundle(id: 2, name: 'Bundle B'),
          ];
          repo.whenGetAll(success(bundles));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(2));
        },
      );

      test('should return empty list when repository has no bundles', () async {
        // Arrange
        repo.whenGetAll(success([]));

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!, isEmpty);
      });

      test('should return Failure when repository.getAll fails', () async {
        // Arrange
        repo.whenGetAll(failure(network()));

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
      });

      test('should call repository.getAll exactly once', () async {
        // Arrange
        repo.whenGetAll(success([]));

        // Act
        await useCase.execute();

        // Assert
        expect(repo.getAllCalls.length, equals(1));
      });
    });
  });
}
