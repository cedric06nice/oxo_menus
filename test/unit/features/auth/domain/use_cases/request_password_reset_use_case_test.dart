import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _RecordingAuthRepository implements AuthRepository {
  Result<void, DomainError> requestResult = const Success(null);
  String? lastEmail;
  String? lastResetUrl;
  int requestCalls = 0;

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
  }) async {
    requestCalls++;
    lastEmail = email;
    lastResetUrl = resetUrl;
    return requestResult;
  }

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

void main() {
  group('RequestPasswordResetUseCase', () {
    test('forwards email and resetUrl to the gateway', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);

      await useCase.execute(
        const RequestPasswordResetInput(
          email: 'a@b.c',
          resetUrl: 'https://app.example/reset',
        ),
      );

      expect(repo.requestCalls, 1);
      expect(repo.lastEmail, 'a@b.c');
      expect(repo.lastResetUrl, 'https://app.example/reset');
    });

    test('passes a null resetUrl through unchanged', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);

      await useCase.execute(const RequestPasswordResetInput(email: 'a@b.c'));

      expect(repo.lastResetUrl, isNull);
    });

    test('returns Success(null) when the gateway succeeds', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);

      final result = await useCase.execute(
        const RequestPasswordResetInput(email: 'a@b.c'),
      );

      expect(result, const Success<void, DomainError>(null));
    });

    test('propagates Failure from the gateway unchanged', () async {
      final repo = _RecordingAuthRepository()
        ..requestResult = const Failure(NetworkError());
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);

      final result = await useCase.execute(
        const RequestPasswordResetInput(email: 'a@b.c'),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NetworkError>());
    });

    test('does not change the gateway auth status on success', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);
      final statusBefore = gateway.status;

      await useCase.execute(const RequestPasswordResetInput(email: 'a@b.c'));

      expect(gateway.status, statusBefore);
    });

    test('does not change the gateway auth status on failure', () async {
      final repo = _RecordingAuthRepository()
        ..requestResult = const Failure(NetworkError());
      final gateway = AuthGateway(repository: repo);
      final useCase = RequestPasswordResetUseCase(gateway: gateway);
      final statusBefore = gateway.status;

      await useCase.execute(const RequestPasswordResetInput(email: 'a@b.c'));

      expect(gateway.status, statusBefore);
    });
  });

  group('RequestPasswordResetInput', () {
    test('value equality is based on email and resetUrl', () {
      const a = RequestPasswordResetInput(
        email: 'a@b.c',
        resetUrl: 'https://x',
      );
      const b = RequestPasswordResetInput(
        email: 'a@b.c',
        resetUrl: 'https://x',
      );
      const c = RequestPasswordResetInput(email: 'a@b.c');
      const d = RequestPasswordResetInput(email: 'other@b.c');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(c, isNot(d));
    });
  });
}
