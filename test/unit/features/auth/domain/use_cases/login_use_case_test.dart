import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _RecordingAuthRepository implements AuthRepository {
  Result<User, DomainError> loginResult = Success(_alice);
  String? lastEmail;
  String? lastPassword;
  int loginCalls = 0;

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    return loginResult;
  }

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => Success(_alice);

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

const _alice = User(id: 'u-1', email: 'alice@example.com', role: UserRole.user);

void main() {
  group('LoginUseCase', () {
    test('forwards email and password to the gateway', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = LoginUseCase(gateway: gateway);

      await useCase.execute(
        const LoginInput(email: 'a@b.c', password: 'secret'),
      );

      expect(repo.loginCalls, 1);
      expect(repo.lastEmail, 'a@b.c');
      expect(repo.lastPassword, 'secret');
    });

    test('returns Success(user) when gateway login succeeds', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = LoginUseCase(gateway: gateway);

      final result = await useCase.execute(
        const LoginInput(email: 'a@b.c', password: 'secret'),
      );

      expect(result, Success<User, DomainError>(_alice));
    });

    test('propagates Failure from the gateway unchanged', () async {
      final repo = _RecordingAuthRepository()
        ..loginResult = const Failure(InvalidCredentialsError());
      final gateway = AuthGateway(repository: repo);
      final useCase = LoginUseCase(gateway: gateway);

      final result = await useCase.execute(
        const LoginInput(email: 'a@b.c', password: 'wrong'),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<InvalidCredentialsError>());
    });

    test('drives the gateway status to authenticated on success', () async {
      final repo = _RecordingAuthRepository();
      final gateway = AuthGateway(repository: repo);
      final useCase = LoginUseCase(gateway: gateway);

      await useCase.execute(
        const LoginInput(email: 'a@b.c', password: 'secret'),
      );

      expect(gateway.status, AuthStatusAuthenticated(_alice));
    });
  });

  group('LoginInput', () {
    test('value equality is based on email and password', () {
      const a = LoginInput(email: 'a@b.c', password: 'pw');
      const b = LoginInput(email: 'a@b.c', password: 'pw');
      const c = LoginInput(email: 'x@b.c', password: 'pw');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
