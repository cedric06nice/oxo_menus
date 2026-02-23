import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';
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

    Widget buildWidget({
      Menu? menu,
      bool isAdmin = false,
      VoidCallback? onTap,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
      VoidCallback? onDuplicate,
      TargetPlatform platform = TargetPlatform.android,
    }) {
      return MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: MenuListItem(
            menu: menu ?? testMenu,
            isAdmin: isAdmin,
            onTap: onTap ?? () {},
            onEdit: onEdit,
            onDelete: onDelete,
            onDuplicate: onDuplicate,
          ),
        ),
      );
    }

    testWidgets('should display menu name', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Summer Menu'), findsOneWidget);
    });

    testWidgets('should display menu status via StatusBadge', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('should display version for admin', (tester) async {
      await tester.pumpWidget(buildWidget(isAdmin: true));

      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('should display version for non-admin', (tester) async {
      await tester.pumpWidget(buildWidget(isAdmin: false));

      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('should display last updated date for admin', (tester) async {
      await tester.pumpWidget(buildWidget(isAdmin: true));

      expect(find.textContaining('Updated'), findsOneWidget);
    });

    testWidgets('should not display last updated date for non-admin', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(isAdmin: false));

      expect(find.textContaining('Updated'), findsNothing);
    });

    testWidgets('should call onTap when tapped on Material', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildWidget(
          onTap: () => tapped = true,
          platform: TargetPlatform.android,
        ),
      );

      await tester.tap(find.byType(MenuListItem));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should call onTap when tapped on Apple', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildWidget(onTap: () => tapped = true, platform: TargetPlatform.iOS),
      );

      await tester.tap(find.byType(MenuListItem));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should show delete icon for admin users on Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onDelete: () {},
          platform: TargetPlatform.android,
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should show delete icon for admin users on Apple', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onDelete: () {},
          platform: TargetPlatform.iOS,
        ),
      );

      expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);
    });

    testWidgets('should not show delete icon for regular users', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(isAdmin: false));

      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(CupertinoIcons.delete), findsNothing);
    });

    testWidgets('should call onDelete when delete icon tapped on Material', (
      tester,
    ) async {
      bool deleteTapped = false;

      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onDelete: () => deleteTapped = true,
          platform: TargetPlatform.android,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(deleteTapped, true);
    });

    testWidgets('should show edit icon for admin on Material', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onEdit: () {},
          platform: TargetPlatform.android,
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should show edit icon for admin on Apple', (tester) async {
      await tester.pumpWidget(
        buildWidget(isAdmin: true, onEdit: () {}, platform: TargetPlatform.iOS),
      );

      expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    });

    testWidgets('should show copy icon for admin on Material', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onDuplicate: () {},
          platform: TargetPlatform.android,
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should show copy icon for admin on Apple', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          isAdmin: true,
          onDuplicate: () {},
          platform: TargetPlatform.iOS,
        ),
      );

      expect(find.byIcon(CupertinoIcons.doc_on_doc), findsOneWidget);
    });

    testWidgets('should not show action icons for regular users', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(isAdmin: false));

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.copy), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('should display draft status', (tester) async {
      const draftMenu = Menu(
        id: 2,
        name: 'Draft Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      await tester.pumpWidget(buildWidget(menu: draftMenu, isAdmin: true));

      expect(find.text('DRAFT'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should display archived status', (tester) async {
      const archivedMenu = Menu(
        id: 3,
        name: 'Archived Menu',
        status: Status.archived,
        version: '1.0.0',
      );

      await tester.pumpWidget(buildWidget(menu: archivedMenu, isAdmin: true));

      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('should handle menu without dates gracefully', (tester) async {
      const menuWithoutDates = Menu(
        id: 4,
        name: 'Menu Without Dates',
        status: Status.published,
        version: '1.0.0',
      );

      await tester.pumpWidget(
        buildWidget(menu: menuWithoutDates, isAdmin: false),
      );

      expect(find.text('Menu Without Dates'), findsOneWidget);
    });

    testWidgets('should be wrapped in Card widget', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have left accent strip with status color', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      // Find the 4px wide left accent container
      final accentFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 4,
      );
      expect(accentFinder, findsOneWidget);
    });

    testWidgets('uses InkWell on Material platform', (tester) async {
      await tester.pumpWidget(buildWidget(platform: TargetPlatform.android));

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('uses CupertinoButton on Apple platform', (tester) async {
      await tester.pumpWidget(buildWidget(platform: TargetPlatform.iOS));

      // CupertinoButton wrapping the card for tap
      expect(
        find.ancestor(
          of: find.byType(Card),
          matching: find.byType(CupertinoButton),
        ),
        findsOneWidget,
      );
    });
  });
}
