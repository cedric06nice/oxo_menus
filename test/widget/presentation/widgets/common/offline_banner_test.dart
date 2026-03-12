import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_banner.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('displays wifi-off icon and offline text on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(body: OfflineBanner()),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('displays Cupertino wifi-off icon on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(body: OfflineBanner()),
        ),
      );

      expect(find.byIcon(CupertinoIcons.wifi_slash), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('uses errorContainer background color', (tester) async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: colorScheme),
          home: const Scaffold(body: OfflineBanner()),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, colorScheme.errorContainer);
    });
  });
}
