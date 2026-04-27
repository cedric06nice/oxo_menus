import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/admin_templates/presentation/widgets/template_card.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';

import '../../../helpers/build_view_model_test_harness.dart';

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

final _draft = Menu(
  id: 1,
  name: 'Cocktails Spring',
  status: Status.draft,
  version: '1.0',
  dateUpdated: DateTime(2026, 4, 26, 10),
);

final _published = Menu(
  id: 2,
  name: 'Cocktails Summer',
  status: Status.published,
  version: '1.0',
  dateUpdated: DateTime(2026, 4, 26, 11),
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

class _FakeListUseCase implements ListTemplatesForAdminUseCase {
  Result<List<Menu>, DomainError> result = const Success(<Menu>[]);
  final List<ListTemplatesForAdminInput> calls = [];
  Completer<void>? gate;

  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async {
    calls.add(input);
    if (gate != null) {
      await gate!.future;
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

Future<
  ({
    AdminTemplatesViewModel vm,
    _RecordingRouter router,
    _FakeListUseCase listUseCase,
    _FakeDeleteUseCase deleteUseCase,
    _StubConnectivityRepository connectivityRepo,
    AuthGateway authGateway,
    ConnectivityGateway connectivityGateway,
  })
>
_buildVm({
  required User? user,
  Result<List<Menu>, DomainError> templates = const Success(<Menu>[]),
  bool blockFirstLoad = false,
}) async {
  final list = _FakeListUseCase()..result = templates;
  if (blockFirstLoad) {
    list.gate = Completer<void>();
  }
  final delete = _FakeDeleteUseCase();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(user);
  final authGateway = AuthGateway(repository: authRepo);
  if (user != null) {
    await authGateway.tryRestoreSession();
  }
  final vm = AdminTemplatesViewModel(
    listTemplates: list,
    deleteTemplate: delete,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    router: router,
    listUseCase: list,
    deleteUseCase: delete,
    connectivityRepo: connectivityRepo,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('AdminTemplatesScreen — chrome', () {
    testWidgets('renders an AppBar with title "Templates"', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Templates'), findsOneWidget);
    });

    testWidgets('shows the Add action only for admin viewers', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides the Add action for non-admin viewers', (tester) async {
      final harness = await _buildVm(user: _regularUser);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('AdminTemplatesScreen — loading & error', () {
    testWidgets('shows a loading indicator while the first load is in flight', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser, blockFirstLoad: true);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      harness.listUseCase.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows an error state with a retry button on failure', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping Retry re-runs the load', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      harness.listUseCase.result = Success([_published]);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Cocktails Summer'), findsOneWidget);
    });
  });

  group('AdminTemplatesScreen — empty state', () {
    testWidgets('shows the empty state when no templates exist', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No templates found'), findsOneWidget);
    });
  });

  group('AdminTemplatesScreen — grid', () {
    testWidgets('renders a TemplateCard per template', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: Success([_draft, _published]),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TemplateCard), findsNWidgets(2));
      expect(find.text('Cocktails Spring'), findsOneWidget);
      expect(find.text('Cocktails Summer'), findsOneWidget);
    });

    testWidgets('selecting a status filter narrows the visible templates', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: Success([_draft, _published]),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cocktails Spring'), findsOneWidget);
      expect(find.text('Cocktails Summer'), findsOneWidget);

      // The use case is called again with the new filter; configure the next
      // payload to return only the published one.
      harness.listUseCase.result = Success([_published]);
      await tester.tap(find.text('Published'));
      await tester.pumpAndSettle();

      expect(find.text('Cocktails Spring'), findsNothing);
      expect(find.text('Cocktails Summer'), findsOneWidget);
    });
  });

  group('AdminTemplatesScreen — interactions', () {
    testWidgets('tapping a template card calls vm.openTemplate', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: Success([_draft]),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cocktails Spring'));
      await tester.pumpAndSettle();

      expect(harness.router.editorTaps, [_draft.id]);
    });

    testWidgets('tapping the create action calls vm.openCreateTemplate', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(harness.router.createTaps, 1);
    });

    testWidgets(
      'tapping the empty state Create action calls vm.openCreateTemplate',
      (tester) async {
        final harness = await _buildVm(user: _adminUser);
        await pumpScreenWithViewModel<AdminTemplatesViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Template'));
        await tester.pumpAndSettle();

        expect(harness.router.createTaps, 1);
      },
    );

    testWidgets('cancelling the delete dialog leaves the template in place', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: Success([_draft]),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(harness.deleteUseCase.calls, isEmpty);
      expect(find.text('Cocktails Spring'), findsOneWidget);
    });

    testWidgets('confirming the delete dialog calls vm.deleteTemplate', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        templates: Success([_draft]),
      );
      await pumpScreenWithViewModel<AdminTemplatesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminTemplatesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(harness.deleteUseCase.calls, [_draft.id]);
      expect(find.text('Cocktails Spring'), findsNothing);
    });
  });
}
