import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_route_page.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async => const Success(null);

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

class _NoopHomeRouter implements HomeRouter {
  @override
  void goToMenus() {}

  @override
  void goToSettings() {}

  @override
  void goToAdminTemplates() {}

  @override
  void goToAdminTemplateCreate() {}

  @override
  void goToAdminExportableMenus() {}
}

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

AppContainer _makeContainer() {
  final gateway = AuthGateway(repository: _StubAuthRepository());
  final connectivityGateway = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('HomeRoutePage', () {
    test('identity is the constant `home` (stack diffing)', () {
      final page = HomeRoutePage(router: _NoopHomeRouter());

      expect(page.identity, 'home');
    });

    testWidgets('buildScreen returns a HomeScreen with a live ViewModel', (
      tester,
    ) async {
      final page = HomeRoutePage(router: _NoopHomeRouter());
      final container = _makeContainer();

      await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = HomeRoutePage(router: _NoopHomeRouter());
      final container = _makeContainer();

      final first = page.buildScreen(container) as HomeScreen;
      final second = page.buildScreen(container) as HomeScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = HomeRoutePage(router: _NoopHomeRouter());
      final container = _makeContainer();
      final screen = page.buildScreen(container) as HomeScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('uses the injected clock when provided', () {
      var ticks = 0;
      DateTime clock() {
        ticks++;
        return DateTime(2026, 4, 27, 9);
      }

      final page = HomeRoutePage(router: _NoopHomeRouter(), clock: clock);
      final container = _makeContainer();

      page.buildScreen(container);

      expect(ticks, 1);
    });
  });
}
