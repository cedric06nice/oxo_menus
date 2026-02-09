import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget.dart';

void main() {
  group('DishWidget', () {
    testWidgets('should display dish name and price', (tester) async {
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

      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('£12.50'), findsOneWidget);
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

      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('£12.50'), findsNothing);
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

      expect(find.text('Pasta Carbonara'), findsOneWidget);
      // Description should not be rendered when empty
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should display allergens', (tester) async {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        allergens: ['Dairy', 'Gluten'],
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
        allergens: ['Dairy', 'Gluten'],
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
          allergens: ['Dairy', 'Gluten'],
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
        expect(find.text('£12.50'), findsOneWidget);
        expect(find.text('GLUTEN, MILK'), findsOneWidget);
      },
    );

    testWidgets('should display dietary tags', (tester) async {
      const props = DishProps(
        name: 'Salad',
        price: 8.50,
        dietary: ['Vegan', 'Gluten-Free'],
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

      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Gluten-Free'), findsOneWidget);
    });

    testWidgets('should display both allergens and dietary tags', (
      tester,
    ) async {
      const props = DishProps(
        name: 'Mixed Dish',
        price: 15.0,
        allergens: ['Nuts'],
        dietary: ['Vegetarian'],
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

      // 'Nuts' is rendered as allergen text 'NUTS', 'Vegetarian' as dietary Chip
      expect(find.text('NUTS'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
      // Only dietary tags render as Chips (allergens are formatted text)
      expect(find.byType(Chip), findsOneWidget);
    });

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
  });
}
