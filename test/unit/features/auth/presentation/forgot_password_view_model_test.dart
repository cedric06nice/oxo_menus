import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/forgot_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';

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
  ForgotPasswordViewModel vm,
  _StubConnectivityRepository connectivityRepo,
  ConnectivityGateway connectivityGateway,
})
_buildViewModel({
  _FakeRequestPasswordResetUseCase? useCase,
  _RecordingForgotPasswordRouter? router,
  String? resetUrl,
}) {
  final connectivityRepo = _StubConnectivityRepository();
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final vm = ForgotPasswordViewModel(
    requestPasswordReset: useCase ?? _FakeRequestPasswordResetUseCase(),
    router: router ?? _RecordingForgotPasswordRouter(),
    connectivityGateway: connectivityGateway,
    resetUrl: resetUrl,
  );
  return (
    vm: vm,
    connectivityRepo: connectivityRepo,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('ForgotPasswordState', () {
    test('default state is idle, no errors, online', () {
      const state = ForgotPasswordState();

      expect(state.emailError, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.emailSent, isFalse);
      expect(state.isOffline, isFalse);
    });

    test('value equality compares all fields including isOffline', () {
      const a = ForgotPasswordState();
      const b = ForgotPasswordState();
      const c = ForgotPasswordState(emailSent: true);
      const d = ForgotPasswordState(errorMessage: 'oops');
      const e = ForgotPasswordState(isOffline: true);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(a, isNot(e));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = ForgotPasswordState(
        emailError: 'bad email',
        isSubmitting: true,
        errorMessage: 'server',
        emailSent: false,
        isOffline: true,
      );

      final next = source.copyWith(isSubmitting: false);

      expect(next.emailError, 'bad email');
      expect(next.errorMessage, 'server');
      expect(next.emailSent, isFalse);
      expect(next.isOffline, isTrue);
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
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.state, const ForgotPasswordState());
    });
  });

  group('ForgotPasswordViewModel — validation', () {
    test('empty email surfaces emailError and skips the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '');

      expect(harness.vm.state.emailError, 'Please enter your email');
      expect(harness.vm.state.isSubmitting, isFalse);
      expect(harness.vm.state.emailSent, isFalse);
      expect(useCase.calls, isEmpty);
    });

    test('whitespace-only email is treated as empty', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '   ');

      expect(harness.vm.state.emailError, 'Please enter your email');
      expect(useCase.calls, isEmpty);
    });

    test('a successful resubmit clears previous validation errors', () async {
      final harness = _buildViewModel();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);
      await harness.vm.submit(email: '');

      await harness.vm.submit(email: 'a@b.c');

      expect(harness.vm.state.emailError, isNull);
    });
  });

  group('ForgotPasswordViewModel — submission', () {
    test('forwards trimmed email and resetUrl to the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _buildViewModel(
        useCase: useCase,
        resetUrl: 'https://app.example/reset',
      );
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: '  a@b.c  ');

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.resetUrl, 'https://app.example/reset');
    });

    test('passes a null resetUrl through to the use case', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: 'a@b.c');

      expect(useCase.calls.single.resetUrl, isNull);
    });

    test('emits isSubmitting=true while the use case is in flight', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final pending = harness.vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isSubmitting, isTrue);

      useCase.release();
      await pending;
    });

    test('on success emits emailSent=true and clears submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final router = _RecordingForgotPasswordRouter();
      final harness = _buildViewModel(useCase: useCase, router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: 'a@b.c');

      expect(harness.vm.state.emailSent, isTrue);
      expect(harness.vm.state.isSubmitting, isFalse);
      expect(harness.vm.state.errorMessage, isNull);
      expect(router.loginCalls, 0);
    });

    test('on failure exposes the error message and stops submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase()
        ..result = const Failure(NetworkError());
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      await harness.vm.submit(email: 'a@b.c');

      expect(harness.vm.state.isSubmitting, isFalse);
      expect(harness.vm.state.errorMessage, isNotNull);
      expect(harness.vm.state.emailSent, isFalse);
    });

    test(
      'a fresh successful submit clears a previous server error message',
      () async {
        final useCase = _FakeRequestPasswordResetUseCase()
          ..result = const Failure(NetworkError());
        final harness = _buildViewModel(useCase: useCase);
        addTearDown(harness.connectivityRepo.close);
        addTearDown(harness.connectivityGateway.dispose);
        addTearDown(harness.vm.dispose);
        await harness.vm.submit(email: 'a@b.c');

        useCase.result = const Success(null);
        await harness.vm.submit(email: 'a@b.c');

        expect(harness.vm.state.errorMessage, isNull);
        expect(harness.vm.state.emailSent, isTrue);
      },
    );

    test('rejects re-entrant submits while already submitting', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      final first = harness.vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);
      final second = harness.vm.submit(email: 'a@b.c');

      useCase.release();
      await Future.wait<void>([first, second]);

      expect(useCase.calls, hasLength(1));
    });
  });

  group('ForgotPasswordViewModel — connectivity', () {
    test(
      'initial state.isOffline reflects the gateway snapshot at construction',
      () async {
        final repo = _StubConnectivityRepository();
        final gateway = ConnectivityGateway(repository: repo);
        addTearDown(repo.close);
        addTearDown(gateway.dispose);

        repo.controller.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);

        final vm = ForgotPasswordViewModel(
          requestPasswordReset: _FakeRequestPasswordResetUseCase(),
          router: _RecordingForgotPasswordRouter(),
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

    test('isOffline survives the emailSent terminal transition', () async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.isOffline, isTrue);

      await harness.vm.submit(email: 'a@b.c');

      expect(harness.vm.state.emailSent, isTrue);
      expect(harness.vm.state.isOffline, isTrue);
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

  group('ForgotPasswordViewModel — disposal', () {
    test('does not emit after dispose', () async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final harness = _buildViewModel(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);

      final pending = harness.vm.submit(email: 'a@b.c');
      await Future<void>.delayed(Duration.zero);
      harness.vm.dispose();
      useCase.release();
      await pending;

      expect(harness.vm.isDisposed, isTrue);
    });
  });

  group('ForgotPasswordViewModel — navigation', () {
    test('goBackToLogin delegates to the router', () {
      final router = _RecordingForgotPasswordRouter();
      final harness = _buildViewModel(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      addTearDown(harness.vm.dispose);

      harness.vm.goBackToLogin();

      expect(router.loginCalls, 1);
    });
  });
}
