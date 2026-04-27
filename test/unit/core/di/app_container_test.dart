import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
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

void main() {
  group('AppContainer', () {
    test('exposes the AuthGateway it was constructed with', () {
      final gateway = AuthGateway(repository: _StubAuthRepository());
      final container = AppContainer(authGateway: gateway);

      expect(container.authGateway, same(gateway));
    });

    test('dispose tears down owned gateways', () {
      final gateway = AuthGateway(repository: _StubAuthRepository());
      final container = AppContainer(authGateway: gateway);

      container.dispose();

      expect(gateway.isDisposed, isTrue);
      expect(container.isDisposed, isTrue);
    });

    test('calling dispose twice is safe', () {
      final gateway = AuthGateway(repository: _StubAuthRepository());
      final container = AppContainer(authGateway: gateway);

      container.dispose();

      expect(() => container.dispose(), returnsNormally);
    });
  });
}
