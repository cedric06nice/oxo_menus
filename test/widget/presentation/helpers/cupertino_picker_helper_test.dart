import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/helpers/cupertino_picker_helper.dart';

void main() {
  group('showCupertinoPicker', () {
    testWidgets('shows CupertinoPicker in a modal popup on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showCupertinoPicker<String>(
                context,
                items: ['Left', 'Center', 'Right'],
                currentValue: 'Left',
                labelBuilder: (item) => item,
                onSelected: (_) {},
              ),
              child: const Text('Pick'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPicker), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('selects current value by default', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showCupertinoPicker<String>(
                context,
                items: ['Left', 'Center', 'Right'],
                currentValue: 'Center',
                labelBuilder: (item) => item,
                onSelected: (value) => selected = value,
              ),
              child: const Text('Pick'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      // Tap Done without scrolling — should select current value
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(selected, 'Center');
    });

    testWidgets('calls onSelected with new value after scrolling', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showCupertinoPicker<String>(
                context,
                items: ['Left', 'Center', 'Right'],
                currentValue: 'Left',
                labelBuilder: (item) => item,
                onSelected: (value) => selected = value,
              ),
              child: const Text('Pick'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      // Scroll the picker down to select 'Center'
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
    });

    testWidgets('dismisses without calling onSelected when tapping outside', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showCupertinoPicker<String>(
                context,
                items: ['Left', 'Center', 'Right'],
                currentValue: 'Left',
                labelBuilder: (item) => item,
                onSelected: (value) => selected = value,
              ),
              child: const Text('Pick'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      // Tap the barrier area to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });
}
