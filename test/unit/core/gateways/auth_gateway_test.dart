import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<User, DomainError> loginResult = Success(_alice);
  Result<User, DomainError> restoreResult = const Failure(
    UnauthorizedError('no session'),
  );
  Result<User, DomainError> currentUserResult = Success(_alice);
  Result<void, DomainError> logoutResult = const Success(null);

  int loginCalls = 0;
  int logoutCalls = 0;
  int restoreCalls = 0;

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    loginCalls++;
    return loginResult;
  }

  @override
  Future<Result<void, DomainError>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => currentUserResult;

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async {
    restoreCalls++;
    return restoreResult;
  }

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
  group('AuthGateway', () {
    test('initial status is AuthStatus.initial', () {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);

      expect(gateway.status, const AuthStatusInitial());
      expect(gateway.isAuthenticated, isFalse);
      expect(gateway.currentUser, isNull);
    });

    test(
      'tryRestoreSession transitions loading -> authenticated on success',
      () async {
        final repo = _FakeAuthRepository()..restoreResult = Success(_alice);
        final gateway = AuthGateway(repository: repo);
        final emitted = <AuthStatus>[];
        final sub = gateway.statusStream.listen(emitted.add);

        await gateway.tryRestoreSession();
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(repo.restoreCalls, 1);
        expect(emitted.first, const AuthStatusLoading());
        expect(emitted.last, AuthStatusAuthenticated(_alice));
        expect(gateway.isAuthenticated, isTrue);
        expect(gateway.currentUser, _alice);
      },
    );

    test(
      'tryRestoreSession transitions to unauthenticated on failure',
      () async {
        final repo = _FakeAuthRepository();
        final gateway = AuthGateway(repository: repo);

        await gateway.tryRestoreSession();

        expect(gateway.status, const AuthStatusUnauthenticated());
        expect(gateway.isAuthenticated, isFalse);
      },
    );

    test('login on success becomes authenticated', () async {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);

      final result = await gateway.login('a@b.c', 'pw');

      expect(repo.loginCalls, 1);
      expect(result.isSuccess, isTrue);
      expect(gateway.status, AuthStatusAuthenticated(_alice));
    });

    test('login on failure exposes error status with message', () async {
      final repo = _FakeAuthRepository()
        ..loginResult = const Failure(InvalidCredentialsError());
      final gateway = AuthGateway(repository: repo);

      final result = await gateway.login('a@b.c', 'wrong');

      expect(result.isFailure, isTrue);
      expect(gateway.status, const AuthStatusError('Invalid credentials'));
      expect(gateway.isAuthenticated, isFalse);
    });

    test('logout transitions to unauthenticated and clears user', () async {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);
      await gateway.login('a@b.c', 'pw');

      await gateway.logout();

      expect(repo.logoutCalls, 1);
      expect(gateway.status, const AuthStatusUnauthenticated());
      expect(gateway.currentUser, isNull);
    });

    test(
      'statusStream is broadcast — multiple subscribers each see new events',
      () async {
        final repo = _FakeAuthRepository();
        final gateway = AuthGateway(repository: repo);

        final a = <AuthStatus>[];
        final b = <AuthStatus>[];
        final subA = gateway.statusStream.listen(a.add);
        final subB = gateway.statusStream.listen(b.add);

        await gateway.login('a@b.c', 'pw');
        await Future<void>.delayed(Duration.zero);
        await subA.cancel();
        await subB.cancel();

        expect(a.last, AuthStatusAuthenticated(_alice));
        expect(b.last, AuthStatusAuthenticated(_alice));
      },
    );

    test('current status is exposed via .status for late callers', () async {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);
      await gateway.login('a@b.c', 'pw');

      expect(gateway.status, AuthStatusAuthenticated(_alice));
    });

    test('refresh on success transitions to authenticated', () async {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);

      final result = await gateway.refresh();

      expect(result.isSuccess, isTrue);
      expect(gateway.status, AuthStatusAuthenticated(_alice));
    });

    test('refresh on failure transitions to unauthenticated', () async {
      final repo = _FakeAuthRepository()
        ..currentUserResult = const Failure(UnauthorizedError());
      final gateway = AuthGateway(repository: repo);
      await gateway.login('a@b.c', 'pw'); // first authenticate

      await gateway.refresh();

      expect(gateway.status, const AuthStatusUnauthenticated());
    });

    test('dispose closes the stream', () async {
      final repo = _FakeAuthRepository();
      final gateway = AuthGateway(repository: repo);

      gateway.dispose();

      expect(gateway.isDisposed, isTrue);
    });
  });
}
