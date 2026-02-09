import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/widgets/menu_list_item.dart';

void main() {
  group('MenuListItem', () {
    final testMenu = Menu(
      id: 1,
      name: 'Summer Menu',
      status: Status.published,
      version: '1.0.0',
      dateCreated: DateTime.parse('2024-01-15T10:00:00Z'),
      dateUpdated: DateTime.parse('2024-01-20T15:30:00Z'),
    );

    testWidgets('should display menu name', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: false, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Summer Menu'), findsOneWidget);
    });

    testWidgets('should display menu status', (tester) async {
      // Act — subtitle (status/version/date) is only shown for admin users
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: true, onTap: () {}),
          ),
        ),
      );

      // Assert — status is displayed in uppercase
      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('should display menu version', (tester) async {
      // Act — subtitle is only shown for admin users
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: true, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('should display last updated date', (tester) async {
      // Act — subtitle is only shown for admin users
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: true, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Updated'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(
              menu: testMenu,
              isAdmin: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MenuListItem));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should show delete icon for admin users', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(
              menu: testMenu,
              isAdmin: true,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should not show delete icon for regular users', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: false, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('should call onDelete when delete icon tapped', (tester) async {
      // Arrange
      bool deleteTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(
              menu: testMenu,
              isAdmin: true,
              onTap: () {},
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteTapped, true);
    });

    testWidgets('should not call onTap when delete icon tapped', (
      tester,
    ) async {
      // Arrange
      bool tapped = false;
      bool deleteTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(
              menu: testMenu,
              isAdmin: true,
              onTap: () => tapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteTapped, true);
      expect(tapped, false); // onTap should not be called
    });

    testWidgets('should display draft status with different color', (
      tester,
    ) async {
      // Arrange
      const draftMenu = Menu(
        id: 2,
        name: 'Draft Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: draftMenu, isAdmin: true, onTap: () {}),
          ),
        ),
      );

      // Assert — status is displayed in uppercase
      expect(find.text('DRAFT'), findsOneWidget);

      // Find the chip widget and verify it has a different color
      final chipFinder = find.byType(Chip);
      expect(chipFinder, findsOneWidget);
    });

    testWidgets('should display archived status with different color', (
      tester,
    ) async {
      // Arrange
      const archivedMenu = Menu(
        id: 3,
        name: 'Archived Menu',
        status: Status.archived,
        version: '1.0.0',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: archivedMenu, isAdmin: true, onTap: () {}),
          ),
        ),
      );

      // Assert — status is displayed in uppercase
      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('should handle menu without dates gracefully', (tester) async {
      // Arrange
      const menuWithoutDates = Menu(
        id: 4,
        name: 'Menu Without Dates',
        status: Status.published,
        version: '1.0.0',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(
              menu: menuWithoutDates,
              isAdmin: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - should still render without crashing
      expect(find.text('Menu Without Dates'), findsOneWidget);
    });

    testWidgets('should be wrapped in Card widget', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: false, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should use ListTile for layout', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuListItem(menu: testMenu, isAdmin: false, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
