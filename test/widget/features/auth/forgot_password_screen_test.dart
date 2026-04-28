import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

import '../../../helpers/build_view_model_test_harness.dart';

class _FakeRequestPasswordResetUseCase implements RequestPasswordResetUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<RequestPasswordResetInput> calls = <RequestPasswordResetInput>[];
  Completer<void>? _gate;

  void blockNextCall() => _gate = Completer<void>();

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
_viewModelWith({
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

ThemeData _materialTheme() => ThemeData(platform: TargetPlatform.android);

ThemeData _appleTheme() => ThemeData(platform: TargetPlatform.iOS);

void main() {
  group('ForgotPasswordScreen — Material', () {
    testWidgets('renders the heading, copy, and email/send controls', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.textContaining('Enter your email address'), findsOneWidget);
      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('send_reset_button')), findsOneWidget);
      expect(find.byKey(const Key('back_to_login')), findsOneWidget);
    });

    testWidgets('does not render the offline banner when online', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('renders the offline banner when connectivity flips offline', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      harness.connectivityRepo.controller.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('shows email validation error when submit is empty', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _viewModelWith(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(useCase.calls, isEmpty);
    });

    testWidgets('valid submit forwards email + resetUrl to the use case', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase();
      final harness = _viewModelWith(
        useCase: useCase,
        resetUrl: 'https://app.example/reset',
      );
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'a@b.c',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.resetUrl, 'https://app.example/reset');
    });

    testWidgets('shows a CircularProgressIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final harness = _viewModelWith(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'a@b.c',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('renders the success message after a successful submit', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'a@b.c',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Check your email for a reset link'), findsOneWidget);
    });

    testWidgets('renders the server error message after a failed submit', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase()
        ..result = const Failure(NetworkError());
      final harness = _viewModelWith(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'a@b.c',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Network'), findsOneWidget);
    });

    testWidgets('back-to-login link calls the router', (tester) async {
      final router = _RecordingForgotPasswordRouter();
      final harness = _viewModelWith(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.byKey(const Key('back_to_login')));
      await tester.pump();

      expect(router.loginCalls, 1);
    });
  });

  group('ForgotPasswordScreen — Apple platform', () {
    testWidgets('renders a Cupertino field when platform is iOS', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('shows a CupertinoActivityIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      final harness = _viewModelWith(useCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'a@b.c',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('inline email error renders below the Cupertino field', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
