import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Mock tryRestoreSession (called by build via Future.microtask) to return unauthenticated by default
    when(
      () => mockAuthRepository.tryRestoreSession(),
    ).thenAnswer((_) async => const Failure(UnauthorizedError()));
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
  });

  tearDown(() => container.dispose());

  AuthNotifier readNotifier() => container.read(authProvider.notifier);
  AuthState readState() => container.read(authProvider);

  group('AuthNotifier', () {
    const testUser = User(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.user,
    );

    test(
      'build() returns initial state, then microtask triggers loading',
      () async {
        // build() returns initial synchronously
        expect(readState(), const AuthState.initial());

        // After microtask, _tryRestoreSession sets loading
        await Future.microtask(() {});
        expect(readState(), const AuthState.loading());
      },
    );

    test('should check auth status on initialization', () async {
      // Trigger provider
      readState();
      // Wait for the initial check to complete
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockAuthRepository.tryRestoreSession()).called(1);
      expect(readState(), const AuthState.unauthenticated());
    });

    test('should set authenticated state when user is logged in', () async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      // Create a fresh container to trigger build with the new mock behavior
      final freshContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(freshContainer.dispose);

      freshContainer.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        freshContainer.read(authProvider),
        const AuthState.authenticated(testUser),
      );
    });

    group('login', () {
      test(
        'should set loading state then authenticated on successful login',
        () async {
          when(
            () => mockAuthRepository.login(any(), any()),
          ).thenAnswer((_) async => const Success(testUser));

          final states = <AuthState>[];
          container.listen<AuthState>(
            authProvider,
            (_, next) => states.add(next),
          );

          // Wait for initial restore to complete
          await Future.delayed(const Duration(milliseconds: 100));

          await readNotifier().login('test@example.com', 'password');

          expect(states, contains(const AuthState.loading()));
          expect(readState(), const AuthState.authenticated(testUser));
          verify(
            () => mockAuthRepository.login('test@example.com', 'password'),
          ).called(1);
        },
      );

      test('should set error state on failed login', () async {
        const error = InvalidCredentialsError('Invalid email or password');
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => const Failure(error));

        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        await readNotifier().login('test@example.com', 'wrong_password');

        expect(readState(), const AuthState.error('Invalid email or password'));
        verify(
          () => mockAuthRepository.login('test@example.com', 'wrong_password'),
        ).called(1);
      });

      test('should handle network errors', () async {
        const error = NetworkError('Network unavailable');
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => const Failure(error));

        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        await readNotifier().login('test@example.com', 'password');

        expect(readState(), const AuthState.error('Network unavailable'));
      });

      test(
        'should clear error and authenticate on retry after failure',
        () async {
          // Wait for initial restore
          await Future.delayed(const Duration(milliseconds: 100));

          // First attempt fails
          when(() => mockAuthRepository.login(any(), any())).thenAnswer(
            (_) async =>
                const Failure(InvalidCredentialsError('wrong password')),
          );
          await readNotifier().login('test@example.com', 'wrong');
          expect(readState(), const AuthState.error('wrong password'));

          // Second attempt succeeds
          when(
            () => mockAuthRepository.login(any(), any()),
          ).thenAnswer((_) async => const Success(testUser));
          await readNotifier().login('test@example.com', 'correct');

          expect(readState(), const AuthState.authenticated(testUser));
        },
      );
    });

    group('logout', () {
      test('should set unauthenticated state after logout', () async {
        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        // First login
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => const Success(testUser));
        await readNotifier().login('test@example.com', 'password');

        expect(readState(), const AuthState.authenticated(testUser));

        // Then logout
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().logout();

        expect(readState(), const AuthState.unauthenticated());
        verify(() => mockAuthRepository.logout()).called(1);
      });

      test('should set unauthenticated even if repo.logout fails', () async {
        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        // First login
        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenAnswer((_) async => const Success(testUser));
        await readNotifier().login('test@example.com', 'password');

        // Logout fails on backend
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Failure(NetworkError('offline')));

        await readNotifier().logout();

        // Documents current fire-and-forget behavior:
        // state is unauthenticated regardless of repo result
        expect(readState(), const AuthState.unauthenticated());
      });
    });

    group('refresh', () {
      test('should reload current user', () async {
        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Success(testUser));

        await readNotifier().refresh();

        expect(readState(), const AuthState.authenticated(testUser));
        verify(
          () => mockAuthRepository.getCurrentUser(),
        ).called(greaterThan(0));
      });

      test('should set unauthenticated if no user', () async {
        // Wait for initial restore
        await Future.delayed(const Duration(milliseconds: 100));

        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Failure(UnauthorizedError()));

        await readNotifier().refresh();

        expect(readState(), const AuthState.unauthenticated());
      });
    });
  });

  group('currentUserProvider — via ProviderContainer', () {
    const testUser = User(
      id: '1',
      email: 'test@example.com',
      role: UserRole.user,
    );

    test('should return user when session restore succeeds', () async {
      final mock = MockAuthRepository();
      when(
        () => mock.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mock)],
      );
      addTearDown(container.dispose);

      // Trigger the provider and wait for async session restore
      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(currentUserProvider), testUser);
    });

    test('should return null when session restore fails', () async {
      final mock = MockAuthRepository();
      when(
        () => mock.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mock)],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(currentUserProvider), isNull);
    });
  });

  group('isAdminProvider logic', () {
    test('should return true for admin users', () {
      const adminUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      expect(adminUser.role == UserRole.admin, true);
    });

    test('should return false for regular users', () {
      const regularUser = User(
        id: '1',
        email: 'user@example.com',
        role: UserRole.user,
      );

      expect(regularUser.role == UserRole.admin, false);
    });

    test('should return false when user has no role', () {
      const userNoRole = User(id: '1', email: 'user@example.com');

      expect(userNoRole.role == UserRole.admin, false);
    });
  });

  group('isAdminProvider with adminViewAsUser override', () {
    const adminUser = User(
      id: '1',
      email: 'admin@example.com',
      role: UserRole.admin,
    );

    const regularUser = User(
      id: '2',
      email: 'user@example.com',
      role: UserRole.user,
    );

    test('should return true for admin when override is false', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(adminUser)],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), true);
    });

    test('should return false for admin when override is true', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(adminUser)],
      );
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);

      expect(container.read(isAdminProvider), false);
    });

    test('should return false for regular user regardless of override', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(regularUser)],
      );
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);

      expect(container.read(isAdminProvider), false);
    });
  });

  group('adminViewAsUserProvider', () {
    test('should default to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(adminViewAsUserProvider), false);
    });

    test('should be togglable to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).set(true);

      expect(container.read(adminViewAsUserProvider), true);
    });
  });
}
