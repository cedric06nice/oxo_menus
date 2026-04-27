import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_menu_repository.dart';

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

const _draftMenu = Menu(
  id: 1,
  name: 'Draft Menu',
  status: Status.draft,
  version: '1.0',
);

const _publishedMenu = Menu(
  id: 2,
  name: 'Published Menu',
  status: Status.published,
  version: '1.0',
);

const _archivedMenu = Menu(
  id: 3,
  name: 'Archived Menu',
  status: Status.archived,
  version: '1.0',
);

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
  group('ListTemplatesForAdminUseCase — admin', () {
    test(
      'with default `all` filter returns every template unfiltered',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeMenuRepository()
          ..whenListAll(
            const Success([_draftMenu, _publishedMenu, _archivedMenu]),
          );
        final useCase = ListTemplatesForAdminUseCase(
          authGateway: gateway,
          menuRepository: repo,
        );

        final result = await useCase.execute(
          const ListTemplatesForAdminInput(),
        );

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, [_draftMenu, _publishedMenu, _archivedMenu]);
        expect(repo.listAllCalls, hasLength(1));
        expect(repo.listAllCalls.single.onlyPublished, isFalse);
        expect(repo.listAllCalls.single.areaIds, isNull);
      },
    );

    test('with `draft` filter narrows by status name', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenListAll(
          const Success([_draftMenu, _publishedMenu, _archivedMenu]),
        );
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(
        const ListTemplatesForAdminInput(statusFilter: 'draft'),
      );

      expect(result.valueOrNull, [_draftMenu]);
    });

    test('with `published` filter narrows by status name', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenListAll(
          const Success([_draftMenu, _publishedMenu, _archivedMenu]),
        );
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(
        const ListTemplatesForAdminInput(statusFilter: 'published'),
      );

      expect(result.valueOrNull, [_publishedMenu]);
    });

    test('with `all` filter preserves order and does not filter', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenListAll(const Success([_publishedMenu, _draftMenu]));
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(
        const ListTemplatesForAdminInput(statusFilter: 'all'),
      );

      expect(result.valueOrNull, [_publishedMenu, _draftMenu]);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenListAll(const Failure(NetworkError()));
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(const ListTemplatesForAdminInput());

      expect(result, const Failure<List<Menu>, DomainError>(NetworkError()));
    });
  });

  group('ListTemplatesForAdminUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(const ListTemplatesForAdminInput());

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = ListTemplatesForAdminUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(const ListTemplatesForAdminInput());

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('ListTemplatesForAdminInput', () {
    test('default filter is "all"', () {
      const input = ListTemplatesForAdminInput();

      expect(input.statusFilter, 'all');
    });

    test('value equality compares the filter', () {
      expect(
        const ListTemplatesForAdminInput(statusFilter: 'draft'),
        const ListTemplatesForAdminInput(statusFilter: 'draft'),
      );
      expect(
        const ListTemplatesForAdminInput(statusFilter: 'draft'),
        isNot(const ListTemplatesForAdminInput(statusFilter: 'published')),
      );
    });
  });
}
