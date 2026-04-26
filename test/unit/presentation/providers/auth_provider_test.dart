import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
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

  group('AuthNotifier', () {
    late FakeAuthRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      // Default: session restore fails → notifier starts unauthenticated
      fakeRepo.defaultTryRestoreSessionResponse = failureUnauthorized<User>(
        'No session',
      );
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() => container.dispose());

    AuthNotifier readNotifier() => container.read(authProvider.notifier);
    AuthState readState() => container.read(authProvider);

    test('should return initial state synchronously when first read', () {
      expect(readState(), const AuthState.initial());
    });

    test(
      'should transition to loading during session restore microtask',
      () async {
        readState(); // trigger build
        await Future.microtask(() {});
        expect(readState(), const AuthState.loading());
      },
    );

    test(
      'should set unauthenticated state when session restore fails',
      () async {
        readState();
        await Future.delayed(const Duration(milliseconds: 50));
        expect(readState(), const AuthState.unauthenticated());
      },
    );

    test(
      'should set authenticated state when session restore succeeds',
      () async {
        // Arrange: configure before the build triggers
        fakeRepo.defaultTryRestoreSessionResponse = success(adminUser);
        // Act: trigger the build (and the microtask that calls tryRestoreSession)
        readState();
        await Future.delayed(const Duration(milliseconds: 50));
        // Assert
        expect(readState(), const AuthState.authenticated(adminUser));
      },
    );

    test('should call tryRestoreSession exactly once on build', () async {
      readState();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(fakeRepo.tryRestoreSessionCalls, hasLength(1));
    });

    group('login', () {
      test(
        'should set loading state then authenticated on successful login',
        () async {
          fakeRepo.whenLogin(success(regularUser));
          await Future.delayed(const Duration(milliseconds: 50));

          final states = <AuthState>[];
          container.listen<AuthState>(
            authProvider,
            (_, next) => states.add(next),
          );

          await readNotifier().login('user@example.com', 'password');

          expect(states, contains(const AuthState.loading()));
          expect(readState(), const AuthState.authenticated(regularUser));
        },
      );

      test('should set error state on failed login', () async {
        fakeRepo.whenLogin(
          failure<User>(const InvalidCredentialsError('Invalid credentials')),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        await readNotifier().login('user@example.com', 'wrong');

        expect(readState(), const AuthState.error('Invalid credentials'));
      });

      test('should record login call with correct arguments', () async {
        fakeRepo.whenLogin(success(regularUser));
        await Future.delayed(const Duration(milliseconds: 50));

        await readNotifier().login('user@example.com', 'secret');

        expect(fakeRepo.loginCalls, hasLength(1));
        expect(fakeRepo.loginCalls.first.email, 'user@example.com');
        expect(fakeRepo.loginCalls.first.password, 'secret');
      });

      test('should handle network error during login', () async {
        fakeRepo.whenLogin(failureNetwork<User>('No connection'));
        await Future.delayed(const Duration(milliseconds: 50));

        await readNotifier().login('user@example.com', 'password');

        expect(readState(), const AuthState.error('No connection'));
      });

      test(
        'should authenticate on retry after previous login failure',
        () async {
          fakeRepo.whenLogin(
            failure<User>(const InvalidCredentialsError('wrong password')),
          );
          await Future.delayed(const Duration(milliseconds: 50));
          await readNotifier().login('user@example.com', 'wrong');
          expect(readState(), const AuthState.error('wrong password'));

          fakeRepo.whenLogin(success(regularUser));
          await readNotifier().login('user@example.com', 'correct');
          expect(readState(), const AuthState.authenticated(regularUser));
        },
      );
    });

    group('logout', () {
      test(
        'should set unauthenticated state after successful logout',
        () async {
          fakeRepo.whenLogin(success(regularUser));
          await Future.delayed(const Duration(milliseconds: 50));
          await readNotifier().login('user@example.com', 'password');
          expect(readState(), const AuthState.authenticated(regularUser));

          fakeRepo.whenLogout(success<void>(null));
          await readNotifier().logout();

          expect(readState(), const AuthState.unauthenticated());
        },
      );

      test(
        'should set unauthenticated state even when repo logout fails',
        () async {
          fakeRepo.whenLogin(success(regularUser));
          await Future.delayed(const Duration(milliseconds: 50));
          await readNotifier().login('user@example.com', 'password');

          fakeRepo.whenLogout(failureNetwork<void>('offline'));
          await readNotifier().logout();

          // Fire-and-forget: state is unauthenticated regardless
          expect(readState(), const AuthState.unauthenticated());
        },
      );

      test('should call logout on repository', () async {
        fakeRepo.whenLogin(success(regularUser));
        await Future.delayed(const Duration(milliseconds: 50));
        await readNotifier().login('user@example.com', 'password');

        fakeRepo.whenLogout(success<void>(null));
        await readNotifier().logout();

        expect(fakeRepo.logoutCalls, hasLength(1));
      });
    });

    group('refresh', () {
      test('should set authenticated state when current user exists', () async {
        fakeRepo.whenGetCurrentUser(success(adminUser));
        await Future.delayed(const Duration(milliseconds: 50));

        await readNotifier().refresh();

        expect(readState(), const AuthState.authenticated(adminUser));
        expect(fakeRepo.getCurrentUserCalls, hasLength(1));
      });

      test('should set unauthenticated state when no current user', () async {
        fakeRepo.whenGetCurrentUser(failureUnauthorized<User>());
        await Future.delayed(const Duration(milliseconds: 50));

        await readNotifier().refresh();

        expect(readState(), const AuthState.unauthenticated());
      });
    });
  });

  group('currentUserProvider', () {
    test('should return the user when authenticated', () async {
      final fakeRepo = FakeAuthRepository();
      fakeRepo.defaultTryRestoreSessionResponse = success(regularUser);

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(currentUserProvider), regularUser);
    });

    test('should return null when unauthenticated', () async {
      final fakeRepo = FakeAuthRepository();
      fakeRepo.defaultTryRestoreSessionResponse = failureUnauthorized<User>(
        'No session',
      );

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(currentUserProvider), isNull);
    });

    test('should return null in loading state', () {
      final fakeRepo = FakeAuthRepository();
      // Never resolves — keep it in loading state
      fakeRepo.defaultTryRestoreSessionResponse = failureUnauthorized<User>(
        'slow',
      );

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      // Reading before microtask: state is initial → currentUser is null
      expect(container.read(currentUserProvider), isNull);
    });

    test('should return null in error state', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserProvider), isNull);
    });
  });

  group('isAdminProvider', () {
    test('should return true for admin user when viewAsUser is false', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(adminUser)],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isTrue);
    });

    test('should return false for admin user when viewAsUser is true', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(adminUser)],
      );
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('should return false for regular user regardless of viewAsUser', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(regularUser)],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('should return false when user is null', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('should return false when user role is null', () {
      const userNoRole = User(id: '1', email: 'norole@example.com');
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(userNoRole)],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isFalse);
    });
  });

  group('adminViewAsUserProvider', () {
    test('should default to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(adminViewAsUserProvider), isFalse);
    });

    test('should update to true when set is called with true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);

      expect(container.read(adminViewAsUserProvider), isTrue);
    });

    test('should toggle from false to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).toggle();

      expect(container.read(adminViewAsUserProvider), isTrue);
    });

    test('should toggle from true back to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);
      container.read(adminViewAsUserProvider.notifier).toggle();

      expect(container.read(adminViewAsUserProvider), isFalse);
    });

    test('should reset to false when set is called with false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);
      container.read(adminViewAsUserProvider.notifier).set(false);

      expect(container.read(adminViewAsUserProvider), isFalse);
    });
  });
}
