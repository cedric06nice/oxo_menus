import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/login_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

class _FakeLoginUseCase implements LoginUseCase {
  Result<User, DomainError> result = Success(_alice);
  final List<LoginInput> calls = <LoginInput>[];
  Completer<void>? _gate;

  /// Hold the next execute() call until [release] is invoked.
  void blockNextCall() {
    _gate = Completer<void>();
  }

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  Future<Result<User, DomainError>> execute(LoginInput input) async {
    calls.add(input);
    if (_gate != null) {
      await _gate!.future;
    }
    return result;
  }
}

class _RecordingLoginRouter implements LoginRouter {
  int homeCalls = 0;
  int forgotCalls = 0;

  @override
  void goToHomeAfterLogin() => homeCalls++;

  @override
  void goToForgotPassword() => forgotCalls++;
}

const _alice = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

LoginViewModel _buildViewModel({
  _FakeLoginUseCase? loginUseCase,
  _RecordingLoginRouter? router,
}) {
  return LoginViewModel(
    login: loginUseCase ?? _FakeLoginUseCase(),
    router: router ?? _RecordingLoginRouter(),
  );
}

void main() {
  group('LoginViewModel — initial state', () {
    test('starts in idle state with no errors and not submitting', () {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);

      expect(vm.state, const LoginState());
      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.emailError, isNull);
      expect(vm.state.passwordError, isNull);
      expect(vm.state.errorMessage, isNull);
    });
  });

  group('LoginViewModel — validation', () {
    test('empty email surfaces emailError and skips the use case', () async {
      final useCase = _FakeLoginUseCase();
      final vm = _buildViewModel(loginUseCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: '', password: 'pw');

      expect(vm.state.emailError, 'Please enter your email');
      expect(vm.state.passwordError, isNull);
      expect(vm.state.isSubmitting, isFalse);
      expect(useCase.calls, isEmpty);
    });

    test(
      'empty password surfaces passwordError and skips the use case',
      () async {
        final useCase = _FakeLoginUseCase();
        final vm = _buildViewModel(loginUseCase: useCase);
        addTearDown(vm.dispose);

        await vm.submit(email: 'a@b.c', password: '');

        expect(vm.state.passwordError, 'Please enter your password');
        expect(vm.state.emailError, isNull);
        expect(useCase.calls, isEmpty);
      },
    );

    test('both empty surfaces both errors', () async {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);

      await vm.submit(email: '', password: '');

      expect(vm.state.emailError, 'Please enter your email');
      expect(vm.state.passwordError, 'Please enter your password');
    });

    test('a successful resubmit clears previous validation errors', () async {
      final vm = _buildViewModel();
      addTearDown(vm.dispose);
      await vm.submit(email: '', password: '');

      await vm.submit(email: 'a@b.c', password: 'pw');

      expect(vm.state.emailError, isNull);
      expect(vm.state.passwordError, isNull);
    });
  });

  group('LoginViewModel — submission', () {
    test('forwards trimmed input to the use case', () async {
      final useCase = _FakeLoginUseCase();
      final vm = _buildViewModel(loginUseCase: useCase);
      addTearDown(vm.dispose);

      await vm.submit(email: '  a@b.c  ', password: 'pw');

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.password, 'pw');
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final vm = _buildViewModel(loginUseCase: useCase);
      addTearDown(vm.dispose);

      final pending = vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test(
      'on success calls router.goToHomeAfterLogin and clears submitting',
      () async {
        final useCase = _FakeLoginUseCase();
        final router = _RecordingLoginRouter();
        final vm = _buildViewModel(loginUseCase: useCase, router: router);
        addTearDown(vm.dispose);

        await vm.submit(email: 'a@b.c', password: 'pw');

        expect(router.homeCalls, 1);
        expect(vm.state.isSubmitting, isFalse);
        expect(vm.state.errorMessage, isNull);
      },
    );

    test(
      'on InvalidCredentials failure exposes the error message and stops submitting',
      () async {
        final useCase = _FakeLoginUseCase()
          ..result = const Failure(InvalidCredentialsError());
        final router = _RecordingLoginRouter();
        final vm = _buildViewModel(loginUseCase: useCase, router: router);
        addTearDown(vm.dispose);

        await vm.submit(email: 'a@b.c', password: 'wrong');

        expect(vm.state.isSubmitting, isFalse);
        expect(vm.state.errorMessage, 'Invalid credentials');
        expect(router.homeCalls, 0);
      },
    );

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeLoginUseCase()
          ..result = const Failure(InvalidCredentialsError());
        final vm = _buildViewModel(loginUseCase: useCase);
        addTearDown(vm.dispose);
        await vm.submit(email: 'a@b.c', password: 'wrong');

        useCase.result = Success(_alice);
        await vm.submit(email: 'a@b.c', password: 'right');

        expect(vm.state.errorMessage, isNull);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final vm = _buildViewModel(loginUseCase: useCase);
      addTearDown(vm.dispose);

      final first = vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);
      final second = vm.submit(email: 'a@b.c', password: 'pw');

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('LoginViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final vm = _buildViewModel(loginUseCase: useCase);

      final pending = vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);
      vm.dispose();
      useCase.release();
      await pending;

      expect(vm.isDisposed, isTrue);
    });
  });

  group('LoginViewModel — navigation', () {
    test('goToForgotPassword delegates to the router', () {
      final router = _RecordingLoginRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToForgotPassword();

      expect(router.forgotCalls, 1);
    });
  });
}
