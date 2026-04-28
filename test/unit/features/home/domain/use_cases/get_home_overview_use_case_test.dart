import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/home/domain/entities/home_overview.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required this.restoredUser});

  final Result<User, DomainError> restoredUser;

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => restoredUser;

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => restoredUser;

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

const _alice = User(
  id: 'u-1',
  email: 'alice@example.com',
  firstName: 'Alice',
  role: UserRole.user,
);
const _admin = User(
  id: 'u-2',
  email: 'admin@example.com',
  firstName: 'Adam',
  role: UserRole.admin,
);

Future<AuthGateway> _makeAuthenticatedGateway(User user) async {
  final repo = _StubAuthRepository(restoredUser: Success(user));
  final gateway = AuthGateway(repository: repo);
  await gateway.tryRestoreSession();
  return gateway;
}

AuthGateway _makeAnonymousGateway() {
  final repo = _StubAuthRepository(
    restoredUser: const Failure(UnauthorizedError()),
  );
  return AuthGateway(repository: repo);
}

void main() {
  group('HomeOverview', () {
    test('value equality compares user and isAdmin', () {
      const a = HomeOverview(user: _alice, isAdmin: false);
      const b = HomeOverview(user: _alice, isAdmin: false);
      const c = HomeOverview(user: _alice, isAdmin: true);
      const d = HomeOverview(user: _admin, isAdmin: false);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
    });

    test('anonymous overview equals another anonymous overview', () {
      const a = HomeOverview(user: null, isAdmin: false);
      const b = HomeOverview(user: null, isAdmin: false);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('GetHomeOverviewUseCase', () {
    test(
      'returns Success with user and isAdmin=false for a regular user',
      () async {
        final gateway = await _makeAuthenticatedGateway(_alice);
        final useCase = GetHomeOverviewUseCase(gateway: gateway);

        final result = useCase.execute(NoInput.instance);

        expect(
          result,
          const Success<HomeOverview, DomainError>(
            HomeOverview(user: _alice, isAdmin: false),
          ),
        );
      },
    );

    test('returns Success with isAdmin=true for an admin user', () async {
      final gateway = await _makeAuthenticatedGateway(_admin);
      final useCase = GetHomeOverviewUseCase(gateway: gateway);

      final result = useCase.execute(NoInput.instance);

      expect(result.isSuccess, isTrue);
      expect(
        result.valueOrNull,
        const HomeOverview(user: _admin, isAdmin: true),
      );
    });

    test('returns Success with null user when gateway is unauthenticated', () {
      final gateway = _makeAnonymousGateway();
      final useCase = GetHomeOverviewUseCase(gateway: gateway);

      final result = useCase.execute(NoInput.instance);

      expect(
        result,
        const Success<HomeOverview, DomainError>(
          HomeOverview(user: null, isAdmin: false),
        ),
      );
    });

    test('reflects the latest gateway snapshot on each call', () async {
      final repo = _StubAuthRepository(restoredUser: Success(_alice));
      final gateway = AuthGateway(repository: repo);
      final useCase = GetHomeOverviewUseCase(gateway: gateway);

      // Initially unauthenticated.
      final before = useCase.execute(NoInput.instance);
      expect(before.valueOrNull?.user, isNull);

      // After session restore, the snapshot reflects Alice.
      await gateway.tryRestoreSession();
      final after = useCase.execute(NoInput.instance);
      expect(after.valueOrNull?.user, _alice);
    });
  });
}
