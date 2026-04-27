import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

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
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

AppContainer _makeContainer() {
  final authGateway = AuthGateway(repository: _StubAuthRepository());
  final connectivityGateway = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    directusDataSource: DirectusDataSource(baseUrl: 'http://localhost'),
  );
}

void main() {
  setUpAll(initializeReflectableForTests);

  group('AppContainer', () {
    test('exposes the AuthGateway it was constructed with', () {
      final gateway = AuthGateway(repository: _StubAuthRepository());
      final connectivity = ConnectivityGateway(
        repository: _StubConnectivityRepository(),
      );
      final container = AppContainer(
        authGateway: gateway,
        connectivityGateway: connectivity,
        directusDataSource: DirectusDataSource(baseUrl: 'http://localhost'),
      );

      expect(container.authGateway, same(gateway));
      expect(container.connectivityGateway, same(connectivity));
    });

    test('exposes the DirectusDataSource it was constructed with', () {
      final ds = DirectusDataSource(baseUrl: 'http://localhost');
      final container = AppContainer(
        authGateway: AuthGateway(repository: _StubAuthRepository()),
        connectivityGateway: ConnectivityGateway(
          repository: _StubConnectivityRepository(),
        ),
        directusDataSource: ds,
      );

      expect(container.directusDataSource, same(ds));
    });

    test('dispose tears down owned gateways', () {
      final container = _makeContainer();

      container.dispose();

      expect(container.authGateway.isDisposed, isTrue);
      expect(container.connectivityGateway.isDisposed, isTrue);
      expect(container.isDisposed, isTrue);
    });

    test('calling dispose twice is safe', () {
      final container = _makeContainer();

      container.dispose();

      expect(() => container.dispose(), returnsNormally);
    });
  });
}
