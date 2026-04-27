import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';

import '../../../../../fakes/builders/menu_bundle_builder.dart';
import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../../../../fakes/result_helpers.dart';

void main() {
  group('PublishBundlesForMenuUseCase', () {
    late FakeMenuBundleRepository repo;
    late FakePublishMenuBundleUseCase publishBundleUseCase;
    late PublishBundlesForMenuUseCase useCase;

    setUp(() {
      repo = FakeMenuBundleRepository();
      publishBundleUseCase = FakePublishMenuBundleUseCase();

      useCase = PublishBundlesForMenuUseCase(
        repository: repo,
        publishMenuBundleUseCase: publishBundleUseCase,
      );
    });

    // -------------------------------------------------------------------------
    // findByIncludedMenu failure
    // -------------------------------------------------------------------------

    group('findByIncludedMenu failure', () {
      test(
        'should return single Failure result when repository lookup fails',
        () async {
          // Arrange
          repo.whenFindByIncludedMenu(failure(network()));

          // Act
          final results = await useCase.execute(1);

          // Assert
          expect(results.length, equals(1));
          expect(results.single.isFailure, isTrue);
          expect(results.single.errorOrNull, isA<NetworkError>());
        },
      );

      test('should propagate ServerError from findByIncludedMenu', () async {
        // Arrange
        repo.whenFindByIncludedMenu(failure(server()));

        // Act
        final results = await useCase.execute(1);

        // Assert
        expect(results.single.errorOrNull, isA<ServerError>());
      });
    });

    // -------------------------------------------------------------------------
    // Empty bundle list
    // -------------------------------------------------------------------------

    group('empty bundle list', () {
      test(
        'should return empty list when no bundles include the given menu',
        () async {
          // Arrange
          repo.whenFindByIncludedMenu(success([]));

          // Act
          final results = await useCase.execute(1);

          // Assert
          expect(results, isEmpty);
        },
      );

      test(
        'should not call publishMenuBundleUseCase when bundle list is empty',
        () async {
          // Arrange
          repo.whenFindByIncludedMenu(success([]));

          // Act
          await useCase.execute(1);

          // Assert
          expect(publishBundleUseCase.calls, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Single bundle
    // -------------------------------------------------------------------------

    group('single bundle', () {
      test(
        'should publish one bundle and return its result when one bundle includes the menu',
        () async {
          // Arrange
          final bundle = buildMenuBundle(id: 10, name: 'Weekend');
          repo.whenFindByIncludedMenu(success([bundle]));
          publishBundleUseCase.stubExecute(
            Success(buildMenuBundle(id: 10, name: 'Weekend')),
          );

          // Act
          final results = await useCase.execute(1);

          // Assert
          expect(results.length, equals(1));
          expect(results.single.isSuccess, isTrue);
          expect(publishBundleUseCase.calls.single.bundleId, equals(10));
        },
      );

      test(
        'should propagate Failure from publishMenuBundleUseCase for single bundle',
        () async {
          // Arrange
          final bundle = buildMenuBundle(id: 10);
          repo.whenFindByIncludedMenu(success([bundle]));
          publishBundleUseCase.stubExecute(failure(server()));

          // Act
          final results = await useCase.execute(1);

          // Assert
          expect(results.single.isFailure, isTrue);
          expect(results.single.errorOrNull, isA<ServerError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Multiple bundles
    // -------------------------------------------------------------------------

    group('multiple bundles', () {
      test('should publish all bundles and return a result for each', () async {
        // Arrange
        final bundles = [
          buildMenuBundle(id: 10),
          buildMenuBundle(id: 20),
          buildMenuBundle(id: 30),
        ];
        repo.whenFindByIncludedMenu(success(bundles));
        publishBundleUseCase.stubExecute(Success(buildMenuBundle(id: 10)));

        // Act
        final results = await useCase.execute(1);

        // Assert
        expect(results.length, equals(3));
        expect(
          publishBundleUseCase.calls.map((c) => c.bundleId).toList(),
          containsAll([10, 20, 30]),
        );
      });

      test(
        'should continue publishing remaining bundles after a partial failure',
        () async {
          // Arrange
          final bundles = [buildMenuBundle(id: 10), buildMenuBundle(id: 20)];
          repo.whenFindByIncludedMenu(success(bundles));
          publishBundleUseCase.stubExecute(failure(server()));

          // Act
          final results = await useCase.execute(1);

          // Assert
          expect(results.length, equals(2));
          expect(publishBundleUseCase.calls.length, equals(2));
        },
      );

      test(
        'should return all Success results when all bundles publish successfully',
        () async {
          // Arrange
          final bundles = [buildMenuBundle(id: 1), buildMenuBundle(id: 2)];
          repo.whenFindByIncludedMenu(success(bundles));
          publishBundleUseCase.stubExecute(Success(buildMenuBundle(id: 1)));

          // Act
          final results = await useCase.execute(5);

          // Assert
          expect(results.every((r) => r.isSuccess), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Repository call verification
    // -------------------------------------------------------------------------

    group('repository call verification', () {
      test('should pass correct menuId to findByIncludedMenu', () async {
        // Arrange
        repo.whenFindByIncludedMenu(success([]));

        // Act
        await useCase.execute(42);

        // Assert
        expect(repo.findByIncludedMenuCalls.single.menuId, equals(42));
      });
    });
  });
}
