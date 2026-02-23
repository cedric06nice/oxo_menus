import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_edit_scaffold.dart';

void main() {
  group('AdaptiveEditScaffold', () {
    group('Material (Android)', () {
      testWidgets('renders AlertDialog with title, Cancel, and Save', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              body: AdaptiveEditScaffold(
                title: 'Edit Section',
                onSave: () {},
                materialFormChildren: const [Text('Material Field')],
                appleFormChildren: const [Text('Apple Field')],
              ),
            ),
          ),
        );

        expect(find.text('Edit Section'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Material Field'), findsOneWidget);
        expect(find.text('Apple Field'), findsNothing);
        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('onSave fires when Save is tapped', (tester) async {
        bool saveCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              body: AdaptiveEditScaffold(
                title: 'Edit Test',
                onSave: () => saveCalled = true,
                materialFormChildren: const [],
                appleFormChildren: const [],
              ),
            ),
          ),
        );

        await tester.tap(find.text('Save'));
        expect(saveCalled, isTrue);
      });

      testWidgets('Cancel pops navigator', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AdaptiveEditScaffold(
                    title: 'Edit Test',
                    onSave: () {},
                    materialFormChildren: const [Text('Content')],
                    appleFormChildren: const [],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Content'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Content'), findsNothing);
      });
    });

    group('Cupertino (iOS)', () {
      testWidgets('renders CupertinoPageScaffold with nav bar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => AdaptiveEditScaffold(
                      title: 'Edit Section',
                      onSave: () {},
                      materialFormChildren: const [Text('Material Field')],
                      appleFormChildren: const [Text('Apple Field')],
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Section'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Apple Field'), findsOneWidget);
        expect(find.text('Material Field'), findsNothing);
        expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      });

      testWidgets('onSave fires when Save is tapped', (tester) async {
        bool saveCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => AdaptiveEditScaffold(
                      title: 'Edit Test',
                      onSave: () => saveCalled = true,
                      materialFormChildren: const [],
                      appleFormChildren: const [],
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        expect(saveCalled, isTrue);
      });

      testWidgets('Cancel pops navigator', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => AdaptiveEditScaffold(
                      title: 'Edit Test',
                      onSave: () {},
                      materialFormChildren: const [],
                      appleFormChildren: const [Text('Apple Content')],
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Apple Content'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Apple Content'), findsNothing);
      });
    });
  });
}
