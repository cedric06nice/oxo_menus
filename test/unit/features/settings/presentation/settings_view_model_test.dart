import 'dart:async';

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
import 'package:oxo_menus/features/settings/presentation/state/settings_state.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

const _admin = User(
  id: 'a1',
  email: 'admin@example.com',
  firstName: 'Ada',
  role: UserRole.admin,
);
const _regular = User(
  id: 'r1',
  email: 'user@example.com',
  firstName: 'Bob',
  role: UserRole.user,
);

class _RecordingAuthRepository implements AuthRepository {
  Result<User, DomainError> restored = const Failure(UnauthorizedError());
  Result<void, DomainError> resetResult = const Success(null);
  Result<void, DomainError> logoutResult = const Success(null);
  int logoutCalls = 0;
  final List<({String email, String? resetUrl})> resetCalls =
      <({String email, String? resetUrl})>[];

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => restored;

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => restored;

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
  String value = '1.0.0 (1)';
  Object? failure;
  Completer<void>? _gate;

  void blockNextRead() => _gate = Completer<void>();
  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<String> read() async {
    if (_gate != null) await _gate!.future;
    if (failure != null) throw failure!;
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
  _RecordingAuthRepository auth,
  _FakeAppVersionGateway version,
  AdminViewAsUserGateway viewAs,
  _RecordingRouter router,
  AuthGateway authGateway,
});

Future<_Harness> _buildVm({
  User? user,
  _FakeAppVersionGateway? versionGateway,
}) async {
  final repo = _RecordingAuthRepository();
  repo.restored = user == null
      ? const Failure(UnauthorizedError())
      : Success(user);
  final auth = AuthGateway(repository: repo);
  if (user != null) {
    await auth.tryRestoreSession();
  }
  final viewAs = AdminViewAsUserGateway();
  final version = versionGateway ?? _FakeAppVersionGateway();
  final router = _RecordingRouter();

  final vm = SettingsViewModel(
    getOverview: GetSettingsOverviewUseCase(
      authGateway: auth,
      adminViewAsUserGateway: viewAs,
    ),
    getAppVersion: GetAppVersionUseCase(gateway: version),
    requestPasswordReset: RequestPasswordResetUseCase(authGateway: auth),
    logout: LogoutUseCase(authGateway: auth),
    setAdminViewAsUser: SetAdminViewAsUserUseCase(gateway: viewAs),
    adminViewAsUserGateway: viewAs,
    router: router,
  );
  return (
    vm: vm,
    auth: repo,
    version: version,
    viewAs: viewAs,
    router: router,
    authGateway: auth,
  );
}

void _registerTeardowns(_Harness h) {
  addTearDown(h.vm.dispose);
  addTearDown(h.viewAs.dispose);
  addTearDown(h.authGateway.dispose);
}

