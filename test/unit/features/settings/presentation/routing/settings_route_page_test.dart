import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_route_page.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
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

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

class _NoopRouter implements SettingsRouter {
  @override
  void goBack() {}
}

class _FakeAppVersionGateway implements AppVersionGateway {
  @override
  Future<String> read() async => '1.0.0';
}

AppContainer _makeContainer() {
  return AppContainer(
    authGateway: AuthGateway(repository: _StubAuthRepository()),
    connectivityGateway: ConnectivityGateway(
      repository: _StubConnectivityRepository(),
    ),
    appVersionGateway: _FakeAppVersionGateway(),
    adminViewAsUserGateway: AdminViewAsUserGateway(),
  );
}

SettingsViewModel _testBuilder(AppContainer container, SettingsRouter router) {
  return SettingsViewModel(
    getOverview: GetSettingsOverviewUseCase(
      authGateway: container.authGateway,
      adminViewAsUserGateway: container.adminViewAsUserGateway,
    ),
    getAppVersion: GetAppVersionUseCase(gateway: container.appVersionGateway),
    requestPasswordReset: RequestPasswordResetUseCase(
      authGateway: container.authGateway,
    ),
    logout: LogoutUseCase(authGateway: container.authGateway),
    setAdminViewAsUser: SetAdminViewAsUserUseCase(
      gateway: container.adminViewAsUserGateway,
    ),
    adminViewAsUserGateway: container.adminViewAsUserGateway,
    router: router,
  );
}

void main() {
  group('SettingsRoutePage', () {
    test('identity is the constant `settings`', () {
      final page = SettingsRoutePage(router: _NoopRouter());

      expect(page.identity, 'settings');
    });

    testWidgets('buildScreen returns a SettingsScreen with a live ViewModel', (
      tester,
    ) async {
      final page = SettingsRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testBuilder,
      );
      final container = _makeContainer();

      await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = SettingsRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as SettingsScreen;
      final second = page.buildScreen(container) as SettingsScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = SettingsRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as SettingsScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked once with the container and router', () {
      var calls = 0;
      AppContainer? receivedContainer;
      SettingsRouter? receivedRouter;
      final router = _NoopRouter();

      SettingsViewModel customBuilder(AppContainer c, SettingsRouter r) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        return _testBuilder(c, r);
      }

      final page = SettingsRoutePage(
        router: router,
        viewModelBuilder: customBuilder,
      );
      final container = _makeContainer();

      page.buildScreen(container);
      page.buildScreen(container);

      expect(calls, 1);
      expect(receivedContainer, same(container));
      expect(receivedRouter, same(router));
    });
  });
}
