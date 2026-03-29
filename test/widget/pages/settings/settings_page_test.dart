import 'package:flutter/cupertino.dart';
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

  group('SettingsPage logout confirmation', () {
    testWidgets('should show CupertinoAlertDialog on iOS', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [currentUserProvider.overrideWithValue(adminUser)],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the logout tile
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    });

    testWidgets('should show AlertDialog on Android', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [currentUserProvider.overrideWithValue(adminUser)],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    });
  });

  group('SettingsPage reset password', () {
    testWidgets('should show reset password tile', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(user: adminUser));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('should show reset password tile for regular user', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(user: regularUser));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
    });
  });

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
