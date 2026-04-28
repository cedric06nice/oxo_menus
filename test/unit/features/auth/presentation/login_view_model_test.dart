import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/login_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
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

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus initial = ConnectivityStatus.online;

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async => initial;

  Future<void> close() => controller.close();
}

const _alice = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

({
  LoginViewModel vm,
  _StubConnectivityRepository connectivityRepo,
  ConnectivityGateway connectivityGateway,
})
_buildViewModel({
  _FakeLoginUseCase? loginUseCase,
  _RecordingLoginRouter? router,
  ConnectivityStatus initialConnectivity = ConnectivityStatus.online,
}) {
  final connectivityRepo = _StubConnectivityRepository()
    ..initial = initialConnectivity;
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final vm = LoginViewModel(
    login: loginUseCase ?? _FakeLoginUseCase(),
    router: router ?? _RecordingLoginRouter(),
    connectivityGateway: connectivityGateway,
  );
  return (
    vm: vm,
    connectivityRepo: connectivityRepo,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('LoginState', () {
    test('default state is idle, no errors, online', () {
      const state = LoginState();

      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.isOffline, isFalse);
    });

    test('value equality compares all fields including isOffline', () {
      const a = LoginState();
      const b = LoginState();
      const c = LoginState(isOffline: true);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = LoginState(
        emailError: 'bad email',
        isSubmitting: true,
        errorMessage: 'server',
        isOffline: true,
      );

      final next = source.copyWith(isSubmitting: false);

      expect(next.emailError, 'bad email');
      expect(next.errorMessage, 'server');
      expect(next.isOffline, isTrue);
      expect(next.isSubmitting, isFalse);
    });
  });

  group('LoginViewModel — initial state', () {
    test('starts in idle state with no errors and not submitting', () {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.state, const LoginState());
      expect(harness.vm.state.isOffline, isFalse);
    });
  });

  group('LoginViewModel — validation', () {
    test('empty email surfaces emailError and skips the use case', () async {
      final useCase = _FakeLoginUseCase();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '', password: 'pw');

      expect(harness.vm.state.emailError, 'Please enter your email');
      expect(harness.vm.state.passwordError, isNull);
      expect(harness.vm.state.isSubmitting, isFalse);
      expect(useCase.calls, isEmpty);
    });

    test(
      'empty password surfaces passwordError and skips the use case',
      () async {
        final useCase = _FakeLoginUseCase();
        final harness = _buildViewModel(loginUseCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(email: 'a@b.c', password: '');

        expect(harness.vm.state.passwordError, 'Please enter your password');
        expect(harness.vm.state.emailError, isNull);
        expect(useCase.calls, isEmpty);
      },
    );

    test('both empty surfaces both errors', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '', password: '');

      expect(harness.vm.state.emailError, 'Please enter your email');
      expect(harness.vm.state.passwordError, 'Please enter your password');
    });

    test('a successful resubmit clears previous validation errors', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);
      await harness.vm.submit(email: '', password: '');

      await harness.vm.submit(email: 'a@b.c', password: 'pw');

      expect(harness.vm.state.emailError, isNull);
      expect(harness.vm.state.passwordError, isNull);
    });
  });

  group('LoginViewModel — submission', () {
    test('forwards trimmed input to the use case', () async {
      final useCase = _FakeLoginUseCase();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '  a@b.c  ', password: 'pw');

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.password, 'pw');
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final pending = harness.vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test(
      'on success calls router.goToHomeAfterLogin and clears submitting',
      () async {
        final useCase = _FakeLoginUseCase();
        final router = _RecordingLoginRouter();
        final harness = _buildViewModel(loginUseCase: useCase, router: router);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(email: 'a@b.c', password: 'pw');

        expect(router.homeCalls, 1);
        expect(harness.vm.state.isSubmitting, isFalse);
        expect(harness.vm.state.errorMessage, isNull);
      },
    );

    test(
      'on InvalidCredentials failure exposes the error message and stops submitting',
      () async {
        final useCase = _FakeLoginUseCase()
          ..result = const Failure(InvalidCredentialsError());
        final router = _RecordingLoginRouter();
        final harness = _buildViewModel(loginUseCase: useCase, router: router);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);

        await harness.vm.submit(email: 'a@b.c', password: 'wrong');

        expect(harness.vm.state.isSubmitting, isFalse);
        expect(harness.vm.state.errorMessage, 'Invalid credentials');
        expect(router.homeCalls, 0);
      },
    );

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeLoginUseCase()
          ..result = const Failure(InvalidCredentialsError());
        final harness = _buildViewModel(loginUseCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);
        await harness.vm.submit(email: 'a@b.c', password: 'wrong');

        useCase.result = Success(_alice);
        await harness.vm.submit(email: 'a@b.c', password: 'right');

        expect(harness.vm.state.errorMessage, isNull);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final first = harness.vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);
      final second = harness.vm.submit(email: 'a@b.c', password: 'pw');

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('LoginViewModel — connectivity', () {
    test(
      'initial state.isOffline reflects the gateway snapshot at construction',
      () async {
        final repo = _StubConnectivityRepository();
        final gateway = ConnectivityGateway(repository: repo);
        addTearDown(repo.close);
        addTearDown(gateway.dispose);

        // Drive the gateway so its current snapshot becomes offline before
        // the view model is constructed.
        repo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);

        final vm = LoginViewModel(
          login: _FakeLoginUseCase(),
          router: _RecordingLoginRouter(),
          connectivityGateway: gateway,
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

    test('isOffline survives across submission state transitions', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.isOffline, isTrue);

      final pending = harness.vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.isOffline, isTrue);
      expect(harness.vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;

      expect(harness.vm.state.isOffline, isTrue);
      expect(harness.vm.state.isSubmitting, isFalse);
    });

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

  group('LoginViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final harness = _buildViewModel(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      final pending = harness.vm.submit(email: 'a@b.c', password: 'pw');
      await Future<void>.delayed(Duration.zero);
      harness.vm.dispose();
      useCase.release();
      await pending;

      expect(harness.vm.isDisposed, isTrue);
    });
  });

  group('LoginViewModel — navigation', () {
    test('goToForgotPassword delegates to the router', () {
      final router = _RecordingLoginRouter();
      final harness = _buildViewModel(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.vm.goToForgotPassword();

      expect(router.forgotCalls, 1);
    });
  });
}
