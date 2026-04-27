import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_page.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
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

class _NoopMenuListRouter implements MenuListRouter {
  @override
  void goToMenuEditor(int menuId) {}

  @override
  void goToAdminTemplateEditor(int menuId) {}

  @override
  void goBack() {}
}

class _StubListMenusForViewerUseCase implements ListMenusForViewerUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async =>
      const Success(<Menu>[]);
}

class _StubCreateMenuUseCase implements CreateMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateMenuInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubDeleteMenuUseCase implements DeleteMenuUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubDuplicateMenuUseCase implements DuplicateMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(int sourceMenuId) async =>
      const Failure(UnauthorizedError());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

MenuListViewModel _testViewModelBuilder(
  AppContainer container,
  MenuListRouter router,
) {
  return MenuListViewModel(
    listMenusForViewer: _StubListMenusForViewerUseCase(),
    createMenu: _StubCreateMenuUseCase(),
    deleteMenu: _StubDeleteMenuUseCase(),
    duplicateMenu: _StubDuplicateMenuUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
  );
}

void main() {
  group('MenuListRoutePage', () {
    test('identity is the constant `menu-list` (stack diffing)', () {
      final page = MenuListRoutePage(router: _NoopMenuListRouter());

      expect(page.identity, 'menu-list');
    });

    testWidgets('buildScreen returns a MenuListScreen with a live ViewModel', (
      tester,
    ) async {
      final page = MenuListRoutePage(
        router: _NoopMenuListRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

      expect(find.byType(MenuListScreen), findsOneWidget);
    });

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = MenuListRoutePage(
        router: _NoopMenuListRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as MenuListScreen;
      final second = page.buildScreen(container) as MenuListScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = MenuListRoutePage(
        router: _NoopMenuListRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as MenuListScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked with the container and router on the '
        'first buildScreen call', () {
      var calls = 0;
      AppContainer? receivedContainer;
      MenuListRouter? receivedRouter;
      final router = _NoopMenuListRouter();
      MenuListViewModel customBuilder(AppContainer c, MenuListRouter r) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        return _testViewModelBuilder(c, r);
      }

      final page = MenuListRoutePage(
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
