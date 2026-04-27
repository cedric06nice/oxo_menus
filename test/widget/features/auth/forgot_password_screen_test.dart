import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';

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

ForgotPasswordViewModel _viewModelWith({
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

ThemeData _materialTheme() => ThemeData(platform: TargetPlatform.android);

ThemeData _appleTheme() => ThemeData(platform: TargetPlatform.iOS);

void main() {
  group('ForgotPasswordScreen — Material', () {
    testWidgets('renders the heading, copy, and email/send controls', (
      tester,
    ) async {
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.textContaining('Enter your email address'), findsOneWidget);
      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('send_reset_button')), findsOneWidget);
      expect(find.byKey(const Key('back_to_login')), findsOneWidget);
    });

    testWidgets('shows email validation error when submit is empty', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase();
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(
          useCase: useCase,
          resetUrl: 'https://app.example/reset',
        ),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('shows a CupertinoActivityIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeRequestPasswordResetUseCase()..blockNextCall();
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
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
      await pumpScreenWithViewModel<ForgotPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ForgotPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
