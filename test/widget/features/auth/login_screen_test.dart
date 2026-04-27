import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

import '../../../helpers/build_view_model_test_harness.dart';

class _FakeLoginUseCase implements LoginUseCase {
  Result<User, DomainError> result = Success(_alice);
  final List<LoginInput> calls = <LoginInput>[];
  Completer<void>? _gate;

  void blockNextCall() => _gate = Completer<void>();

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

LoginViewModel _viewModelWith({
  _FakeLoginUseCase? loginUseCase,
  _RecordingLoginRouter? router,
}) {
  return LoginViewModel(
    login: loginUseCase ?? _FakeLoginUseCase(),
    router: router ?? _RecordingLoginRouter(),
  );
}

ThemeData _materialTheme() => ThemeData(platform: TargetPlatform.android);

ThemeData _appleTheme() => ThemeData(platform: TargetPlatform.iOS);

void main() {
  group('LoginScreen — Material', () {
    testWidgets('renders the brand mark and email/password fields', (
      tester,
    ) async {
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.textContaining('OXO'), findsOneWidget);
      expect(find.text('Menu Template Builder'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('shows email validation error when submit is empty', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(loginUseCase: useCase),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(useCase.calls, isEmpty);
    });

    testWidgets('valid submit forwards credentials to the use case', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(loginUseCase: useCase),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(useCase.calls.single.email, 'a@b.c');
      expect(useCase.calls.single.password, 'pw');
    });

    testWidgets('shows a CircularProgressIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(loginUseCase: useCase),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('renders the server error message after a failed submit', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase()
        ..result = const Failure(InvalidCredentialsError());
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(loginUseCase: useCase),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrong');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('forgot-password link calls the router', (tester) async {
      final router = _RecordingLoginRouter();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pump();

      expect(router.forgotCalls, 1);
    });

    testWidgets('successful submit calls router.goToHomeAfterLogin', (
      tester,
    ) async {
      final router = _RecordingLoginRouter();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(router.homeCalls, 1);
    });
  });

  group('LoginScreen — Apple platform', () {
    testWidgets('renders Cupertino fields when platform is iOS', (
      tester,
    ) async {
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
    });

    testWidgets('shows a CupertinoActivityIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(loginUseCase: useCase),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      useCase.release();
      await tester.pumpAndSettle();
    });

    testWidgets('inline email error renders below the Cupertino field', (
      tester,
    ) async {
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
