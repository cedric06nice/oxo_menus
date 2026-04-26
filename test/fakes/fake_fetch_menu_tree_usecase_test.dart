import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

import 'builders/menu_builder.dart';
import 'fake_fetch_menu_tree_usecase.dart';
import 'result_helpers.dart';

void main() {
  group('FakeFetchMenuTreeUseCase', () {
    late FakeFetchMenuTreeUseCase fake;

    setUp(() {
      fake = FakeFetchMenuTreeUseCase();
    });

    // -----------------------------------------------------------------------
    // Default state — unset execute throws StateError
    // -----------------------------------------------------------------------

    group('default state', () {
      test(
        'should throw StateError when execute is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.execute(1),
            throwsStateError,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // Preset response — stubExecute returns canned value and records call
    // -----------------------------------------------------------------------

    group('stubExecute', () {
      test(
        'should return the configured Success result when execute is called',
        () async {
          // Arrange
          final menuTree = MenuTree(
            menu: buildMenu(id: 42),
            pages: [],
          );
          fake.stubExecute(Success(menuTree));

          // Act
          final result = await fake.execute(42);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.menu.id, equals(42));
        },
      );

      test(
        'should return the configured Failure result when execute is called',
        () async {
          // Arrange
          fake.stubExecute(failure<MenuTree>(notFound()));

          // Act
          final result = await fake.execute(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should record the call with the correct menuId when execute succeeds',
        () async {
          // Arrange
          final tree = MenuTree(menu: buildMenu(id: 7), pages: []);
          fake.stubExecute(Success(tree));

          // Act
          await fake.execute(7);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.menuId, equals(7));
        },
      );

      test(
        'should record the call even when execute returns a Failure',
        () async {
          // Arrange
          fake.stubExecute(failure<MenuTree>(network()));

          // Act
          await fake.execute(55);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.menuId, equals(55));
        },
      );

      test(
        'should accumulate calls across multiple execute invocations',
        () async {
          // Arrange
          final tree = MenuTree(menu: buildMenu(), pages: []);
          fake.stubExecute(Success(tree));

          // Act
          await fake.execute(1);
          await fake.execute(2);
          await fake.execute(3);

          // Assert
          expect(fake.calls, hasLength(3));
          expect(fake.calls.map((c) => c.menuId).toList(), equals([1, 2, 3]));
        },
      );
    });
  });
}
