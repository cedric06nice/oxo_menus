import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/display_options_dialog_helper.dart';

import '../../../../fakes/fake_menu_repository.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared fixtures
  // ---------------------------------------------------------------------------

  Menu makeMenu({
    MenuDisplayOptions? displayOptions = const MenuDisplayOptions(
      showPrices: true,
      showAllergens: true,
    ),
  }) {
    return Menu(
      id: 1,
      name: 'Test',
      status: Status.draft,
      version: '1',
      displayOptions: displayOptions,
    );
  }

  // ---------------------------------------------------------------------------
  // Widget builder
  // ---------------------------------------------------------------------------

  Widget buildTestWidget({
    required FakeMenuRepository fakeMenuRepo,
    required void Function(BuildContext, WidgetRef) onPressed,
  }) {
    return ProviderScope(
      overrides: [menuRepositoryProvider.overrideWithValue(fakeMenuRepo)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => onPressed(context, ref),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('showDisplayOptionsDialog', () {
    late FakeMenuRepository fakeMenuRepo;

    setUp(() {
      fakeMenuRepo = FakeMenuRepository();
    });

    group('dialog display', () {
      testWidgets('should open the MenuDisplayOptionsDialog when triggered', (
        tester,
      ) async {
        // Arrange — no update needed; just verify the dialog appears
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: makeMenu(),
              onMenuUpdated: (_) {},
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Display Options'), findsOneWidget);
      });

      testWidgets('should show Show Prices toggle in the dialog', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: makeMenu(),
              onMenuUpdated: (_) {},
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Show Prices'), findsOneWidget);
      });

      testWidgets('should show Show Allergens toggle in the dialog', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: makeMenu(),
              onMenuUpdated: (_) {},
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Show Allergens'), findsOneWidget);
      });

      testWidgets('should open the dialog when menu is null', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: null,
              onMenuUpdated: (_) {},
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Display Options'), findsOneWidget);
      });
    });

    group('save — success', () {
      testWidgets(
        'should call the menu update repository when Save is tapped',
        (tester) async {
          // Arrange
          final menu = makeMenu();
          fakeMenuRepo.whenUpdate(success(menu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showDisplayOptionsDialog(
                context: context,
                ref: ref,
                menuId: 1,
                menu: menu,
                onMenuUpdated: (_) {},
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Assert
          expect(fakeMenuRepo.updateCalls, hasLength(1));
        },
      );

      testWidgets(
        'should call onMenuUpdated with non-null menu when Save succeeds',
        (tester) async {
          // Arrange
          final menu = makeMenu();
          fakeMenuRepo.whenUpdate(success(menu));

          Menu? updatedMenu;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showDisplayOptionsDialog(
                context: context,
                ref: ref,
                menuId: 1,
                menu: menu,
                onMenuUpdated: (m) => updatedMenu = m,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Assert
          expect(updatedMenu, isNotNull);
        },
      );

      testWidgets(
        'should show a success snackbar after saving display options',
        (tester) async {
          // Arrange
          final menu = makeMenu();
          fakeMenuRepo.whenUpdate(success(menu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showDisplayOptionsDialog(
                context: context,
                ref: ref,
                menuId: 1,
                menu: menu,
                onMenuUpdated: (_) {},
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Display options saved'), findsOneWidget);
        },
      );

      testWidgets('should dismiss the dialog after Save is tapped', (
        tester,
      ) async {
        // Arrange
        final menu = makeMenu();
        fakeMenuRepo.whenUpdate(success(menu));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: menu,
              onMenuUpdated: (_) {},
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert — dialog is gone after save
        expect(find.text('Display Options'), findsNothing);
      });
    });

    group('save — failure', () {
      testWidgets('should not call onMenuUpdated when the update fails', (
        tester,
      ) async {
        // Arrange
        final menu = makeMenu();
        fakeMenuRepo.whenUpdate(failure<Menu>(const ServerError('fail')));

        Menu? updatedMenu;

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: menu,
              onMenuUpdated: (m) => updatedMenu = m,
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert
        expect(updatedMenu, isNull);
      });

      testWidgets(
        'should call update exactly once when Save is tapped even on failure',
        (tester) async {
          // Arrange
          final menu = makeMenu();
          fakeMenuRepo.whenUpdate(
            failure<Menu>(const NetworkError('no connection')),
          );

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showDisplayOptionsDialog(
                context: context,
                ref: ref,
                menuId: 1,
                menu: menu,
                onMenuUpdated: (_) {},
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Assert
          expect(fakeMenuRepo.updateCalls, hasLength(1));
        },
      );
    });

    group('cancel', () {
      testWidgets(
        'should dismiss the dialog without calling onMenuUpdated when Cancel is tapped',
        (tester) async {
          // Arrange
          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showDisplayOptionsDialog(
                context: context,
                ref: ref,
                menuId: 1,
                menu: makeMenu(),
                onMenuUpdated: (_) => callbackInvoked = true,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isFalse);
          expect(fakeMenuRepo.updateCalls, isEmpty);
        },
      );

      testWidgets('should hide the dialog after Cancel is tapped', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeMenuRepo: fakeMenuRepo,
            onPressed: (context, ref) => showDisplayOptionsDialog(
              context: context,
              ref: ref,
              menuId: 1,
              menu: makeMenu(),
              onMenuUpdated: (_) {},
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Display Options'), findsNothing);
      });
    });
  });
}
