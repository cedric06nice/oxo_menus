import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/app_shell.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_banner.dart';

void main() {
  Widget buildTestApp({
    required Stream<ConnectivityStatus> connectivityStream,
  }) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const Text('Home'),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        isAdminProvider.overrideWithValue(false),
        connectivityProvider.overrideWith((_) => connectivityStream),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('AppShell offline banner', () {
    testWidgets('shows OfflineBanner when offline', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.offline),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('does not show OfflineBanner when online', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.online),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('does not show OfflineBanner when loading', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: const Stream<ConnectivityStatus>.empty(),
        ),
      );
      await tester.pump();

      expect(find.byType(OfflineBanner), findsNothing);
    });
  });
}
