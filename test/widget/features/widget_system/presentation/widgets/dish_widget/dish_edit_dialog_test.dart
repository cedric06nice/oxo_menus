import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_edit_dialog.dart';

void main() {
  const testProps = DishProps(
    name: 'Fish & Chips',
    price: 14.50,
    description: 'Classic British dish',
    calories: 800,
    allergenInfo: [],
  );

  group('DishEditDialog', () {
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
                      DishEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Dish'), findsOneWidget);
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
                        DishEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Dish'), findsOneWidget);
      expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(4));
    });

    testWidgets('saves correct props from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      DishProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => DishEditDialog(
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

      // Tap Save with existing values
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'Fish & Chips');
      expect(savedProps!.price, 14.50);
    });

    group('multi-price (Material)', () {
      Future<void> openDialog(
        WidgetTester tester, {
        required DishProps props,
        void Function(DishProps)? onSave,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        DishEditDialog(props: props, onSave: onSave ?? (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
      }

      testWidgets(
        'shows a "Use multiple prices" switch that is off by default for single-price dishes',
        (tester) async {
          await openDialog(tester, props: testProps);

          expect(find.text('Use multiple prices'), findsOneWidget);
          final switchWidget = tester.widget<Switch>(find.byType(Switch));
          expect(switchWidget.value, isFalse);
          // Single-price field still shown.
          expect(find.widgetWithText(TextField, 'Price'), findsOneWidget);
          // No variant list yet.
          expect(find.widgetWithText(TextField, 'Label'), findsNothing);
        },
      );

      testWidgets(
        'toggling the switch on hides single-price field and shows two empty variant rows + add button',
        (tester) async {
          await openDialog(tester, props: testProps);

          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          expect(find.widgetWithText(TextField, 'Price'), findsNothing);
          expect(find.widgetWithText(TextField, 'Label'), findsNWidgets(2));
          expect(
            find.widgetWithText(TextField, 'Variant price'),
            findsNWidgets(2),
          );
          expect(find.widgetWithText(TextButton, 'Add price'), findsOneWidget);
        },
      );

      testWidgets('pre-populates rows for a dish that already has variants', (
        tester,
      ) async {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        await openDialog(tester, props: props);

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
        expect(find.widgetWithText(TextField, 'Label'), findsNWidgets(2));

        final labelFields = tester
            .widgetList<TextField>(find.widgetWithText(TextField, 'Label'))
            .toList();
        expect(labelFields[0].controller!.text, 'Per 3');
        expect(labelFields[1].controller!.text, 'Per 6');
      });

      testWidgets('tapping "Add price" appends a new empty row', (
        tester,
      ) async {
        await openDialog(tester, props: testProps);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Add price'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'Label'), findsNWidgets(3));
      });

      testWidgets('tapping a row delete icon removes that row', (tester) async {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        await openDialog(tester, props: props);

        expect(find.widgetWithText(TextField, 'Label'), findsNWidgets(2));

        await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'Label'), findsOneWidget);
      });

      testWidgets(
        'saving with valid variants emits DishProps with priceVariants and uses first variant price as base',
        (tester) async {
          DishProps? saved;

          await openDialog(tester, props: testProps, onSave: (p) => saved = p);
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          final labelFields = find.widgetWithText(TextField, 'Label');
          final priceFields = find.widgetWithText(TextField, 'Variant price');

          await tester.enterText(labelFields.at(0), 'Small');
          await tester.enterText(priceFields.at(0), '10');
          await tester.enterText(labelFields.at(1), 'Large');
          await tester.enterText(priceFields.at(1), '14');

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(saved, isNotNull);
          expect(saved!.priceVariants, [
            const PriceVariant(label: 'Small', price: 10.0),
            const PriceVariant(label: 'Large', price: 14.0),
          ]);
          // Base price follows first variant so legacy readers keep a sensible number.
          expect(saved!.price, 10.0);
        },
      );

      testWidgets(
        'saving with an empty label does not call onSave and shows validation message',
        (tester) async {
          DishProps? saved;

          await openDialog(tester, props: testProps, onSave: (p) => saved = p);
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          final priceFields = find.widgetWithText(TextField, 'Variant price');
          await tester.enterText(priceFields.at(0), '10');
          await tester.enterText(priceFields.at(1), '14');
          // Labels left blank.

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(saved, isNull);
          expect(
            find.textContaining('label', findRichText: true),
            findsWidgets,
          );
        },
      );

      testWidgets('saving with an unparseable price does not call onSave', (
        tester,
      ) async {
        DishProps? saved;

        await openDialog(tester, props: testProps, onSave: (p) => saved = p);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        final labelFields = find.widgetWithText(TextField, 'Label');
        final priceFields = find.widgetWithText(TextField, 'Variant price');

        await tester.enterText(labelFields.at(0), 'Small');
        await tester.enterText(priceFields.at(0), 'abc');
        await tester.enterText(labelFields.at(1), 'Large');
        await tester.enterText(priceFields.at(1), '14');

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(saved, isNull);
      });

      testWidgets('toggling the switch off clears priceVariants when saving', (
        tester,
      ) async {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        DishProps? saved;
        await openDialog(tester, props: props, onSave: (p) => saved = p);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Single-price field reappears with original price.
        expect(find.widgetWithText(TextField, 'Price'), findsOneWidget);

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(saved, isNotNull);
        expect(saved!.priceVariants, isEmpty);
      });
    });
  });
}
