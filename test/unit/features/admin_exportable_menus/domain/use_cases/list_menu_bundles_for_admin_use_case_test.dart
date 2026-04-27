import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_menu_bundle_repository.dart';

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

const _admin = User(
  id: 'u-admin',
  email: 'admin@example.com',
  role: UserRole.admin,
);

const _regular = User(
  id: 'u-1',
  email: 'alice@example.com',
  role: UserRole.user,
);

const _bundleA = MenuBundle(id: 1, name: 'Lunch', menuIds: [10, 11]);
const _bundleB = MenuBundle(id: 2, name: 'Dinner', menuIds: [20]);

Future<AuthGateway> _gatewayFor(User? user) async {
  final repo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final gateway = AuthGateway(repository: repo);
  if (user != null) {
    await gateway.tryRestoreSession();
  }
  return gateway;
}

void main() {
  group('ListMenuBundlesForAdminUseCase — admin', () {
    test(
      'returns every bundle in the order provided by the repository',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeMenuBundleRepository()
          ..whenGetAll(const Success([_bundleA, _bundleB]));
        final useCase = ListMenuBundlesForAdminUseCase(
          authGateway: gateway,
          bundleRepository: repo,
        );

        final result = await useCase.execute(NoInput.instance);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, [_bundleA, _bundleB]);
        expect(repo.calls.single, isA<MenuBundleGetAllCall>());
      },
    );

    test('returns an empty list when the repository returns no bundles', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository()
        ..whenGetAll(const Success(<MenuBundle>[]));
      final useCase = ListMenuBundlesForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.valueOrNull, isEmpty);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListMenuBundlesForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(
        result,
        const Failure<List<MenuBundle>, DomainError>(NetworkError()),
      );
    });
  });

  group('ListMenuBundlesForAdminUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository();
      final useCase = ListMenuBundlesForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository();
      final useCase = ListMenuBundlesForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
