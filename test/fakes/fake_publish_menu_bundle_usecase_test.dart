import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';

import 'builders/menu_bundle_builder.dart';
import 'fake_publish_menu_bundle_usecase.dart';
import 'result_helpers.dart';

void main() {
  group('FakePublishMenuBundleUseCase', () {
    late FakePublishMenuBundleUseCase fake;

    setUp(() {
      fake = FakePublishMenuBundleUseCase();
    });

    // -----------------------------------------------------------------------
    // Default state — unset execute throws StateError
    // -----------------------------------------------------------------------

    group('default state', () {
      test(
        'should throw StateError when execute is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.execute(1), throwsStateError);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Preset response — stubExecute returns canned value and records call
    // -----------------------------------------------------------------------

    group('stubExecute', () {
      test(
        'should return the configured Success with the bundle when execute is called',
        () async {
          // Arrange
          final bundle = buildMenuBundle(id: 5, name: 'Dinner Bundle');
          fake.stubExecute(Success(bundle));

          // Act
          final result = await fake.execute(5);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.id, equals(5));
          expect(result.valueOrNull!.name, equals('Dinner Bundle'));
        },
      );

      test(
        'should return the configured Failure when execute is called',
        () async {
          // Arrange
          fake.stubExecute(failureNotFound<MenuBundle>());

          // Act
          final result = await fake.execute(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should record the call with the correct bundleId when execute succeeds',
        () async {
          // Arrange
          final bundle = buildMenuBundle(id: 3);
          fake.stubExecute(Success(bundle));

          // Act
          await fake.execute(3);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.bundleId, equals(3));
        },
      );

      test(
        'should record the call even when execute returns a Failure',
        () async {
          // Arrange
          fake.stubExecute(failure<MenuBundle>(server()));

          // Act
          await fake.execute(77);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.bundleId, equals(77));
        },
      );

      test(
        'should accumulate calls across multiple execute invocations',
        () async {
          // Arrange
          final bundle = buildMenuBundle();
          fake.stubExecute(Success(bundle));

          // Act
          await fake.execute(10);
          await fake.execute(20);
          await fake.execute(30);

          // Assert
          expect(fake.calls, hasLength(3));
          expect(
            fake.calls.map((c) => c.bundleId).toList(),
            equals([10, 20, 30]),
          );
        },
      );

      test(
        'should reflect the most recently stubbed result when stubExecute is called multiple times',
        () async {
          // Arrange
          final firstBundle = buildMenuBundle(id: 1, name: 'First');
          final secondBundle = buildMenuBundle(id: 2, name: 'Second');
          fake.stubExecute(Success(firstBundle));
          fake.stubExecute(Success(secondBundle));

          // Act
          final result = await fake.execute(2);

          // Assert
          expect(result.valueOrNull!.name, equals('Second'));
        },
      );
    });
  });
}
