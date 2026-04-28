import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _StubAuthRepository implements AuthRepository {
  Result<void, DomainError> logoutResult = const Success(null);
  int logoutCalls = 0;

  @override
  Future<Result<void, DomainError>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

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
  group('LogoutUseCase', () {
    test('delegates to AuthGateway.logout and returns success', () async {
      final repo = _StubAuthRepository();
      final gateway = AuthGateway(repository: repo);
      addTearDown(gateway.dispose);
      final useCase = LogoutUseCase(authGateway: gateway);

      final result = await useCase.execute(NoInput.instance);

      expect(result, isA<Success<void, DomainError>>());
      expect(repo.logoutCalls, 1);
    });

    test('flips gateway status to unauthenticated', () async {
      final repo = _StubAuthRepository();
      final gateway = AuthGateway(repository: repo);
      addTearDown(gateway.dispose);
      final useCase = LogoutUseCase(authGateway: gateway);

      await useCase.execute(NoInput.instance);

      expect(gateway.status, isA<AuthStatusUnauthenticated>());
    });

    test('propagates failure from the gateway', () async {
      final repo = _StubAuthRepository()
        ..logoutResult = const Failure(ServerError('boom'));
      final gateway = AuthGateway(repository: repo);
      addTearDown(gateway.dispose);
      final useCase = LogoutUseCase(authGateway: gateway);

      final result = await useCase.execute(NoInput.instance);

      expect(result, isA<Failure<void, DomainError>>());
    });
  });
}
