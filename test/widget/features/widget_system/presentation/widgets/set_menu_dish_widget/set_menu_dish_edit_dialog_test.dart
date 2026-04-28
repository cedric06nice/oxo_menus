import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/set_menu_dish_widget/set_menu_dish_edit_dialog.dart';

void main() {
  group('SetMenuDishEditDialog', () {
    testWidgets('should display all fields', (tester) async {
      const props = SetMenuDishProps(name: 'Test Dish');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      SetMenuDishEditDialog(props: props, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Dish'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.byType(DropdownButton<DietaryType?>), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('should pre-fill fields with existing props', (tester) async {
      const props = SetMenuDishProps(
        name: 'Lobster Thermidor',
        description: 'Classic French dish',
        calories: 650,
        dietary: DietaryType.vegetarian,
        hasSupplement: true,
        supplementPrice: 7.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      SetMenuDishEditDialog(props: props, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Name'),
      );
      expect(nameField.controller?.text, 'Lobster Thermidor');

      final descField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Description (optional)'),
      );
      expect(descField.controller?.text, 'Classic French dish');

      final caloriesField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Calories'),
      );
      expect(caloriesField.controller?.text, '650');

      // Supplement switch should be on
      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, true);

      // Supplement price field should be visible
      expect(find.text('Supplement price'), findsOneWidget);
    });

    testWidgets('should call onSave with updated props', (tester) async {
      const props = SetMenuDishProps(name: 'Old Dish');
      SetMenuDishProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuDishEditDialog(
                    props: props,
                    onSave: (p) => savedProps = p,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'New Dish Name',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'New Dish Name');
    });

    testWidgets('should dismiss without saving on Cancel', (tester) async {
      const props = SetMenuDishProps(name: 'Test Dish');
      SetMenuDishProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuDishEditDialog(
                    props: props,
                    onSave: (p) => savedProps = p,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(savedProps, isNull);
      expect(find.text('Edit Set Menu Dish'), findsNothing);
    });

    testWidgets('should toggle supplement switch and show price field', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Test Dish');
      SetMenuDishProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuDishEditDialog(
                    props: props,
                    onSave: (p) => savedProps = p,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Initially no supplement price field
      expect(find.text('Supplement price'), findsNothing);

      // Toggle supplement on
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Now supplement price field should appear
      expect(find.text('Supplement price'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Supplement price'),
        '5.0',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.hasSupplement, true);
      expect(savedProps!.supplementPrice, 5.0);
    });

    testWidgets('should reset supplement price when toggle is off', (
      tester,
    ) async {
      const props = SetMenuDishProps(
        name: 'Test',
        hasSupplement: true,
        supplementPrice: 10.0,
      );
      SetMenuDishProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuDishEditDialog(
                    props: props,
                    onSave: (p) => savedProps = p,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Toggle supplement off
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.hasSupplement, false);
      expect(savedProps!.supplementPrice, 0.0);
    });
  });
}
