import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/state/admin_templates_screen_state.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
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

const _draft = Menu(
  id: 1,
  name: 'Draft Template',
  status: Status.draft,
  version: '1.0',
);

const _published = Menu(
  id: 2,
  name: 'Published Template',
  status: Status.published,
  version: '1.0',
);

class _FakeListUseCase implements ListTemplatesForAdminUseCase {
  Result<List<Menu>, DomainError> result = const Success(<Menu>[]);
  final List<ListTemplatesForAdminInput> calls = [];
  Completer<void>? _gate;

  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _FakeDeleteUseCase implements DeleteTemplateUseCase {
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

class _RecordingRouter implements AdminTemplatesRouter {
  final List<int> editorTaps = [];
  int createTaps = 0;
  int backCalls = 0;

  @override
  void goToAdminTemplateCreate() => createTaps++;

  @override
  void goToAdminTemplateEditor(int menuId) => editorTaps.add(menuId);

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
  AdminTemplatesViewModel vm,
  _FakeListUseCase listUseCase,
  _FakeDeleteUseCase deleteUseCase,
  _RecordingRouter router,
  AuthGateway authGateway,
  ConnectivityGateway connectivityGateway,
  _StubConnectivityRepository connectivityRepo,
})
_buildVm({User? user, _FakeListUseCase? listUseCase}) {
  final list = listUseCase ?? _FakeListUseCase();
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
  final vm = AdminTemplatesViewModel(
    listTemplates: list,
    deleteTemplate: deleteUc,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    listUseCase: list,
    deleteUseCase: deleteUc,
    router: router,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

void main() {
  group('AdminTemplatesScreenState', () {
    test('default state is loading=true, no error, empty list, all filter, '
        'not admin', () {
      const state = AdminTemplatesScreenState();

      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.templates, isEmpty);
      expect(state.statusFilter, 'all');
      expect(state.isAdmin, isFalse);
    });

    test('value equality compares all fields', () {
      const a = AdminTemplatesScreenState(
        isLoading: false,
        templates: [_draft],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const b = AdminTemplatesScreenState(
        isLoading: false,
        templates: [_draft],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const c = AdminTemplatesScreenState(
        isLoading: false,
        templates: [_published],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = AdminTemplatesScreenState(
        isLoading: false,
        templates: [_draft],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(source.copyWith(), source);
    });

    test('copyWith can null-out errorMessage via the sentinel', () {
      const source = AdminTemplatesScreenState(
        errorMessage: 'boom',
        isLoading: false,
      );

      final cleared = source.copyWith(errorMessage: null);

      expect(cleared.errorMessage, isNull);
      expect(cleared.isLoading, isFalse);
    });
  });

  group('AdminTemplatesViewModel — initial state', () {
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

      final vm = AdminTemplatesViewModel(
        listTemplates: list,
        deleteTemplate: _FakeDeleteUseCase(),
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

      final vm = AdminTemplatesViewModel(
        listTemplates: list,
        deleteTemplate: _FakeDeleteUseCase(),
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

      final vm = AdminTemplatesViewModel(
        listTemplates: list,
        deleteTemplate: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('stays in isLoading=true with no templates while the first load is '
        'in flight', () async {
      final list = _FakeListUseCase()..blockNextCall();
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminTemplatesViewModel(
        listTemplates: list,
        deleteTemplate: _FakeDeleteUseCase(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(list.calls, hasLength(1));
      expect(vm.state.isLoading, isTrue);
      expect(vm.state.templates, isEmpty);

      list.release();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('AdminTemplatesViewModel — initial load', () {
    test('drives the use case once and exposes the templates', () async {
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
      expect(
        harness.listUseCase.calls.single,
        const ListTemplatesForAdminInput(),
      );
      expect(harness.vm.state.templates, [_draft, _published]);
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
        expect(harness.vm.state.templates, isEmpty);
      },
    );
  });

  group('AdminTemplatesViewModel — refresh', () {
    test('re-runs the use case and replaces the templates', () async {
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
      expect(harness.vm.state.templates, [_published]);
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
      expect(harness.vm.state.templates, [_draft]);
    });
  });

  group('AdminTemplatesViewModel — setStatusFilter', () {
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
          const ListTemplatesForAdminInput(statusFilter: 'draft'),
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

  group('AdminTemplatesViewModel — deleteTemplate', () {
    test('on success removes the template and returns true', () async {
      final list = _FakeListUseCase()
        ..result = const Success([_draft, _published]);
      final harness = _buildVm(user: _adminUser, listUseCase: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await harness.authGateway.tryRestoreSession();
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.deleteTemplate(_draft.id);

      expect(ok, isTrue);
      expect(harness.deleteUseCase.calls.single, _draft.id);
      expect(harness.vm.state.templates, [_published]);
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

      final ok = await harness.vm.deleteTemplate(_draft.id);

      expect(ok, isFalse);
      expect(harness.vm.state.templates, [_draft, _published]);
      expect(harness.vm.state.errorMessage, 'offline');
    });
  });

  group('AdminTemplatesViewModel — navigation', () {
    test('openTemplate delegates to router.goToAdminTemplateEditor', () {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.openTemplate(7);

      expect(harness.router.editorTaps, [7]);
    });

    test('openCreateTemplate delegates to router.goToAdminTemplateCreate', () {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.openCreateTemplate();

      expect(harness.router.createTaps, 1);
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

  group('AdminTemplatesViewModel — connectivity restore', () {
    test('reloads templates on offline → online transition', () async {
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
      // Going offline alone does not retrigger a load.
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

  group('AdminTemplatesViewModel — disposal', () {
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
