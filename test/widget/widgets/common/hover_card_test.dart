import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/hover_card.dart';

void main() {
  group('HoverCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HoverCard(child: Text('Card Content'))),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('wraps child in MouseRegion', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HoverCard(child: Text('Content'))),
        ),
      );

      // HoverCard should contain a MouseRegion as a descendant
      expect(
        find.descendant(
          of: find.byType(HoverCard),
          matching: find.byType(MouseRegion),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wraps child in AnimatedContainer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HoverCard(child: Text('Content'))),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });
}
