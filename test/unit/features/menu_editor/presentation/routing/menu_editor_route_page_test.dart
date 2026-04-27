import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/load_menu_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_route_page.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/menu_editor_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../../../../fakes/fake_widget_repository.dart';

const _user = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

const _menu = Menu(id: 7, name: 'Menu', version: '1', status: Status.draft);

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
      const Success(_user);

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Success(_user);

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

class _NoopRouter implements MenuEditorRouter {
  @override
  void goBack() {}
  @override
  void goToPdfPreview(int menuId) {}
}

Future<AppContainer> _makeContainer() async {
  final auth = AuthGateway(repository: _StubAuthRepository());
  await auth.tryRestoreSession();
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

MenuEditorViewModel _testViewModelBuilder(
  AppContainer container,
  MenuEditorRouter router,
  int menuId,
) {
  final menuRepo = FakeMenuRepository()..whenGetById(const Success(_menu));
  final pageRepo = FakePageRepository()..whenGetAllForMenu(const Success([]));
  final containerRepo = FakeContainerRepository();
  final columnRepo = FakeColumnRepository();
  final widgetRepo = FakeWidgetRepository();
  final subRepo = FakeMenuSubscriptionRepository();
  final presenceRepo = FakePresenceRepository()
    ..whenJoinMenu(const Success(null))
    ..whenGetActiveUsers(menuId, const Success([]))
    ..whenHeartbeat(const Success(null))
    ..whenLeaveMenu(const Success(null));
  final bundleRepo = FakeMenuBundleRepository()
    ..whenFindByIncludedMenu(const Success([]));
  final publishMenuBundleStub = FakePublishMenuBundleUseCase();
  final publishBundlesDelegate = PublishBundlesForMenuUseCase(
    repository: bundleRepo,
    publishMenuBundleUseCase: publishMenuBundleStub,
  );
  return MenuEditorViewModel(
    menuId: menuId,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
    loadMenu: LoadMenuForEditorUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepo,
      pageRepository: pageRepo,
      containerRepository: containerRepo,
      columnRepository: columnRepo,
      widgetRepository: widgetRepo,
    ),
    createWidget: CreateWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    updateWidget: UpdateWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    deleteWidget: DeleteWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    moveWidget: MoveWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    lockWidget: LockWidgetForEditingUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    unlockWidget: UnlockWidgetUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepo,
    ),
    saveMenu: SaveMenuUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepo,
    ),
    publishBundles: PublishExportableBundlesForMenuUseCase(
      authGateway: container.authGateway,
      delegate: publishBundlesDelegate,
    ),
    watchChanges: WatchMenuChangesUseCase(repository: subRepo),
    presence: MenuPresenceUseCase(repository: presenceRepo),
  );
}

void main() {
  group('MenuEditorRoutePage', () {
    test('identity is namespaced with the menuId so distinct menus are '
        'distinct stack entries', () {
      final a = MenuEditorRoutePage(router: _NoopRouter(), menuId: 7);
      final b = MenuEditorRoutePage(router: _NoopRouter(), menuId: 7);
      final c = MenuEditorRoutePage(router: _NoopRouter(), menuId: 8);

      expect(a.identity, b.identity);
      expect(a.identity, isNot(c.identity));
    });

    testWidgets(
      'buildScreen returns a MenuEditorScreen with a live ViewModel',
      (tester) async {
        final page = MenuEditorRoutePage(
          router: _NoopRouter(),
          menuId: 7,
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = await _makeContainer();

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: page.buildScreen(container))),
        );
        await tester.pump();

        expect(find.byType(MenuEditorScreen), findsOneWidget);
        page.disposeResources();
      },
    );

    testWidgets(
      'buildScreen is idempotent — same ViewModel survives rebuilds',
      (tester) async {
        final page = MenuEditorRoutePage(
          router: _NoopRouter(),
          menuId: 7,
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = await _makeContainer();

        final first = page.buildScreen(container) as MenuEditorScreen;
        final second = page.buildScreen(container) as MenuEditorScreen;

        expect(identical(first.viewModel, second.viewModel), isTrue);
        page.disposeResources();
      },
    );

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = MenuEditorRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = await _makeContainer();
      final screen = page.buildScreen(container) as MenuEditorScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });
  });
}
