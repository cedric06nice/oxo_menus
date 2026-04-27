import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_filter_bar.dart';

void main() {
  group('StatusFilterBar', () {
    testWidgets('renders all four status chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusFilterBar(
              selectedFilter: 'all',
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('highlights the selected filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusFilterBar(
              selectedFilter: 'draft',
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      final draftChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Draft'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(draftChip.selected, isTrue);

      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('All'), matching: find.byType(ChoiceChip)),
      );
      expect(allChip.selected, isFalse);
    });

    testWidgets('calls onFilterChanged when chip is tapped', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusFilterBar(
              selectedFilter: 'all',
              onFilterChanged: (filter) => selected = filter,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Published'));
      expect(selected, 'published');
    });
  });
}
