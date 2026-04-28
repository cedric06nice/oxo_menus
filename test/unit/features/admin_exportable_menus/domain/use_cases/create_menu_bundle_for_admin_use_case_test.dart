import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
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

const _created = MenuBundle(id: 99, name: 'Lunch', menuIds: [1, 2]);

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
  group('CreateMenuBundleForAdminUseCase — admin', () {
    test(
      'forwards the input to repository.create and returns the bundle',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeMenuBundleRepository()
          ..whenCreate(const Success(_created));
        final useCase = CreateMenuBundleForAdminUseCase(
          authGateway: gateway,
          bundleRepository: repo,
        );

        const input = CreateMenuBundleInput(name: 'Lunch', menuIds: [1, 2]);
        final result = await useCase.execute(input);

        expect(result.valueOrNull, _created);
        expect(repo.calls, hasLength(1));
        expect(repo.calls.single, isA<MenuBundleCreateCall>());
        expect((repo.calls.single as MenuBundleCreateCall).input, input);
      },
    );

    test('returns ValidationError when name is empty without calling the '
        'repository', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository();
      final useCase = CreateMenuBundleForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(
        const CreateMenuBundleInput(name: '   ', menuIds: [1]),
      );

      expect(result.errorOrNull, isA<ValidationError>());
      expect(repo.calls, isEmpty);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository()
        ..whenCreate(const Failure(NetworkError()));
      final useCase = CreateMenuBundleForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(
        const CreateMenuBundleInput(name: 'Lunch', menuIds: [1]),
      );

      expect(result, const Failure<MenuBundle, DomainError>(NetworkError()));
    });
  });

  group('CreateMenuBundleForAdminUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository();
      final useCase = CreateMenuBundleForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(
        const CreateMenuBundleInput(name: 'Lunch', menuIds: [1]),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuBundleRepository();
      final useCase = CreateMenuBundleForAdminUseCase(
        authGateway: gateway,
        bundleRepository: repo,
      );

      final result = await useCase.execute(
        const CreateMenuBundleInput(name: 'Lunch', menuIds: [1]),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
