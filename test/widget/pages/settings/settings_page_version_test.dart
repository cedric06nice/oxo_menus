import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/settings/settings_page.dart';
import 'package:oxo_menus/presentation/providers/app_version_provider.dart';
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

  Widget createWidgetUnderTest({required User user, required String version}) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(user),
        appVersionProvider.overrideWith((_) async => version),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('SettingsPage version display', () {
    testWidgets('should show version with build number', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: regularUser, version: '1.1.2 (42)'),
      );
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version 1.1.2 (42)'), findsOneWidget);
    });

    testWidgets('should show version for admin user', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, version: '1.0.0'),
      );
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });
  });
}
