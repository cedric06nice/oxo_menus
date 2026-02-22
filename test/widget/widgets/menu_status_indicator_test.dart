import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/presentation/widgets/menu_status_indicator.dart';

void main() {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

  Widget buildWidget(Status status) {
    return MaterialApp(
      theme: ThemeData(colorScheme: colorScheme),
      home: Scaffold(body: MenuStatusIndicator(status: status)),
    );
  }

  group('MenuStatusIndicator', () {
    testWidgets('renders uppercase status text for published', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('renders uppercase status text for draft', (tester) async {
      await tester.pumpWidget(buildWidget(Status.draft));

      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('renders uppercase status text for archived', (tester) async {
      await tester.pumpWidget(buildWidget(Status.archived));

      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('renders a colored dot', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      // Find the dot container (8x8 circle)
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 8 &&
            widget.constraints?.maxHeight == 8,
      );
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('dot uses statusColor for published', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      final expectedColor = statusColor(Status.published, colorScheme);

      final dotFinder = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            return decoration.shape == BoxShape.circle &&
                decoration.color == expectedColor;
          }
        }
        return false;
      });
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('dot uses statusColor for draft', (tester) async {
      await tester.pumpWidget(buildWidget(Status.draft));

      final expectedColor = statusColor(Status.draft, colorScheme);

      final dotFinder = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            return decoration.shape == BoxShape.circle &&
                decoration.color == expectedColor;
          }
        }
        return false;
      });
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('text uses statusColor for the text style', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      final expectedColor = statusColor(Status.published, colorScheme);

      final textWidget = tester.widget<Text>(find.text('PUBLISHED'));
      expect(textWidget.style?.color, expectedColor);
    });

    testWidgets('uses Row with mainAxisSize.min', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      final row = tester.widget<Row>(
        find.ancestor(of: find.text('PUBLISHED'), matching: find.byType(Row)),
      );
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });
}
