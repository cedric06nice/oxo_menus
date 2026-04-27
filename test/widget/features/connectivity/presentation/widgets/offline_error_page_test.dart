import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_error_page.dart';

void main() {
  group('OfflineErrorPage', () {
    testWidgets(
      'renders wifi-off icon, title, subtitle, and retry button on Android',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(body: OfflineErrorPage(onRetry: () {})),
          ),
        );

        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        expect(find.text('You are offline'), findsOneWidget);
        expect(
          find.text('This page requires an active internet connection.'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      },
    );

    testWidgets('renders Cupertino wifi icon on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(body: OfflineErrorPage(onRetry: () {})),
        ),
      );

      expect(find.byIcon(CupertinoIcons.wifi_slash), findsOneWidget);
      expect(find.widgetWithText(CupertinoButton, 'Retry'), findsOneWidget);
    });

    testWidgets('renders Cupertino wifi icon on macOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Scaffold(body: OfflineErrorPage(onRetry: () {})),
        ),
      );

      expect(find.byIcon(CupertinoIcons.wifi_slash), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: OfflineErrorPage(onRetry: () => retryCalled = true),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });

    testWidgets('calls onRetry when Cupertino retry button is tapped', (
      tester,
    ) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: OfflineErrorPage(onRetry: () => retryCalled = true),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });
  });
}
