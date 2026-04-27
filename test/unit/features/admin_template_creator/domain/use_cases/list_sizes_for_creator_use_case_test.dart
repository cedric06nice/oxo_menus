import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
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

const _draft = Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.draft,
  direction: 'portrait',
);

const _published = Size(
  id: 2,
  name: 'A3',
  width: 297,
  height: 420,
  status: Status.published,
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
  group('ListSizesForCreatorUseCase — admin', () {
    test(
      'returns every size in the order provided by the repository',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeSizeRepository()
          ..whenGetAll(const Success([_draft, _published]));
        final useCase = ListSizesForCreatorUseCase(
          authGateway: gateway,
          sizeRepository: repo,
        );

        final result = await useCase.execute(NoInput.instance);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, [_draft, _published]);
        expect(repo.calls, hasLength(1));
        expect(repo.calls.single, isA<GetAllSizesCall>());
      },
    );

    test(
      'returns an empty list when the repository returns no sizes',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeSizeRepository()..whenGetAll(const Success(<Size>[]));
        final useCase = ListSizesForCreatorUseCase(
          authGateway: gateway,
          sizeRepository: repo,
        );

        final result = await useCase.execute(NoInput.instance);

        expect(result.valueOrNull, isEmpty);
      },
    );

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListSizesForCreatorUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result, const Failure<List<Size>, DomainError>(NetworkError()));
    });
  });

  group('ListSizesForCreatorUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForCreatorUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForCreatorUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
