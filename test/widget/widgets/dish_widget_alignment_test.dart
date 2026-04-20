import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/common/price_cell.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    WidgetAlignment alignment, {
    DishProps? props,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DishWidget(
            props: props ?? const DishProps(name: 'Pasta', price: 12.50),
            context: WidgetContext(isEditable: false, alignment: alignment),
          ),
        ),
      ),
    );
  }

  Column innerColumn(WidgetTester tester) {
    return tester.widget<Column>(
      find
          .descendant(of: find.byType(Card), matching: find.byType(Column))
          .first,
    );
  }

  Iterable<Text> textsInCard(WidgetTester tester) => tester.widgetList<Text>(
    find.descendant(of: find.byType(Card), matching: find.byType(Text)),
  );

  group('DishWidget alignment', () {
    testWidgets('start: column.start, every Text textAlign.start', (t) async {
      await pump(
        t,
        WidgetAlignment.start,
        props: const DishProps(
          name: 'Pasta',
          price: 12.50,
          description: 'desc',
          calories: 350,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        ),
      );
      expect(innerColumn(t).crossAxisAlignment, CrossAxisAlignment.start);
      for (final text in textsInCard(t)) {
        expect(text.textAlign, TextAlign.start);
      }
    });

    testWidgets('center: column.center, every Text textAlign.center', (
      t,
    ) async {
      await pump(
        t,
        WidgetAlignment.center,
        props: const DishProps(
          name: 'Pasta',
          price: 12.50,
          description: 'desc',
          calories: 350,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        ),
      );
      expect(innerColumn(t).crossAxisAlignment, CrossAxisAlignment.center);
      for (final text in textsInCard(t)) {
        expect(text.textAlign, TextAlign.center);
      }
    });

    testWidgets('end: column.end, every Text textAlign.end', (t) async {
      await pump(t, WidgetAlignment.end);
      expect(innerColumn(t).crossAxisAlignment, CrossAxisAlignment.end);
      for (final text in textsInCard(t)) {
        expect(text.textAlign, TextAlign.end);
      }
    });

    testWidgets('justified: header is a Row containing PriceCell', (t) async {
      await pump(
        t,
        WidgetAlignment.justified,
        props: const DishProps(name: 'Pasta', price: 1.5),
      );
      expect(find.byType(PriceCell), findsOneWidget);
      // Name still present
      expect(find.text('PASTA'), findsOneWidget);
      // PriceCell shows split parts
      expect(find.text('£1'), findsOneWidget);
      expect(find.text('.5'), findsOneWidget);
    });

    testWidgets('justified: hides PriceCell when showPrices=false', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DishWidget(
              props: DishProps(name: 'Pasta', price: 1.5),
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
      expect(find.text('PASTA'), findsOneWidget);
    });
  });
}
