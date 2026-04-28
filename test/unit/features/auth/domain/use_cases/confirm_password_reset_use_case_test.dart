import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _RecordingAuthRepository implements AuthRepository {
  Result<void, DomainError> confirmResult = const Success(null);
  String? lastToken;
  String? lastPassword;
  int confirmCalls = 0;

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
  }) async {
    confirmCalls++;
    lastToken = token;
    lastPassword = password;
    return confirmResult;
  }
}

void main() {
  group('ConfirmPasswordResetUseCase', () {
    test('forwards token and password to the gateway', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = ConfirmPasswordResetUseCase(gateway: gateway);

      await useCase.execute(
        const ConfirmPasswordResetInput(token: 'tk-1', password: 'p@ss'),
      );

      expect(repo.confirmCalls, 1);
      expect(repo.lastToken, 'tk-1');
      expect(repo.lastPassword, 'p@ss');
    });

    test('returns Success(null) when the gateway succeeds', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = ConfirmPasswordResetUseCase(gateway: gateway);

      final result = await useCase.execute(
        const ConfirmPasswordResetInput(token: 't', password: 'p'),
      );

      expect(result, const Success<void, DomainError>(null));
    });

    test('propagates Failure from the gateway unchanged', () async {
      final repo = _RecordingAuthRepository()
        ..confirmResult = const Failure(ValidationError('expired'));
      final gateway = AuthGateway(repository: repo);
      final useCase = ConfirmPasswordResetUseCase(gateway: gateway);

      final result = await useCase.execute(
        const ConfirmPasswordResetInput(token: 't', password: 'p'),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('does not change the gateway auth status on success', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = ConfirmPasswordResetUseCase(gateway: gateway);
      final statusBefore = gateway.status;

      await useCase.execute(
        const ConfirmPasswordResetInput(token: 't', password: 'p'),
      );

      expect(gateway.status, statusBefore);
    });

    test('does not change the gateway auth status on failure', () async {
      final repo = _RecordingAuthRepository()
        ..confirmResult = const Failure(NetworkError());
      final gateway = AuthGateway(repository: repo);
      final useCase = ConfirmPasswordResetUseCase(gateway: gateway);
      final statusBefore = gateway.status;

      await useCase.execute(
        const ConfirmPasswordResetInput(token: 't', password: 'p'),
      );

      expect(gateway.status, statusBefore);
    });
  });

  group('ConfirmPasswordResetInput', () {
    test('value equality is based on token and password', () {
      const a = ConfirmPasswordResetInput(token: 't', password: 'p');
      const b = ConfirmPasswordResetInput(token: 't', password: 'p');
      const c = ConfirmPasswordResetInput(token: 't', password: 'other');
      const d = ConfirmPasswordResetInput(token: 'other', password: 'p');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
    });
  });
}
