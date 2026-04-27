import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
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

const _a4 = Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.published,
  direction: 'portrait',
);

const _a3 = Size(
  id: 2,
  name: 'A3',
  width: 297,
  height: 420,
  status: Status.published,
  direction: 'portrait',
);

const _dining = Area(id: 1, name: 'Dining');
const _bar = Area(id: 2, name: 'Bar');

const _createdMenu = Menu(
  id: 99,
  name: 'My Template',
  version: '1.0.0',
  status: Status.draft,
  displayOptions: MenuDisplayOptions(),
);

class _FakeListSizes implements ListSizesForCreatorUseCase {
  Result<List<Size>, DomainError> result = const Success([_a4, _a3]);
  final List<NoInput> calls = [];
  Completer<void>? _gate;

  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<List<Size>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _FakeListAreas implements ListAreasForCreatorUseCase {
  Result<List<Area>, DomainError> result = const Success([_dining, _bar]);
  final List<NoInput> calls = [];

  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeCreateTemplate implements CreateTemplateUseCase {
  Result<Menu, DomainError> result = const Success(_createdMenu);
  final List<CreateTemplateInput> calls = [];
  Completer<Result<Menu, DomainError>>? _gate;

  void blockNextCall() {
    _gate = Completer<Result<Menu, DomainError>>();
  }

  void release() {
    _gate?.complete(result);
    _gate = null;
  }

  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) {
    calls.add(input);
    if (_gate != null) {
      return _gate!.future;
    }
    return Future.value(result);
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

class _RecordingRouter implements AdminTemplateCreatorRouter {
  int backCalls = 0;
  int adminSizesCalls = 0;
  final List<int> templateEditorCalls = [];

  @override
  void goBack() => backCalls++;

  @override
  void goToAdminSizes() => adminSizesCalls++;

  @override
  void goToAdminTemplateEditor(int menuId) => templateEditorCalls.add(menuId);
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
  AdminTemplateCreatorViewModel vm,
  _FakeListSizes listSizes,
  _FakeListAreas listAreas,
  _FakeCreateTemplate createTemplate,
  _RecordingRouter router,
  AuthGateway authGateway,
  ConnectivityGateway connectivityGateway,
  _StubConnectivityRepository connectivityRepo,
})
_buildVm({
  User? user,
  _FakeListSizes? listSizes,
  _FakeListAreas? listAreas,
  _FakeCreateTemplate? createTemplate,
}) {
  final list = listSizes ?? _FakeListSizes();
  final areas = listAreas ?? _FakeListAreas();
  final create = createTemplate ?? _FakeCreateTemplate();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final authGateway = AuthGateway(repository: authRepo);
  final vm = AdminTemplateCreatorViewModel(
    listSizes: list,
    listAreas: areas,
    createTemplate: create,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    listSizes: list,
    listAreas: areas,
    createTemplate: create,
    router: router,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

void main() {
  group('AdminTemplateCreatorViewModel — initial state', () {
    test('isAdmin is true for admin viewers', () async {
      final authGateway = await _gatewayFor(_adminUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminTemplateCreatorViewModel(
        listSizes: _FakeListSizes(),
        listAreas: _FakeListAreas(),
        createTemplate: _FakeCreateTemplate(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isTrue);
    });

    test('isAdmin is false for regular viewers', () async {
      final authGateway = await _gatewayFor(_regularUser);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminTemplateCreatorViewModel(
        listSizes: _FakeListSizes(),
        listAreas: _FakeListAreas(),
        createTemplate: _FakeCreateTemplate(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('isAdmin is false for anonymous viewers', () async {
      final authGateway = await _gatewayFor(null);
      addTearDown(authGateway.dispose);
      final connectivityRepo = _StubConnectivityRepository();
      addTearDown(connectivityRepo.close);
      final connectivityGateway = ConnectivityGateway(
        repository: connectivityRepo,
      );
      addTearDown(connectivityGateway.dispose);

      final vm = AdminTemplateCreatorViewModel(
        listSizes: _FakeListSizes(),
        listAreas: _FakeListAreas(),
        createTemplate: _FakeCreateTemplate(),
        authGateway: authGateway,
        connectivityGateway: connectivityGateway,
        router: _RecordingRouter(),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isFalse);
    });

    test('starts with both loading flags true and selections empty', () async {
      final list = _FakeListSizes()..blockNextCall();
      final harness = _buildVm(user: _adminUser, listSizes: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      expect(harness.vm.state.isLoadingSizes, isTrue);
      expect(harness.vm.state.isLoadingAreas, isTrue);
      expect(harness.vm.state.selectedSize, isNull);
      expect(harness.vm.state.selectedArea, isNull);
      expect(harness.vm.state.isSaving, isFalse);
      expect(harness.vm.state.errorMessage, isNull);

      list.release();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('AdminTemplateCreatorViewModel — initial load', () {
    test('drives both use cases once and exposes the data', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.listSizes.calls, hasLength(1));
      expect(harness.listAreas.calls, hasLength(1));
      expect(harness.vm.state.sizes, [_a4, _a3]);
      expect(harness.vm.state.areas, [_dining, _bar]);
      expect(harness.vm.state.isLoadingSizes, isFalse);
      expect(harness.vm.state.isLoadingAreas, isFalse);
    });

    test('auto-selects the first size on a successful sizes load', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.selectedSize, _a4);
    });

    test('does not select when the sizes list is empty', () async {
      final list = _FakeListSizes()..result = const Success(<Size>[]);
      final harness = _buildVm(user: _adminUser, listSizes: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.sizes, isEmpty);
      expect(harness.vm.state.selectedSize, isNull);
    });

    test(
      'does not override an explicit selection when sizes load completes later',
      () async {
        final list = _FakeListSizes()..blockNextCall();
        final harness = _buildVm(user: _adminUser, listSizes: list);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);

        harness.vm.setSelectedSize(_a3);
        list.release();
        await Future<void>.delayed(Duration.zero);

        expect(harness.vm.state.selectedSize, _a3);
      },
    );

    test('exposes errorMessage when sizes load fails', () async {
      final list = _FakeListSizes()
        ..result = const Failure(NetworkError('sizes are down'));
      final harness = _buildVm(user: _adminUser, listSizes: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isLoadingSizes, isFalse);
      expect(harness.vm.state.errorMessage, 'sizes are down');
      expect(harness.vm.state.sizes, isEmpty);
    });

    test('exposes errorMessage when areas load fails', () async {
      final areas = _FakeListAreas()
        ..result = const Failure(NetworkError('areas are down'));
      final harness = _buildVm(user: _adminUser, listAreas: areas);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isLoadingAreas, isFalse);
      expect(harness.vm.state.errorMessage, 'areas are down');
    });
  });

  group('AdminTemplateCreatorViewModel — selection setters', () {
    test('setSelectedSize replaces the selection and notifies', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      var notifications = 0;
      harness.vm.addListener(() => notifications++);

      harness.vm.setSelectedSize(_a3);

      expect(harness.vm.state.selectedSize, _a3);
      expect(notifications, 1);
    });

    test('setSelectedSize is a no-op when the value is unchanged', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      // _a4 was auto-selected during load; selecting it again notifies nothing.
      var notifications = 0;
      harness.vm.addListener(() => notifications++);

      harness.vm.setSelectedSize(_a4);

      expect(notifications, 0);
    });

    test('setSelectedArea replaces the selection and accepts null', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      harness.vm.setSelectedArea(_dining);
      expect(harness.vm.state.selectedArea, _dining);

      harness.vm.setSelectedArea(null);
      expect(harness.vm.state.selectedArea, isNull);
    });
  });

  group('AdminTemplateCreatorViewModel — createTemplate', () {
    test('marks isSaving while the use case is in flight', () async {
      final create = _FakeCreateTemplate()..blockNextCall();
      final harness = _buildVm(user: _adminUser, createTemplate: create);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final saveFuture = harness.vm.createTemplate(
        name: 'My Template',
        version: '1.0.0',
      );

      expect(harness.vm.state.isSaving, isTrue);

      create.release();
      await saveFuture;

      expect(harness.vm.state.isSaving, isFalse);
    });

    test('on success forwards to router.goToAdminTemplateEditor', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.createTemplate(
        name: 'My Template',
        version: '1.0.0',
      );

      expect(ok, isTrue);
      expect(harness.createTemplate.calls.single.name, 'My Template');
      expect(harness.createTemplate.calls.single.version, '1.0.0');
      expect(harness.createTemplate.calls.single.sizeId, _a4.id);
      expect(harness.createTemplate.calls.single.areaId, isNull);
      expect(harness.router.templateEditorCalls, [_createdMenu.id]);
      expect(harness.vm.state.isSaving, isFalse);
      expect(harness.vm.state.errorMessage, isNull);
    });

    test('forwards areaId when an area is selected', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      harness.vm.setSelectedArea(_bar);

      await harness.vm.createTemplate(name: 'X', version: '1.0.0');

      expect(harness.createTemplate.calls.single.areaId, _bar.id);
    });

    test(
      'on failure surfaces errorMessage, clears isSaving, returns false, and '
      'does not navigate',
      () async {
        final create = _FakeCreateTemplate()
          ..result = const Failure(NetworkError('boom'));
        final harness = _buildVm(user: _adminUser, createTemplate: create);
        addTearDown(harness.vm.dispose);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await Future<void>.delayed(Duration.zero);

        final ok = await harness.vm.createTemplate(
          name: 'My Template',
          version: '1.0.0',
        );

        expect(ok, isFalse);
        expect(harness.vm.state.isSaving, isFalse);
        expect(harness.vm.state.errorMessage, 'boom');
        expect(harness.router.templateEditorCalls, isEmpty);
      },
    );

    test('does nothing without a selectedSize', () async {
      final list = _FakeListSizes()..result = const Success(<Size>[]);
      final harness = _buildVm(user: _adminUser, listSizes: list);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final ok = await harness.vm.createTemplate(name: 'X', version: '1.0.0');

      expect(ok, isFalse);
      expect(harness.createTemplate.calls, isEmpty);
      expect(harness.vm.state.isSaving, isFalse);
    });

    test('is a no-op when invoked while already saving', () async {
      final create = _FakeCreateTemplate()..blockNextCall();
      final harness = _buildVm(user: _adminUser, createTemplate: create);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final first = harness.vm.createTemplate(name: 'X', version: '1.0.0');
      final secondOk = await harness.vm.createTemplate(
        name: 'Y',
        version: '2.0.0',
      );

      expect(secondOk, isFalse);
      expect(create.calls, hasLength(1));

      create.release();
      await first;
    });
  });

  group('AdminTemplateCreatorViewModel — navigation', () {
    test('goBack delegates to router.goBack', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.goBack();

      expect(harness.router.backCalls, 1);
    });

    test('openAdminSizes delegates to router.goToAdminSizes', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.openAdminSizes();

      expect(harness.router.adminSizesCalls, 1);
    });
  });

  group('AdminTemplateCreatorViewModel — connectivity restore', () {
    test('reloads both sizes and areas on offline → online', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(harness.listSizes.calls, hasLength(1));
      expect(harness.listAreas.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(harness.listSizes.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(harness.listSizes.calls, hasLength(2));
      expect(harness.listAreas.calls, hasLength(2));
    });

    test('does not reload when online → online (no transition)', () async {
      final harness = _buildVm(user: _adminUser);
      addTearDown(harness.vm.dispose);
      addTearDown(harness.authGateway.dispose);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(harness.listSizes.calls, hasLength(1));

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(harness.listSizes.calls, hasLength(1));
    });
  });

  group('AdminTemplateCreatorViewModel — disposal', () {
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
        final harness = _buildVm(user: _adminUser);
        addTearDown(harness.authGateway.dispose);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        await Future<void>.delayed(Duration.zero);
        expect(harness.listSizes.calls, hasLength(1));

        harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        harness.vm.dispose();

        harness.connectivityRepo.controller.add(ConnectivityStatus.online);
        await Future<void>.delayed(Duration.zero);

        expect(harness.listSizes.calls, hasLength(1));
      },
    );
  });
}
