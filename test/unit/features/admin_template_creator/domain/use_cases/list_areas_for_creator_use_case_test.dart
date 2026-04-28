import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_area_repository.dart';

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

const _dining = Area(id: 1, name: 'Dining');
const _bar = Area(id: 2, name: 'Bar');

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
  group('ListAreasForCreatorUseCase — admin', () {
    test(
      'returns every area in the order provided by the repository',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeAreaRepository()
          ..whenGetAll(const Success([_dining, _bar]));
        final useCase = ListAreasForCreatorUseCase(
          authGateway: gateway,
          areaRepository: repo,
        );

        final result = await useCase.execute(NoInput.instance);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, [_dining, _bar]);
        expect(repo.calls, hasLength(1));
        expect(repo.calls.single, isA<GetAllAreasCall>());
      },
    );

    test(
      'returns an empty list when the repository returns no areas',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeAreaRepository()..whenGetAll(const Success(<Area>[]));
        final useCase = ListAreasForCreatorUseCase(
          authGateway: gateway,
          areaRepository: repo,
        );

        final result = await useCase.execute(NoInput.instance);

        expect(result.valueOrNull, isEmpty);
      },
    );

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListAreasForCreatorUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result, const Failure<List<Area>, DomainError>(NetworkError()));
    });
  });

  group('ListAreasForCreatorUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository();
      final useCase = ListAreasForCreatorUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository();
      final useCase = ListAreasForCreatorUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
