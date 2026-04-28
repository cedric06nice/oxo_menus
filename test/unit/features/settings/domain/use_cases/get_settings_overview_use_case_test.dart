import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/entities/settings_overview.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

const _admin = User(
  id: 'a1',
  email: 'admin@example.com',
  firstName: 'Ada',
  role: UserRole.admin,
);
const _regular = User(
  id: 'r1',
  email: 'user@example.com',
  firstName: 'Bob',
  role: UserRole.user,
);

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required this.restored});
  Result<User, DomainError> restored;

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => restored;

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => restored;

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

Future<AuthGateway> _gatewayFor(User? user) async {
  final repo = _StubAuthRepository(
    restored: user == null ? const Failure(UnauthorizedError()) : Success(user),
  );
  final gateway = AuthGateway(repository: repo);
  if (user != null) {
    await gateway.tryRestoreSession();
  }
  return gateway;
}

void main() {
  group('GetSettingsOverviewUseCase', () {
    test(
      'returns admin overview with viewAsUser snapshot for admins',
      () async {
        final auth = await _gatewayFor(_admin);
        addTearDown(auth.dispose);
        final viewAs = AdminViewAsUserGateway();
        addTearDown(viewAs.dispose);
        final useCase = GetSettingsOverviewUseCase(
          authGateway: auth,
          adminViewAsUserGateway: viewAs,
        );

        final result = useCase.execute(NoInput.instance);

        expect(result, isA<Success<SettingsOverview, DomainError>>());
        result.fold(
          onSuccess: (overview) {
            expect(overview.user, _admin);
            expect(overview.isAdmin, isTrue);
            expect(overview.viewAsUser, isFalse);
          },
          onFailure: (_) => fail('expected success'),
        );
      },
    );

    test('returns isAdmin=false for regular users', () async {
      final auth = await _gatewayFor(_regular);
      addTearDown(auth.dispose);
      final viewAs = AdminViewAsUserGateway();
      addTearDown(viewAs.dispose);
      final useCase = GetSettingsOverviewUseCase(
        authGateway: auth,
        adminViewAsUserGateway: viewAs,
      );

      final result = useCase.execute(NoInput.instance);

      result.fold(
        onSuccess: (overview) {
          expect(overview.user, _regular);
          expect(overview.isAdmin, isFalse);
        },
        onFailure: (_) => fail('expected success'),
      );
    });

    test('returns null user when nobody is signed in', () async {
      final auth = await _gatewayFor(null);
      addTearDown(auth.dispose);
      final viewAs = AdminViewAsUserGateway();
      addTearDown(viewAs.dispose);
      final useCase = GetSettingsOverviewUseCase(
        authGateway: auth,
        adminViewAsUserGateway: viewAs,
      );

      final result = useCase.execute(NoInput.instance);

      result.fold(
        onSuccess: (overview) {
          expect(overview.user, isNull);
          expect(overview.isAdmin, isFalse);
        },
        onFailure: (_) => fail('expected success'),
      );
    });

    test('reflects the current viewAsUser value', () async {
      final auth = await _gatewayFor(_admin);
      addTearDown(auth.dispose);
      final viewAs = AdminViewAsUserGateway()..set(true);
      addTearDown(viewAs.dispose);
      final useCase = GetSettingsOverviewUseCase(
        authGateway: auth,
        adminViewAsUserGateway: viewAs,
      );

      final result = useCase.execute(NoInput.instance);

      result.fold(
        onSuccess: (overview) {
          expect(overview.isAdmin, isTrue);
          expect(overview.viewAsUser, isTrue);
        },
        onFailure: (_) => fail('expected success'),
      );
    });

    test('re-reads gateway state on each invocation', () async {
      final auth = await _gatewayFor(_admin);
      addTearDown(auth.dispose);
      final viewAs = AdminViewAsUserGateway();
      addTearDown(viewAs.dispose);
      final useCase = GetSettingsOverviewUseCase(
        authGateway: auth,
        adminViewAsUserGateway: viewAs,
      );

      final first = useCase.execute(NoInput.instance);
      first.fold(
        onSuccess: (overview) => expect(overview.viewAsUser, isFalse),
        onFailure: (_) => fail('expected success'),
      );

      viewAs.set(true);
      final second = useCase.execute(NoInput.instance);
      second.fold(
        onSuccess: (overview) => expect(overview.viewAsUser, isTrue),
        onFailure: (_) => fail('expected success'),
      );
    });
  });
}
