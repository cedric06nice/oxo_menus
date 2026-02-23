import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.restaurant_menu,
              title: 'No menus found',
              subtitle: 'Create your first menu',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
      expect(find.text('Create your first menu'), findsOneWidget);
    });

    testWidgets('displays action button when provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Empty',
              subtitle: 'Nothing here',
              actionLabel: 'Create',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Create'), findsOneWidget);
      await tester.tap(find.text('Create'));
      expect(tapped, isTrue);
    });

    testWidgets('hides action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Empty',
              subtitle: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
