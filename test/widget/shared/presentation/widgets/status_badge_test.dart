import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_badge.dart';

void main() {
  Widget buildTestWidget(Status status) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: StatusBadge(status: status)),
      ),
    );
  }

  group('StatusBadge', () {
    testWidgets('displays DRAFT text for draft status', (tester) async {
      await tester.pumpWidget(buildTestWidget(Status.draft));
      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('displays PUBLISHED text for published status', (tester) async {
      await tester.pumpWidget(buildTestWidget(Status.published));
      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('displays ARCHIVED text for archived status', (tester) async {
      await tester.pumpWidget(buildTestWidget(Status.archived));
      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('shows icon for each status', (tester) async {
      await tester.pumpWidget(buildTestWidget(Status.draft));
      expect(find.byIcon(Icons.edit_note), findsOneWidget);

      await tester.pumpWidget(buildTestWidget(Status.published));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      await tester.pumpWidget(buildTestWidget(Status.archived));
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('has pill shape (StadiumBorder)', (tester) async {
      await tester.pumpWidget(buildTestWidget(Status.draft));

      final container = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
