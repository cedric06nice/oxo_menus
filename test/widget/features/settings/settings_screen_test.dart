import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_view.dart';

import '../../../helpers/build_view_model_test_harness.dart';

const _admin = User(
  id: 'a1',
  email: 'admin@example.com',
  firstName: 'Ada',
  lastName: 'Lovelace',
  role: UserRole.admin,
);
const _regular = User(
  id: 'r1',
  email: 'user@example.com',
  firstName: 'Bob',
  lastName: 'Builder',
  role: UserRole.user,
);

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository(this.user);
  final User? user;
  Result<void, DomainError> resetResult = const Success(null);
  Result<void, DomainError> logoutResult = const Success(null);
  int logoutCalls = 0;
  final List<({String email, String? resetUrl})> resetCalls =
      <({String email, String? resetUrl})>[];

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      user == null ? const Failure(UnauthorizedError()) : Success(user!);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      user == null ? const Failure(UnauthorizedError()) : Success(user!);

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async {
    resetCalls.add((email: email, resetUrl: resetUrl));
    return resetResult;
  }

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

class _FakeAppVersionGateway implements AppVersionGateway {
  String value = '1.2.3 (42)';
  Completer<void>? _gate;

  void blockNextRead() => _gate = Completer<void>();
  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<String> read() async {
    if (_gate != null) await _gate!.future;
    return value;
  }
}

class _RecordingRouter implements SettingsRouter {
  int backCalls = 0;

  @override
  void goBack() => backCalls++;
}

typedef _Harness = ({
  SettingsViewModel vm,
  _StubAuthRepository auth,
  _FakeAppVersionGateway version,
  AdminViewAsUserGateway viewAs,
  _RecordingRouter router,
  AuthGateway authGateway,
});

Future<_Harness> _buildVm({User? user, String version = '1.2.3 (42)'}) =>
    _buildVmCore(
      user: user,
      versionGateway: _FakeAppVersionGateway()..value = version,
    );

Future<_Harness> _buildVmWithGatedVersion({required User user}) {
  final versionGateway = _FakeAppVersionGateway()..blockNextRead();
  return _buildVmCore(user: user, versionGateway: versionGateway);
}

Future<_Harness> _buildVmCore({
  required User? user,
  required _FakeAppVersionGateway versionGateway,
}) async {
  final repo = _StubAuthRepository(user);
  final auth = AuthGateway(repository: repo);
  if (user != null) {
    await auth.tryRestoreSession();
  }
  final viewAs = AdminViewAsUserGateway();
  final router = _RecordingRouter();

  final vm = SettingsViewModel(
    getOverview: GetSettingsOverviewUseCase(
      authGateway: auth,
      adminViewAsUserGateway: viewAs,
    ),
    getAppVersion: GetAppVersionUseCase(gateway: versionGateway),
    requestPasswordReset: RequestPasswordResetUseCase(authGateway: auth),
    logout: LogoutUseCase(authGateway: auth),
    setAdminViewAsUser: SetAdminViewAsUserUseCase(gateway: viewAs),
    adminViewAsUserGateway: viewAs,
    router: router,
  );
  addTearDown(viewAs.dispose);
  addTearDown(auth.dispose);
  return (
    vm: vm,
    auth: repo,
    version: versionGateway,
    viewAs: viewAs,
    router: router,
    authGateway: auth,
  );
}

void main() {
  group('SettingsScreen — chrome', () {
    testWidgets('shows AppBar with Settings title and back button', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('shows loading indicator while user is null', (tester) async {
      final h = await _buildVm();

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );

      expect(find.byType(CircularProgressIndicator), findsAny);
    });

    testWidgets('back button delegates to viewModel.goBack', (tester) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(h.router.backCalls, 1);
    });
  });

  group('SettingsScreen — profile section', () {
    testWidgets('renders full name, email, role chip, and avatar view', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('admin@example.com'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.byType(UserAvatarView), findsOneWidget);
    });

    testWidgets('regular user shows User chip', (tester) async {
      final h = await _buildVm(user: _regular);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('User'), findsOneWidget);
      expect(find.text('Bob Builder'), findsOneWidget);
    });

    testWidgets('falls back to email when no name is set', (tester) async {
      const noName = User(
        id: 'x',
        email: 'noname@example.com',
        role: UserRole.user,
      );
      final h = await _buildVm(user: noName);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('noname@example.com'), findsAtLeastNWidgets(1));
    });
  });

  group('SettingsScreen — account section', () {
    testWidgets('shows Reset Password and Logout tiles', (tester) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('tapping Reset Password fires the password-reset request', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(h.auth.resetCalls.single.email, _admin.email);
    });

    testWidgets('successful reset shows a snackbar with the email', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining(_admin.email), findsAtLeastNWidgets(1));
    });

    testWidgets('failed reset shows a snackbar with the error message', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);
      h.auth.resetResult = const Failure(NetworkError('offline'));

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('offline'), findsOneWidget);
    });

    testWidgets('tapping Logout invokes confirmer; cancel does not log out', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(h.auth.logoutCalls, 0);
    });

    testWidgets('confirmed logout calls the gateway', (tester) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(h.auth.logoutCalls, 1);
    });
  });

  group('SettingsScreen — debug section (admin only)', () {
    testWidgets('admin sees Debug section', (tester) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Debug'), findsOneWidget);
      expect(find.text('Show as non-admin user'), findsOneWidget);
    });

    testWidgets('regular user does NOT see Debug section', (tester) async {
      final h = await _buildVm(user: _regular);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Debug'), findsNothing);
    });

    testWidgets('toggling the switch updates the gateway', (tester) async {
      final h = await _buildVm(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(h.viewAs.currentValue, isTrue);
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isTrue);
    });
  });

  group('SettingsScreen — about section', () {
    testWidgets('shows version with build number after eager load', (
      tester,
    ) async {
      final h = await _buildVm(user: _admin, version: '2.5.0 (12)');

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Version 2.5.0 (12)'), findsOneWidget);
    });

    testWidgets('shows "Version ..." while version load is gated', (
      tester,
    ) async {
      final h = await _buildVmWithGatedVersion(user: _admin);

      await pumpScreenWithViewModel(
        tester,
        viewModel: h.vm,
        screenBuilder: (vm) =>
            SettingsScreen(viewModel: vm, confirmLogout: (_) async => false),
      );
      await tester.pump();

      expect(find.text('Version ...'), findsOneWidget);

      h.version.release();
      await tester.pumpAndSettle();
    });
  });
}
