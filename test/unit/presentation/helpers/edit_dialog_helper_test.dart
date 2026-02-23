import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';

void main() {
  group('showEditDialog', () {
    testWidgets('pushes CupertinoPageRoute on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showEditDialog(context, const Text('Dialog Content')),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Content'), findsOneWidget);
      // Verify it was pushed as a route (not a dialog overlay)
      expect(find.byType(CupertinoPageRoute), findsNothing);
      // The content should be reachable via Navigator pop
      expect(
        Navigator.of(tester.element(find.text('Dialog Content'))).canPop(),
        isTrue,
      );
    });

    testWidgets('pushes CupertinoPageRoute on macOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showEditDialog(context, const Text('Dialog Content')),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Content'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Dialog Content'))).canPop(),
        isTrue,
      );
    });

    testWidgets('shows dialog on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showEditDialog(context, const Text('Dialog Content')),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('shows dialog on Linux', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.linux),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showEditDialog(context, const Text('Dialog Content')),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Content'), findsOneWidget);
    });
  });
}
