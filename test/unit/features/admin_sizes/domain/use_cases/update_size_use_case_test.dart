import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
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

const _input = UpdateSizeInput(id: 5, name: 'Renamed');

const _updated = Size(
  id: 5,
  name: 'Renamed',
  width: 210,
  height: 297,
  status: Status.draft,
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
  group('UpdateSizeUseCase — admin', () {
    test('forwards the input to the repository on success', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()..whenUpdate(const Success(_updated));
      final useCase = UpdateSizeUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result, const Success<Size, DomainError>(_updated));
      expect(repo.updateCalls.single.input, _input);
    });

    test('passes through repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenUpdate(const Failure(NetworkError('offline')));
      final useCase = UpdateSizeUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result, const Failure<Size, DomainError>(NetworkError('offline')));
    });
  });

  group('UpdateSizeUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = UpdateSizeUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = UpdateSizeUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
