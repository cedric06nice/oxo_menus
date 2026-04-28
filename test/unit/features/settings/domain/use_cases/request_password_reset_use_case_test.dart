import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

class _StubAuthRepository implements AuthRepository {
  Result<void, DomainError> resetResult = const Success(null);
  final List<({String email, String? resetUrl})> calls =
      <({String email, String? resetUrl})>[];

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async {
    calls.add((email: email, resetUrl: resetUrl));
    return resetResult;
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
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

void main() {
  group('RequestPasswordResetUseCase', () {
    test(
      'forwards email and resetUrl to the gateway and returns success',
      () async {
        final repo = _StubAuthRepository();
        final gateway = AuthGateway(repository: repo);
        addTearDown(gateway.dispose);
        final useCase = RequestPasswordResetUseCase(authGateway: gateway);

        final result = await useCase.execute(
          const RequestPasswordResetInput(
            email: 'a@example.com',
            resetUrl: 'https://app.example/reset',
          ),
        );

        expect(result, isA<Success<void, DomainError>>());
        expect(repo.calls.single.email, 'a@example.com');
        expect(repo.calls.single.resetUrl, 'https://app.example/reset');
      },
    );

    test('passes a null resetUrl when not provided', () async {
      final repo = _StubAuthRepository();
      final gateway = AuthGateway(repository: repo);
      addTearDown(gateway.dispose);
      final useCase = RequestPasswordResetUseCase(authGateway: gateway);

      await useCase.execute(
        const RequestPasswordResetInput(email: 'a@example.com'),
      );

      expect(repo.calls.single.resetUrl, isNull);
    });

    test('propagates failures from the gateway', () async {
      final repo = _StubAuthRepository()
        ..resetResult = const Failure(NetworkError('offline'));
      final gateway = AuthGateway(repository: repo);
      addTearDown(gateway.dispose);
      final useCase = RequestPasswordResetUseCase(authGateway: gateway);

      final result = await useCase.execute(
        const RequestPasswordResetInput(email: 'x@example.com'),
      );

      expect(result, isA<Failure<void, DomainError>>());
      result.fold(
        onSuccess: (_) => fail('expected failure'),
        onFailure: (error) => expect(
          error,
          isA<NetworkError>().having((e) => e.message, 'msg', 'offline'),
        ),
      );
    });
  });
}
