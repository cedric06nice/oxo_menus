import 'dart:async';

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
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
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
      expect(container.adminViewAsUserGateway.isDisposed, isTrue);
      expect(container.isDisposed, isTrue);
    });

    test('calling dispose twice is safe', () {
      final container = _makeContainer();

      container.dispose();

      expect(() => container.dispose(), returnsNormally);
    });

    test(
      'exposes appVersionGateway and adminViewAsUserGateway when injected',
      () {
        final version = _FakeAppVersionGateway();
        final viewAs = AdminViewAsUserGateway();
        final container = AppContainer(
          authGateway: AuthGateway(repository: _StubAuthRepository()),
          connectivityGateway: ConnectivityGateway(
            repository: _StubConnectivityRepository(),
          ),
          appVersionGateway: version,
          adminViewAsUserGateway: viewAs,
        );

        expect(container.appVersionGateway, same(version));
        expect(container.adminViewAsUserGateway, same(viewAs));
      },
    );

    test('defaults appVersionGateway/adminViewAsUserGateway when omitted', () {
      final container = AppContainer(
        authGateway: AuthGateway(repository: _StubAuthRepository()),
        connectivityGateway: ConnectivityGateway(
          repository: _StubConnectivityRepository(),
        ),
      );

      expect(container.appVersionGateway, isA<PackageInfoAppVersionGateway>());
      expect(container.adminViewAsUserGateway, isA<AdminViewAsUserGateway>());
    });

    group('directus credentials', () {
      test('directusBaseUrl returns the value injected at construction', () {
        final container = AppContainer(
          authGateway: AuthGateway(repository: _StubAuthRepository()),
          connectivityGateway: ConnectivityGateway(
            repository: _StubConnectivityRepository(),
          ),
          directusDataSource: DirectusDataSource(baseUrl: 'http://localhost'),
          directusBaseUrl: 'https://example.com',
        );

        expect(container.directusBaseUrl, 'https://example.com');
      });

      test(
        'directusAccessToken delegates to DirectusDataSource.currentAccessToken',
        () {
          final ds = DirectusDataSource(baseUrl: 'http://localhost');
          final container = AppContainer(
            authGateway: AuthGateway(repository: _StubAuthRepository()),
            connectivityGateway: ConnectivityGateway(
              repository: _StubConnectivityRepository(),
            ),
            directusDataSource: ds,
          );

          expect(container.directusAccessToken, ds.currentAccessToken);
        },
      );
    });

    group('widgetRegistry', () {
      test('exposes a PresentableWidgetRegistry with all 8 widget types', () {
        final container = _makeContainer();

        final registry = container.widgetRegistry;

        expect(registry, isA<PresentableWidgetRegistry>());
        expect(registry.count, 8);
        expect(
          registry.registeredTypes,
          containsAll(<String>[
            'dish',
            'dish_to_share',
            'image',
            'section',
            'set_menu_dish',
            'set_menu_title',
            'text',
            'wine',
          ]),
        );
      });

      test('returns the same instance on repeated access (lazy singleton)', () {
        final container = _makeContainer();

        final first = container.widgetRegistry;
        final second = container.widgetRegistry;

        expect(identical(first, second), isTrue);
      });
    });
  });
}

class _FakeAppVersionGateway implements AppVersionGateway {
  @override
  Future<String> read() async => '1.0.0';
}
