import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
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
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/state/menu_list_state.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

const _adminUser = User(
  id: 'u-admin',
  email: 'admin@example.com',
  role: UserRole.admin,
);

const _regularUser = User(
  id: 'u-1',
  email: 'alice@example.com',
  role: UserRole.user,
);

const _menuOne = Menu(
  id: 1,
  name: 'Menu 1',
  status: Status.draft,
  version: '1.0',
);
const _menuTwo = Menu(
  id: 2,
  name: 'Menu 2',
  status: Status.published,
  version: '1.0',
);
const _menuNew = Menu(
  id: 9,
  name: 'Brand New',
  status: Status.draft,
  version: '0.1',
);

class _FakeListMenusForViewerUseCase implements ListMenusForViewerUseCase {
  Result<List<Menu>, DomainError> result = const Success(<Menu>[]);
  int calls = 0;
  Completer<void>? _gate;

  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async {
    calls++;
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _FakeCreateMenuUseCase implements CreateMenuUseCase {
  Result<Menu, DomainError> result = const Success(_menuNew);
  final List<CreateMenuInput> calls = [];

  @override
  Future<Result<Menu, DomainError>> execute(CreateMenuInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeDeleteMenuUseCase implements DeleteMenuUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<int> calls = [];

  @override
  Future<Result<void, DomainError>> execute(int input) async {
    calls.add(input);
    return result;
  }
}

class _FakeDuplicateMenuUseCase implements DuplicateMenuUseCase {
  _FakeDuplicateMenuUseCase();
  Result<Menu, DomainError> result = const Success(_menuNew);
  final List<int> calls = [];

  @override
  Future<Result<Menu, DomainError>> execute(int sourceMenuId) async {
    calls.add(sourceMenuId);
    return result;
  }

  // Ignored — not used by the VM, satisfied via `noSuchMethod` would force a
  // bunch of mocks; instead we declare every getter we don't need to throw.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      '_FakeDuplicateMenuUseCase: unexpected call ${invocation.memberName}',
    );
  }
}

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus initial = ConnectivityStatus.online;

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async => initial;

  Future<void> close() => controller.close();
}

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required this.restoredUser});
  Result<User, DomainError> restoredUser;

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => restoredUser;

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => restoredUser;

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

class _RecordingMenuListRouter implements MenuListRouter {
  final List<int> menuTaps = [];
  final List<int> editorTaps = [];
  int backCalls = 0;
  int adminSizesPushCalls = 0;

  @override
  void goToMenuEditor(int menuId) => menuTaps.add(menuId);

  @override
  void goToAdminTemplateEditor(int menuId) => editorTaps.add(menuId);

  @override
  void pushAdminSizes() => adminSizesPushCalls++;

  @override
  void goBack() => backCalls++;
}

Future<AuthGateway> _gatewayFor(User? user) async {
  final repo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final gateway = AuthGateway(repository: repo);
  if (user != null) {
    await gateway.tryRestoreSession();
  }
  return gateway;
}

