import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async => const Success(null);

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

class _NoopResetPasswordRouter implements ResetPasswordRouter {
  @override
  void goToLogin() {}

  @override
  void goToForgotPassword() {}
}

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

AppContainer _makeContainer() {
  final gateway = AuthGateway(repository: _StubAuthRepository());
  final connectivityGateway = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
  );
}

void main() {
  group('ResetPasswordRoutePage', () {
    test('identity namespaces with the token so two links can coexist', () {
      final a = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: 'tk-1',
      );
      final b = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: 'tk-2',
      );

      expect(a.identity, isNot(b.identity));
    });

    test('identity is stable for a null token (missing-token branch)', () {
      final a = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: null,
      );
      final b = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: null,
      );

      expect(a.identity, b.identity);
    });

    testWidgets(
      'buildScreen returns a ResetPasswordScreen with a live ViewModel',
      (tester) async {
        final page = ResetPasswordRoutePage(
          router: _NoopResetPasswordRouter(),
          token: 'tk-1',
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

        expect(find.byType(ResetPasswordScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: 'tk-1',
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as ResetPasswordScreen;
      final second = page.buildScreen(container) as ResetPasswordScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    test('the built ViewModel carries the page token', () {
      final page = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: 'tk-77',
      );
      final container = _makeContainer();

      final screen = page.buildScreen(container) as ResetPasswordScreen;

      expect(screen.viewModel.token, 'tk-77');
    });

    test('a null page token yields a ViewModel with no token', () {
      final page = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: null,
      );
      final container = _makeContainer();

      final screen = page.buildScreen(container) as ResetPasswordScreen;

      expect(screen.viewModel.hasToken, isFalse);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = ResetPasswordRoutePage(
        router: _NoopResetPasswordRouter(),
        token: 'tk-1',
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as ResetPasswordScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });
  });
}
