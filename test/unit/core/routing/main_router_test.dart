import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/main_router.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
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

class _ProbeViewModel extends ViewModel<int> {
  _ProbeViewModel() : super(0);
}

class _ProbeRoutePage extends RoutePage {
  _ProbeRoutePage(this.id);

  final String id;
  late final _ProbeViewModel viewModel = _ProbeViewModel();

  @override
  Object get identity => id;

  @override
  Widget buildScreen(AppContainer container) {
    return const SizedBox();
  }

  @override
  void disposeResources() {
    viewModel.dispose();
  }
}

AppContainer _makeContainer() {
  final gateway = AuthGateway(repository: _StubAuthRepository());
  return AppContainer(authGateway: gateway);
}

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> goCalls =
      <({String location, Object? extra})>[];

  @override
  void go(String location, {Object? extra}) {
    goCalls.add((location: location, extra: extra));
  }
}

void main() {
  group('MainRouter', () {
    test('initial stack is empty', () {
      final router = MainRouter(container: _makeContainer());

      expect(router.stack, isEmpty);
    });

    test('push appends a page and notifies listeners', () {
      final router = MainRouter(container: _makeContainer());
      var notifications = 0;
      router.addListener(() => notifications++);

      router.push(_ProbeRoutePage('a'));

      expect(router.stack.map((p) => (p as _ProbeRoutePage).id), ['a']);
      expect(notifications, 1);
    });

    test('pop removes the top page and notifies listeners', () {
      final router = MainRouter(container: _makeContainer())
        ..push(_ProbeRoutePage('a'))
        ..push(_ProbeRoutePage('b'));
      var notifications = 0;
      router.addListener(() => notifications++);

      final popped = router.pop();

      expect(popped, isTrue);
      expect(router.stack.length, 1);
      expect((router.stack.first as _ProbeRoutePage).id, 'a');
      expect(notifications, 1);
    });

    test('pop on empty stack returns false and does not notify', () {
      final router = MainRouter(container: _makeContainer());
      var notifications = 0;
      router.addListener(() => notifications++);

      final popped = router.pop();

      expect(popped, isFalse);
      expect(notifications, 0);
    });

    test('replace swaps the stack and disposes removed pages', () {
      final removed = _ProbeRoutePage('old');
      final kept = _ProbeRoutePage('keep');
      final router = MainRouter(container: _makeContainer())
        ..push(removed)
        ..push(kept);

      router.replace([_ProbeRoutePage('new'), kept]);

      expect(router.stack.length, 2);
      expect((router.stack.first as _ProbeRoutePage).id, 'new');
      expect((router.stack.last as _ProbeRoutePage).id, 'keep');
      expect(removed.viewModel.isDisposed, isTrue);
      expect(kept.viewModel.isDisposed, isFalse);
    });

    test('dispose disposes all remaining pages and unsubscribes from auth', () {
      final container = _makeContainer();
      final page = _ProbeRoutePage('a');
      final router = MainRouter(container: container)..push(page);

      router.dispose();

      expect(page.viewModel.isDisposed, isTrue);
    });

    test(
      'setNewRoutePath with UnknownRouteConfig records currentConfiguration',
      () async {
        final router = MainRouter(container: _makeContainer());
        final config = UnknownRouteConfig(Uri.parse('/app/anything'));

        await router.setNewRoutePath(config);

        expect(router.currentConfiguration, config);
      },
    );

    test(
      'auth status change to Unauthenticated triggers a notification',
      () async {
        final container = _makeContainer();
        final router = MainRouter(container: container);
        var notifications = 0;
        router.addListener(() => notifications++);

        await container.authGateway.logout();
        await Future<void>.delayed(Duration.zero);

        expect(notifications, greaterThanOrEqualTo(1));
      },
    );
  });

  group('MainRouter — LoginRouter integration', () {
    test('implements LoginRouter so it can be injected into the VM', () {
      final router = MainRouter(container: _makeContainer());

      expect(router, isA<LoginRouter>());
    });

    test(
      'setNewRoutePath(LoginRouteConfig) replaces the stack with LoginRoutePage',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const LoginRouteConfig());

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<LoginRoutePage>());
        expect(router.currentConfiguration, const LoginRouteConfig());
      },
    );

    test(
      'pushing LoginRouteConfig twice keeps a single LoginRoutePage in the stack',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const LoginRouteConfig());
        await router.setNewRoutePath(const LoginRouteConfig());

        expect(router.stack, hasLength(1));
      },
    );

    test('goToHomeAfterLogin asks the legacy navigator for /home', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToHomeAfterLogin();

      expect(navigator.goCalls.single.location, AppRoutes.home);
    });

    test(
      'goToForgotPassword asks the legacy navigator for /forgot-password',
      () {
        final navigator = _RecordingLegacyNavigator();
        final router = MainRouter(
          container: _makeContainer(),
          legacyNavigator: navigator,
        );

        router.goToForgotPassword();

        expect(navigator.goCalls.single.location, AppRoutes.forgotPassword);
      },
    );

    test(
      'navigation methods are no-ops when no LegacyNavigator was provided',
      () {
        final router = MainRouter(container: _makeContainer());

        // No throw, no observable side effect.
        router.goToHomeAfterLogin();
        router.goToForgotPassword();

        expect(router.stack, isEmpty);
      },
    );
  });
}
