import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/settings/settings_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';

void main() {
  const adminUser = User(
    id: '1',
    email: 'admin@example.com',
    firstName: 'Admin',
    lastName: 'User',
    role: UserRole.admin,
  );

  const regularUser = User(
    id: '2',
    email: 'user@example.com',
    firstName: 'Regular',
    lastName: 'User',
    role: UserRole.user,
  );

  Widget createWidgetUnderTest({required User user}) {
    return ProviderScope(
      overrides: [currentUserProvider.overrideWithValue(user)],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('SettingsPage debug toggle', () {
    testWidgets('should show debug section for admin user', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(user: adminUser));
      await tester.pumpAndSettle();

      expect(find.text('Debug'), findsOneWidget);
      expect(find.text('Show as non-admin user'), findsOneWidget);
    });

    testWidgets('should not show debug section for regular user', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(user: regularUser));
      await tester.pumpAndSettle();

      expect(find.text('Debug'), findsNothing);
      expect(find.text('Show as non-admin user'), findsNothing);
    });

    testWidgets('switch should be off by default for admin user', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(user: adminUser));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchWidget.value, false);
    });

    testWidgets('tapping switch should toggle adminViewAsUserProvider', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(user: adminUser));
      await tester.pumpAndSettle();

      // Scroll to make SwitchListTile visible
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Tap the switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Switch should now be on
      final switchWidget = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchWidget.value, true);
    });
  });
}
