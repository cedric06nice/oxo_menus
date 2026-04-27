import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';

void main() {
  group('AdaptiveErrorState', () {
    testWidgets('displays error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveErrorState(
              message: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error: Something went wrong'), findsOneWidget);
    });

    testWidgets('truncates long messages to 200 characters', (
      WidgetTester tester,
    ) async {
      final longMessage = 'A' * 300;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveErrorState(message: longMessage, onRetry: () {}),
          ),
        ),
      );

      // "Error: " is 7 chars, so total displayed should be clamped to 200
      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.startsWith('Error: ') &&
            widget.data!.length == 200,
      );
      expect(textFinder, findsOneWidget);
    });

    testWidgets('shows Material error icon on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: AdaptiveErrorState(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows Cupertino error icon on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: AdaptiveErrorState(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      expect(
        find.byIcon(CupertinoIcons.exclamationmark_triangle),
        findsOneWidget,
      );
    });

    testWidgets('shows FilledButton on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: AdaptiveErrorState(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows CupertinoButton on iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: AdaptiveErrorState(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveErrorState(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });
}
