import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';

import '../../../../helpers/build_view_model_test_harness.dart';

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

class _FakeListUseCase implements ListSizesForAdminUseCase {
  Result<List<Size>, DomainError> result = const Success(<Size>[]);
  final List<ListSizesForAdminInput> calls = [];
  Completer<void>? gate;

  @override
  Future<Result<List<Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async {
    calls.add(input);
    if (gate != null) {
      await gate!.future;
    }
    return result;
  }
}

class _FakeCreateUseCase implements CreateSizeUseCase {
  Result<Size, DomainError> result = const Success(_draft);
  final List<CreateSizeInput> calls = [];

  @override
  Future<Result<Size, DomainError>> execute(CreateSizeInput input) async {
    calls.add(input);
    return result;
  }
}

class _FakeUpdateUseCase implements UpdateSizeUseCase {
  Result<Size, DomainError> result = const Success(_draft);
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

class _RecordingRouter implements AdminSizesRouter {
  int backCalls = 0;

  @override
  void goBack() => backCalls++;
}

Future<
  ({
    AdminSizesViewModel vm,
    _RecordingRouter router,
    _FakeListUseCase listUseCase,
    _FakeCreateUseCase createUseCase,
    _FakeUpdateUseCase updateUseCase,
    _FakeDeleteUseCase deleteUseCase,
    _StubConnectivityRepository connectivityRepo,
    AuthGateway authGateway,
    ConnectivityGateway connectivityGateway,
  })
>
_buildVm({
  required User? user,
  Result<List<Size>, DomainError> sizes = const Success(<Size>[]),
  bool blockFirstLoad = false,
}) async {
  final list = _FakeListUseCase()..result = sizes;
  if (blockFirstLoad) {
    list.gate = Completer<void>();
  }
  final create = _FakeCreateUseCase();
  final update = _FakeUpdateUseCase();
  final del = _FakeDeleteUseCase();
  final router = _RecordingRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(user);
  final authGateway = AuthGateway(repository: authRepo);
  if (user != null) {
    await authGateway.tryRestoreSession();
  }
  final vm = AdminSizesViewModel(
    listSizes: list,
    createSize: create,
    updateSize: update,
    deleteSize: del,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    router: router,
  );
  return (
    vm: vm,
    router: router,
    listUseCase: list,
    createUseCase: create,
    updateUseCase: update,
    deleteUseCase: del,
    connectivityRepo: connectivityRepo,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('AdminSizesScreen — chrome', () {
    testWidgets('renders an AppBar with title "Page Sizes"', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Page Sizes'), findsOneWidget);
    });

    testWidgets('shows the Add action only for admin viewers', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides the Add action for non-admin viewers', (tester) async {
      final harness = await _buildVm(user: _regularUser);
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('AdminSizesScreen — loading & error', () {
    testWidgets('shows a loading indicator while the first load is in flight', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser, blockFirstLoad: true);
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
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
        sizes: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping Retry re-runs the load', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        sizes: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      harness.listUseCase.result = const Success([_published]);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('A3 Published'), findsOneWidget);
    });
  });

  group('AdminSizesScreen — empty state', () {
    testWidgets('shows the empty state when no sizes exist', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No page sizes found'), findsOneWidget);
    });
  });

  group('AdminSizesScreen — list', () {
    testWidgets('renders a card per size', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        sizes: const Success([_draft, _published]),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.text('A4 Draft'), findsOneWidget);
      expect(find.text('A3 Published'), findsOneWidget);
    });

    testWidgets('selecting a status filter narrows the visible sizes', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        sizes: const Success([_draft, _published]),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();
      expect(find.text('A4 Draft'), findsOneWidget);
      expect(find.text('A3 Published'), findsOneWidget);

      harness.listUseCase.result = const Success([_published]);
      await tester.tap(find.text('Published'));
      await tester.pumpAndSettle();

      expect(find.text('A4 Draft'), findsNothing);
      expect(find.text('A3 Published'), findsOneWidget);
    });
  });

  group('AdminSizesScreen — create', () {
    testWidgets(
      'tapping the AppBar Add action opens the create dialog and saving '
      'invokes vm.createSize',
      (tester) async {
        final harness = await _buildVm(user: _adminUser);
        await pumpScreenWithViewModel<AdminSizesViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Custom');
        await tester.enterText(textFields.at(1), '150');
        await tester.enterText(textFields.at(2), '200');
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
        await tester.pumpAndSettle();

        expect(harness.createUseCase.calls, hasLength(1));
        final input = harness.createUseCase.calls.single;
        expect(input.name, 'Custom');
        expect(input.width, 150);
        expect(input.height, 200);
      },
    );

    testWidgets(
      'tapping the empty-state Create action opens the create dialog',
      (tester) async {
        final harness = await _buildVm(user: _adminUser);
        await pumpScreenWithViewModel<AdminSizesViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        // The empty state surfaces a FilledButton labelled "Create Page Size".
        await tester.tap(find.widgetWithText(FilledButton, 'Create Page Size'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(TextField), findsAtLeast(3));
      },
    );
  });

  group('AdminSizesScreen — delete', () {
    testWidgets('cancelling the delete dialog leaves the size in place', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        sizes: const Success([_draft]),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(harness.deleteUseCase.calls, isEmpty);
      expect(find.text('A4 Draft'), findsOneWidget);
    });

    testWidgets('confirming the delete dialog calls vm.deleteSize', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        sizes: const Success([_draft]),
      );
      await pumpScreenWithViewModel<AdminSizesViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(harness.deleteUseCase.calls, [_draft.id]);
      expect(find.text('A4 Draft'), findsNothing);
    });
  });

  group('AdminSizesScreen — edit', () {
    testWidgets(
      'tapping the edit icon opens the edit dialog prefilled with the size '
      'and saving invokes vm.updateSize',
      (tester) async {
        final harness = await _buildVm(
          user: _adminUser,
          sizes: const Success([_draft]),
        );
        await pumpScreenWithViewModel<AdminSizesViewModel>(
          tester,
          viewModel: harness.vm,
          screenBuilder: (vm) => AdminSizesScreen(viewModel: vm),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();
        // First TextField is "Name" — overwrite with the new value.
        await tester.enterText(find.byType(TextField).first, 'Renamed');
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
        await tester.pumpAndSettle();

        expect(harness.updateUseCase.calls, hasLength(1));
        final input = harness.updateUseCase.calls.single;
        expect(input.id, _draft.id);
        expect(input.name, 'Renamed');
      },
    );
  });
}