({
  MenuListViewModel vm,
  _FakeListMenusForViewerUseCase listUseCase,
  _FakeCreateMenuUseCase createUseCase,
  _FakeDeleteMenuUseCase deleteUseCase,
  _FakeDuplicateMenuUseCase duplicateUseCase,
  _RecordingMenuListRouter router,
  AuthGateway authGateway,
  ConnectivityGateway connectivityGateway,
  _StubConnectivityRepository connectivityRepo,
})
_buildVm({User? user, _FakeListMenusForViewerUseCase? listUseCase}) {
  final list = listUseCase ?? _FakeListMenusForViewerUseCase();
  final create = _FakeCreateMenuUseCase();
  final delete = _FakeDeleteMenuUseCase();
  final duplicate = _FakeDuplicateMenuUseCase();
  final router = _RecordingMenuListRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final authGateway = AuthGateway(repository: authRepo);
  // Warm up auth state synchronously without awaiting (tests use this
  // synchronous entry-point, so we resolve the future before constructing
  // the VM in the async tests below).
  final vm = MenuListViewModel(
    listMenusForViewer: list,
    createMenu: create,
    deleteMenu: delete,
    duplicateMenu: duplicate,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    listUseCase: list,
    createUseCase: create,
    deleteUseCase: delete,
    duplicateUseCase: duplicate,
    router: router,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

void main() {
  group('MenuListState', () {
    test('default state is loading=true, no error, empty menus, all filter, '
        'not admin', () {
      const state = MenuListState();

      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.menus, isEmpty);
      expect(state.statusFilter, 'all');
      expect(state.isAdmin, isFalse);
    });

    test('value equality compares all fields', () {
      const a = MenuListState(
        isLoading: false,
        menus: [_menuOne],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const b = MenuListState(
        isLoading: false,
        menus: [_menuOne],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const c = MenuListState(
        isLoading: false,
        menus: [_menuTwo],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = MenuListState(
        isLoading: false,
        menus: [_menuOne],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(source.copyWith(), source);
    });

    test('copyWith can null-out errorMessage via the sentinel', () {
      const source = MenuListState(errorMessage: 'boom', isLoading: false);

      final cleared = source.copyWith(errorMessage: null);

      expect(cleared.errorMessage, isNull);
      expect(cleared.isLoading, isFalse);
    });
  });

  group('MenuListViewModel — initial state', () {
    test('isAdmin mirrors the auth gateway snapshot for admins', () async {
      final list = _FakeListMenusForViewerUseCase();
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = MenuListViewModel(
        listMenusForViewer: list,
        createMenu: _FakeCreateMenuUseCase(),
        deleteMenu: _FakeDeleteMenuUseCase(),
        duplicateMenu: _FakeDuplicateMenuUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingMenuListRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isTrue);
    });

    test('isAdmin is false for regular users', () async {
      final list = _FakeListMenusForViewerUseCase();
      final authGateway = await _gatewayFor(_regularUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = MenuListViewModel(
        listMenusForViewer: list,
        createMenu: _FakeCreateMenuUseCase(),
        deleteMenu: _FakeDeleteMenuUseCase(),
        duplicateMenu: _FakeDuplicateMenuUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingMenuListRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('stays in isLoading=true with no menus while the first load is in '
        'flight', () async {
      final list = _FakeListMenusForViewerUseCase()..blockNextCall();
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = MenuListViewModel(
        listMenusForViewer: list,
        createMenu: _FakeCreateMenuUseCase(),
        deleteMenu: _FakeDeleteMenuUseCase(),
        duplicateMenu: _FakeDuplicateMenuUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingMenuListRouter(),
      );
      addTearDown(vm.dispose);

      // Constructor fires the load, but it is gated.
      expect(list.calls, 1);
      expect(vm.state.isLoading, isTrue);
      expect(vm.state.menus, isEmpty);

      list.release();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('MenuListViewModel — initial load', () {
    test(
      'constructor drives the use case once and exposes the menus',
      () async {
        final list = _FakeListMenusForViewerUseCase()
          ..result = const Success([_menuOne, _menuTwo]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();

        await Future<void>.delayed(Duration.zero);

        expect(harness.listUseCase.calls, 1);
        expect(harness.vm.state.menus, [_menuOne, _menuTwo]);
        expect(harness.vm.state.isLoading, isFalse);
        expect(harness.vm.state.errorMessage, isNull);
      },
    );

    test(
      'on use case failure exposes errorMessage and clears loading',
      () async {
        final list = _FakeListMenusForViewerUseCase()
          ..result = const Failure(NetworkError('Network is down'));
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();

        await Future<void>.delayed(Duration.zero);

        expect(harness.vm.state.isLoading, isFalse);
        expect(harness.vm.state.errorMessage, 'Network is down');
        expect(harness.vm.state.menus, isEmpty);
      },
    );
  });

  group('MenuListViewModel — refresh', () {
    test('refresh re-runs the use case and replaces the menus', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      list.result = const Success([_menuTwo]);
      await harness.vm.refresh();

      expect(list.calls, 2);
      expect(harness.vm.state.menus, [_menuTwo]);
    });

    test('refresh clears a previously surfaced error on success', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Failure(NetworkError('boom'));
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.errorMessage, 'boom');

      list.result = const Success([_menuOne]);
      await harness.vm.refresh();

      expect(harness.vm.state.errorMessage, isNull);
      expect(harness.vm.state.menus, [_menuOne]);
    });
  });

  group('MenuListViewModel — setStatusFilter', () {
    test('updates the statusFilter and notifies', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      var notifications = 0;
      harness.vm.addListener(() => notifications++);

      harness.vm.setStatusFilter('draft');

      expect(harness.vm.state.statusFilter, 'draft');
      expect(notifications, 1);
    });

    test('setting the same filter is a no-op (no notification)', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      var notifications = 0;
      harness.vm.addListener(() => notifications++);

      harness.vm.setStatusFilter('all');

      expect(notifications, 0);
    });
  });

  group('MenuListViewModel — createTemplate', () {
    test('on success prepends the new menu and returns it', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.createUseCase.result = const Success(_menuNew);

      const input = CreateMenuInput(name: 'New', version: '0.1');
      final created = await harness.vm.createTemplate(input);

      expect(created, _menuNew);
      expect(harness.createUseCase.calls.single, input);
      expect(harness.vm.state.menus, [_menuNew, _menuOne]);
    });

    test('on failure returns null and exposes errorMessage', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      harness.createUseCase.result = const Failure(ServerError('nope'));

      final created = await harness.vm.createTemplate(
        const CreateMenuInput(name: 'New', version: '0.1'),
      );

      expect(created, isNull);
      expect(harness.vm.state.errorMessage, 'nope');
    });
  });

  group('MenuListViewModel — deleteMenu', () {
    test('on success removes the menu from state and returns true', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne, _menuTwo]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.deleteMenu(_menuOne.id);

      expect(ok, isTrue);
      expect(harness.deleteUseCase.calls.single, _menuOne.id);
      expect(harness.vm.state.menus, [_menuTwo]);
    });

    test('on failure surfaces errorMessage, leaves the list intact, and '
        'returns false', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne, _menuTwo]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.deleteUseCase.result = const Failure(NetworkError('offline'));

      final ok = await harness.vm.deleteMenu(_menuOne.id);

      expect(ok, isFalse);
      expect(harness.vm.state.menus, [_menuOne, _menuTwo]);
      expect(harness.vm.state.errorMessage, 'offline');
    });
  });

  group('MenuListViewModel — duplicateMenu', () {
    test('on success prepends the duplicated menu and returns it', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.duplicateUseCase.result = const Success(_menuNew);

      final dup = await harness.vm.duplicateMenu(_menuOne.id);

      expect(dup, _menuNew);
      expect(harness.duplicateUseCase.calls.single, _menuOne.id);
      expect(harness.vm.state.menus, [_menuNew, _menuOne]);
    });

    test('on failure returns null and exposes errorMessage', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      harness.duplicateUseCase.result = const Failure(ServerError('boom'));

      final dup = await harness.vm.duplicateMenu(42);

      expect(dup, isNull);
      expect(harness.vm.state.errorMessage, 'boom');
    });
  });

  group('MenuListViewModel — navigation', () {
    test('openMenu delegates to router.goToMenuEditor', () {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.openMenu(7);

      expect(harness.router.menuTaps, [7]);
    });

    test('openTemplateEditor delegates to router.goToAdminTemplateEditor', () {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.openTemplateEditor(11);

      expect(harness.router.editorTaps, [11]);
    });

    test('goBack delegates to router.goBack', () {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.goBack();

      expect(harness.router.backCalls, 1);
    });
  });

  group('MenuListViewModel — connectivity restore', () {
    test('reloads menus on offline → online transition', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(list.calls, 1);

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      // Going offline alone does not retrigger a load.
      expect(list.calls, 1);

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(list.calls, 2);
    });

    test('does not reload when online → online (no transition)', () async {
      final list = _FakeListMenusForViewerUseCase()
        ..result = const Success([_menuOne]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(list.calls, 1);

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(list.calls, 1);
    });
  });

  group('MenuListViewModel — disposal', () {
    test('dispose marks the VM as disposed', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.dispose();

      expect(harness.vm.isDisposed, isTrue);
    });

    test(
      'does not retrigger loads on connectivity events after dispose',
      () async {
        final list = _FakeListMenusForViewerUseCase()
          ..result = const Success([_menuOne]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);
        expect(list.calls, 1);

        // Mark offline so the VM would retry on a subsequent online event.
        harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        harness.vm.dispose();

        harness.connectivityRepo.controller.add(ConnectivityStatus.online);
        await Future<void>.delayed(Duration.zero);

        expect(list.calls, 1);
      },
    );
  });
}
