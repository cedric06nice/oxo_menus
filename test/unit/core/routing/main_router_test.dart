import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/main_router.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_route_page.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_route_page.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_page.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_route_page.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';
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

    test('goToHomeAfterLogin replaces the stack with a HomeRoutePage', () {
      final router = MainRouter(container: _makeContainer())
        ..push(LoginRoutePage(router: MainRouter(container: _makeContainer())));

      router.goToHomeAfterLogin();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<HomeRoutePage>());
    });

    test(
      'goToHomeAfterLogin disposes the previous LoginRoutePage on the stack',
      () {
        final router = MainRouter(container: _makeContainer());
        final loginPage = LoginRoutePage(
          router: MainRouter(container: _makeContainer()),
        );
        router.push(loginPage);
        // Build the screen so the VM is constructed.
        loginPage.buildScreen(router.container);
        final loginVm =
            (loginPage.buildScreen(router.container) as dynamic).viewModel;

        router.goToHomeAfterLogin();

        expect(loginVm.isDisposed, isTrue);
      },
    );

    test('goToHomeAfterLogin does not require a LegacyNavigator', () {
      final router = MainRouter(container: _makeContainer());

      router.goToHomeAfterLogin();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<HomeRoutePage>());
    });
  });

  group('MainRouter — ForgotPasswordRouter integration', () {
    test(
      'implements ForgotPasswordRouter so it can be injected into the VM',
      () {
        final router = MainRouter(container: _makeContainer());

        expect(router, isA<ForgotPasswordRouter>());
      },
    );

    test('setNewRoutePath(ForgotPasswordRouteConfig) replaces the stack with '
        'ForgotPasswordRoutePage', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const ForgotPasswordRouteConfig());

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<ForgotPasswordRoutePage>());
      expect(router.currentConfiguration, const ForgotPasswordRouteConfig());
    });

    test('pushing ForgotPasswordRouteConfig twice keeps a single page in the '
        'stack', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const ForgotPasswordRouteConfig());
      await router.setNewRoutePath(const ForgotPasswordRouteConfig());

      expect(router.stack, hasLength(1));
    });

    test(
      'goToForgotPassword pushes a ForgotPasswordRoutePage onto the stack',
      () async {
        final router = MainRouter(container: _makeContainer())
          ..push(
            LoginRoutePage(router: MainRouter(container: _makeContainer())),
          );

        router.goToForgotPassword();

        expect(router.stack, hasLength(2));
        expect(router.stack.last, isA<ForgotPasswordRoutePage>());
      },
    );

    test(
      'goToForgotPassword does not stack a second copy when already on top',
      () async {
        final router = MainRouter(container: _makeContainer());
        await router.setNewRoutePath(const ForgotPasswordRouteConfig());

        router.goToForgotPassword();

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<ForgotPasswordRoutePage>());
      },
    );

    test('goToForgotPassword does not require a LegacyNavigator', () {
      final router = MainRouter(container: _makeContainer());

      router.goToForgotPassword();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<ForgotPasswordRoutePage>());
    });

    test(
      'goBackToLogin pops back to an existing LoginRoutePage on the stack',
      () async {
        final router = MainRouter(container: _makeContainer());
        await router.setNewRoutePath(const LoginRouteConfig());
        router.goToForgotPassword();

        router.goBackToLogin();

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<LoginRoutePage>());
      },
    );

    test('goBackToLogin disposes the popped forgot-password page', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const LoginRouteConfig());
      router.goToForgotPassword();
      final forgotPage = router.stack.last as ForgotPasswordRoutePage;
      // Build the screen so the VM exists.
      forgotPage.buildScreen(router.container);
      final vm =
          (forgotPage.buildScreen(router.container) as dynamic).viewModel;

      router.goBackToLogin();

      expect(vm.isDisposed, isTrue);
    });

    test('goBackToLogin replaces the stack with a LoginRoutePage when '
        'forgot-password was deep-linked', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const ForgotPasswordRouteConfig());

      router.goBackToLogin();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<LoginRoutePage>());
    });
  });

  group('MainRouter — HomeRouter integration', () {
    test('implements HomeRouter so it can be injected into the VM', () {
      final router = MainRouter(container: _makeContainer());

      expect(router, isA<HomeRouter>());
    });

    test(
      'setNewRoutePath(HomeRouteConfig) replaces the stack with HomeRoutePage',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const HomeRouteConfig());

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<HomeRoutePage>());
        expect(router.currentConfiguration, const HomeRouteConfig());
      },
    );

    test(
      'pushing HomeRouteConfig twice keeps a single HomeRoutePage on the stack',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const HomeRouteConfig());
        await router.setNewRoutePath(const HomeRouteConfig());

        expect(router.stack, hasLength(1));
      },
    );

    test('goToMenus pushes a MenuListRoutePage onto the stack', () {
      final router = MainRouter(container: _makeContainer())
        ..push(HomeRoutePage(router: MainRouter(container: _makeContainer())));

      router.goToMenus();

      expect(router.stack, hasLength(2));
      expect(router.stack.last, isA<MenuListRoutePage>());
    });

    test(
      'goToMenus does not stack a second MenuListRoutePage when already on top',
      () async {
        final router = MainRouter(container: _makeContainer());
        await router.setNewRoutePath(const MenuListRouteConfig());

        router.goToMenus();

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<MenuListRoutePage>());
      },
    );

    test(
      'goToAdminTemplates pushes an AdminTemplatesRoutePage onto the stack',
      () async {
        final router = MainRouter(container: _makeContainer());
        await router.setNewRoutePath(const HomeRouteConfig());

        router.goToAdminTemplates();

        expect(router.stack, hasLength(2));
        expect(router.stack.last, isA<AdminTemplatesRoutePage>());
      },
    );

    test('goToAdminTemplates is idempotent when AdminTemplatesRoutePage is '
        'already on top', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const AdminTemplatesRouteConfig());

      router.goToAdminTemplates();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<AdminTemplatesRoutePage>());
    });

    test('goToAdminTemplates does not require a LegacyNavigator', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const HomeRouteConfig());

      router.goToAdminTemplates();

      expect(router.stack, hasLength(2));
      expect(router.stack.last, isA<AdminTemplatesRoutePage>());
    });

    test('goToAdminTemplateCreate delegates to the legacy navigator with '
        '/admin/templates/create', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToAdminTemplateCreate();

      expect(navigator.goCalls.single.location, AppRoutes.adminTemplateCreate);
    });

    test('goToAdminExportableMenus delegates to the legacy navigator with '
        '/admin/exportable_menus', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToAdminExportableMenus();

      expect(navigator.goCalls.single.location, AppRoutes.adminExportableMenus);
    });

    test('HomeRouter legacy-only admin quick-actions are no-ops without a '
        'LegacyNavigator', () {
      final router = MainRouter(container: _makeContainer());

      router.goToAdminTemplateCreate();
      router.goToAdminExportableMenus();

      // Both are still legacy-bridged, so without a navigator they should
      // not push anything onto the migrated stack. (goToAdminTemplates is
      // covered separately — it always pushes, with or without a navigator.)
      expect(router.stack, isEmpty);
    });
  });

  group('MainRouter — MenuListRouter integration', () {
    test('implements MenuListRouter so it can be injected into the VM', () {
      final router = MainRouter(container: _makeContainer());

      expect(router, isA<MenuListRouter>());
    });

    test('setNewRoutePath(MenuListRouteConfig) replaces the stack with '
        'MenuListRoutePage', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const MenuListRouteConfig());

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<MenuListRoutePage>());
      expect(router.currentConfiguration, const MenuListRouteConfig());
    });

    test(
      'pushing MenuListRouteConfig twice keeps a single page on the stack',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const MenuListRouteConfig());
        await router.setNewRoutePath(const MenuListRouteConfig());

        expect(router.stack, hasLength(1));
      },
    );

    test('goToMenuEditor delegates to the legacy navigator', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToMenuEditor(42);

      expect(navigator.goCalls.single.location, AppRoutes.menuEditor(42));
    });

    test('goToAdminTemplateEditor delegates to the legacy navigator', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToAdminTemplateEditor(7);

      expect(
        navigator.goCalls.single.location,
        AppRoutes.adminTemplateEditor(7),
      );
    });

    test('goBack pops the menu list page off the stack', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const HomeRouteConfig());
      router.goToMenus();
      expect(router.stack, hasLength(2));

      router.goBack();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<HomeRoutePage>());
    });

    test('MenuListRouter sub-route navigation is a no-op without a '
        'LegacyNavigator', () {
      final router = MainRouter(container: _makeContainer());

      router.goToMenuEditor(1);
      router.goToAdminTemplateEditor(1);

      expect(router.stack, isEmpty);
    });
  });

  group('MainRouter — SettingsRouter integration', () {
    test('implements SettingsRouter so it can be injected into the VM', () {
      final router = MainRouter(container: _makeContainer());

      expect(router, isA<SettingsRouter>());
    });

    test('setNewRoutePath(SettingsRouteConfig) replaces the stack with '
        'SettingsRoutePage', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const SettingsRouteConfig());

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<SettingsRoutePage>());
      expect(router.currentConfiguration, const SettingsRouteConfig());
    });

    test(
      'pushing SettingsRouteConfig twice keeps a single page on the stack',
      () async {
        final router = MainRouter(container: _makeContainer());

        await router.setNewRoutePath(const SettingsRouteConfig());
        await router.setNewRoutePath(const SettingsRouteConfig());

        expect(router.stack, hasLength(1));
      },
    );

    test('goToSettings pushes a SettingsRoutePage onto the stack', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const HomeRouteConfig());

      router.goToSettings();

      expect(router.stack, hasLength(2));
      expect(router.stack.last, isA<SettingsRoutePage>());
    });

    test(
      'goToSettings is idempotent when SettingsRoutePage is already on top',
      () async {
        final router = MainRouter(container: _makeContainer());
        await router.setNewRoutePath(const SettingsRouteConfig());

        router.goToSettings();

        expect(router.stack, hasLength(1));
        expect(router.stack.single, isA<SettingsRoutePage>());
      },
    );

    test('goBack pops the settings page off the stack', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const HomeRouteConfig());
      router.goToSettings();
      expect(router.stack, hasLength(2));

      router.goBack();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<HomeRoutePage>());
    });
  });

  group('MainRouter — AdminTemplatesRouter integration', () {
    test(
      'implements AdminTemplatesRouter so it can be injected into the VM',
      () {
        final router = MainRouter(container: _makeContainer());

        expect(router, isA<AdminTemplatesRouter>());
      },
    );

    test('setNewRoutePath(AdminTemplatesRouteConfig) replaces the stack with '
        'AdminTemplatesRoutePage', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const AdminTemplatesRouteConfig());

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<AdminTemplatesRoutePage>());
      expect(router.currentConfiguration, const AdminTemplatesRouteConfig());
    });

    test('pushing AdminTemplatesRouteConfig twice keeps a single page on the '
        'stack', () async {
      final router = MainRouter(container: _makeContainer());

      await router.setNewRoutePath(const AdminTemplatesRouteConfig());
      await router.setNewRoutePath(const AdminTemplatesRouteConfig());

      expect(router.stack, hasLength(1));
    });

    test('goBack pops the admin-templates page off the stack', () async {
      final router = MainRouter(container: _makeContainer());
      await router.setNewRoutePath(const HomeRouteConfig());
      router.goToAdminTemplates();
      expect(router.stack, hasLength(2));

      router.goBack();

      expect(router.stack, hasLength(1));
      expect(router.stack.single, isA<HomeRoutePage>());
    });

    test('goToAdminTemplateCreate delegates to the legacy navigator with '
        '/admin/templates/create', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToAdminTemplateCreate();

      expect(navigator.goCalls.single.location, AppRoutes.adminTemplateCreate);
    });

    test('goToAdminTemplateEditor delegates to the legacy navigator', () {
      final navigator = _RecordingLegacyNavigator();
      final router = MainRouter(
        container: _makeContainer(),
        legacyNavigator: navigator,
      );

      router.goToAdminTemplateEditor(99);

      expect(
        navigator.goCalls.single.location,
        AppRoutes.adminTemplateEditor(99),
      );
    });
  });
}
