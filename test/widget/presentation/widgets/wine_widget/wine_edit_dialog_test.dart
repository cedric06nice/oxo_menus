import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/presentation/widgets/wine_widget/wine_edit_dialog.dart';

void main() {
  const testProps = WineProps(
    name: 'Merlot',
    price: 12.50,
    description: 'Full-bodied red',
    vintage: 2019,
    containsSulphites: true,
  );

  group('WineEditDialog', () {
    testWidgets('renders AlertDialog on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      WineEditDialog(props: testProps, onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit Wine'), findsOneWidget);
    });

    testWidgets('renders CupertinoPageScaffold on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) =>
                        WineEditDialog(props: testProps, onSave: (_) {}),
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

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text('Edit Wine'), findsOneWidget);
      expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(4));
      expect(find.byType(CupertinoCheckbox), findsOneWidget);
    });

    testWidgets('saves correct props from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      WineProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => WineEditDialog(
                      props: testProps,
                      onSave: (p) => savedProps = p,
                    ),
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

      // Tap Save with existing values
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.name, 'Merlot');
      expect(savedProps!.price, 12.50);
      expect(savedProps!.containsSulphites, true);
    });
  });
}
