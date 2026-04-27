import 'dart:async';

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

const _regular = User(
  id: 'u-1',
  email: 'alice@example.com',
  role: UserRole.user,
);

const _bundleA = MenuBundle(id: 1, name: 'Lunch', menuIds: [10]);
const _bundleB = MenuBundle(id: 2, name: 'Dinner', menuIds: [20]);
const _menu = Menu(id: 10, name: 'Lunch', status: Status.draft, version: '1');

class _FakeListBundles implements ListMenuBundlesForAdminUseCase {
  Result<List<MenuBundle>, DomainError> result =
      const Success([_bundleA, _bundleB]);
  final List<NoInput> calls = [];
  Completer<void>? _gate;

  void blockNextCall() => _gate = Completer<void>();

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _FakeListMenus implements ListAvailableMenusForBundlesUseCase {
  Result<List<Menu>, DomainError> result = const Success([_menu]);
  final List<NoInput> calls = [];

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeCreate implements CreateMenuBundleForAdminUseCase {
  Result<MenuBundle, DomainError> result = const Success(_bundleA);
  final List<CreateMenuBundleInput> calls = [];

  @override
  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async {
    calls.add(input);
    return result;
  }
}

class _FakeUpdate implements UpdateMenuBundleForAdminUseCase {
  Result<MenuBundle, DomainError> result = const Success(_bundleA);
  final List<UpdateMenuBundleInput> calls = [];

  @override
  Future<Result<MenuBundle, DomainError>> execute(
    UpdateMenuBundleInput input,
  ) async {
    calls.add(input);
    return result;
  }
}

class _FakeDelete implements DeleteMenuBundleForAdminUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<int> calls = [];

  @override
  Future<Result<void, DomainError>> execute(int id) async {
    calls.add(id);
    return result;
  }
}

class _FakePublish implements PublishMenuBundleForAdminUseCase {
  Result<MenuBundle, DomainError> result = const Success(_bundleA);
  final List<int> calls = [];
  Completer<Result<MenuBundle, DomainError>>? _gate;

  void blockNextCall() {
    _gate = Completer<Result<MenuBundle, DomainError>>();
  }

  void release() {
    _gate?.complete(result);
    _gate = null;
  }

  @override
  Future<Result<MenuBundle, DomainError>> execute(int bundleId) {
    calls.add(bundleId);
    if (_gate != null) {
      return _gate!.future;
    }
    return Future.value(result);
  }
}

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required this.restoredUser});

  final Result<User, DomainError> restoredUser;

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

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;

  Future<void> close() => controller.close();
}

class _RecordingRouter implements AdminExportableMenusRouter {
  int backCalls = 0;

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

Future<({
  AdminExportableMenusViewModel vm,
  _FakeListBundles listBundles,
  _FakeListMenus listMenus,
  _FakeCreate create,
  _FakeUpdate update,
  _FakeDelete delete,
  _FakePublish publish,
  _RecordingRouter router,
  AuthGateway authGateway,
  ConnectivityGateway connectivityGateway,
  _StubConnectivityRepository connectivityRepo,
})>
_buildVm({
  User? user = _admin,
  _FakeListBundles? listBundles,
  _FakeListMenus? listMenus,
  _FakeCreate? create,
  _FakeUpdate? update,
  _FakeDelete? delete,
  _FakePublish? publish,
}) async {
  final lb = listBundles ?? _FakeListBundles();
  final lm = listMenus ?? _FakeListMenus();
  final c = create ?? _FakeCreate();
  final u = update ?? _FakeUpdate();
  final d = delete ?? _FakeDelete();
  final p = publish ?? _FakePublish();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authGateway = await _gatewayFor(user);
  final vm = AdminExportableMenusViewModel(
    listBundles: lb,
    listAvailableMenus: lm,
    createBundle: c,
    updateBundle: u,
    deleteBundle: d,
    publishBundle: p,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    listBundles: lb,
    listMenus: lm,
    create: c,
    update: u,
    delete: d,
    publish: p,
    router: router,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('AdminExportableMenusViewModel — initial state', () {
    test('starts with isLoading true and empty lists', () async {
      final lb = _FakeListBundles()..blockNextCall();
      final h = await _buildVm(listBundles: lb);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);

      expect(h.vm.state.isLoading, isTrue);
      expect(h.vm.state.bundles, isEmpty);
      expect(h.vm.state.availableMenus, isEmpty);
      expect(h.vm.state.errorMessage, isNull);

      lb.release();
      await _settle();
    });

    test('isAdmin is true for admin viewers', () async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.vm.state.isAdmin, isTrue);
    });

    test('isAdmin is false for regular viewers', () async {
      final h = await _buildVm(user: _regular);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.vm.state.isAdmin, isFalse);
    });

