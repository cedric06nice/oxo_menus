import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';

import '../../../helpers/build_view_model_test_harness.dart';

class _FakeConfirmPasswordResetUseCase implements ConfirmPasswordResetUseCase {
  Result<void, DomainError> result = const Success(null);
  final List<ConfirmPasswordResetInput> calls = <ConfirmPasswordResetInput>[];
  Completer<void>? _gate;

  void blockNextCall() => _gate = Completer<void>();

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

ResetPasswordViewModel _viewModelWith({
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

ThemeData _materialTheme() => ThemeData(platform: TargetPlatform.android);

ThemeData _appleTheme() => ThemeData(platform: TargetPlatform.iOS);

void main() {
  group('ResetPasswordScreen — missing token branch', () {
    testWidgets('renders the missing-token message and a request-link button',
        (tester) async {
      final router = _RecordingResetPasswordRouter();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(router: router, token: null),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.text('Invalid or missing reset token'), findsOneWidget);
      expect(find.text('Request a new link'), findsOneWidget);
      expect(find.byKey(const Key('new_password_field')), findsNothing);
    });

    testWidgets('request-link button calls router.goToForgotPassword',
        (tester) async {
      final router = _RecordingResetPasswordRouter();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(router: router, token: null),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.text('Request a new link'));
      await tester.pump();

      expect(router.forgotCalls, 1);
    });

    testWidgets('treats empty token as missing', (tester) async {
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(token: ''),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });
  });

  group('ResetPasswordScreen — Material form', () {
    testWidgets('renders the heading, copy, and password/confirm fields',
        (tester) async {
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      // Both the heading and the submit button read "Reset Password".
      expect(find.text('Reset Password'), findsNWidgets(2));
      expect(find.textContaining('Enter your new password'), findsOneWidget);
      expect(find.byKey(const Key('new_password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
      expect(find.byKey(const Key('reset_password_button')), findsOneWidget);
    });

    testWidgets('shows password validation error when submit is empty',
        (tester) async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.text('Please enter a new password'), findsOneWidget);
      expect(useCase.calls, isEmpty);
    });

    testWidgets('shows mismatch error when confirm differs', (tester) async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'different1',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(useCase.calls, isEmpty);
    });

    testWidgets('valid submit forwards token + password to the use case',
        (tester) async {
      final useCase = _FakeConfirmPasswordResetUseCase();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase, token: 'tk-77'),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      expect(useCase.calls.single.token, 'tk-77');
      expect(useCase.calls.single.password, 'longenough');
    });

    testWidgets('shows a CircularProgressIndicator while submitting',
        (tester) async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('renders the success branch with a Go-to-Login button',
        (tester) async {
      final router = _RecordingResetPasswordRouter();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Password reset successfully'), findsOneWidget);
      expect(find.byKey(const Key('go_to_login_button')), findsOneWidget);
    });

    testWidgets('go-to-login button calls router.goToLogin', (tester) async {
      final router = _RecordingResetPasswordRouter();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('go_to_login_button')));
      await tester.pump();

      expect(router.loginCalls, 1);
    });

    testWidgets(
      'on server error, renders the message and a request-link affordance',
      (tester) async {
        final router = _RecordingResetPasswordRouter();
        final useCase = _FakeConfirmPasswordResetUseCase()
          ..result = const Failure(ValidationError('Token expired'));
        await pumpScreenWithViewModel<ResetPasswordViewModel>(
          tester,
          viewModel: _viewModelWith(useCase: useCase, router: router),
          screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
          theme: _materialTheme(),
        );

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'longenough',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'longenough',
        );
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        expect(find.textContaining('Token expired'), findsOneWidget);
        expect(find.text('Request a new link'), findsOneWidget);

        await tester.tap(find.text('Request a new link'));
        await tester.pump();

        expect(router.forgotCalls, 1);
      },
    );
  });

  group('ResetPasswordScreen — Apple platform', () {
    testWidgets('renders Cupertino fields when platform is iOS',
        (tester) async {
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
    });

    testWidgets('shows a CupertinoActivityIndicator while submitting',
        (tester) async {
      final useCase = _FakeConfirmPasswordResetUseCase()..blockNextCall();
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(useCase: useCase),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'longenough',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('inline password error renders below the Cupertino field',
        (tester) async {
      await pumpScreenWithViewModel<ResetPasswordViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => ResetPasswordScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.text('Please enter a new password'), findsOneWidget);
    });
  });
}
