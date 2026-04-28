import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/shared/presentation/widgets/app_shell.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

void main() {
  Widget buildTestApp({required bool isOffline}) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(
            navigator: GoRouterRouteNavigator(context),
            currentLocation: state.matchedLocation,
            isAdmin: false,
            isOffline: isOffline,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const Text('Home'),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('AppShell offline banner', () {
    testWidgets('shows OfflineBanner when offline', (tester) async {
      await tester.pumpWidget(buildTestApp(isOffline: true));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('does not show OfflineBanner when online', (tester) async {
      await tester.pumpWidget(buildTestApp(isOffline: false));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('does not show OfflineBanner when loading', (tester) async {
      await tester.pumpWidget(buildTestApp(isOffline: false));
      await tester.pump();

      expect(find.byType(OfflineBanner), findsNothing);
    });
  });
}
