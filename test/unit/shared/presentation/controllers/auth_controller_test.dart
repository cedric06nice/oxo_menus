import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/controllers/auth_controller.dart';

import '../../../../fakes/fake_auth_repository.dart';
import '../../../../fakes/reflectable_bootstrap.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  setUpAll(initializeReflectableForTests);

  const adminUser = User(
    id: 'admin-1',
    email: 'admin@example.com',
    firstName: 'Admin',
    lastName: 'User',
    role: UserRole.admin,
  );

  const regularUser = User(
    id: 'user-1',
    email: 'user@example.com',
    firstName: 'Regular',
    lastName: 'User',
    role: UserRole.user,
  );

  group('AuthController', () {
    late FakeAuthRepository fakeRepo;
    late AuthGateway gateway;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      fakeRepo.defaultTryRestoreSessionResponse = failureUnauthorized<User>(
        'No session',
      );
      gateway = AuthGateway(repository: fakeRepo);
    });

    tearDown(() => gateway.dispose());

    test('initial status mirrors the gateway snapshot', () {
      final controller = AuthController(gateway: gateway, autoRestore: false);
      addTearDown(controller.dispose);

      expect(controller.status, isA<AuthStatusInitial>());
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });

    test(
      'autoRestore triggers tryRestoreSession on the gateway exactly once',
      () async {
        final controller = AuthController(gateway: gateway);
        addTearDown(controller.dispose);

        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(fakeRepo.tryRestoreSessionCalls, hasLength(1));
      },
    );

    test('transitions to authenticated when restore succeeds and notifies once '
        'per status change', () async {
      fakeRepo.defaultTryRestoreSessionResponse = success(adminUser);
      final controller = AuthController(gateway: gateway);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.status, AuthStatusAuthenticated(adminUser));
      expect(controller.currentUser, adminUser);
      expect(controller.isAuthenticated, isTrue);
      expect(notifications, greaterThanOrEqualTo(1));
    });

    test('login delegates to the gateway and reflects its state', () async {
      final controller = AuthController(gateway: gateway, autoRestore: false);
      addTearDown(controller.dispose);

      fakeRepo.whenLogin(success(regularUser));
      await controller.login('user@example.com', 'pw');
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, AuthStatusAuthenticated(regularUser));
      expect(controller.isAuthenticated, isTrue);
    });

    test('logout transitions to unauthenticated', () async {
      fakeRepo.defaultTryRestoreSessionResponse = success(adminUser);
      final controller = AuthController(gateway: gateway);
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fakeRepo.whenLogout(const Success<void, DomainError>(null));
      await controller.logout();
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, isA<AuthStatusUnauthenticated>());
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });

    test('refresh calls the gateway and updates the status', () async {
      final controller = AuthController(gateway: gateway, autoRestore: false);
      addTearDown(controller.dispose);

      fakeRepo.whenGetCurrentUser(success(adminUser));
      await controller.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, AuthStatusAuthenticated(adminUser));
    });

    test('does not notify after dispose', () async {
      fakeRepo.defaultTryRestoreSessionResponse = success(adminUser);
      final controller = AuthController(gateway: gateway, autoRestore: false);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.dispose();
      // Push a status update through the gateway after dispose.
      await gateway.tryRestoreSession();

      expect(notifications, 0);
    });

    test('disposing twice is safe', () {
      final controller = AuthController(gateway: gateway, autoRestore: false);

      controller.dispose();

      expect(controller.dispose, returnsNormally);
    });
  });
}
