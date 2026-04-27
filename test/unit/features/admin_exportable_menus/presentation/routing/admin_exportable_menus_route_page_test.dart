import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/delete_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_available_menus_for_bundles_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/update_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_route_page.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/screens/admin_exportable_menus_screen.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
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

class _NoopRouter implements AdminExportableMenusRouter {
  @override
  void goBack() {}
}

class _StubListBundles implements ListMenuBundlesForAdminUseCase {
  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) async =>
      const Success(<MenuBundle>[]);
}

class _StubListMenus implements ListAvailableMenusForBundlesUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async =>
      const Success(<Menu>[]);
}

class _StubCreate implements CreateMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdate implements UpdateMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(
    UpdateMenuBundleInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDelete implements DeleteMenuBundleForAdminUseCase {
  @override
  Future<Result<void, DomainError>> execute(int id) async =>
      const Failure(UnauthorizedError());
}

class _StubPublish implements PublishMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(int bundleId) async =>
      const Failure(UnauthorizedError());
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

AdminExportableMenusViewModel _testViewModelBuilder(
  AppContainer container,
  AdminExportableMenusRouter router,
) {
  return AdminExportableMenusViewModel(
    listBundles: _StubListBundles(),
    listAvailableMenus: _StubListMenus(),
    createBundle: _StubCreate(),
    updateBundle: _StubUpdate(),
    deleteBundle: _StubDelete(),
    publishBundle: _StubPublish(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
  );
}

void main() {
  group('AdminExportableMenusRoutePage', () {
    test(
      'identity is the constant `admin-exportable-menus` (stack diffing)',
      () {
        final page = AdminExportableMenusRoutePage(router: _NoopRouter());

        expect(page.identity, 'admin-exportable-menus');
      },
    );

    testWidgets(
      'buildScreen returns an AdminExportableMenusScreen with a live ViewModel',
      (tester) async {
        final page = AdminExportableMenusRoutePage(
          router: _NoopRouter(),
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));
        await tester.pump();

        expect(find.byType(AdminExportableMenusScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = AdminExportableMenusRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as AdminExportableMenusScreen;
      final second = page.buildScreen(container) as AdminExportableMenusScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = AdminExportableMenusRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as AdminExportableMenusScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test(
      'viewModelBuilder is invoked with the container and router on the first '
      'buildScreen call',
      () {
        var calls = 0;
        AppContainer? receivedContainer;
        AdminExportableMenusRouter? receivedRouter;
        final router = _NoopRouter();
        AdminExportableMenusViewModel customBuilder(
          AppContainer c,
          AdminExportableMenusRouter r,
        ) {
          calls++;
          receivedContainer = c;
          receivedRouter = r;
          return _testViewModelBuilder(c, r);
        }

        final page = AdminExportableMenusRoutePage(
          router: router,
          viewModelBuilder: customBuilder,
        );
        final container = _makeContainer();

        page.buildScreen(container);
        page.buildScreen(container);

        expect(calls, 1);
        expect(receivedContainer, same(container));
        expect(receivedRouter, same(router));
      },
    );
  });
}
