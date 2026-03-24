import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/set_menu_title_widget/set_menu_title_widget.dart';

void main() {
  group('SetMenuTitleWidget', () {
    testWidgets('should display title uppercased by default', (tester) async {
      const props = SetMenuTitleProps(title: 'Set Lunch Menu');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SET LUNCH MENU'), findsOneWidget);
    });

    testWidgets('should display title without uppercase when flag is false', (
      tester,
    ) async {
      const props = SetMenuTitleProps(
        title: 'Set Lunch Menu',
        uppercase: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Set Lunch Menu'), findsOneWidget);
      expect(find.text('SET LUNCH MENU'), findsNothing);
    });

    testWidgets('should display subtitle when present', (tester) async {
      const props = SetMenuTitleProps(
        title: 'Set Menu',
        subtitle: 'Seasonal dishes',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Seasonal dishes'), findsOneWidget);
    });

    testWidgets('should not display empty subtitle', (tester) async {
      const props = SetMenuTitleProps(title: 'Set Menu', subtitle: '');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SET MENU'), findsOneWidget);
    });

    testWidgets('should not display divider', (tester) async {
      const props = SetMenuTitleProps(title: 'Set Menu');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('should display prices inline after title', (tester) async {
      const props = SetMenuTitleProps(
        title: 'Set Menu',
        priceLabel1: '3 Courses',
        price1: 45.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SET MENU  3 Courses 45'), findsOneWidget);
    });

    testWidgets('should display both prices inline after title', (
      tester,
    ) async {
      const props = SetMenuTitleProps(
        title: 'Set Menu',
        priceLabel1: '3 Courses',
        price1: 45.0,
        priceLabel2: '4 Courses',
        price2: 55.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(
        find.text('SET MENU  3 Courses 45 / 4 Courses 55'),
        findsOneWidget,
      );
    });

    testWidgets('should hide prices when showPrices is false', (tester) async {
      const props = SetMenuTitleProps(
        title: 'Set Menu',
        priceLabel1: '3 Courses',
        price1: 45.0,
        priceLabel2: '4 Courses',
        price2: 55.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(
                isEditable: false,
                displayOptions: MenuDisplayOptions(showPrices: false),
              ),
            ),
          ),
        ),
      );

      expect(find.text('SET MENU'), findsOneWidget);
      expect(find.textContaining('45'), findsNothing);
    });

    testWidgets('should display price without label inline', (tester) async {
      const props = SetMenuTitleProps(title: 'Set Menu', price1: 45.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('SET MENU  45'), findsOneWidget);
    });

    testWidgets('should render title with LibreBaskerville font', (
      tester,
    ) async {
      const props = SetMenuTitleProps(title: 'Test');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('TEST'));
      expect(textWidget.style?.fontFamily, 'LibreBaskerville');
      expect(textWidget.style?.fontSize, 17);
    });

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = SetMenuTitleProps(title: 'Set Menu');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SET MENU'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Title'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = SetMenuTitleProps(title: 'Set Menu');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SET MENU'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Title'), findsNothing);
    });

    testWidgets('should call onEditStarted and onEditEnded around dialog', (
      tester,
    ) async {
      const props = SetMenuTitleProps(title: 'Set Menu');
      var editStartedCount = 0;
      var editEndedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetMenuTitleWidget(
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

      await tester.tap(find.text('SET MENU'));
      await tester.pumpAndSettle();

      expect(editStartedCount, 1);
      expect(editEndedCount, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(editEndedCount, 1);
    });
  });
}
