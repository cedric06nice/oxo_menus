import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_helpers.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_status_indicator.dart';

void main() {
  Widget buildWidget(Status status) {
    return MaterialApp(
      home: Scaffold(body: TemplateStatusIndicator(status: status)),
    );
  }

  group('TemplateStatusIndicator', () {
    testWidgets('displays uppercase status text for draft', (tester) async {
      await tester.pumpWidget(buildWidget(Status.draft));

      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('displays uppercase status text for published', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('displays uppercase status text for archived', (tester) async {
      await tester.pumpWidget(buildWidget(Status.archived));

      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('renders a colored dot (Container with circular shape)', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(Status.draft));

      // Find the dot: a small Container with BoxDecoration
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('dot uses statusColor from theme', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));

      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      final dot = tester.widget<Container>(dotFinder);
      final decoration = dot.decoration! as BoxDecoration;
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      final expectedColor = statusColor(Status.published, theme.colorScheme);

      expect(decoration.color, expectedColor);
    });
  });
}
