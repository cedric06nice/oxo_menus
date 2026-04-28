import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
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

const _createdMenu = Menu(
  id: 42,
  name: 'My Template',
  version: '1.0.0',
  status: Status.draft,
  displayOptions: MenuDisplayOptions(),
);

const _input = CreateTemplateInput(
  name: 'My Template',
  version: '1.0.0',
  sizeId: 7,
  areaId: 3,
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
  group('CreateTemplateUseCase — admin', () {
    test(
      'forwards the input to the repository as a draft CreateMenuInput',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final repo = FakeMenuRepository()
          ..whenCreate(const Success(_createdMenu));
        final useCase = CreateTemplateUseCase(
          authGateway: gateway,
          menuRepository: repo,
        );

        final result = await useCase.execute(_input);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, _createdMenu);
        expect(repo.createCalls, hasLength(1));
        final call = repo.createCalls.single;
        expect(call.input.name, 'My Template');
        expect(call.input.version, '1.0.0');
        expect(call.input.status, Status.draft);
        expect(call.input.sizeId, 7);
        expect(call.input.areaId, 3);
      },
    );

    test('omits areaId when not supplied', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenCreate(const Success(_createdMenu));
      final useCase = CreateTemplateUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      await useCase.execute(
        const CreateTemplateInput(name: 'Solo', version: '0.1.0', sizeId: 1),
      );

      expect(repo.createCalls.single.input.areaId, isNull);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenCreate(const Failure(NetworkError('offline')));
      final useCase = CreateTemplateUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result, const Failure<Menu, DomainError>(NetworkError('offline')));
    });
  });

  group('CreateTemplateUseCase — non-admin', () {
    test('regular user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(_regular);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = CreateTemplateUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous user is denied without calling the repository', () async {
      final gateway = await _gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = CreateTemplateUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('CreateTemplateInput', () {
    test('value equality compares every field', () {
      expect(
        const CreateTemplateInput(
          name: 'A',
          version: '1.0.0',
          sizeId: 1,
          areaId: 2,
        ),
        const CreateTemplateInput(
          name: 'A',
          version: '1.0.0',
          sizeId: 1,
          areaId: 2,
        ),
      );
      expect(
        const CreateTemplateInput(
          name: 'A',
          version: '1.0.0',
          sizeId: 1,
          areaId: 2,
        ).hashCode,
        const CreateTemplateInput(
          name: 'A',
          version: '1.0.0',
          sizeId: 1,
          areaId: 2,
        ).hashCode,
      );
      expect(
        const CreateTemplateInput(name: 'A', version: '1.0.0', sizeId: 1),
        isNot(
          const CreateTemplateInput(name: 'A', version: '1.0.0', sizeId: 2),
        ),
      );
      expect(
        const CreateTemplateInput(name: 'A', version: '1.0.0', sizeId: 1),
        isNot(
          const CreateTemplateInput(
            name: 'A',
            version: '1.0.0',
            sizeId: 1,
            areaId: 9,
          ),
        ),
      );
    });

    test('areaId defaults to null', () {
      const input = CreateTemplateInput(name: 'A', version: '1.0.0', sizeId: 1);

      expect(input.areaId, isNull);
    });
  });
}
