import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/reset_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';

class _FakeConfirmPasswordResetUseCase implements ConfirmPasswordResetUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<ConfirmPasswordResetInput> calls = <ConfirmPasswordResetInput>[];
  Completer<void>? _gate;

  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<void, DomainError>> execute(
    ConfirmPasswordResetInput input,
  ) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _RecordingResetPasswordRouter implements ResetPasswordRouter {
  int loginCalls = 0;
  int forgotCalls = 0;

  @override
  void goToLogin() => loginCalls++;

  @override
  void goToForgotPassword() => forgotCalls++;
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

({
  ResetPasswordViewModel vm,
  _StubConnectivityRepository connectivityRepo,
  ConnectivityGateway connectivityGateway,
})
_buildViewModel({
  _FakeConfirmPasswordResetUseCase? useCase,
  _RecordingResetPasswordRouter? router,
  String? token = 'tk-1',
}) {
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final vm = ResetPasswordViewModel(
    confirmPasswordReset: useCase ?? _FakeConfirmPasswordResetUseCase(),
    router: router ?? _RecordingResetPasswordRouter(),
    connectivityGateway: connectivityGateway,
    token: token,
  );
  return (
    vm: vm,
    connectivityRepo: connectivityRepo,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('ResetPasswordState', () {
    test('default state is idle, no errors, online', () {
      const state = ResetPasswordState();

      expect(state.passwordError, isNull);
      expect(state.confirmError, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.passwordChanged, isFalse);
      expect(state.isOffline, isFalse);
    });

    test('value equality compares all fields including isOffline', () {
      const a = ResetPasswordState();
      const b = ResetPasswordState();
      const c = ResetPasswordState(passwordChanged: true);
      const d = ResetPasswordState(errorMessage: 'oops');
      const e = ResetPasswordState(passwordError: 'short');
      const f = ResetPasswordState(confirmError: 'mismatch');
      const g = ResetPasswordState(isSubmitting: true);
      const h = ResetPasswordState(isOffline: true);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(a, isNot(e));
      expect(a, isNot(f));
      expect(a, isNot(g));
      expect(a, isNot(h));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = ResetPasswordState(
        passwordError: 'too short',
        confirmError: 'mismatch',
        isSubmitting: true,
        errorMessage: 'server',
        passwordChanged: false,
        isOffline: true,
      );

      final next = source.copyWith(isSubmitting: false);

      expect(next.passwordError, 'too short');
      expect(next.confirmError, 'mismatch');
      expect(next.errorMessage, 'server');
      expect(next.passwordChanged, isFalse);
      expect(next.isOffline, isTrue);
      expect(next.isSubmitting, isFalse);
    });

    test('copyWith allows clearing nullable fields explicitly to null', () {
      const source = ResetPasswordState(
        passwordError: 'short',
        confirmError: 'mismatch',
        errorMessage: 'server',
      );

      final next = source.copyWith(
        passwordError: null,
        confirmError: null,
        errorMessage: null,
      );

      expect(next.passwordError, isNull);
      expect(next.confirmError, isNull);
      expect(next.errorMessage, isNull);
    });
  });

  group('ResetPasswordViewModel — initial state', () {
    test('starts in idle state', () {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.state, const ResetPasswordState());
    });

    test('exposes the token it was constructed with', () {
      final harness = _buildViewModel(token: 'tk-42');
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.token, 'tk-42');
    });

    test('hasToken is false when constructed with null', () {
      final harness = _buildViewModel(token: null);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.hasToken, isFalse);
    });

    test('hasToken is false when constructed with the empty string', () {
      final harness = _buildViewModel(token: '');
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.hasToken, isFalse);
    });

    test('hasToken is true for a non-empty token', () {
      final harness = _buildViewModel(token: 'tk');
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.hasToken, isTrue);
    });
  });

  group('ResetPasswordViewModel — validation', () {
    test(
      'empty password surfaces passwordError and skips the use case',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase();
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(password: '', confirm: '');

        expect(harness.vm.state.passwordError, 'Please enter a new password');
        expect(harness.vm.state.isSubmitting, isFalse);
        expect(useCase.calls, isEmpty);
      },
    );

    test('password under 8 characters surfaces a length error', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(password: 'short', confirm: 'short');

      expect(
        harness.vm.state.passwordError,
        'Password must be at least 8 characters',
      );
      expect(useCase.calls, isEmpty);
    });

    test('mismatched confirm surfaces a confirmError', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(password: 'longenough', confirm: 'different1');

      expect(harness.vm.state.passwordError, isNull);
      expect(harness.vm.state.confirmError, 'Passwords do not match');
      expect(useCase.calls, isEmpty);
    });

    test(
      'an empty confirm with a valid password is treated as a mismatch',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase();
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(password: 'longenough', confirm: '');

        expect(harness.vm.state.confirmError, 'Passwords do not match');
        expect(useCase.calls, isEmpty);
      },
    );

    test('submit aborts with errorMessage when token is null', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase, token: null);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(password: 'longenough', confirm: 'longenough');

      expect(useCase.calls, isEmpty);
      expect(harness.vm.state.errorMessage, isNotNull);
    });

    test('a successful resubmit clears previous validation errors', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);
      await harness.vm.submit(password: '', confirm: '');

      await harness.vm.submit(password: 'longenough', confirm: 'longenough');

      expect(harness.vm.state.passwordError, isNull);
      expect(harness.vm.state.confirmError, isNull);
    });
  });

  group('ResetPasswordViewModel — submission', () {
    test('forwards token and password to the use case', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase, token: 'tk-9');
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(password: 'longenough', confirm: 'longenough');

      expect(useCase.calls, hasLength(1));
      expect(useCase.calls.single.token, 'tk-9');
      expect(useCase.calls.single.password, 'longenough');
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final pending = harness.vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test(
      'on success emits passwordChanged=true and clears submitting',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase();
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(password: 'longenough', confirm: 'longenough');

        expect(harness.vm.state.passwordChanged, isTrue);
        expect(harness.vm.state.isSubmitting, isFalse);
        expect(harness.vm.state.errorMessage, isNull);
      },
    );

    test('on failure exposes the error message and stops submitting', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()
        ..result = const Failure(NetworkError());
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(password: 'longenough', confirm: 'longenough');

      expect(harness.vm.state.isSubmitting, isFalse);
      expect(harness.vm.state.errorMessage, isNotNull);
      expect(harness.vm.state.passwordChanged, isFalse);
    });

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase()
          ..result = const Failure(NetworkError());
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);
        await harness.vm.submit(password: 'longenough', confirm: 'longenough');

        useCase.result = const Success(null);
        await harness.vm.submit(password: 'longenough', confirm: 'longenough');

        expect(harness.vm.state.errorMessage, isNull);
        expect(harness.vm.state.passwordChanged, isTrue);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final first = harness.vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);
      final second = harness.vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('ResetPasswordViewModel — connectivity', () {
    test(
      'initial state.isOffline reflects the gateway snapshot at construction',
      () async {
        final repo = _StubConnectivityRepository();
        final gateway = ConnectivityGateway(repository: repo);
        addTearDown(repo.close);
        addTearDown(gateway.dispose);

        repo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);

        final vm = ResetPasswordViewModel(
          confirmPasswordReset: _FakeConfirmPasswordResetUseCase(),
          router: _RecordingResetPasswordRouter(),
          connectivityGateway: gateway,
          token: 'tk-1',
        );
        addTearDown(vm.dispose);

        expect(vm.state.isOffline, isTrue);
      },
    );

    test('state.isOffline flips on connectivity stream events', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.state.isOffline, isFalse);

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isOffline, isTrue);

      harness.connectivityRepo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isOffline, isFalse);
    });

    test(
      'isOffline survives the passwordChanged terminal transition',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase();
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        expect(harness.vm.state.isOffline, isTrue);

        await harness.vm.submit(password: 'longenough', confirm: 'longenough');

        expect(harness.vm.state.passwordChanged, isTrue);
        expect(harness.vm.state.isOffline, isTrue);
      },
    );

    test('does not emit after dispose when connectivity flips', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      harness.vm.dispose();
      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.isDisposed, isTrue);
    });
  });

  group('ResetPasswordViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      final pending = harness.vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);
      harness.vm.dispose();
      useCase.release();
      await pending;

      expect(harness.vm.isDisposed, isTrue);
    });
  });

  group('ResetPasswordViewModel — navigation', () {
    test('goToLogin delegates to the router', () {
      final router = _RecordingResetPasswordRouter();
      final harness = _buildViewModel(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.vm.goToLogin();

      expect(router.loginCalls, 1);
    });

    test('goToForgotPassword delegates to the router', () {
      final router = _RecordingResetPasswordRouter();
      final harness = _buildViewModel(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.vm.goToForgotPassword();

      expect(router.forgotCalls, 1);
    });
  });
}
