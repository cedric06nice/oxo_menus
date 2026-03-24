import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/dish_to_share_widget/dish_to_share_widget.dart';

void main() {
  group('DishToShareWidget', () {
    testWidgets('should display dish name uppercased and price', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('MEZZE PLATTER'), findsOneWidget);
      expect(find.text('£18.50'), findsOneWidget);
    });

    testWidgets('should display "To Share" when servings is null', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Board', price: 20.00);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('To Share'), findsOneWidget);
    });

    testWidgets('should display "For Two To Share" when servings is 2', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Board', price: 20.00, servings: 2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('For Two To Share'), findsOneWidget);
    });

    testWidgets('should display "For Four To Share" when servings is 4', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Nachos', price: 14.00, servings: 4);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('For Four To Share'), findsOneWidget);
    });

    testWidgets('should hide price when showPrices is false', (tester) async {
      const props = DishToShareProps(name: 'Board', price: 20.00, servings: 2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showPrices: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BOARD'), findsOneWidget);
      expect(find.text('£20.00'), findsNothing);
      // Sharing text should still be visible
      expect(find.text('For Two To Share'), findsOneWidget);
    });

    testWidgets('should display description', (tester) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        description: 'Selection of artisan cheeses',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Selection of artisan cheeses'), findsOneWidget);
    });

    testWidgets('should not display empty description', (tester) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        description: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('BOARD'), findsOneWidget);
    });

    testWidgets('should display allergens', (tester) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        allergens: ['Dairy', 'Gluten'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('GLUTEN, MILK'), findsOneWidget);
    });

    testWidgets('should hide allergens when showAllergens is false', (
      tester,
    ) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        allergens: ['Dairy', 'Gluten'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showAllergens: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('GLUTEN, MILK'), findsNothing);
    });

    testWidgets(
      'should display dietary abbreviation inline with uppercased name',
      (tester) async {
        const props = DishToShareProps(
          name: 'Mezze',
          price: 18.50,
          dietary: DietaryType.vegan,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DishToShareWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        expect(find.text('MEZZE (Ve)'), findsOneWidget);
      },
    );

    testWidgets('should display calories when present and allergens showing', (
      tester,
    ) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        calories: 850,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('850 KCAL'), findsOneWidget);
    });

    testWidgets('should not display calories when showAllergens is false', (
      tester,
    ) async {
      const props = DishToShareProps(
        name: 'Board',
        price: 20.00,
        calories: 850,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showAllergens: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('850 KCAL'), findsNothing);
    });

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Board', price: 20.00);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Dish To Share'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Board', price: 20.00);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Dish To Share'), findsNothing);
    });

    testWidgets('should call onUpdate with updated props when saved', (
      tester,
    ) async {
      const props = DishToShareProps(name: 'Board', price: 20.00);

      Map<String, dynamic>? capturedUpdate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
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
        find.widgetWithText(TextField, 'Name'),
        'Updated Board',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(capturedUpdate, isNotNull);
      expect(capturedUpdate!['name'], 'Updated Board');
      expect(capturedUpdate!['price'], 20.00);
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        const props = DishToShareProps(name: 'Board', price: 20.00);
        var editStartedCount = 0;
        var editEndedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DishToShareWidget(
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

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(editStartedCount, 1);
        expect(editEndedCount, 0);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(editEndedCount, 1);
      },
    );

    testWidgets('should render card with proper styling', (tester) async {
      const props = DishToShareProps(name: 'Board', price: 20.00);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishToShareWidget(
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
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
