import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/presentation/widgets/dish_to_share_widget/dish_to_share_edit_dialog.dart';

void main() {
  const testProps = DishToShareProps(
    name: 'Mezze Platter',
    price: 18.50,
    description: 'Selection of dips and breads',
    calories: 650,
    allergens: [],
    allergenInfo: [],
    servings: 2,
  );

  group('DishToShareEditDialog', () {
    testWidgets('renders AlertDialog on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      DishToShareEditDialog(props: testProps, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit Dish To Share'), findsOneWidget);
    });

    testWidgets('renders CupertinoPageScaffold on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) =>
                        DishToShareEditDialog(props: testProps, onSave: (_) {}),
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

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text('Edit Dish To Share'), findsOneWidget);
      // 5 fields: name, description, price, calories, servings
      expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(5));
    });

    testWidgets('pre-populates servings field on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      DishToShareEditDialog(props: testProps, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Servings'),
      );
      expect(textField.controller?.text, '2');
    });

    testWidgets('saves correct props including servings from Android form', (
      WidgetTester tester,
    ) async {
      DishToShareProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DishToShareEditDialog(
                    props: testProps,
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

      // Change servings to 4
      await tester.enterText(find.widgetWithText(TextField, 'Servings'), '4');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'Mezze Platter');
      expect(savedProps!.price, 18.50);
      expect(savedProps!.servings, 4);
    });

    testWidgets('saves null servings when field is empty', (
      WidgetTester tester,
    ) async {
      DishToShareProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DishToShareEditDialog(
                    props: testProps,
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

      // Clear servings
      await tester.enterText(find.widgetWithText(TextField, 'Servings'), '');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.servings, isNull);
    });

    testWidgets('saves correct props from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      DishToShareProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => DishToShareEditDialog(
                      props: testProps,
                      onSave: (p) => savedProps = p,
                    ),
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

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'Mezze Platter');
      expect(savedProps!.price, 18.50);
      expect(savedProps!.servings, 2);
    });
  });
}
