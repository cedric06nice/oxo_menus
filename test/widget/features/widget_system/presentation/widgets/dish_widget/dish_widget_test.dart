import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/allergens/domain/uk_allergen.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/shared/presentation/widgets/price_cell.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget.dart';

void main() {
  group('DishWidget', () {
    testWidgets('should display dish name uppercased and price', (
      tester,
    ) async {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('PASTA CARBONARA'), findsOneWidget);
      expect(find.text('£12.5'), findsOneWidget);
    });

    testWidgets('should hide price when showPrice is false', (tester) async {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showPrices: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('PASTA CARBONARA'), findsOneWidget);
      expect(find.text('£12.5'), findsNothing);
    });

    testWidgets('should display description', (tester) async {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: 'Classic Italian pasta with bacon and cream',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(
        find.text('Classic Italian pasta with bacon and cream'),
        findsOneWidget,
      );
    });

    testWidgets('should not display empty description', (tester) async {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('PASTA CARBONARA'), findsOneWidget);
      // Description should not be rendered when empty
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should display allergens', (tester) async {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.gluten),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      // Allergens are displayed as UK-formatted text (not individual Chips)
      // 'Dairy' → MILK, 'Gluten' → GLUTEN, sorted alphabetically
      expect(find.text('GLUTEN, MILK'), findsOneWidget);
    });

    testWidgets('should hide allergens when showAllergens is false', (
      tester,
    ) async {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.gluten),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showAllergens: false),
              ),
            ),
          ),
        ),
      );

      // Allergen text should not be present when showAllergens is false
      expect(find.text('GLUTEN, MILK'), findsNothing);
    });

    testWidgets(
      'should default to showing prices and allergens when displayOptions is null',
      (tester) async {
        const props = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          allergenInfo: [
            AllergenInfo(allergen: UkAllergen.milk),
            AllergenInfo(allergen: UkAllergen.gluten),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        // Both price and allergens should be shown by default
        expect(find.text('£12.5'), findsOneWidget);
        expect(find.text('GLUTEN, MILK'), findsOneWidget);
      },
    );

    testWidgets(
      'should display dietary abbreviation inline with uppercased name',
      (tester) async {
        const props = DishProps(
          name: 'Salad',
          price: 8.50,
          dietary: DietaryType.vegan,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        // Single Text widget with inline abbreviation
        expect(find.text('SALAD (Ve)'), findsOneWidget);
        // No Chip widgets
        expect(find.byType(Chip), findsNothing);
      },
    );

    testWidgets(
      'should display vegetarian abbreviation inline with allergens',
      (tester) async {
        const props = DishProps(
          name: 'Mixed Dish',
          price: 15.0,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.nuts)],
          dietary: DietaryType.vegetarian,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        // Name with dietary inline
        expect(find.text('MIXED DISH (V)'), findsOneWidget);
        // Allergen text
        expect(find.text('NUTS'), findsOneWidget);
        // No Chip widgets
        expect(find.byType(Chip), findsNothing);
      },
    );

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Edit dialog should appear
      expect(find.text('Edit Dish'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Edit dialog should NOT appear
      expect(find.text('Edit Dish'), findsNothing);
    });

    testWidgets('should call onUpdate with updated props when saved', (
      tester,
    ) async {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      Map<String, dynamic>? capturedUpdate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(
                isEditable: true,
                onUpdate: (updatedProps) => capturedUpdate = updatedProps,
              ),
            ),
          ),
        ),
      );

      // Tap to open edit dialog
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Modify the name
      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Updated Pasta',
      );

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onUpdate was called
      expect(capturedUpdate, isNotNull);
      expect(capturedUpdate!['name'], 'Updated Pasta');
      expect(capturedUpdate!['price'], 12.50);
    });

    testWidgets('should render card with proper styling', (tester) async {
      const props = DishProps(name: 'Test Dish', price: 10.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        card.margin,
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      );

      // Verify the widget renders a Card
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets(
      'edit dialog should show dietary dropdown with None selected by default',
      (tester) async {
        const props = DishProps(name: 'Test Dish', price: 10.0);
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: true),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Should show DropdownButton for dietary
        expect(find.byType(DropdownButton<DietaryType?>), findsOneWidget);
        // Should not show a TextField for dietary
        expect(find.widgetWithText(TextField, 'Dietary'), findsNothing);
      },
    );

    testWidgets('edit dialog should pre-select current dietary value', (
      tester,
    ) async {
      const props = DishProps(
        name: 'Test Dish',
        price: 10.0,
        dietary: DietaryType.vegetarian,
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Verify the dropdown shows 'Vegetarian'
      expect(find.text('Vegetarian'), findsOneWidget);
    });

    testWidgets('edit dialog dropdown should contain dietary options', (
      tester,
    ) async {
      const props = DishProps(name: 'Test Dish', price: 10.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Verify dropdown is present
      expect(find.byType(DropdownButton<DietaryType?>), findsOneWidget);

      // Verify "None" is shown as the current selection (default)
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('edit dialog should show pre-selected dietary in dropdown', (
      tester,
    ) async {
      const props = DishProps(
        name: 'Test Dish',
        price: 10.0,
        dietary: DietaryType.vegan,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Verify "Vegan" is shown as the current selection
      expect(find.text('Vegan'), findsOneWidget);
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);
        var editStartedCount = 0;
        var editEndedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(
                  isEditable: true,
                  onEditStarted: () => editStartedCount++,
                  onEditEnded: () => editEndedCount++,
                ),
              ),
            ),
          ),
        );

        // Tap to open edit dialog
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // onEditStarted should have been called
        expect(editStartedCount, 1);
        // onEditEnded should NOT have been called yet
        expect(editEndedCount, 0);

        // Close the dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // onEditEnded should now have been called
        expect(editEndedCount, 1);
      },
    );

    group('calories display', () {
      testWidgets(
        'should display calories after description when present and allergens showing',
        (tester) async {
          const props = DishProps(
            name: 'Pasta',
            price: 12.50,
            description: 'Creamy pasta',
            calories: 350,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: DishWidget(
                  props: props,
                  context: WidgetContext(isEditable: false),
                ),
              ),
            ),
          );

          expect(find.text('350 KCAL'), findsOneWidget);
        },
      );

      testWidgets('should not display calories when null', (tester) async {
        const props = DishProps(name: 'Pasta', price: 12.50);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        expect(find.textContaining('KCAL'), findsNothing);
      });

      testWidgets('should not display calories when showAllergens is false', (
        tester,
      ) async {
        const props = DishProps(name: 'Pasta', price: 12.50, calories: 350);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(
                  isEditable: false,
                  displayOptions: MenuDisplayOptions(showAllergens: false),
                ),
              ),
            ),
          ),
        );

        expect(find.text('350 KCAL'), findsNothing);
      });

      testWidgets('should display correct format for calories', (tester) async {
        const props = DishProps(name: 'Salad', price: 8.50, calories: 120);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        expect(find.text('120 KCAL'), findsOneWidget);
      });
    });

    group('calories in edit dialog', () {
      testWidgets('should show calories field in edit dialog', (tester) async {
        const props = DishProps(name: 'Pasta', price: 12.50);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(isEditable: true),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(find.text('Calories'), findsOneWidget);
      });

      testWidgets(
        'should pre-populate calories field when editing dish with calories',
        (tester) async {
          const props = DishProps(name: 'Pasta', price: 12.50, calories: 450);

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: DishWidget(
                  props: props,
                  context: WidgetContext(isEditable: true),
                ),
              ),
            ),
          );

          await tester.tap(find.byType(Card));
          await tester.pumpAndSettle();

          final textField = tester.widget<TextField>(
            find.widgetWithText(TextField, 'Calories'),
          );
          expect(textField.controller?.text, '450');
        },
      );

      testWidgets(
        'should have empty calories field when editing dish without calories',
        (tester) async {
          const props = DishProps(name: 'Pasta', price: 12.50);

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: DishWidget(
                  props: props,
                  context: WidgetContext(isEditable: true),
                ),
              ),
            ),
          );

          await tester.tap(find.byType(Card));
          await tester.pumpAndSettle();

          final textField = tester.widget<TextField>(
            find.widgetWithText(TextField, 'Calories'),
          );
          expect(textField.controller?.text, '');
        },
      );

      testWidgets('should save with calories value', (tester) async {
        const props = DishProps(name: 'Pasta', price: 12.50);
        Map<String, dynamic>? capturedUpdate;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(
                  isEditable: true,
                  onUpdate: (updatedProps) => capturedUpdate = updatedProps,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Calories'),
          '350',
        );

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(capturedUpdate, isNotNull);
        expect(capturedUpdate!['calories'], 350);
      });

      testWidgets('should save with null when calories field is empty', (
        tester,
      ) async {
        const props = DishProps(name: 'Pasta', price: 12.50, calories: 350);
        Map<String, dynamic>? capturedUpdate;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: props,
                context: WidgetContext(
                  isEditable: true,
                  onUpdate: (updatedProps) => capturedUpdate = updatedProps,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // Clear the calories field
        await tester.enterText(find.widgetWithText(TextField, 'Calories'), '');

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(capturedUpdate, isNotNull);
        expect(capturedUpdate!['calories'], isNull);
      });
    });

    group('multi-price rendering', () {
      const multiPriceProps = DishProps(
        name: 'Oysters',
        price: 9.0,
        priceVariants: [
          PriceVariant(label: 'Per 3', price: 9.0),
          PriceVariant(label: 'Per 6', price: 17.0),
          PriceVariant(label: 'Per 9', price: 24.0),
        ],
      );

      testWidgets(
        'non-justified: renders one text line per variant and suppresses single-price text',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: DishWidget(
                  props: multiPriceProps,
                  context: WidgetContext(
                    isEditable: false,
                    alignment: WidgetAlignment.start,
                  ),
                ),
              ),
            ),
          );

          expect(find.text('OYSTERS'), findsOneWidget);
          expect(find.text('Per 3 — £9'), findsOneWidget);
          expect(find.text('Per 6 — £17'), findsOneWidget);
          expect(find.text('Per 9 — £24'), findsOneWidget);
          // No fallback single-price text should be rendered.
          expect(find.text('£9'), findsNothing);
        },
      );

      testWidgets(
        'justified: renders a PriceCell per variant with its label alongside',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: DishWidget(
                  props: multiPriceProps,
                  context: WidgetContext(
                    isEditable: false,
                    alignment: WidgetAlignment.justified,
                  ),
                ),
              ),
            ),
          );

          expect(find.byType(PriceCell), findsNWidgets(3));
          expect(find.text('Per 3'), findsOneWidget);
          expect(find.text('Per 6'), findsOneWidget);
          expect(find.text('Per 9'), findsOneWidget);
          // Name still appears without an inline PriceCell alongside it.
          expect(find.text('OYSTERS'), findsOneWidget);
        },
      );

      testWidgets('hides all variants when showPrices is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishWidget(
                props: multiPriceProps,
                context: WidgetContext(
                  isEditable: false,
                  alignment: WidgetAlignment.justified,
                  displayOptions: MenuDisplayOptions(showPrices: false),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(PriceCell), findsNothing);
        expect(find.text('Per 3 — £9'), findsNothing);
        expect(find.text('Per 3'), findsNothing);
        expect(find.text('OYSTERS'), findsOneWidget);
      });
    });
  });
}