    test('isAdmin is false for anonymous viewers', () async {
      final h = await _buildVm(user: null);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.vm.state.isAdmin, isFalse);
    });
  });

  group('AdminExportableMenusViewModel — initial load', () {
    test('drives both list use cases once and exposes the data', () async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.listBundles.calls, hasLength(1));
      expect(h.listMenus.calls, hasLength(1));
      expect(h.vm.state.bundles, [_bundleA, _bundleB]);
      expect(h.vm.state.availableMenus, [_menu]);
      expect(h.vm.state.isLoading, isFalse);
      expect(h.vm.state.errorMessage, isNull);
    });

    test('exposes errorMessage when bundles load fails', () async {
      final lb = _FakeListBundles()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(listBundles: lb);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.vm.state.isLoading, isFalse);
      expect(h.vm.state.errorMessage, 'boom');
      expect(h.vm.state.bundles, isEmpty);
    });

    test('exposes errorMessage when menus load fails', () async {
      final lm = _FakeListMenus()
        ..result = const Failure(NetworkError('menus down'));
      final h = await _buildVm(listMenus: lm);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      expect(h.vm.state.isLoading, isFalse);
      expect(h.vm.state.errorMessage, 'menus down');
    });

    test('reload re-runs both use cases and clears errorMessage', () async {
      final lb = _FakeListBundles()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(listBundles: lb);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();
      expect(h.vm.state.errorMessage, 'boom');

      lb.result = const Success([_bundleA]);
      await h.vm.reload();

      expect(h.listBundles.calls, hasLength(2));
      expect(h.listMenus.calls, hasLength(2));
      expect(h.vm.state.bundles, [_bundleA]);
      expect(h.vm.state.errorMessage, isNull);
    });
  });

  group('AdminExportableMenusViewModel — create', () {
    test('appends the new bundle to state on success and returns it',
        () async {
      final create = _FakeCreate()
        ..result = const Success(MenuBundle(id: 99, name: 'New', menuIds: [1]));
      final h = await _buildVm(create: create);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final created = await h.vm.createBundle(
        const CreateMenuBundleInput(name: 'New', menuIds: [1]),
      );

      expect(created?.id, 99);
      expect(h.vm.state.bundles.last.id, 99);
      expect(h.vm.state.errorMessage, isNull);
    });

    test('surfaces errorMessage and returns null on failure', () async {
      final create = _FakeCreate()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(create: create);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final created = await h.vm.createBundle(
        const CreateMenuBundleInput(name: 'New', menuIds: [1]),
      );

      expect(created, isNull);
      expect(h.vm.state.errorMessage, 'boom');
    });
  });

  group('AdminExportableMenusViewModel — update', () {
    test('replaces the matching bundle on success and returns it', () async {
      final updated = const MenuBundle(id: 1, name: 'Renamed', menuIds: [10]);
      final update = _FakeUpdate()..result = Success(updated);
      final h = await _buildVm(update: update);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final result = await h.vm.updateBundle(
        const UpdateMenuBundleInput(id: 1, name: 'Renamed'),
      );

      expect(result, updated);
      expect(h.vm.state.bundles.firstWhere((b) => b.id == 1).name, 'Renamed');
    });

    test('surfaces errorMessage and returns null on failure', () async {
      final update = _FakeUpdate()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(update: update);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final result = await h.vm.updateBundle(
        const UpdateMenuBundleInput(id: 1, name: 'X'),
      );

      expect(result, isNull);
      expect(h.vm.state.errorMessage, 'boom');
    });
  });

  group('AdminExportableMenusViewModel — delete', () {
    test('removes the bundle from state on success', () async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();
      expect(h.vm.state.bundles.map((b) => b.id), [1, 2]);

      await h.vm.deleteBundle(1);

      expect(h.vm.state.bundles.map((b) => b.id), [2]);
      expect(h.delete.calls, [1]);
    });

    test('surfaces errorMessage on failure and keeps the bundle in state',
        () async {
      final delete = _FakeDelete()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(delete: delete);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      await h.vm.deleteBundle(1);

      expect(h.vm.state.bundles.map((b) => b.id), [1, 2]);
      expect(h.vm.state.errorMessage, 'boom');
    });
  });

  group('AdminExportableMenusViewModel — publish', () {
    test('marks the bundle as publishing while in flight', () async {
      final publish = _FakePublish()..blockNextCall();
      final h = await _buildVm(publish: publish);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final future = h.vm.publishBundle(1);

      expect(h.vm.state.publishingBundleIds.contains(1), isTrue);
      publish.release();
      await future;
      expect(h.vm.state.publishingBundleIds.contains(1), isFalse);
    });

    test('replaces the published bundle in state on success', () async {
      const published = MenuBundle(
        id: 1,
        name: 'Lunch',
        menuIds: [10],
        pdfFileId: 'abc',
      );
      final publish = _FakePublish()..result = const Success(published);
      final h = await _buildVm(publish: publish);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final result = await h.vm.publishBundle(1);

      expect(result.valueOrNull, published);
      expect(
        h.vm.state.bundles.firstWhere((b) => b.id == 1).pdfFileId,
        'abc',
      );
    });

    test('surfaces errorMessage on failure', () async {
      final publish = _FakePublish()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(publish: publish);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final result = await h.vm.publishBundle(1);

      expect(result.errorOrNull, isA<NetworkError>());
      expect(h.vm.state.errorMessage, 'boom');
      expect(h.vm.state.publishingBundleIds, isEmpty);
    });
  });

  group('AdminExportableMenusViewModel — clearError + navigation', () {
    test('clearError clears the error message and notifies listeners',
        () async {
      final lb = _FakeListBundles()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(listBundles: lb);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();
      expect(h.vm.state.errorMessage, 'boom');

      h.vm.clearError();

      expect(h.vm.state.errorMessage, isNull);
    });

    test('goBack delegates to router.goBack', () async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);

      h.vm.goBack();

      expect(h.router.backCalls, 1);
    });
  });

  group('AdminExportableMenusViewModel — connectivity restore', () {
    test('reloads on offline → online when an error was last seen', () async {
      final lb = _FakeListBundles()
        ..result = const Failure(NetworkError('boom'));
      final h = await _buildVm(listBundles: lb);
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();
      expect(h.listBundles.calls, hasLength(1));

      h.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await _settle();
      lb.result = const Success([_bundleA]);
      h.connectivityRepo.controller.add(ConnectivityStatus.online);
      await _settle();

      expect(h.listBundles.calls, hasLength(2));
    });

    test('does not reload when there is no error to recover from', () async {
      final h = await _buildVm();
      addTearDown(h.vm.dispose);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();
      expect(h.listBundles.calls, hasLength(1));

      h.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await _settle();
      h.connectivityRepo.controller.add(ConnectivityStatus.online);
      await _settle();

      expect(h.listBundles.calls, hasLength(1));
    });
  });

  group('AdminExportableMenusViewModel — disposal', () {
    test('dispose marks the VM as disposed and stops further emits',
        () async {
      final publish = _FakePublish()..blockNextCall();
      final h = await _buildVm(publish: publish);
      addTearDown(h.authGateway.dispose);
      addTearDown(h.connectivityRepo.close);
      addTearDown(h.connectivityGateway.dispose);
      await _settle();

      final future = h.vm.publishBundle(1);
      h.vm.dispose();
      publish.release();
      await future;

      expect(h.vm.isDisposed, isTrue);
    });
  });
}
