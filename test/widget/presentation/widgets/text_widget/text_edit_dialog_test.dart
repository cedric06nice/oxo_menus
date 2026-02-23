import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_edit_dialog.dart';

void main() {
  const testProps = TextProps(
    text: 'Hello World',
    fontSize: 14,
    align: 'left',
    bold: false,
    italic: false,
  );

  group('TextEditDialog', () {
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
                      TextEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Text'), findsOneWidget);
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
                        TextEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Text'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2));
      expect(find.byType(CupertinoSlider), findsOneWidget);
    });

    testWidgets('saves correct props from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      TextProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => TextEditDialog(
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

      // Enter new text
      final textField = find.byType(CupertinoTextField);
      await tester.enterText(textField, 'Updated text');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.text, 'Updated text');
    });
  });
}
