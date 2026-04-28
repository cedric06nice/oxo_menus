import 'dart:async';

import 'package:flutter/widgets.dart';
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
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/controllers/auth_controller.dart';

/// Wraps [child] in an [AppScope] backed by a hand-rolled [AppContainer].
///
/// Used by widget tests that need to read AppContainer.directusBaseUrl /
/// directusAccessToken via `AppScope.of(context)` without standing up a real
/// `DirectusDataSource`. The scope auto-builds the four controllers; tests
/// that need finer control should construct their own `AppScope` directly.
Widget wrapInTestAppScope({
  required Widget child,
  String directusBaseUrl = 'http://localhost:8055',
  String? directusAccessToken = 'test-token',
}) {
  final container = AppContainer(
    authGateway: AuthGateway(repository: _StubAuthRepository()),
    connectivityGateway: ConnectivityGateway(
      repository: _StubConnectivityRepository(),
    ),
    adminViewAsUserGateway: AdminViewAsUserGateway(),
    directusBaseUrl: directusBaseUrl,
    directusAccessTokenOverride: directusAccessToken,
  );
  // Disable auto-restore so the controller doesn't fire a tryRestoreSession
  // microtask during the test.
  final auth = AuthController(
    gateway: container.authGateway,
    autoRestore: false,
  );
  addTearDown(() {
    auth.dispose();
    container.dispose();
  });
  return AppScope(container: container, authController: auth, child: child);
}

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
