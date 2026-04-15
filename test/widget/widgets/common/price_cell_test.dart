import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/price_cell.dart';

void main() {
  Future<void> pump(WidgetTester tester, double price) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PriceCell(price: price, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  group('PriceCell', () {
    testWidgets('integer-only price (1.0)', (tester) async {
      await pump(tester, 1.0);
      expect(find.text('£1'), findsOneWidget);
      expect(find.text('.5'), findsNothing);
      expect(find.text('.0'), findsNothing);
    });

    testWidgets('half price (1.5) -> .5', (tester) async {
      await pump(tester, 1.5);
      expect(find.text('£1'), findsOneWidget);
      expect(find.text('.5'), findsOneWidget);
    });

    testWidgets('two-decimal price (1.25)', (tester) async {
      await pump(tester, 1.25);
      expect(find.text('£1'), findsOneWidget);
      expect(find.text('.25'), findsOneWidget);
    });

    testWidgets('leading-zero decimal preserved (1.05)', (tester) async {
      await pump(tester, 1.05);
      expect(find.text('£1'), findsOneWidget);
      expect(find.text('.05'), findsOneWidget);
    });

    testWidgets('thousands separator (1000)', (tester) async {
      await pump(tester, 1000.0);
      expect(find.text('£1,000'), findsOneWidget);
    });

    testWidgets('thousands and decimal (1000.5)', (tester) async {
      await pump(tester, 1000.5);
      expect(find.text('£1,000'), findsOneWidget);
      expect(find.text('.5'), findsOneWidget);
    });

    testWidgets('integer cell is right-aligned, decimal cell left-aligned', (
      tester,
    ) async {
      await pump(tester, 1.5);
      final texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(PriceCell),
              matching: find.byType(Text),
            ),
          )
          .toList();
      expect(texts[0].textAlign, TextAlign.end); // integer
      expect(texts[1].textAlign, TextAlign.start); // decimal
    });
  });
}
