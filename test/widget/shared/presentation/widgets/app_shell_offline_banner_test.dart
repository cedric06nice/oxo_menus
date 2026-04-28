import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/shared/presentation/widgets/app_shell.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

void main() {
  Widget buildTestApp({required bool isOffline}) {
    final router = OxoRouter(
      initialLocation: '/home',
      shellBuilder: (context, currentLocation, child) => AppShell(
        navigator: OxoRouterRouteNavigator(context),
        currentLocation: currentLocation,
        isAdmin: false,
        isOffline: isOffline,
        child: child,
      ),
      routes: <OxoRoute>[
        OxoRoute(
          pattern: '/home',
          inShell: true,
          builder: (_, _) => const Text('Home'),
        ),
      ],
    );

    return OxoRouterScope(
      router: router,
      child: MaterialApp.router(routerConfig: router),
    );
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
