import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_status_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';

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

    testWidgets('delegates to StatusBadge', (tester) async {
      await tester.pumpWidget(buildWidget(Status.draft));
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('shows status icon for published', (tester) async {
      await tester.pumpWidget(buildWidget(Status.published));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
