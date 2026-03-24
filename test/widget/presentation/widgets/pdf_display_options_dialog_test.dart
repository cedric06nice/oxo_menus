import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/pdf_display_options_dialog.dart';

void main() {
  group('PdfDisplayOptionsDialog', () {
    testWidgets('displays title, switches, and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const PdfDisplayOptionsDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('PDF Options'), findsOneWidget);
      expect(find.text('Show Prices'), findsOneWidget);
      expect(find.text('Show Allergens'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('defaults to showPrices=true, showAllergens=false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const PdfDisplayOptionsDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.elementAt(0).value, true); // showPrices
      expect(switches.elementAt(1).value, false); // showAllergens
    });

    testWidgets('toggles switches correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const PdfDisplayOptionsDialog(),
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

      // Toggle "Show Allergens" on
      await tester.tap(find.text('Show Allergens'));
      await tester.pump();

      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.elementAt(0).value, false); // prices toggled off
      expect(switches.elementAt(1).value, true); // allergens toggled on
    });

    testWidgets('returns MenuDisplayOptions on Preview tap', (
      WidgetTester tester,
    ) async {
      MenuDisplayOptions? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MenuDisplayOptions>(
                    context: context,
                    builder: (_) => const PdfDisplayOptionsDialog(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Toggle allergens on
      await tester.tap(find.text('Show Allergens'));
      await tester.pump();

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.showPrices, true);
      expect(result!.showAllergens, true);
    });

    testWidgets('returns null on Cancel tap', (WidgetTester tester) async {
      MenuDisplayOptions? result;
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MenuDisplayOptions>(
                    context: context,
                    builder: (_) => const PdfDisplayOptionsDialog(),
                  );
                  dialogClosed = true;
                },
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

      expect(dialogClosed, true);
      expect(result, isNull);
    });

    testWidgets('renders CupertinoAlertDialog on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const PdfDisplayOptionsDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2));
      expect(find.text('PDF Options'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('Cupertino defaults to showPrices=true, showAllergens=false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const PdfDisplayOptionsDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<CupertinoSwitch>(
        find.byType(CupertinoSwitch),
      );
      expect(switches.elementAt(0).value, true); // showPrices
      expect(switches.elementAt(1).value, false); // showAllergens
    });
  });
}
