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
  ];

  Future<void> pump(
    WidgetTester tester, {
    MenuBundle? existing,
    required void Function(MenuBundleCreateEditResult) onSave,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuBundleCreateEditDialog(
            existingBundle: existing,
            availableMenus: menus,
            onSave: onSave,
          ),
        ),
      ),
    );
  }

  testWidgets('Save is disabled until a name and at least one menu are set', (
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

    await tester.tap(find.byKey(const Key('bundle_menu_toggle_10')));
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(save).onPressed,
      isNotNull,
      reason: 'Enabled once a name and at least one menu are selected',
    );

    expect(captured, isNull);
  });

  testWidgets('tapping Save invokes onSave with the chosen name and menu ids', (
    tester,
  ) async {
    MenuBundleCreateEditResult? captured;
    await pump(tester, onSave: (r) => captured = r);

    await tester.enterText(
      find.byKey(const Key('bundle_name_field')),
      'SampleRestaurantMenu',
    );
    await tester.tap(find.byKey(const Key('bundle_menu_toggle_10')));
    await tester.tap(find.byKey(const Key('bundle_menu_toggle_20')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('bundle_save_button')));
    await tester.pump();

    expect(captured, isNotNull);
    expect(captured!.name, 'SampleRestaurantMenu');
    expect(captured!.menuIds.toSet(), {10, 20});
  });

  testWidgets('pre-fills name and toggles when editing an existing bundle', (
    tester,
  ) async {
    const existing = MenuBundle(id: 1, name: 'Existing', menuIds: [20]);
    await pump(tester, existing: existing, onSave: (_) {});

    expect(find.text('Existing'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('bundle_menu_toggle_20')),
          )
          .value,
      true,
    );
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('bundle_menu_toggle_10')),
          )
          .value,
      false,
    );
  });
}
