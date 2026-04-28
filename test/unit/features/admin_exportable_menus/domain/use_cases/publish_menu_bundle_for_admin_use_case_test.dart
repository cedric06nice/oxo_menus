import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';

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

const _published = MenuBundle(
  id: 5,
  name: 'Lunch',
  menuIds: [1, 2],
  pdfFileId: 'file-123',
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
  group('PublishMenuBundleForAdminUseCase — admin', () {
    test(
      'forwards the bundleId to the inner use case and returns its result',
      () async {
        final gateway = await _gatewayFor(_admin);
        addTearDown(gateway.dispose);
        final inner = FakePublishMenuBundleUseCase()
          ..stubExecute(const Success(_published));
        final useCase = PublishMenuBundleForAdminUseCase(
          authGateway: gateway,
          publishMenuBundleUseCase: inner,
        );

        final result = await useCase.execute(5);

        expect(result.valueOrNull, _published);
        expect(inner.calls.single.bundleId, 5);
      },
    );

    test('surfaces inner-use-case failures unchanged', () async {
      final gateway = await _gatewayFor(_admin);
      addTearDown(gateway.dispose);
      final inner = FakePublishMenuBundleUseCase()
        ..stubExecute(const Failure(NetworkError()));
      final useCase = PublishMenuBundleForAdminUseCase(
        authGateway: gateway,
        publishMenuBundleUseCase: inner,
      );

      final result = await useCase.execute(5);

      expect(result, const Failure<MenuBundle, DomainError>(NetworkError()));
    });
  });

  group('PublishMenuBundleForAdminUseCase — non-admin', () {
    test(
      'regular user is denied without invoking the inner use case',
      () async {
        final gateway = await _gatewayFor(_regular);
        addTearDown(gateway.dispose);
        final inner = FakePublishMenuBundleUseCase();
        final useCase = PublishMenuBundleForAdminUseCase(
          authGateway: gateway,
          publishMenuBundleUseCase: inner,
        );

        final result = await useCase.execute(5);

        expect(result.errorOrNull, isA<UnauthorizedError>());
        expect(inner.calls, isEmpty);
      },
    );

    test(
      'anonymous viewer is denied without invoking the inner use case',
      () async {
        final gateway = await _gatewayFor(null);
        addTearDown(gateway.dispose);
        final inner = FakePublishMenuBundleUseCase();
        final useCase = PublishMenuBundleForAdminUseCase(
          authGateway: gateway,
          publishMenuBundleUseCase: inner,
        );

        final result = await useCase.execute(5);

        expect(result.errorOrNull, isA<UnauthorizedError>());
        expect(inner.calls, isEmpty);
      },
    );
  });
}
