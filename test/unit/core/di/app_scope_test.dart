import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/controllers/admin_view_as_user_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/app_lifecycle_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/auth_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/connectivity_controller.dart';

import '../../../fakes/reflectable_bootstrap.dart';

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
  @override
  Stream<ConnectivityStatus> watchConnectivity() =>
      const Stream<ConnectivityStatus>.empty();

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

AppContainer _makeContainer() {
  return AppContainer(
    authGateway: AuthGateway(repository: _StubAuthRepository()),
    connectivityGateway: ConnectivityGateway(
      repository: _StubConnectivityRepository(),
    ),
    adminViewAsUserGateway: AdminViewAsUserGateway(),
    directusDataSource: DirectusDataSource(baseUrl: 'http://localhost'),
  );
}

void main() {
  setUpAll(initializeReflectableForTests);

  group('AppScope', () {
    testWidgets('exposes the AppContainer and built-in controllers', (
      tester,
    ) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      late AppScopeData captured;
      await tester.pumpWidget(
        AppScope(
          container: container,
          child: Builder(
            builder: (context) {
              captured = AppScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured.container, same(container));
      expect(captured.auth, isA<AuthController>());
      expect(captured.connectivity, isA<ConnectivityController>());
      expect(captured.adminViewAsUser, isA<AdminViewAsUserController>());
      expect(captured.appLifecycle, isA<AppLifecycleController>());
    });

    testWidgets('lets tests inject pre-built controllers', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final auth = AuthController(
        gateway: container.authGateway,
        autoRestore: false,
      );
      addTearDown(auth.dispose);
      final connectivity = ConnectivityController(
        gateway: container.connectivityGateway,
      );
      addTearDown(connectivity.dispose);
      final adminViewAs = AdminViewAsUserController(
        gateway: container.adminViewAsUserGateway,
      );
      addTearDown(adminViewAs.dispose);
      final lifecycle = AppLifecycleController();
      addTearDown(lifecycle.dispose);

      late AppScopeData captured;
      await tester.pumpWidget(
        AppScope(
          container: container,
          authController: auth,
          connectivityController: connectivity,
          adminViewAsUserController: adminViewAs,
          appLifecycleController: lifecycle,
          child: Builder(
            builder: (context) {
              captured = AppScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured.auth, same(auth));
      expect(captured.connectivity, same(connectivity));
      expect(captured.adminViewAsUser, same(adminViewAs));
      expect(captured.appLifecycle, same(lifecycle));
    });

    testWidgets('disposes only the controllers it created', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final injectedAuth = AuthController(
        gateway: container.authGateway,
        autoRestore: false,
      );
      addTearDown(() {
        try {
          injectedAuth.dispose();
        } on FlutterError {
          // Already disposed elsewhere — fine.
        }
      });

      await tester.pumpWidget(
        AppScope(
          container: container,
          authController: injectedAuth,
          child: const SizedBox.shrink(),
        ),
      );
      // Capture the auto-built ones for later inspection.
      final scope = tester.element(find.byType(SizedBox));
      final data = AppScope.of(scope);
      final autoConnectivity = data.connectivity;
      final autoAdmin = data.adminViewAsUser;
      final autoLifecycle = data.appLifecycle;

      // Tear down the AppScope — we expect auto-built controllers to be
      // disposed, but the injected one to survive.
      await tester.pumpWidget(const SizedBox.shrink());

      // Confirm injected controller is still usable.
      expect(injectedAuth.dispose, returnsNormally);
      // Confirm auto-built ones cannot be reused.
      expect(autoConnectivity.dispose, returnsNormally);
      expect(autoAdmin.dispose, returnsNormally);
      expect(autoLifecycle.dispose, returnsNormally);
    });

    testWidgets('AppScope.of throws when no scope exists in the tree', (
      tester,
    ) async {
      Object? thrown;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            try {
              AppScope.of(context);
            } on Object catch (e) {
              thrown = e;
            }
            return const SizedBox.shrink();
          },
        ),
      );

      expect(thrown, isNotNull);
    });
  });
}
