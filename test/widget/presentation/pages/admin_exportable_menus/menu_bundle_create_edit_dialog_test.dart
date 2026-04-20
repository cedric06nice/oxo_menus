import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/widgets/menu_bundle_create_edit_dialog.dart';

void main() {
  const menus = [
    Menu(id: 10, name: 'Mains', status: Status.published, version: '1'),
    Menu(id: 20, name: 'Desserts', status: Status.published, version: '1'),
    Menu(id: 30, name: 'Wines', status: Status.published, version: '1'),
  ];

  Future<void> pump(
    WidgetTester tester, {
    MenuBundle? existing,
    required void Function(MenuBundleCreateEditResult) onSave,
    List<Menu> availableMenus = menus,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuBundleCreateEditDialog(
            existingBundle: existing,
            availableMenus: availableMenus,
            onSave: onSave,
          ),
        ),
      ),
    );
  }

  testWidgets('Save is disabled until a name and at least one menu are added', (
    tester,
  ) async {
    MenuBundleCreateEditResult? captured;
    await pump(tester, onSave: (r) => captured = r);

    final save = find.byKey(const Key('bundle_save_button'));
    expect(
      tester.widget<ElevatedButton>(save).onPressed,
      isNull,
      reason: 'Save should be disabled with empty name and no menu selected',
    );

    await tester.enterText(
      find.byKey(const Key('bundle_name_field')),
      'SampleRestaurantMenu',
    );
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(save).onPressed,
      isNull,
      reason: 'Still disabled with zero menus selected',
    );

    await tester.tap(find.byKey(const Key('bundle_add_10')));
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(save).onPressed,
      isNotNull,
      reason: 'Enabled once a name and at least one menu are selected',
    );

    expect(captured, isNull);
  });

  testWidgets('tapping Save emits the menu ids in their selected order', (
    tester,
  ) async {
    MenuBundleCreateEditResult? captured;
    await pump(tester, onSave: (r) => captured = r);

    await tester.enterText(
      find.byKey(const Key('bundle_name_field')),
      'SampleRestaurantMenu',
    );
    await tester.tap(find.byKey(const Key('bundle_add_10')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('bundle_add_20')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('bundle_save_button')));
    await tester.pump();

    expect(captured, isNotNull);
    expect(captured!.name, 'SampleRestaurantMenu');
    expect(captured!.menuIds, [10, 20]);
  });

  testWidgets(
    'pre-fills name and preserves menu order when editing an existing bundle',
    (tester) async {
      const existing = MenuBundle(id: 1, name: 'Existing', menuIds: [20, 10]);
      await pump(tester, existing: existing, onSave: (_) {});

      expect(find.text('Existing'), findsOneWidget);

      // Both selected rows are present in the expected order.
      final slot0 = find.byKey(const Key('bundle_selected_slot_0'));
      final slot1 = find.byKey(const Key('bundle_selected_slot_1'));
      expect(slot0, findsOneWidget);
      expect(slot1, findsOneWidget);
      expect(
        find.descendant(of: slot0, matching: find.text('Desserts')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: slot1, matching: find.text('Mains')),
        findsOneWidget,
      );
    },
  );

  testWidgets('move down swaps rows and reorders the saved menu ids', (
    tester,
  ) async {
    MenuBundleCreateEditResult? captured;
    const existing = MenuBundle(id: 1, name: 'Existing', menuIds: [10, 20]);
    await pump(tester, existing: existing, onSave: (r) => captured = r);

    await tester.tap(find.byKey(const Key('bundle_move_down_10')));
    await tester.pump();

    // Row order is now [Desserts, Mains].
    final slot0 = find.byKey(const Key('bundle_selected_slot_0'));
    final slot1 = find.byKey(const Key('bundle_selected_slot_1'));
    expect(
      find.descendant(of: slot0, matching: find.text('Desserts')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: slot1, matching: find.text('Mains')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('bundle_save_button')));
    await tester.pump();

    expect(captured!.menuIds, [20, 10]);
  });

  testWidgets(
    'move up is disabled on the first row and move down on the last row',
    (tester) async {
      const existing = MenuBundle(id: 1, name: 'Existing', menuIds: [10, 20]);
      await pump(tester, existing: existing, onSave: (_) {});

      final topUp = tester.widget<IconButton>(
        find.byKey(const Key('bundle_move_up_10')),
      );
      final bottomDown = tester.widget<IconButton>(
        find.byKey(const Key('bundle_move_down_20')),
      );
      expect(topUp.onPressed, isNull);
      expect(bottomDown.onPressed, isNull);

      final topDown = tester.widget<IconButton>(
        find.byKey(const Key('bundle_move_down_10')),
      );
      final bottomUp = tester.widget<IconButton>(
        find.byKey(const Key('bundle_move_up_20')),
      );
      expect(topDown.onPressed, isNotNull);
      expect(bottomUp.onPressed, isNotNull);
    },
  );

  testWidgets(
    'add appends a menu to the selected section and remove moves it back',
    (tester) async {
      MenuBundleCreateEditResult? captured;
      await pump(tester, onSave: (r) => captured = r);

      await tester.enterText(
        find.byKey(const Key('bundle_name_field')),
        'Bundle',
      );
      await tester.tap(find.byKey(const Key('bundle_add_10')));
      await tester.pump();

      // After adding, the add button for id 10 is gone and remove is visible.
      expect(find.byKey(const Key('bundle_add_10')), findsNothing);
      expect(find.byKey(const Key('bundle_remove_10')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bundle_remove_10')));
      await tester.pump();

      // After remove, add is visible again and remove is gone.
      expect(find.byKey(const Key('bundle_add_10')), findsOneWidget);
      expect(find.byKey(const Key('bundle_remove_10')), findsNothing);

      // Save is disabled again because no menus are selected.
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(const Key('bundle_save_button')))
            .onPressed,
        isNull,
      );
      expect(captured, isNull);
    },
  );
}
