import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';

void main() {
  group('GoRouterRouteNavigator', () {
    Future<({GoRouter router, BuildContext context})> pumpRouter(
      WidgetTester tester,
    ) async {
      late BuildContext capturedContext;
      final router = GoRouter(
        initialLocation: '/a',
        routes: [
          GoRoute(
            path: '/a',
            builder: (context, _) {
              capturedContext = context;
              return const Scaffold(body: Text('A'));
            },
          ),
          GoRoute(
            path: '/b',
            builder: (_, _) => const Scaffold(body: Text('B')),
          ),
          GoRoute(
            path: '/c',
            builder: (_, _) => const Scaffold(body: Text('C')),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return (router: router, context: capturedContext);
    }

    testWidgets('go replaces the top of the navigation stack', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = GoRouterRouteNavigator(pumped.context);

      navigator.go('/b');
      await tester.pumpAndSettle();

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('push pushes a new route on top of the stack', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = GoRouterRouteNavigator(pumped.context);

      navigator.push('/c');
      await tester.pumpAndSettle();

      expect(find.text('C'), findsOneWidget);

      // Pop to confirm /a is still beneath /c on the stack — proves push
      // (vs go) was used.
      pumped.router.pop();
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('push forwards extra to go_router', (tester) async {
      final pumped = await pumpRouter(tester);
      final navigator = GoRouterRouteNavigator(pumped.context);

      navigator.push('/b', extra: const _Payload(42));
      await tester.pumpAndSettle();

      final state = GoRouterState.of(tester.element(find.text('B')));
      expect(state.extra, const _Payload(42));
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