void main() {
  group('SettingsState', () {
    test('default state is empty/idle', () {
      const state = SettingsState();

      expect(state.user, isNull);
      expect(state.isAdmin, isFalse);
      expect(state.viewAsUser, isFalse);
      expect(state.version, isNull);
      expect(state.passwordResetInFlight, isFalse);
      expect(state.passwordResetOutcome, PasswordResetOutcome.idle);
      expect(state.passwordResetMessage, isNull);
    });

    test('value equality compares all fields', () {
      const a = SettingsState(
        user: _admin,
        isAdmin: true,
        viewAsUser: true,
        version: '1.0',
        passwordResetInFlight: true,
        passwordResetOutcome: PasswordResetOutcome.sent,
        passwordResetMessage: 'sent',
      );
      const b = SettingsState(
        user: _admin,
        isAdmin: true,
        viewAsUser: true,
        version: '1.0',
        passwordResetInFlight: true,
        passwordResetOutcome: PasswordResetOutcome.sent,
        passwordResetMessage: 'sent',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith leaves untouched fields equal', () {
      const source = SettingsState(user: _admin, isAdmin: true);

      expect(source.copyWith(), source);
    });

    test('copyWith can null-out version via the sentinel', () {
      const source = SettingsState(version: '1.0');

      final cleared = source.copyWith(version: null);

      expect(cleared.version, isNull);
    });

    test('copyWith can null-out passwordResetMessage via the sentinel', () {
      const source = SettingsState(passwordResetMessage: 'hi');

      final cleared = source.copyWith(passwordResetMessage: null);

      expect(cleared.passwordResetMessage, isNull);
    });

    test('copyWith can null-out user via the sentinel', () {
      const source = SettingsState(user: _admin);

      final cleared = source.copyWith(user: null);

      expect(cleared.user, isNull);
    });
  });

  group('SettingsViewModel — initial state', () {
    test('reflects admin user, isAdmin=true, viewAsUser snapshot', () async {
      final version = _FakeAppVersionGateway()..blockNextRead();
      final h = await _buildVm(user: _admin, versionGateway: version);
      _registerTeardowns(h);

      expect(h.vm.state.user, _admin);
      expect(h.vm.state.isAdmin, isTrue);
      expect(h.vm.state.viewAsUser, isFalse);
      expect(h.vm.state.version, isNull); // version load gated

      version.release();
      await Future<void>.delayed(Duration.zero);
    });

    test('reflects regular user, isAdmin=false', () async {
      final h = await _buildVm(user: _regular);
      _registerTeardowns(h);

      expect(h.vm.state.user, _regular);
      expect(h.vm.state.isAdmin, isFalse);
    });

    test('user is null when nobody is signed in', () async {
      final h = await _buildVm();
      _registerTeardowns(h);

      expect(h.vm.state.user, isNull);
      expect(h.vm.state.isAdmin, isFalse);
    });

    test('eager version load populates state.version', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);

      await Future<void>.delayed(Duration.zero);

      expect(h.vm.state.version, '1.0.0 (1)');
    });

    test('version load failure surfaces "unknown"', () async {
      final version = _FakeAppVersionGateway()..failure = StateError('boom');
      final h = await _buildVm(user: _admin, versionGateway: version);
      _registerTeardowns(h);

      await Future<void>.delayed(Duration.zero);

      expect(h.vm.state.version, 'unknown');
    });
  });

  group('SettingsViewModel — requestPasswordReset', () {
    test('on success surfaces sent outcome with the email message', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);
      await Future<void>.delayed(Duration.zero);

      final ok = await h.vm.requestPasswordReset();

      expect(ok, isTrue);
      expect(h.auth.resetCalls.single.email, _admin.email);
      expect(h.auth.resetCalls.single.resetUrl, isNull);
      expect(h.vm.state.passwordResetOutcome, PasswordResetOutcome.sent);
      expect(h.vm.state.passwordResetMessage, contains(_admin.email));
      expect(h.vm.state.passwordResetInFlight, isFalse);
    });

    test('forwards the supplied resetUrl to the gateway', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);
      await Future<void>.delayed(Duration.zero);

      await h.vm.requestPasswordReset(resetUrl: 'https://example/reset');

      expect(h.auth.resetCalls.single.resetUrl, 'https://example/reset');
    });

    test('on failure exposes failed outcome and the error message', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);
      await Future<void>.delayed(Duration.zero);
      h.auth.resetResult = const Failure(NetworkError('offline'));

      final ok = await h.vm.requestPasswordReset();

      expect(ok, isFalse);
      expect(h.vm.state.passwordResetOutcome, PasswordResetOutcome.failed);
      expect(h.vm.state.passwordResetMessage, 'offline');
      expect(h.vm.state.passwordResetInFlight, isFalse);
    });

    test(
      'with no signed-in user is a no-op and surfaces failed outcome',
      () async {
        final h = await _buildVm();
        _registerTeardowns(h);

        final ok = await h.vm.requestPasswordReset();

        expect(ok, isFalse);
        expect(h.auth.resetCalls, isEmpty);
        expect(h.vm.state.passwordResetOutcome, PasswordResetOutcome.failed);
      },
    );
  });

  group('SettingsViewModel — acknowledgePasswordReset', () {
    test('clears the outcome and message back to idle', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);
      await Future<void>.delayed(Duration.zero);
      await h.vm.requestPasswordReset();
      expect(h.vm.state.passwordResetOutcome, PasswordResetOutcome.sent);

      h.vm.acknowledgePasswordReset();

      expect(h.vm.state.passwordResetOutcome, PasswordResetOutcome.idle);
      expect(h.vm.state.passwordResetMessage, isNull);
    });

    test('is a no-op when already idle (no notification)', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);
      // Drain the eager version load notification before counting.
      await Future<void>.delayed(Duration.zero);

      var notifications = 0;
      h.vm.addListener(() => notifications++);
      h.vm.acknowledgePasswordReset();

      expect(notifications, 0);
    });
  });

  group('SettingsViewModel — logout', () {
    test('delegates to the auth gateway', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);

      await h.vm.logout();

      expect(h.auth.logoutCalls, 1);
      expect(h.authGateway.status, isA<AuthStatusUnauthenticated>());
    });
  });

  group('SettingsViewModel — setViewAsUser', () {
    test('writes to the gateway and updates state via the stream', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);

      h.vm.setViewAsUser(true);
      await Future<void>.delayed(Duration.zero);

      expect(h.viewAs.currentValue, isTrue);
      expect(h.vm.state.viewAsUser, isTrue);
    });

    test(
      'idempotent — same value is a no-op (no state notification)',
      () async {
        final h = await _buildVm(user: _admin);
        _registerTeardowns(h);
        await Future<void>.delayed(Duration.zero);

        var notifications = 0;
        h.vm.addListener(() => notifications++);
        h.vm.setViewAsUser(false);
        await Future<void>.delayed(Duration.zero);

        expect(notifications, 0);
      },
    );

    test('external gateway changes propagate into state', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);

      h.viewAs.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(h.vm.state.viewAsUser, isTrue);
    });
  });

  group('SettingsViewModel — navigation', () {
    test('goBack delegates to router.goBack', () async {
      final h = await _buildVm(user: _admin);
      _registerTeardowns(h);

      h.vm.goBack();

      expect(h.router.backCalls, 1);
    });
  });

  group('SettingsViewModel — disposal', () {
    test('dispose marks the VM as disposed and ignores later events', () async {
      final h = await _buildVm(user: _admin);
      addTearDown(h.viewAs.dispose);
      addTearDown(h.authGateway.dispose);

      h.vm.dispose();
      expect(h.vm.isDisposed, isTrue);

      h.viewAs.set(true);
      await Future<void>.delayed(Duration.zero);
      expect(h.vm.state.viewAsUser, isFalse);
    });

    test('version load resolving after dispose does not emit', () async {
      final version = _FakeAppVersionGateway()..blockNextRead();
      final h = await _buildVm(user: _admin, versionGateway: version);
      addTearDown(h.viewAs.dispose);
      addTearDown(h.authGateway.dispose);

      h.vm.dispose();
      version.release();
      await Future<void>.delayed(Duration.zero);

      expect(h.vm.isDisposed, isTrue);
    });
  });
}
