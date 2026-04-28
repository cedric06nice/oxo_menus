import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/reset_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';

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

ResetPasswordViewModel _buildViewModel({
  _FakeConfirmPasswordResetUseCase? useCase,
  _RecordingResetPasswordRouter? router,
  String? token = 'tk-1',
}) {
  return ResetPasswordViewModel(
    confirmPasswordReset: useCase ?? _FakeConfirmPasswordResetUseCase(),
    router: router ?? _RecordingResetPasswordRouter(),
    token: token,
  );
}

void main() {
  group('ResetPasswordState', () {
    test('default state is idle with no errors and not submitting', () {
      const state = ResetPasswordState();

      expect(state.passwordError, isNull);
      expect(state.confirmError, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.passwordChanged, isFalse);
    });

    test('value equality compares all five fields', () {
      const a = ResetPasswordState();
      const b = ResetPasswordState();
      const c = ResetPasswordState(passwordChanged: true);
      const d = ResetPasswordState(errorMessage: 'oops');
      const e = ResetPasswordState(passwordError: 'short');
      const f = ResetPasswordState(confirmError: 'mismatch');
      const g = ResetPasswordState(isSubmitting: true);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(a, isNot(e));
      expect(a, isNot(f));
      expect(a, isNot(g));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = ResetPasswordState(
        passwordError: 'too short',
        confirmError: 'mismatch',
        isSubmitting: true,
        errorMessage: 'server',
        passwordChanged: false,
      );

      final next = source.copyWith(isSubmitting: false);

      expect(next.passwordError, 'too short');
      expect(next.confirmError, 'mismatch');
      expect(next.errorMessage, 'server');
      expect(next.passwordChanged, isFalse);
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
      final vm = _buildViewModel();
      addTearDown(vm.dispose);

      expect(vm.state, const ResetPasswordState());
    });

    test('exposes the token it was constructed with', () {
      final vm = _buildViewModel(token: 'tk-42');
      addTearDown(vm.dispose);

      expect(vm.token, 'tk-42');
    });

    test('hasToken is false when constructed with null', () {
      final vm = _buildViewModel(token: null);
      addTearDown(vm.dispose);

      expect(vm.hasToken, isFalse);
    });

    test('hasToken is false when constructed with the empty string', () {
      final vm = _buildViewModel(token: '');
      addTearDown(vm.dispose);

      expect(vm.hasToken, isFalse);
    });

    test('hasToken is true for a non-empty token', () {
      final vm = _buildViewModel(token: 'tk');
      addTearDown(vm.dispose);

      expect(vm.hasToken, isTrue);
    });
  });

  group('ResetPasswordViewModel — validation', () {
    test('empty password surfaces passwordError and skips the use case',
        () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(password: '', confirm: '');

      expect(vm.state.passwordError, 'Please enter a new password');
      expect(vm.state.isSubmitting, isFalse);
      expect(useCase.calls, isEmpty);
    });

    test('password under 8 characters surfaces a length error', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(password: 'short', confirm: 'short');

      expect(vm.state.passwordError, 'Password must be at least 8 characters');
      expect(useCase.calls, isEmpty);
    });

    test('mismatched confirm surfaces a confirmError', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(password: 'longenough', confirm: 'different1');

      expect(vm.state.passwordError, isNull);
      expect(vm.state.confirmError, 'Passwords do not match');
      expect(useCase.calls, isEmpty);
    });

    test(
      'an empty confirm with a valid password is treated as a mismatch',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase();
        final vm = _buildViewModel(useCase: useCase);
        addTearDown(vm.dispose);

        await vm.submit(password: 'longenough', confirm: '');

        expect(vm.state.confirmError, 'Passwords do not match');
        expect(useCase.calls, isEmpty);
      },
    );

    test('submit aborts with errorMessage when token is null', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase, token: null);
      addTearDown(vm.dispose);

      await vm.submit(password: 'longenough', confirm: 'longenough');

      expect(useCase.calls, isEmpty);
      expect(vm.state.errorMessage, isNotNull);
    });

    test('a successful resubmit clears previous validation errors', () async {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);
      await vm.submit(password: '', confirm: '');

      await vm.submit(password: 'longenough', confirm: 'longenough');

      expect(vm.state.passwordError, isNull);
      expect(vm.state.confirmError, isNull);
    });
  });

  group('ResetPasswordViewModel — submission', () {
    test('forwards token and password to the use case', () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase, token: 'tk-9');
      addTearDown(vm.dispose);

      await vm.submit(password: 'longenough', confirm: 'longenough');

      expect(useCase.calls, hasLength(1));
      expect(useCase.calls.single.token, 'tk-9');
      expect(useCase.calls.single.password, 'longenough');
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      final pending = vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test('on success emits passwordChanged=true and clears submitting',
        () async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(password: 'longenough', confirm: 'longenough');

      expect(vm.state.passwordChanged, isTrue);
      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.errorMessage, isNull);
    });

    test('on failure exposes the error message and stops submitting',
        () async {
      final useCase = _FakeConfirmPasswordResetUseCase()
        ..result = const Failure(NetworkError());
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(password: 'longenough', confirm: 'longenough');

      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.errorMessage, isNotNull);
      expect(vm.state.passwordChanged, isFalse);
    });

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeConfirmPasswordResetUseCase()
          ..result = const Failure(NetworkError());
        final vm = _buildViewModel(useCase: useCase);
        addTearDown(vm.dispose);
        await vm.submit(password: 'longenough', confirm: 'longenough');

        useCase.result = const Success(null);
        await vm.submit(password: 'longenough', confirm: 'longenough');

        expect(vm.state.errorMessage, isNull);
        expect(vm.state.passwordChanged, isTrue);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      final first = vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);
      final second = vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('ResetPasswordViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);

      final pending = vm.submit(
        password: 'longenough',
        confirm: 'longenough',
      );
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      useCase.release();
      await pending;

      expect(vm.isDisposed, isTrue);
    });
  });

  group('ResetPasswordViewModel — navigation', () {
    test('goToLogin delegates to the router', () {
      final router = _RecordingResetPasswordRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToLogin();

      expect(router.loginCalls, 1);
    });

    test('goToForgotPassword delegates to the router', () {
      final router = _RecordingResetPasswordRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToForgotPassword();

      expect(router.forgotCalls, 1);
    });
  });
}
