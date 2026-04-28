import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/section_widget/section_edit_dialog.dart';

void main() {
  const testProps = SectionProps(
    title: 'Starters',
    uppercase: true,
    showDivider: true,
  );

  group('SectionEditDialog', () {
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
                      SectionEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Section'), findsOneWidget);
    });

    testWidgets('renders CupertinoPageScaffold on iOS via fullscreen route', (
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
                        SectionEditDialog(props: testProps, onSave: (_) {}),
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
      expect(find.text('Edit Section'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2));
      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('saves correct props from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      SectionProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => SectionEditDialog(
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

      // Clear title and type new one
      await tester.enterText(find.byType(CupertinoTextField), 'Mains');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps!.title, 'Mains');
    });

    testWidgets('Cancel pops on iOS', (WidgetTester tester) async {
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
                        SectionEditDialog(props: testProps, onSave: (_) {}),
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

      expect(find.byType(CupertinoPageScaffold), findsNothing);
    });
  });
}
