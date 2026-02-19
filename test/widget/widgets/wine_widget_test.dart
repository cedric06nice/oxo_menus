import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/wine_widget/wine_widget.dart';

void main() {
  group('WineWidget', () {
    testWidgets('should display wine name uppercased', (tester) async {
      const props = WineProps(name: 'Chateau Margaux', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('CHATEAU MARGAUX'), findsOneWidget);
    });

    testWidgets('should display price when present and showPrices true', (
      tester,
    ) async {
      const props = WineProps(name: 'Merlot', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('£12.50'), findsOneWidget);
    });

    testWidgets('should hide price when showPrices is false', (tester) async {
      const props = WineProps(name: 'Merlot', price: 12.50);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showPrices: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('£12.50'), findsNothing);
    });

    testWidgets('should display vintage when present', (tester) async {
      const props = WineProps(name: 'Merlot', price: 9.0, vintage: 2019);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Vintage: 2019'), findsOneWidget);
    });

    testWidgets('should not display vintage when null', (tester) async {
      const props = WineProps(name: 'Merlot', price: 9.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.textContaining('Vintage'), findsNothing);
    });

    testWidgets('should display dietary abbreviation in name', (tester) async {
      const props = WineProps(
        name: 'Pinot Noir',
        price: 10.0,
        dietary: DietaryType.vegan,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('PINOT NOIR (Ve)'), findsOneWidget);
    });

    testWidgets('should display description when present', (tester) async {
      const props = WineProps(
        name: 'Merlot',
        price: 9.0,
        description: 'Full-bodied Bordeaux',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Full-bodied Bordeaux'), findsOneWidget);
    });

    testWidgets('should not display empty description', (tester) async {
      const props = WineProps(name: 'Merlot', price: 9.0, description: '');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('MERLOT'), findsOneWidget);
      // Only the name text widget, no description text
    });

    testWidgets(
      'should display SULPHITES when containsSulphites and showAllergens true',
      (tester) async {
        const props = WineProps(
          name: 'Merlot',
          price: 9.0,
          containsSulphites: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WineWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        expect(find.text('SULPHITES'), findsOneWidget);
      },
    );

    testWidgets('should hide SULPHITES when showAllergens is false', (
      tester,
    ) async {
      const props = WineProps(
        name: 'Merlot',
        price: 9.0,
        containsSulphites: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showAllergens: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('SULPHITES'), findsNothing);
    });

    testWidgets(
      'should not display SULPHITES when containsSulphites is false',
      (tester) async {
        const props = WineProps(name: 'Merlot', price: 9.0);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: WineWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        );

        expect(find.text('SULPHITES'), findsNothing);
      },
    );

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = WineProps(name: 'Merlot', price: 9.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Wine'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = WineProps(name: 'Merlot', price: 9.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Edit Wine'), findsNothing);
    });

    testWidgets('should render card with proper styling', (tester) async {
      const props = WineProps(name: 'Test Wine', price: 0.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WineWidget(
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
