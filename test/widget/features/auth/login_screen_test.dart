import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';
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

const _alice = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

({
  LoginViewModel vm,
  _StubConnectivityRepository connectivityRepo,
  ConnectivityGateway connectivityGateway,
})
_viewModelWith({
  _FakeLoginUseCase? loginUseCase,
  _RecordingLoginRouter? router,
}) {
  final connectivityRepo = _StubConnectivityRepository();
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

ThemeData _materialTheme() => ThemeData(platform: TargetPlatform.android);

ThemeData _appleTheme() => ThemeData(platform: TargetPlatform.iOS);

void main() {
  group('LoginScreen — Material', () {
    testWidgets('renders the brand mark and email/password fields', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _materialTheme(),
      );

      expect(find.textContaining('OXO'), findsOneWidget);
      expect(find.text('Menu Template Builder'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('does not render the offline banner when online', (
      tester,
    ) async {
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
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
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
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
      final useCase = _FakeLoginUseCase();
      final harness = _viewModelWith(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith(router: router);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
        screenBuilder: (vm) => LoginScreen(viewModel: vm),
        theme: _appleTheme(),
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
    });

    testWidgets('shows a CupertinoActivityIndicator while submitting', (
      tester,
    ) async {
      final useCase = _FakeLoginUseCase()..blockNextCall();
      final harness = _viewModelWith(loginUseCase: useCase);
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
      final harness = _viewModelWith();
      addTearDown(harness.connectivityRepo.close);
      addTearDown(harness.connectivityGateway.dispose);
      await pumpScreenWithViewModel<LoginViewModel>(
        tester,
        viewModel: harness.vm,
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
