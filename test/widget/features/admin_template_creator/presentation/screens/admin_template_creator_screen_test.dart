import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
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

import '../../../../../helpers/build_view_model_test_harness.dart';

const _adminUser = User(
  id: 'u-admin',
  email: 'admin@example.com',
  role: UserRole.admin,
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

class _FakeListSizes implements ListSizesForCreatorUseCase {
  Result<List<Size>, DomainError> result = const Success([_a4, _a3]);
  Completer<void>? gate;
  final List<NoInput> calls = [];

  @override
  Future<Result<List<Size>, DomainError>> execute(NoInput input) async {
    calls.add(input);
    if (gate != null) {
      await gate!.future;
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

  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) async {
    calls.add(input);
    return result;
  }
}

class _RecordingRouter implements AdminTemplateCreatorRouter {
  int backCalls = 0;
  int adminSizesCalls = 0;
  final List<int> editorCalls = [];

  @override
  void goBack() => backCalls++;

  @override
  void goToAdminSizes() => adminSizesCalls++;

  @override
  void goToAdminTemplateEditor(int menuId) => editorCalls.add(menuId);
}

Future<
  ({
    AdminTemplateCreatorViewModel vm,
    _RecordingRouter router,
    _FakeListSizes listSizes,
    _FakeListAreas listAreas,
    _FakeCreateTemplate createTemplate,
    AuthGateway authGateway,
    ConnectivityGateway connectivityGateway,
  })
>
_buildVm({
  required User? user,
  Result<List<Size>, DomainError> sizes = const Success([_a4, _a3]),
  Result<List<Area>, DomainError> areas = const Success([_dining, _bar]),
  bool blockFirstLoad = false,
}) async {
  final list = _FakeListSizes()..result = sizes;
  if (blockFirstLoad) {
    list.gate = Completer<void>();
  }
  final areasUc = _FakeListAreas()..result = areas;
  final create = _FakeCreateTemplate();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(user);
  final authGateway = AuthGateway(repository: authRepo);
  if (user != null) {
    await authGateway.tryRestoreSession();
  }
  final vm = AdminTemplateCreatorViewModel(
    listSizes: list,
    listAreas: areasUc,
    createTemplate: create,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    router: router,
    listSizes: list,
    listAreas: areasUc,
    createTemplate: create,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
  );
}

Future<void> _enterText(
  WidgetTester tester, {
  required String name,
  required String version,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), version);
  await tester.pump();
}

void main() {
  group('AdminTemplateCreatorScreen — chrome', () {
    testWidgets('renders an AppBar with title "Create Template"', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Create Template'), findsOneWidget);
    });

    testWidgets('AppBar close button calls router.goBack', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      expect(harness.router.backCalls, 1);
    });

    testWidgets('Cancel button calls router.goBack', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      expect(harness.router.backCalls, 1);
    });
  });

  group('AdminTemplateCreatorScreen — loading state', () {
    testWidgets(
      'shows a loading indicator next to "Loading sizes..." while the first '
      'sizes load is in flight',
      (tester) async {
        final harness = await _buildVm(user: _adminUser, blockFirstLoad: true);
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pump();

        expect(find.text('Loading sizes...'), findsOneWidget);

        harness.listSizes.gate!.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('AdminTemplateCreatorScreen — empty sizes', () {
    testWidgets(
      'shows the "No page sizes available" message and a "Manage Page Sizes" '
      'button when no sizes exist',
      (tester) async {
        final harness = await _buildVm(
          user: _adminUser,
          sizes: const Success(<Size>[]),
        );
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        expect(find.text('No page sizes available.'), findsOneWidget);
        expect(find.text('Manage Page Sizes'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping "Manage Page Sizes" delegates to router.goToAdminSizes',
      (tester) async {
        final harness = await _buildVm(
          user: _adminUser,
          sizes: const Success(<Size>[]),
        );
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Page Sizes'));
        expect(harness.router.adminSizesCalls, 1);
      },
    );
  });

  group('AdminTemplateCreatorScreen — form behavior', () {
    testWidgets('Create button is disabled until the name field is filled in', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      // Version is pre-filled as `1.0.0` and a size is auto-selected, but
      // name starts empty so Create stays disabled.
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create'),
      );
      expect(createButton.onPressed, isNull);

      await _enterText(tester, name: 'My Template', version: '1.0.0');

      final enabled = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create'),
      );
      expect(enabled.onPressed, isNotNull);
    });

    testWidgets(
      'Create button is disabled when no size is selected (empty list)',
      (tester) async {
        final harness = await _buildVm(
          user: _adminUser,
          sizes: const Success(<Size>[]),
        );
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();
        await _enterText(tester, name: 'My Template', version: '1.0.0');

        final createButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(createButton.onPressed, isNull);
      },
    );

    testWidgets(
      'tapping Create with valid input invokes the use case and navigates to '
      'the editor on success',
      (tester) async {
        final harness = await _buildVm(user: _adminUser);
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();
        await _enterText(tester, name: 'My Template', version: '1.0.0');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        expect(harness.createTemplate.calls.single.name, 'My Template');
        expect(harness.createTemplate.calls.single.version, '1.0.0');
        expect(harness.createTemplate.calls.single.sizeId, _a4.id);
        expect(harness.createTemplate.calls.single.areaId, isNull);
        expect(harness.router.editorCalls, [_createdMenu.id]);
      },
    );

    testWidgets(
      'failed create surfaces the error in a SnackBar and stays on the screen',
      (tester) async {
        final harness = await _buildVm(user: _adminUser);
        harness.createTemplate.result = const Failure(NetworkError('boom'));
        await pumpScreenWithViewModel<AdminTemplateCreatorViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplateCreatorScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();
        await _enterText(tester, name: 'My Template', version: '1.0.0');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pump();
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('boom'), findsOneWidget);
        expect(harness.router.editorCalls, isEmpty);
      },
    );
  });
}
