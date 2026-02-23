import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders FilledButton on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No items',
              subtitle: 'Nothing here yet',
              actionLabel: 'Add',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('renders CupertinoButton.filled on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No items',
              subtitle: 'Nothing here yet',
              actionLabel: 'Add',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('taps CupertinoButton.filled on iOS', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No items',
              subtitle: 'Nothing here yet',
              actionLabel: 'Add',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      expect(tapped, true);
    });

    testWidgets('hides button when actionLabel is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No items',
              subtitle: 'Nothing here yet',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(CupertinoButton), findsNothing);
    });
  });
}
