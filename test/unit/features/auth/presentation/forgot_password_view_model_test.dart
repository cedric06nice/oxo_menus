import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/forgot_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';

class _FakeRequestPasswordResetUseCase implements RequestPasswordResetUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<RequestPasswordResetInput> calls = <RequestPasswordResetInput>[];
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
    RequestPasswordResetInput input,
  ) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _RecordingForgotPasswordRouter implements ForgotPasswordRouter {
  int loginCalls = 0;

  @override
  void goBackToLogin() => loginCalls++;
}

ForgotPasswordViewModel _buildViewModel({
  _FakeRequestPasswordResetUseCase? useCase,
  _RecordingForgotPasswordRouter? router,
  String? resetUrl,
}) {
  return ForgotPasswordViewModel(
    requestPasswordReset: useCase ?? _FakeRequestPasswordResetUseCase(),
    router: router ?? _RecordingForgotPasswordRouter(),
    resetUrl: resetUrl,
  );
}

void main() {
  group('ForgotPasswordState', () {
    test('default state is idle with no errors and not submitting', () {
      const state = ForgotPasswordState();

      expect(state.emailError, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.emailSent, isFalse);
    });

    test('value equality compares all four fields', () {
      const a = ForgotPasswordState();
      const b = ForgotPasswordState();
      const c = ForgotPasswordState(emailSent: true);
      const d = ForgotPasswordState(errorMessage: 'oops');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = ForgotPasswordState(
        emailError: 'bad email',
        isSubmitting: true,
        errorMessage: 'server',
        emailSent: false,
      );

      final next = source.copyWith(isSubmitting: false);

      expect(next.emailError, 'bad email');
      expect(next.errorMessage, 'server');
      expect(next.emailSent, isFalse);
      expect(next.isSubmitting, isFalse);
    });

    test('copyWith allows clearing nullable fields explicitly to null', () {
      const source = ForgotPasswordState(
        emailError: 'bad email',
        errorMessage: 'server',
      );

      final next = source.copyWith(emailError: null, errorMessage: null);

      expect(next.emailError, isNull);
      expect(next.errorMessage, isNull);
    });
  });

  group('ForgotPasswordViewModel — initial state', () {
    test('starts in idle state', () {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);

      expect(vm.state, const ForgotPasswordState());
    });
  });

  group('ForgotPasswordViewModel — validation', () {
    test('empty email surfaces emailError and skips the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: '');

      expect(vm.state.emailError, 'Please enter your email');
      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.emailSent, isFalse);
      expect(useCase.calls, isEmpty);
    });

    test('whitespace-only email is treated as empty', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: '   ');

      expect(vm.state.emailError, 'Please enter your email');
      expect(useCase.calls, isEmpty);
    });

    test('a successful resubmit clears previous validation errors', () async {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);
      await vm.submit(email: '');

      await vm.submit(email: 'a@b.c');

      expect(vm.state.emailError, isNull);
    });
  });

  group('ForgotPasswordViewModel — submission', () {
    test('forwards trimmed email and resetUrl to the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final vm = _buildViewModel(
        useCase: useCase,
        resetUrl: 'https://app.example/reset',
      );
      addTearDown(vm.dispose);

      await vm.submit(email: '  a@b.c  ');

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.resetUrl, 'https://app.example/reset');
    });

    test('passes a null resetUrl through to the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: 'a@b.c');

      expect(useCase.calls.single.resetUrl, isNull);
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      final pending = vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test('on success emits emailSent=true and clears submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final router = _RecordingForgotPasswordRouter();
      final vm = _buildViewModel(useCase: useCase, router: router);
      addTearDown(vm.dispose);

      await vm.submit(email: 'a@b.c');

      expect(vm.state.emailSent, isTrue);
      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.errorMessage, isNull);
      expect(router.loginCalls, 0);
    });

    test('on failure exposes the error message and stops submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase()
        ..result = const Failure(NetworkError());
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: 'a@b.c');

      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.errorMessage, isNotNull);
      expect(vm.state.emailSent, isFalse);
    });

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeRequestPasswordResetUseCase()
          ..result = const Failure(NetworkError());
        final vm = _buildViewModel(useCase: useCase);
        addTearDown(vm.dispose);
        await vm.submit(email: 'a@b.c');

        useCase.result = const Success(null);
        await vm.submit(email: 'a@b.c');

        expect(vm.state.errorMessage, isNull);
        expect(vm.state.emailSent, isTrue);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);
      addTearDown(vm.dispose);

      final first = vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);
      final second = vm.submit(email: 'a@b.c');

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('ForgotPasswordViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final vm = _buildViewModel(useCase: useCase);

      final pending = vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      useCase.release();
      await pending;

      expect(vm.isDisposed, isTrue);
    });
  });

  group('ForgotPasswordViewModel — navigation', () {
    test('goBackToLogin delegates to the router', () {
      final router = _RecordingForgotPasswordRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goBackToLogin();

      expect(router.loginCalls, 1);
    });
  });
}
