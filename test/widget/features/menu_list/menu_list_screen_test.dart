import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/menu_list_item.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';

import '../../../helpers/build_view_model_test_harness.dart';

const _adminUser = User(
  id: 'u-1',
  email: 'admin@example.com',
  role: UserRole.admin,
);

const _regularUser = User(
  id: 'u-2',
  email: 'alice@example.com',
  role: UserRole.user,
);

const _bar = Area(id: 1, name: 'Bar');
const _terrace = Area(id: 2, name: 'Terrace');

final _draftBar = Menu(
  id: 1,
  name: 'Cocktails Spring',
  status: Status.draft,
  version: '1.0',
  area: _bar,
  dateUpdated: DateTime(2026, 4, 26, 10),
);
final _publishedBar = Menu(
  id: 2,
  name: 'Cocktails Summer',
  status: Status.published,
  version: '1.0',
  area: _bar,
  dateUpdated: DateTime(2026, 4, 26, 11),
);
final _terraceMenu = Menu(
  id: 3,
  name: 'Terrace Lunch',
  status: Status.published,
  version: '1.0',
  area: _terrace,
  dateUpdated: DateTime(2026, 4, 26, 12),
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

class _FakeListMenusForViewerUseCase implements ListMenusForViewerUseCase {
  Result<List<Menu>, DomainError> result = const Success(<Menu>[]);
  Completer<void>? gate;

  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async {
    if (gate != null) {
      await gate!.future;
    }
    return result;
  }
}

class _FakeCreateMenuUseCase implements CreateMenuUseCase {
  Result<Menu, DomainError> result = const Failure(UnauthorizedError());
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
  Result<Menu, DomainError> result = const Failure(UnauthorizedError());
  final List<int> calls = [];

  @override
  Future<Result<Menu, DomainError>> execute(int sourceMenuId) async {
    calls.add(sourceMenuId);
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _RecordingMenuListRouter implements MenuListRouter {
  final List<int> menuTaps = [];
  final List<int> editorTaps = [];
  int backCalls = 0;

  @override
  void goToMenuEditor(int menuId) => menuTaps.add(menuId);

  @override
  void goToAdminTemplateEditor(int menuId) => editorTaps.add(menuId);

  @override
  void goBack() => backCalls++;
}

Future<
  ({
    MenuListViewModel vm,
    _RecordingMenuListRouter router,
    _FakeListMenusForViewerUseCase listUseCase,
    _FakeCreateMenuUseCase createUseCase,
    _FakeDeleteMenuUseCase deleteUseCase,
    _FakeDuplicateMenuUseCase duplicateUseCase,
    _StubConnectivityRepository connectivityRepo,
    AuthGateway authGateway,
    ConnectivityGateway connectivityGateway,
  })
>
_buildVm({
  required User? user,
  Result<List<Menu>, DomainError> menus = const Success(<Menu>[]),
  bool blockFirstLoad = false,
}) async {
  final list = _FakeListMenusForViewerUseCase()..result = menus;
  if (blockFirstLoad) {
    list.gate = Completer<void>();
  }
  final create = _FakeCreateMenuUseCase();
  final delete = _FakeDeleteMenuUseCase();
  final duplicate = _FakeDuplicateMenuUseCase();
  final router = _RecordingMenuListRouter();
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final authRepo = _StubAuthRepository(user);
  final authGateway = AuthGateway(repository: authRepo);
  if (user != null) {
    await authGateway.tryRestoreSession();
  }
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
    router: router,
    listUseCase: list,
    createUseCase: create,
    deleteUseCase: delete,
    duplicateUseCase: duplicate,
    connectivityRepo: connectivityRepo,
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
  );
}

Future<CreateMenuInput?> _noopOpener(BuildContext context) async => null;

void main() {
  group('MenuListScreen — chrome', () {
    testWidgets('renders an AppBar with title "Menus"', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Menus'), findsOneWidget);
    });

    testWidgets('shows the Add action only for admin viewers', (tester) async {
      final adminHarness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: adminHarness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides the Add action for regular viewers', (tester) async {
      final harness = await _buildVm(user: _regularUser);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(CupertinoIcons.add), findsNothing);
    });
  });

  group('MenuListScreen — loading & error', () {
    testWidgets('shows a loading indicator while the first load is in flight', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser, blockFirstLoad: true);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
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
        menus: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry re-runs the load', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: const Failure(NetworkError('No connection')),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      harness.listUseCase.result = Success([_publishedBar]);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Cocktails Summer'), findsOneWidget);
    });
  });

  group('MenuListScreen — empty state', () {
    testWidgets('shows the empty state when the list is empty', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
    });
  });

  group('MenuListScreen — admin grid', () {
    testWidgets('groups menus by area, sorted alphabetically', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_publishedBar, _terraceMenu, _draftBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Terrace'), findsOneWidget);
      expect(find.byType(MenuListItem), findsNWidgets(3));
    });

    testWidgets('admin sees the status filter bar', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_draftBar, _publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      // Filter chips include All / Draft / Published / Archived.
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
    });

    testWidgets('selecting a status filter narrows the visible menus', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_draftBar, _publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cocktails Spring'), findsOneWidget);
      expect(find.text('Cocktails Summer'), findsOneWidget);

      await tester.tap(find.text('Published'));
      await tester.pumpAndSettle();

      expect(find.text('Cocktails Spring'), findsNothing);
      expect(find.text('Cocktails Summer'), findsOneWidget);
    });
  });

  group('MenuListScreen — regular viewer', () {
    testWidgets('regular viewer does not see the status filter bar', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _regularUser,
        menus: Success([_publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsNothing);
      expect(find.text('Published'), findsNothing);
      expect(find.text('Cocktails Summer'), findsOneWidget);
    });
  });

  group('MenuListScreen — interactions', () {
    testWidgets('tapping a menu calls vm.openMenu via the router', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _regularUser,
        menus: Success([_publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cocktails Summer'));
      await tester.pumpAndSettle();

      expect(harness.router.menuTaps, [_publishedBar.id]);
    });

    testWidgets('tapping the edit icon opens the template editor for admins', (
      tester,
    ) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(harness.router.editorTaps, [_publishedBar.id]);
    });

    testWidgets('tapping duplicate triggers vm.duplicateMenu', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_publishedBar]),
      );
      harness.duplicateUseCase.result = Success(_draftBar);
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      expect(harness.duplicateUseCase.calls, [_publishedBar.id]);
    });

    testWidgets('tapping delete prompts a confirmation and removes the menu '
        'on confirm', (tester) async {
      final harness = await _buildVm(
        user: _adminUser,
        menus: Success([_publishedBar]),
      );
      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: _noopOpener,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      // Confirmation dialog appears — tap the "Delete" affirmative.
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(harness.deleteUseCase.calls, [_publishedBar.id]);
      expect(harness.vm.state.menus, isEmpty);
    });

    testWidgets('tapping Add invokes the create-template opener', (
      tester,
    ) async {
      final harness = await _buildVm(user: _adminUser);
      var openerCalls = 0;
      Future<CreateMenuInput?> opener(BuildContext context) async {
        openerCalls++;
        return null;
      }

      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) =>
            MenuListScreen(viewModel: vm, openCreateTemplateDialog: opener),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(openerCalls, 1);
    });

    testWidgets('on create-template success the screen routes to the new '
        'template editor', (tester) async {
      final harness = await _buildVm(user: _adminUser);
      harness.createUseCase.result = Success(_draftBar);
      const input = CreateMenuInput(name: 'New', version: '0.1');

      await pumpScreenWithViewModel<MenuListViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => MenuListScreen(
          viewModel: vm,
          openCreateTemplateDialog: (_) async => input,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(harness.createUseCase.calls.single, input);
      expect(harness.router.editorTaps, [_draftBar.id]);
    });
  });
}
