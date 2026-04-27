import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
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
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/screens/admin_exportable_menus_screen.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

const _admin = User(
  id: 'u-admin',
  email: 'admin@example.com',
  role: UserRole.admin,
);

const _bundleA = MenuBundle(id: 1, name: 'Lunch', menuIds: [10]);
const _bundleB = MenuBundle(
  id: 2,
  name: 'Dinner',
  menuIds: [20],
  pdfFileId: 'file-2',
);
const _menu = Menu(id: 10, name: 'Lunch', status: Status.draft, version: '1');

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.user);
  final User? user;

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      user == null ? const Failure(UnauthorizedError()) : Success(user!);

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      user == null ? const Failure(UnauthorizedError()) : Success(user!);

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

class _FakeListBundles implements ListMenuBundlesForAdminUseCase {
  Result<List<MenuBundle>, DomainError> result = const Success([
    _bundleA,
    _bundleB,
  ]);
  final List<NoInput> calls = [];

  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeListMenus implements ListAvailableMenusForBundlesUseCase {
  Result<List<Menu>, DomainError> result = const Success([_menu]);

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async {
    return result;
  }
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

class _FakeDelete implements DeleteMenuBundleForAdminUseCase {
  final List<int> calls = [];
  Result<void, DomainError> result = const Success(null);

  @override
  Future<Result<void, DomainError>> execute(int id) async {
    calls.add(id);
    return result;
  }
}

class _StubPublish implements PublishMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(int bundleId) async =>
      const Failure(UnauthorizedError());
}

class _RecordingRouter implements AdminExportableMenusRouter {
  int backCalls = 0;

  @override
  void goBack() => backCalls++;
}

Future<
  ({
    AdminExportableMenusViewModel vm,
    _RecordingRouter router,
    _FakeListBundles listBundles,
    _FakeDelete delete,
    AuthGateway authGateway,
    ConnectivityGateway connectivityGateway,
  })
>
_buildVm({
  Result<List<MenuBundle>, DomainError> bundles = const Success([
    _bundleA,
    _bundleB,
  ]),
  _FakeDelete? delete,
}) async {
  final lb = _FakeListBundles()..result = bundles;
  final lm = _FakeListMenus();
  final del = delete ?? _FakeDelete();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authGateway = AuthGateway(repository: _StubAuthRepository(_admin));
  await authGateway.tryRestoreSession();
  final vm = AdminExportableMenusViewModel(
    listBundles: lb,
    listAvailableMenus: lm,
    createBundle: _StubCreate(),
    updateBundle: _StubUpdate(),
    deleteBundle: del,
    publishBundle: _StubPublish(),
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    router: router,
    listBundles: lb,
    delete: del,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('AdminExportableMenusScreen', () {
    testWidgets(
      'renders a list of bundles with the public URL when published',
      (tester) async {
        final h = await _buildVm();
        addTearDown(h.vm.dispose);
        addTearDown(h.authGateway.dispose);
        addTearDown(h.connectivityGateway.dispose);

        await tester.pumpWidget(
          _wrap(
            AdminExportableMenusScreen(
              viewModel: h.vm,
              directusBaseUrl: 'https://api.example.com',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Lunch'), findsOneWidget);
        expect(find.text('Dinner'), findsOneWidget);
        expect(
          find.text('https://api.example.com/assets/file-2'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders the empty state when no bundles exist', (
      tester,
    ) async {
      final h = await _buildVm(bundles: const Success(<MenuBundle>[]));
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityGateway.dispose);

      await tester.pumpWidget(
        _wrap(AdminExportableMenusScreen(viewModel: h.vm, directusBaseUrl: '')),
      );
      await tester.pump();

      expect(find.text('No exportable menus'), findsOneWidget);
      expect(find.text('Create Bundle'), findsWidgets);
    });

    testWidgets('back button delegates to router.goBack', (tester) async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityGateway.dispose);

      await tester.pumpWidget(
        _wrap(AdminExportableMenusScreen(viewModel: h.vm, directusBaseUrl: '')),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(h.router.backCalls, 1);
    });

    testWidgets(
      'tapping the delete icon and confirming forwards to deleteBundle',
      (tester) async {
        final delete = _FakeDelete();
        final h = await _buildVm(delete: delete);
        addTearDown(h.vm.dispose);
        addTearDown(h.authGateway.dispose);
        addTearDown(h.connectivityGateway.dispose);

        await tester.pumpWidget(
          _wrap(
            AdminExportableMenusScreen(viewModel: h.vm, directusBaseUrl: ''),
          ),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(delete.calls, [_bundleA.id]);
      },
    );

    testWidgets('renders the loading indicator while the initial load is in '
        'flight', (tester) async {
      final lb = _FakeListBundles();
      final completer = Completer<Result<List<MenuBundle>, DomainError>>();
      final blockedListBundles = _BlockingListBundles(completer);
      final lm = _FakeListMenus();
      final connectivityRepo = _StubConnectivityRepository();
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      final authGateway = AuthGateway(repository: _StubAuthRepository(_admin));
      await authGateway.tryRestoreSession();
      final vm = AdminExportableMenusViewModel(
        listBundles: blockedListBundles,
        listAvailableMenus: lm,
        createBundle: _StubCreate(),
        updateBundle: _StubUpdate(),
        deleteBundle: _FakeDelete(),
        publishBundle: _StubPublish(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);
      addTearDown(authGateway.dispose);
      addTearDown(connectivityGateway.dispose);

      await tester.pumpWidget(
        _wrap(AdminExportableMenusScreen(viewModel: vm, directusBaseUrl: '')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Success(<MenuBundle>[]));
      await tester.pumpAndSettle();
      // touch lb to silence unused warning
      expect(lb.calls, isEmpty);
    });
  });
}

class _BlockingListBundles implements ListMenuBundlesForAdminUseCase {
  _BlockingListBundles(this._completer);

  final Completer<Result<List<MenuBundle>, DomainError>> _completer;

  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) =>
      _completer.future;
}
