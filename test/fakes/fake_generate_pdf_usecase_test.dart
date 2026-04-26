import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';

import 'builders/menu_builder.dart';
import 'fake_generate_pdf_usecase.dart';
import 'result_helpers.dart';

void main() {
  group('FakeGeneratePdfUseCase', () {
    late FakeGeneratePdfUseCase fake;

    // Helper to create a minimal MenuTree
    MenuTree buildMenuTree({int menuId = 1}) {
      return MenuTree(
        menu: buildMenu(id: menuId),
        pages: [],
      );
    }

    setUp(() {
      fake = FakeGeneratePdfUseCase();
    });

    // -----------------------------------------------------------------------
    // Default state — unset execute throws StateError
    // -----------------------------------------------------------------------

    group('default state', () {
      test(
        'should throw StateError when execute is called without configuration',
        () async {
          // Arrange
          final tree = buildMenuTree();

          // Act / Assert
          await expectLater(fake.execute(tree), throwsStateError);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Preset response — stubExecute returns canned value and records call
    // -----------------------------------------------------------------------

    group('stubExecute', () {
      test(
        'should return the configured Success with bytes when execute is called',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([37, 80, 68, 70]); // %PDF header
          fake.stubExecute(Success(bytes));
          final tree = buildMenuTree();

          // Act
          final result = await fake.execute(tree);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, equals(bytes));
        },
      );

      test(
        'should return the configured Failure when execute is called',
        () async {
          // Arrange
          fake.stubExecute(failure<Uint8List>(unknown()));
          final tree = buildMenuTree();

          // Act
          final result = await fake.execute(tree);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should record the call with the correct menuTree when execute succeeds',
        () async {
          // Arrange
          fake.stubExecute(Success(Uint8List(0)));
          final tree = buildMenuTree(menuId: 99);

          // Act
          await fake.execute(tree);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.menuTree.menu.id, equals(99));
        },
      );

      test(
        'should record the call even when execute returns a Failure',
        () async {
          // Arrange
          fake.stubExecute(failure<Uint8List>(server()));
          final tree = buildMenuTree(menuId: 7);

          // Act
          await fake.execute(tree);

          // Assert
          expect(fake.calls, hasLength(1));
          expect(fake.calls.single.menuTree.menu.id, equals(7));
        },
      );

      test(
        'should accumulate calls across multiple execute invocations',
        () async {
          // Arrange
          fake.stubExecute(Success(Uint8List(0)));
          final tree1 = buildMenuTree(menuId: 1);
          final tree2 = buildMenuTree(menuId: 2);

          // Act
          await fake.execute(tree1);
          await fake.execute(tree2);

          // Assert
          expect(fake.calls, hasLength(2));
          expect(fake.calls[0].menuTree.menu.id, equals(1));
          expect(fake.calls[1].menuTree.menu.id, equals(2));
        },
      );
    });
  });
}
