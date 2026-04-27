import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/app_shell.dart';

void main() {
  const adminUser = User(
    id: '1',
    email: 'admin@test.com',
    role: UserRole.admin,
    firstName: 'Admin',
  );

  const regularUser = User(
    id: '2',
    email: 'user@test.com',
    role: UserRole.user,
    firstName: 'User',
  );

  Widget buildTestApp({
    User? user,
    bool isAdmin = false,
    String initialLocation = '/home',
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const Center(child: Text('Home Content')),
            ),
            GoRoute(
              path: '/menus',
              builder: (_, _) => const Center(child: Text('Menus Content')),
            ),
            GoRoute(
              path: '/admin/templates',
              builder: (_, _) => const Center(child: Text('Templates Content')),
            ),
            GoRoute(
              path: '/admin/sizes',
              builder: (_, _) => const Center(child: Text('Sizes Content')),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, _) => const Center(child: Text('Settings Content')),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(user),
        isAdminProvider.overrideWithValue(isAdmin),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  void setScreenSize(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
  }

  group('AppShell', () {
    group('mobile layout (<600px)', () {
      testWidgets('shows NavigationBar on mobile', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('shows 3 destinations for regular user', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        // Home, Menus, Settings
        expect(find.byType(NavigationDestination), findsNWidgets(3));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Menus'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('shows 5 destinations for admin', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: adminUser, isAdmin: true));
        await tester.pumpAndSettle();

        // Home, Menus, Templates, Sizes, Settings
        expect(find.byType(NavigationDestination), findsNWidgets(5));
        expect(find.text('Templates'), findsOneWidget);
        expect(find.text('Sizes'), findsOneWidget);
      });

      testWidgets('displays child content', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        expect(find.text('Home Content'), findsOneWidget);
      });

      testWidgets('navigates on destination tap', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menus'));
        await tester.pumpAndSettle();

        expect(find.text('Menus Content'), findsOneWidget);
      });
    });

    group('tablet layout (600-1200px)', () {
      testWidgets('shows NavigationRail on tablet', (tester) async {
        setScreenSize(tester, 800, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });
    });

    group('desktop layout (>1200px)', () {
      testWidgets('shows NavigationDrawer on desktop', (tester) async {
        setScreenSize(tester, 1400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(buildTestApp(user: regularUser));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationDrawer), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
      });
    });

    group('route-to-index mapping', () {
      testWidgets('selects Menus when at /menus route', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(
          buildTestApp(user: regularUser, initialLocation: '/menus'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Menus Content'), findsOneWidget);
      });

      testWidgets('selects Settings when at /settings route', (tester) async {
        setScreenSize(tester, 400, 800);
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(
          buildTestApp(user: regularUser, initialLocation: '/settings'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Settings Content'), findsOneWidget);
      });
    });
  });
}
