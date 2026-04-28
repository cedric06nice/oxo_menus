import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/widgets/size_create_edit_dialog.dart';

void main() {
  group('SizeCreateEditDialog', () {
    testWidgets('renders AlertDialog on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
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
      expect(find.text('Create Page Size'), findsOneWidget);
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
                    builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
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
      expect(find.text('Create Page Size'), findsOneWidget);
      expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(3));
    });

    testWidgets('saves correct result from Cupertino form on iOS', (
      WidgetTester tester,
    ) async {
      SizeCreateEditResult? savedResult;

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
                        SizeCreateEditDialog(onSave: (r) => savedResult = r),
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

      // Enter name
      final nameField = find.byType(CupertinoTextFormFieldRow).first;
      await tester.enterText(nameField, 'A4');

      // Enter width
      final widthField = find.byType(CupertinoTextFormFieldRow).at(1);
      await tester.enterText(widthField, '210');

      // Enter height
      final heightField = find.byType(CupertinoTextFormFieldRow).at(2);
      await tester.enterText(heightField, '297');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.name, 'A4');
      expect(savedResult!.width, 210);
      expect(savedResult!.height, 297);
    });
  });
}
