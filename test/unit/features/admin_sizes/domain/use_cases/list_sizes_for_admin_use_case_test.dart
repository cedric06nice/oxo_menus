import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_size_repository.dart';

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

const _draftSize = Size(
  id: 1,
  name: 'A4 Draft',
  width: 210,
  height: 297,
  status: Status.draft,
  direction: 'portrait',
);

const _publishedSize = Size(
  id: 2,
  name: 'A3 Published',
  width: 297,
  height: 420,
  status: Status.published,
  direction: 'portrait',
);

const _archivedSize = Size(
  id: 3,
  name: 'Letter Archived',
  width: 216,
  height: 279,
  status: Status.archived,
  direction: 'portrait',
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
  group('ListSizesForAdminUseCase — admin', () {
    test('with default `all` filter returns every size unfiltered', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(
          const Success([_draftSize, _publishedSize, _archivedSize]),
        );
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(const ListSizesForAdminInput());

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, [_draftSize, _publishedSize, _archivedSize]);
      expect(repo.calls, hasLength(1));
      expect(repo.calls.single, isA<GetAllSizesCall>());
    });

    test('with `draft` filter narrows by status name', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(
          const Success([_draftSize, _publishedSize, _archivedSize]),
        );
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(
        const ListSizesForAdminInput(statusFilter: 'draft'),
      );

      expect(result.valueOrNull, [_draftSize]);
    });

    test('with `published` filter narrows by status name', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(
          const Success([_draftSize, _publishedSize, _archivedSize]),
        );
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(
        const ListSizesForAdminInput(statusFilter: 'published'),
      );

      expect(result.valueOrNull, [_publishedSize]);
    });

    test('with `archived` filter narrows by status name', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(
          const Success([_draftSize, _publishedSize, _archivedSize]),
        );
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(
        const ListSizesForAdminInput(statusFilter: 'archived'),
      );

      expect(result.valueOrNull, [_archivedSize]);
    });

    test('with `all` filter preserves order and does not filter', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(const Success([_publishedSize, _draftSize]));
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(
        const ListSizesForAdminInput(statusFilter: 'all'),
      );

      expect(result.valueOrNull, [_publishedSize, _draftSize]);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(const ListSizesForAdminInput());

      expect(result, const Failure<List<Size>, DomainError>(NetworkError()));
    });
  });

  group('ListSizesForAdminUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(const ListSizesForAdminInput());

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForAdminUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(const ListSizesForAdminInput());

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('ListSizesForAdminInput', () {
    test('default filter is "all"', () {
      const input = ListSizesForAdminInput();

      expect(input.statusFilter, 'all');
    });

    test('value equality compares the filter', () {
      expect(
        const ListSizesForAdminInput(statusFilter: 'draft'),
        const ListSizesForAdminInput(statusFilter: 'draft'),
      );
      expect(
        const ListSizesForAdminInput(statusFilter: 'draft').hashCode,
        const ListSizesForAdminInput(statusFilter: 'draft').hashCode,
      );
      expect(
        const ListSizesForAdminInput(statusFilter: 'draft'),
        isNot(const ListSizesForAdminInput(statusFilter: 'published')),
      );
    });
  });
}
