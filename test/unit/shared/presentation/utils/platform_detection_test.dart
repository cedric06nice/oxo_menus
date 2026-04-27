import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

void main() {
  group('isApplePlatform', () {
    Widget buildWithPlatform(
      TargetPlatform platform,
      void Function(BuildContext) callback,
    ) {
      return MaterialApp(
        theme: ThemeData(platform: platform),
        home: Builder(
          builder: (context) {
            callback(context);
            return const SizedBox();
          },
        ),
      );
    }

    testWidgets('returns true for iOS', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithPlatform(TargetPlatform.iOS, (ctx) {
          result = isApplePlatform(ctx);
        }),
      );
      expect(result, isTrue);
    });

    testWidgets('returns true for macOS', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithPlatform(TargetPlatform.macOS, (ctx) {
          result = isApplePlatform(ctx);
        }),
      );
      expect(result, isTrue);
    });

    testWidgets('returns false for Android', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithPlatform(TargetPlatform.android, (ctx) {
          result = isApplePlatform(ctx);
        }),
      );
      expect(result, isFalse);
    });

    testWidgets('returns false for Linux', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithPlatform(TargetPlatform.linux, (ctx) {
          result = isApplePlatform(ctx);
        }),
      );
      expect(result, isFalse);
    });

    testWidgets('returns false for Windows', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithPlatform(TargetPlatform.windows, (ctx) {
          result = isApplePlatform(ctx);
        }),
      );
      expect(result, isFalse);
    });
  });
}
