import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
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
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/menu_editor_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_connectivity_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../../../../fakes/reflectable_bootstrap.dart';

const _user = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

const _menu = Menu(id: 1, name: 'My Menu', version: '1', status: Status.draft);

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

class _NoopRouter implements MenuEditorRouter {
  @override
  void goBack() {}
  @override
  void goToPdfPreview(int menuId) {}
}

Future<MenuEditorViewModel> _makeVm(
  AuthGateway gateway, {
  void Function(FakeMenuRepository menuRepo)? configureMenuRepo,
}) async {
  final connectivityGateway = ConnectivityGateway(
    repository: FakeConnectivityRepository()
      ..whenCheckConnectivity(ConnectivityStatus.online),
  );
  addTearDown(connectivityGateway.dispose);
  final menuRepo = FakeMenuRepository()..whenGetById(const Success(_menu));
  configureMenuRepo?.call(menuRepo);
  final pageRepo = FakePageRepository()..whenGetAllForMenu(const Success([]));
  final widgetRepo = FakeWidgetRepository();
  final subRepo = FakeMenuSubscriptionRepository();
  final presenceRepo = FakePresenceRepository()
    ..whenJoinMenu(const Success(null))
    ..whenGetActiveUsers(1, const Success([]))
    ..whenHeartbeat(const Success(null))
    ..whenLeaveMenu(const Success(null));
  final bundleRepo = FakeMenuBundleRepository();
  final delegate = PublishBundlesForMenuUseCase(
    repository: bundleRepo,
    publishMenuBundleUseCase: FakePublishMenuBundleUseCase(),
  );
  return MenuEditorViewModel(
    menuId: 1,
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
    router: _NoopRouter(),
    registry: PresentableWidgetRegistry(),
    loadMenu: LoadMenuForEditorUseCase(
      authGateway: gateway,
      menuRepository: menuRepo,
      pageRepository: pageRepo,
      containerRepository: FakeContainerRepository(),
      columnRepository: FakeColumnRepository(),
      widgetRepository: widgetRepo,
    ),
    createWidget: CreateWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    updateWidget: UpdateWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    deleteWidget: DeleteWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    moveWidget: MoveWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    lockWidget: LockWidgetForEditingUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    unlockWidget: UnlockWidgetUseCase(
      authGateway: gateway,
      widgetRepository: widgetRepo,
    ),
    saveMenu: SaveMenuUseCase(authGateway: gateway, menuRepository: menuRepo),
    publishBundles: PublishExportableBundlesForMenuUseCase(
      authGateway: gateway,
      delegate: delegate,
    ),
    watchChanges: WatchMenuChangesUseCase(repository: subRepo),
    presence: MenuPresenceUseCase(repository: presenceRepo),
  );
}

void main() {
  setUpAll(initializeReflectableForTests);

  testWidgets('shows the menu name in the AppBar after the load completes', (
    tester,
  ) async {
    final auth = AuthGateway(repository: _StubAuthRepository());
    addTearDown(auth.dispose);
    await auth.tryRestoreSession();

    final vm = await _makeVm(auth);

    await tester.pumpWidget(MaterialApp(home: MenuEditorScreen(viewModel: vm)));
    // Drain the load future + post-frame.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.text('My Menu'), findsOneWidget);
    expect(find.byKey(const Key('show_pdf_button')), findsOneWidget);
    expect(find.byKey(const Key('save_menu_button')), findsOneWidget);

    // Dispose the VM so its periodic heartbeat / WebSocket subscriptions
    // tear down before the test framework checks for pending timers.
    vm.dispose();
  });

  testWidgets('tapping save shows the "Menu saved" snackbar', (tester) async {
    final auth = AuthGateway(repository: _StubAuthRepository());
    addTearDown(auth.dispose);
    await auth.tryRestoreSession();

    final vm = await _makeVm(
      auth,
      configureMenuRepo: (repo) => repo.whenUpdate(const Success(_menu)),
    );

    await tester.pumpWidget(MaterialApp(home: MenuEditorScreen(viewModel: vm)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.tap(find.byKey(const Key('save_menu_button')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.text('Menu saved'), findsOneWidget);

    vm.dispose();
  });
}
