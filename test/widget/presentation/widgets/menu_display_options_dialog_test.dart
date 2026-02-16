import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/presentation/widgets/menu_display_options_dialog.dart';

void main() {
  group('MenuDisplayOptionsDialog', () {
    testWidgets('should display title and switches with defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => MenuDisplayOptionsDialog(
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

      expect(find.text('Display Options'), findsOneWidget);
      expect(find.text('Show Prices'), findsOneWidget);
      expect(find.text('Show Allergens'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should initialize with provided display options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => MenuDisplayOptionsDialog(
                    displayOptions: const MenuDisplayOptions(
                      showPrices: false,
                      showAllergens: false,
                    ),
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

      // Both switches should be off
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.elementAt(0).value, false);
      expect(switches.elementAt(1).value, false);
    });

    testWidgets('should toggle switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => MenuDisplayOptionsDialog(
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

      // Toggle "Show Prices" off
      await tester.tap(find.text('Show Prices'));
      await tester.pump();

      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.elementAt(0).value, false); // prices toggled off
      expect(switches.elementAt(1).value, true); // allergens still on
    });

    testWidgets('should call onSave with correct options',
        (WidgetTester tester) async {
      MenuDisplayOptions? savedOptions;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => MenuDisplayOptionsDialog(
                    onSave: (options) => savedOptions = options,
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

      // Toggle prices off
      await tester.tap(find.text('Show Prices'));
      await tester.pump();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedOptions, isNotNull);
      expect(savedOptions!.showPrices, false);
      expect(savedOptions!.showAllergens, true);
    });

    testWidgets('should close dialog on Cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => MenuDisplayOptionsDialog(
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

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Display Options'), findsNothing);
    });
  });
}
