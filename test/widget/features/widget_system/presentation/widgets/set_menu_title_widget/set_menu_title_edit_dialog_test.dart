import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/set_menu_title_widget/set_menu_title_edit_dialog.dart';

void main() {
  group('SetMenuTitleEditDialog', () {
    testWidgets('should display all fields', (tester) async {
      const props = SetMenuTitleProps(title: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      SetMenuTitleEditDialog(props: props, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Set Menu Title'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle (optional)'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Price label 1 (optional)'), findsOneWidget);
      expect(find.text('Price 1'), findsOneWidget);
      expect(find.text('Price label 2 (optional)'), findsOneWidget);
      expect(find.text('Price 2'), findsOneWidget);
    });

    testWidgets('should pre-fill fields with existing props', (tester) async {
      const props = SetMenuTitleProps(
        title: 'Set Lunch',
        subtitle: 'Seasonal dishes',
        uppercase: false,
        priceLabel1: '3 Courses',
        price1: 45.0,
        priceLabel2: '4 Courses',
        price2: 55.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      SetMenuTitleEditDialog(props: props, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final titleField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Title'),
      );
      expect(titleField.controller?.text, 'Set Lunch');

      final subtitleField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Subtitle (optional)'),
      );
      expect(subtitleField.controller?.text, 'Seasonal dishes');

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, false);
    });

    testWidgets('should call onSave with updated props', (tester) async {
      const props = SetMenuTitleProps(title: 'Old Title');
      SetMenuTitleProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuTitleEditDialog(
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
        find.widgetWithText(TextField, 'Title'),
        'New Title',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.title, 'New Title');
    });

    testWidgets('should dismiss without saving on Cancel', (tester) async {
      const props = SetMenuTitleProps(title: 'Test');
      SetMenuTitleProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuTitleEditDialog(
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
      expect(find.text('Edit Set Menu Title'), findsNothing);
    });

    testWidgets('should save with price values', (tester) async {
      const props = SetMenuTitleProps(title: 'Set Menu');
      SetMenuTitleProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuTitleEditDialog(
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
        find.widgetWithText(TextField, 'Price label 1 (optional)'),
        '3 Courses',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Price 1'), '45');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.priceLabel1, '3 Courses');
      expect(savedProps!.price1, 45.0);
    });

    testWidgets('should save null for empty price fields', (tester) async {
      const props = SetMenuTitleProps(
        title: 'Set Menu',
        priceLabel1: '3 Courses',
        price1: 45.0,
      );
      SetMenuTitleProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SetMenuTitleEditDialog(
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

      // Clear the label field
      await tester.enterText(
        find.widgetWithText(TextField, 'Price label 1 (optional)'),
        '',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Price 1'), '');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.priceLabel1, isNull);
      expect(savedProps!.price1, isNull);
    });
  });
}
