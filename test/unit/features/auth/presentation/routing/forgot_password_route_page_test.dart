import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
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

class _NoopForgotPasswordRouter implements ForgotPasswordRouter {
  @override
  void goBackToLogin() {}
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
  group('ForgotPasswordRoutePage', () {
    test('identity is the constant `forgot-password` (stack diffing)', () {
      final page = ForgotPasswordRoutePage(router: _NoopForgotPasswordRouter());

      expect(page.identity, 'forgot-password');
    });

    testWidgets(
      'buildScreen returns a ForgotPasswordScreen with a live ViewModel',
      (tester) async {
        final page = ForgotPasswordRoutePage(
          router: _NoopForgotPasswordRouter(),
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = ForgotPasswordRoutePage(router: _NoopForgotPasswordRouter());
      final container = _makeContainer();

      final first = page.buildScreen(container) as ForgotPasswordScreen;
      final second = page.buildScreen(container) as ForgotPasswordScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = ForgotPasswordRoutePage(router: _NoopForgotPasswordRouter());
      final container = _makeContainer();
      final screen = page.buildScreen(container) as ForgotPasswordScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });
  });
}
