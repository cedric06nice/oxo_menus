import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/set_menu_dish_widget/set_menu_dish_widget.dart';

void main() {
  group('SetMenuDishWidget', () {
    testWidgets('should display dish name uppercased', (tester) async {
      const props = SetMenuDishProps(name: 'Beef Wellington');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('BEEF WELLINGTON'), findsOneWidget);
    });

    testWidgets('should not display any price by default', (tester) async {
      const props = SetMenuDishProps(name: 'Soup');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SOUP'), findsOneWidget);
      // No price text should appear
      expect(find.textContaining('£'), findsNothing);
    });

    testWidgets('should display supplement text when hasSupplement is true', (
      tester,
    ) async {
      const props = SetMenuDishProps(
        name: 'Lobster',
        hasSupplement: true,
        supplementPrice: 5.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Supplement 5'), findsOneWidget);
    });

    testWidgets('should display supplement with decimal', (tester) async {
      const props = SetMenuDishProps(
        name: 'Wagyu Steak',
        hasSupplement: true,
        supplementPrice: 7.5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Supplement 7.5'), findsOneWidget);
    });

    testWidgets('should not display supplement when hasSupplement is false', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Soup');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.textContaining('Supplement'), findsNothing);
    });

    testWidgets('should display description', (tester) async {
      const props = SetMenuDishProps(
        name: 'Soup',
        description: 'Homemade daily',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Homemade daily'), findsOneWidget);
    });

    testWidgets('should not display empty description', (tester) async {
      const props = SetMenuDishProps(name: 'Soup', description: '');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SOUP'), findsOneWidget);
    });

    testWidgets('should display allergens', (tester) async {
      const props = SetMenuDishProps(
        name: 'Soup',
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.gluten),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
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
      const props = SetMenuDishProps(
        name: 'Soup',
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.gluten),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
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

    testWidgets('should display dietary abbreviation in name', (tester) async {
      const props = SetMenuDishProps(
        name: 'Garden Risotto',
        dietary: DietaryType.vegan,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('GARDEN RISOTTO (Ve)'), findsOneWidget);
    });

    testWidgets('should display calories when present', (tester) async {
      const props = SetMenuDishProps(name: 'Soup', calories: 320);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('320 KCAL'), findsOneWidget);
    });

    testWidgets('should not display calories when showAllergens is false', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Soup', calories: 320);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showAllergens: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('320 KCAL'), findsNothing);
    });

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Soup');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Dish'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Soup');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Dish'), findsNothing);
    });

    testWidgets('should call onEditStarted and onEditEnded around dialog', (
      tester,
    ) async {
      const props = SetMenuDishProps(name: 'Soup');
      var editStartedCount = 0;
      var editEndedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
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
    });

    testWidgets('should render card with proper styling', (tester) async {
      const props = SetMenuDishProps(name: 'Soup');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuDishWidget(
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
    });
  });
}
