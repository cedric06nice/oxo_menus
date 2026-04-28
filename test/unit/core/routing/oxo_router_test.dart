import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OxoRouter — platform integration', () {
    OxoRouter buildRouter() => OxoRouter(
      initialLocation: '/a',
      routes: <OxoRoute>[
        OxoRoute(
          pattern: '/a',
          builder: (_, _) => const Scaffold(body: Text('A')),
        ),
        OxoRoute(
          pattern: '/b',
          builder: (_, _) => const Scaffold(body: Text('B')),
        ),
      ],
    );

    test('exposes a PlatformRouteInformationProvider so the engine learns '
        'about URL changes', () {
      final router = buildRouter();
      addTearDown(router.dispose);

      expect(router.routeInformationProvider, isA<RouteInformationProvider>());
      expect(
        router.routeInformationProvider,
        isA<PlatformRouteInformationProvider>(),
      );
    });

    test('exposes a RootBackButtonDispatcher so the OS back button reaches '
        'the delegate', () {
      final router = buildRouter();
      addTearDown(router.dispose);

      expect(router.backButtonDispatcher, isA<RootBackButtonDispatcher>());
    });

    test('parser.restoreRouteInformation round-trips the delegate location '
        'so MaterialApp.router can publish it to the engine', () {
      final router = buildRouter();
      addTearDown(router.dispose);

      router.go('/b');

      final config = router.routerDelegate.currentConfiguration!;
      final restored = router.routeInformationParser.restoreRouteInformation(
        config,
      );

      expect(restored, isNotNull);
      expect(restored!.uri.toString(), '/b');
    });

    test('go(...) notifies listeners so MaterialApp.router rebuilds and '
        'reports new route information', () {
      final router = buildRouter();
      addTearDown(router.dispose);
      var notifications = 0;
      router.routerDelegate.addListener(() => notifications++);

      router.go('/b');

      expect(notifications, 1);
      expect(router.currentLocation, '/b');
    });

    test("seeds the provider with platform defaultRouteName when it's a real "
        'path so web deep-links open the right screen', () {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      final previous = binding.platformDispatcher.defaultRouteName;
      binding.platformDispatcher.defaultRouteNameTestValue = '/b';
      addTearDown(
        () => binding.platformDispatcher.defaultRouteNameTestValue = previous,
      );

      final router = buildRouter();
      addTearDown(router.dispose);

      expect(router.routeInformationProvider!.value.uri.toString(), '/b');
    });

    test(
      "falls back to initialLocation when platform defaultRouteName is the "
      "'/' placeholder so native/tests don't crash on an unmatched route",
      () {
        final binding = TestWidgetsFlutterBinding.ensureInitialized();
        final previous = binding.platformDispatcher.defaultRouteName;
        binding.platformDispatcher.defaultRouteNameTestValue = '/';
        addTearDown(
          () => binding.platformDispatcher.defaultRouteNameTestValue = previous,
        );

        final router = buildRouter();
        addTearDown(router.dispose);

        expect(router.routeInformationProvider!.value.uri.toString(), '/a');
      },
    );
  });
}
