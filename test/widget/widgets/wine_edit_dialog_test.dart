import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/presentation/widgets/wine_widget/wine_edit_dialog.dart';

void main() {
  group('WineEditDialog', () {
    testWidgets('should display all fields', (tester) async {
      const props = WineProps(name: 'Test Wine', price: 0.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
                    props: props,
                    onSave: (_) {},
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

      expect(find.text('Edit Wine'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Vintage'), findsOneWidget);
      expect(find.byType(DropdownButton<DietaryType?>), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('should pre-fill fields with existing props', (tester) async {
      const props = WineProps(
        name: 'Chateau Margaux',
        price: 12.50,
        description: 'Full-bodied Bordeaux',
        vintage: 2019,
        dietary: DietaryType.vegan,
        containsSulphites: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
                    props: props,
                    onSave: (_) {},
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

      final nameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Name'),
      );
      expect(nameField.controller?.text, 'Chateau Margaux');

      final priceField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Price'),
      );
      expect(priceField.controller?.text, '12.5');

      final descField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Description (optional)'),
      );
      expect(descField.controller?.text, 'Full-bodied Bordeaux');

      final vintageField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Vintage'),
      );
      expect(vintageField.controller?.text, '2019');

      expect(find.text('Vegan'), findsOneWidget);
    });

    testWidgets('should call onSave with updated props', (tester) async {
      const props = WineProps(name: 'Old Wine', price: 0.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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
        'New Wine Name',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'New Wine Name');
    });

    testWidgets('should dismiss without saving on Cancel', (tester) async {
      const props = WineProps(name: 'Test Wine', price: 0.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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
      expect(find.text('Edit Wine'), findsNothing);
    });

    testWidgets('should save with price value', (tester) async {
      const props = WineProps(name: 'Wine', price: 0.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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
        find.widgetWithText(TextField, 'Price'),
        '15.50',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.price, 15.50);
    });

    testWidgets('should fallback to original price when field is empty', (
      tester,
    ) async {
      const props = WineProps(name: 'Wine', price: 10.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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
        find.widgetWithText(TextField, 'Price'),
        '',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.price, 10.0);
    });

    testWidgets('should save with vintage value', (tester) async {
      const props = WineProps(name: 'Wine', price: 0.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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
        find.widgetWithText(TextField, 'Vintage'),
        '2020',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.vintage, 2020);
    });

    testWidgets('should toggle sulphites checkbox', (tester) async {
      const props = WineProps(name: 'Wine', price: 0.0);
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => WineEditDialog(
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

      final checkbox = find.byType(CheckboxListTile);
      await tester.ensureVisible(checkbox);
      await tester.pumpAndSettle();

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.containsSulphites, true);
    });
  });
}
