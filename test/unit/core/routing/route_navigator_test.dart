import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';

void main() {
  group('OxoRouterRouteNavigator', () {
    Future<({OxoRouter router, BuildContext context})> pumpRouter(
      WidgetTester tester,
    ) async {
      late BuildContext capturedContext;
      final router = OxoRouter(
        initialLocation: '/a',
        routes: <OxoRoute>[
          OxoRoute(
            pattern: '/a',
            builder: (context, _) {
              capturedContext = context;
              return const Scaffold(body: Text('A'));
            },
          ),
          OxoRoute(
            pattern: '/b',
            builder: (_, _) => const Scaffold(body: Text('B')),
          ),
          OxoRoute(
            pattern: '/c',
            builder: (_, _) => const Scaffold(body: Text('C')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        OxoRouterScope(
          router: router,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      return (router: router, context: capturedContext);
    }

    testWidgets('go replaces the top of the navigation stack', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = OxoRouterRouteNavigator(pumped.context);

      navigator.go('/b');
      await tester.pumpAndSettle();

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('push pushes a new route on top of the stack', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = OxoRouterRouteNavigator(pumped.context);

      navigator.push('/c');
      await tester.pumpAndSettle();

      expect(find.text('C'), findsOneWidget);

      // Pop to confirm /a is still beneath /c on the stack — proves push
      // (vs go) was used.
      pumped.router.pop();
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('push preserves extra on the route entry', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = OxoRouterRouteNavigator(pumped.context);

      navigator.push('/b', extra: const _Payload(42));
      await tester.pumpAndSettle();

      final stack = pumped.router.routerDelegate.currentConfiguration!.stack;
      expect(stack.last.location, '/b');
      expect(stack.last.extra, const _Payload(42));
    });
  });
}

class _Payload {
  const _Payload(this.value);
  final int value;

  @override
  bool operator ==(Object other) => other is _Payload && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
