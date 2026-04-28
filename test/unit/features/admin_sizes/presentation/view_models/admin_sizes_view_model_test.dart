import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
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

const _draft = Size(
  id: 1,
  name: 'A4 Draft',
  width: 210,
  height: 297,
  status: Status.draft,
  direction: 'portrait',
);

const _published = Size(
  id: 2,
  name: 'A3 Published',
  width: 297,
  height: 420,
  status: Status.published,
  direction: 'portrait',
);

const _newSize = Size(
  id: 3,
  name: 'New',
  width: 200,
  height: 200,
  status: Status.draft,
  direction: 'portrait',
);

const _createInput = CreateSizeInput(
  name: 'New',
  width: 200,
  height: 200,
  status: Status.draft,
  direction: 'portrait',
);

const _updatedDraft = Size(
  id: 1,
  name: 'A4 Updated',
  width: 210,
  height: 297,
  status: Status.draft,
  direction: 'portrait',
);

const _updateInput = UpdateSizeInput(id: 1, name: 'A4 Updated');

class _FakeListUseCase implements ListSizesForAdminUseCase {
  Result<List<Size>, DomainError> result = const Success(<Size>[]);
  final List<ListSizesForAdminInput> calls = [];
  Completer<void>? _gate;

  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<List<Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _FakeCreateUseCase implements CreateSizeUseCase {
  Result<Size, DomainError> result = const Success(_newSize);
  final List<CreateSizeInput> calls = [];

  @override
  Future<Result<Size, DomainError>> execute(CreateSizeInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeUpdateUseCase implements UpdateSizeUseCase {
  Result<Size, DomainError> result = const Success(_updatedDraft);
  final List<UpdateSizeInput> calls = [];

  @override
  Future<Result<Size, DomainError>> execute(UpdateSizeInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeDeleteUseCase implements DeleteSizeUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<int> calls = [];

  @override
  Future<Result<void, DomainError>> execute(int input) async {
    calls.add(input);
    return result;
  }
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

class _RecordingRouter implements AdminSizesRouter {
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

({
  AdminSizesViewModel vm,
  _FakeListUseCase listUseCase,
  _FakeCreateUseCase createUseCase,
  _FakeUpdateUseCase updateUseCase,
  _FakeDeleteUseCase deleteUseCase,
  _RecordingRouter router,
  AuthGateway authGateway,
  ConnectivityGateway connectivityGateway,
  _StubConnectivityRepository connectivityRepo,
})
_buildVm({User? user, _FakeListUseCase? listUseCase}) {
  final list = listUseCase ?? _FakeListUseCase();
  final createUc = _FakeCreateUseCase();
  final updateUc = _FakeUpdateUseCase();
  final deleteUc = _FakeDeleteUseCase();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final authGateway = AuthGateway(repository: authRepo);
  final vm = AdminSizesViewModel(
    listSizes: list,
    createSize: createUc,
    updateSize: updateUc,
    deleteSize: deleteUc,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    listUseCase: list,
    createUseCase: createUc,
    updateUseCase: updateUc,
    deleteUseCase: deleteUc,
    router: router,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

void main() {
  group('AdminSizesViewModel — initial state', () {
    test('isAdmin is true for admin viewers', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminSizesViewModel(
        listSizes: list,
        createSize: _FakeCreateUseCase(),
        updateSize: _FakeUpdateUseCase(),
        deleteSize: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isTrue);
    });

    test('isAdmin is false for regular viewers', () async {
      final list = _FakeListUseCase();
      final authGateway = await _gatewayFor(_regularUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminSizesViewModel(
        listSizes: list,
        createSize: _FakeCreateUseCase(),
        updateSize: _FakeUpdateUseCase(),
        deleteSize: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('isAdmin is false for anonymous viewers', () async {
      final list = _FakeListUseCase();
      final authGateway = await _gatewayFor(null);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminSizesViewModel(
        listSizes: list,
        createSize: _FakeCreateUseCase(),
        updateSize: _FakeUpdateUseCase(),
        deleteSize: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('stays in isLoading=true with no sizes while the first load is in '
        'flight', () async {
      final list = _FakeListUseCase()..blockNextCall();
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminSizesViewModel(
        listSizes: list,
        createSize: _FakeCreateUseCase(),
        updateSize: _FakeUpdateUseCase(),
        deleteSize: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(list.calls, hasLength(1));
      expect(vm.state.isLoading, isTrue);
      expect(vm.state.sizes, isEmpty);

      list.release();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('AdminSizesViewModel — initial load', () {
    test('drives the use case once and exposes the sizes', () async {
      final list = _FakeListUseCase()
        ..result = const Success([_draft, _published]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();

      await Future<void>.delayed(Duration.zero);

      expect(harness.listUseCase.calls, hasLength(1));
      expect(harness.listUseCase.calls.single, const ListSizesForAdminInput());
      expect(harness.vm.state.sizes, [_draft, _published]);
      expect(harness.vm.state.isLoading, isFalse);
      expect(harness.vm.state.errorMessage, isNull);
    });

    test(
      'on use case failure exposes errorMessage and clears loading',
      () async {
        final list = _FakeListUseCase()
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
        expect(harness.vm.state.sizes, isEmpty);
      },
    );
  });

  group('AdminSizesViewModel — refresh', () {
    test('re-runs the use case and replaces the sizes', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      list.result = const Success([_published]);
      await harness.vm.refresh();

      expect(list.calls, hasLength(2));
      expect(harness.vm.state.sizes, [_published]);
    });

    test('clears a previously surfaced error on success', () async {
      final list = _FakeListUseCase()
        ..result = const Failure(NetworkError('boom'));
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.errorMessage, 'boom');

      list.result = const Success([_draft]);
      await harness.vm.refresh();

      expect(harness.vm.state.errorMessage, isNull);
      expect(harness.vm.state.sizes, [_draft]);
    });
  });

  group('AdminSizesViewModel — setStatusFilter', () {
    test(
      'updates the filter and re-runs the use case with the new filter',
      () async {
        final list = _FakeListUseCase()..result = const Success([_draft]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);
        expect(list.calls, hasLength(1));

        list.result = const Success([_draft]);
        harness.vm.setStatusFilter('draft');
        await Future<void>.delayed(Duration.zero);

        expect(harness.vm.state.statusFilter, 'draft');
        expect(list.calls, hasLength(2));
        expect(
          list.calls.last,
          const ListSizesForAdminInput(statusFilter: 'draft'),
        );
      },
    );

    test(
      'setting the same filter is a no-op (no notification, no reload)',
      () async {
        final list = _FakeListUseCase()..result = const Success([_draft]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);
        expect(list.calls, hasLength(1));

        var notifications = 0;
        harness.vm.addListener(() => notifications++);

        harness.vm.setStatusFilter('all');
        await Future<void>.delayed(Duration.zero);

        expect(notifications, 0);
        expect(list.calls, hasLength(1));
      },
    );
  });

  group('AdminSizesViewModel — createSize', () {
    test('on success appends the new size and returns true', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.createSize(_createInput);

      expect(ok, isTrue);
      expect(harness.createUseCase.calls.single, _createInput);
      expect(harness.vm.state.sizes, [_draft, _newSize]);
      expect(harness.vm.state.errorMessage, isNull);
    });

    test('on failure surfaces errorMessage, leaves the list intact, and '
        'returns false', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.createUseCase.result = const Failure(NetworkError('offline'));

      final ok = await harness.vm.createSize(_createInput);

      expect(ok, isFalse);
      expect(harness.vm.state.sizes, [_draft]);
      expect(harness.vm.state.errorMessage, 'offline');
    });
  });

  group('AdminSizesViewModel — updateSize', () {
    test(
      'on success replaces the matching size in place and returns true',
      () async {
        final list = _FakeListUseCase()
          ..result = const Success([_draft, _published]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);

        final ok = await harness.vm.updateSize(_updateInput);

        expect(ok, isTrue);
        expect(harness.updateUseCase.calls.single, _updateInput);
        expect(harness.vm.state.sizes, [_updatedDraft, _published]);
        expect(harness.vm.state.errorMessage, isNull);
      },
    );

    test('on failure surfaces errorMessage, leaves the list intact, and '
        'returns false', () async {
      final list = _FakeListUseCase()
        ..result = const Success([_draft, _published]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.updateUseCase.result = const Failure(NetworkError('offline'));

      final ok = await harness.vm.updateSize(_updateInput);

      expect(ok, isFalse);
      expect(harness.vm.state.sizes, [_draft, _published]);
      expect(harness.vm.state.errorMessage, 'offline');
    });
  });

  group('AdminSizesViewModel — deleteSize', () {
    test('on success removes the size and returns true', () async {
      final list = _FakeListUseCase()
        ..result = const Success([_draft, _published]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.deleteSize(_draft.id);

      expect(ok, isTrue);
      expect(harness.deleteUseCase.calls.single, _draft.id);
      expect(harness.vm.state.sizes, [_published]);
      expect(harness.vm.state.errorMessage, isNull);
    });

    test('on failure surfaces errorMessage, leaves the list intact, and '
        'returns false', () async {
      final list = _FakeListUseCase()
        ..result = const Success([_draft, _published]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      harness.deleteUseCase.result = const Failure(NetworkError('offline'));

      final ok = await harness.vm.deleteSize(_draft.id);

      expect(ok, isFalse);
      expect(harness.vm.state.sizes, [_draft, _published]);
      expect(harness.vm.state.errorMessage, 'offline');
    });
  });

  group('AdminSizesViewModel — navigation', () {
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

  group('AdminSizesViewModel — connectivity restore', () {
    test('reloads sizes on offline → online transition', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(list.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(list.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(list.calls, hasLength(2));
    });

    test('does not reload when online → online (no transition)', () async {
      final list = _FakeListUseCase()..result = const Success([_draft]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);
      expect(list.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(list.calls, hasLength(1));
    });
  });

  group('AdminSizesViewModel — disposal', () {
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
        final list = _FakeListUseCase()..result = const Success([_draft]);
        final harness = _buildVm(user: _adminUser, listUseCase: list);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await harness.authGateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);
        expect(list.calls, hasLength(1));

        harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        harness.vm.dispose();

        harness.connectivityRepo.controller.add(ConnectivityStatus.online);
        await Future<void>.delayed(Duration.zero);

        expect(list.calls, hasLength(1));
      },
    );
  });
}
