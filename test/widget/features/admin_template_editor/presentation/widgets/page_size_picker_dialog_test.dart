import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/widgets/page_size_picker_dialog.dart';

void main() {
  final testSizes = [
    const domain.Size(
      id: 1,
      name: 'A4',
      width: 210,
      height: 297,
      direction: 'portrait',
      status: Status.published,
    ),
    const domain.Size(
      id: 2,
      name: 'A5',
      width: 148,
      height: 210,
      direction: 'portrait',
      status: Status.published,
    ),
  ];

  group('PageSizePickerDialog', () {
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
                      PageSizePickerDialog(sizes: testSizes, onSelect: (_) {}),
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
      expect(find.text('Select Page Size'), findsOneWidget);
      expect(find.text('A4'), findsOneWidget);
      expect(find.text('A5'), findsOneWidget);
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
                  builder: (_) =>
                      PageSizePickerDialog(sizes: testSizes, onSelect: (_) {}),
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
      expect(find.text('Select Page Size'), findsOneWidget);
      expect(find.text('A4'), findsOneWidget);
      expect(find.text('A5'), findsOneWidget);
    });

    testWidgets('calls onSelect when item tapped on Android', (
      WidgetTester tester,
    ) async {
      domain.Size? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => PageSizePickerDialog(
                    sizes: testSizes,
                    onSelect: (s) => selected = s,
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

      await tester.tap(find.text('A5'));
      await tester.pumpAndSettle();

      expect(selected?.name, 'A5');
    });

    testWidgets('calls onSelect when item tapped on iOS', (
      WidgetTester tester,
    ) async {
      domain.Size? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => PageSizePickerDialog(
                    sizes: testSizes,
                    onSelect: (s) => selected = s,
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

      await tester.tap(find.text('A5'));
      await tester.pumpAndSettle();

      expect(selected?.name, 'A5');
    });

    testWidgets('shows check icon for selected size on iOS', (
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
                  builder: (_) => PageSizePickerDialog(
                    sizes: testSizes,
                    currentPageSize: const PageSize(
                      name: 'A4',
                      width: 210,
                      height: 297,
                    ),
                    onSelect: (_) {},
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

      expect(find.byIcon(CupertinoIcons.checkmark_alt), findsOneWidget);
    });
  });
}
