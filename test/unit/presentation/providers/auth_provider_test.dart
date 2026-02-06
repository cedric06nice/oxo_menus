import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthNotifier authNotifier;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Mock tryRestoreSession (called by constructor) to return unauthenticated by default
    when(() => mockAuthRepository.tryRestoreSession())
        .thenAnswer((_) async => const Failure(UnauthorizedError()));
    authNotifier = AuthNotifier(mockAuthRepository);
  });

  group('AuthNotifier', () {
    const testUser = User(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.user,
    );

    test('should start with initial state', () {
      // Create a new notifier to avoid the auto-check
      final notifier = AuthNotifier(mockAuthRepository);
      // State will be loading because of _checkAuthStatus in constructor
      expect(notifier.state, isA<AuthState>());
    });

    test('should check auth status on initialization', () async {
      // Wait for the initial check to complete
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockAuthRepository.tryRestoreSession()).called(1);
      expect(authNotifier.state, const AuthState.unauthenticated());
    });

    test('should set authenticated state when user is logged in', () async {
      when(() => mockAuthRepository.tryRestoreSession())
          .thenAnswer((_) async => const Success(testUser));

      final newNotifier = AuthNotifier(mockAuthRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(newNotifier.state, const AuthState.authenticated(testUser));
    });

    group('login', () {
      test('should set loading state then authenticated on successful login',
          () async {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Success(testUser));

        final states = <AuthState>[];
        authNotifier.addListener((state) => states.add(state));

        await authNotifier.login('test@example.com', 'password');

        expect(states, contains(const AuthState.loading()));
        expect(authNotifier.state, const AuthState.authenticated(testUser));
        verify(() => mockAuthRepository.login('test@example.com', 'password'))
            .called(1);
      });

      test('should set error state on failed login', () async {
        const error = InvalidCredentialsError('Invalid email or password');
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Failure(error));

        await authNotifier.login('test@example.com', 'wrong_password');

        expect(
          authNotifier.state,
          const AuthState.error('Invalid email or password'),
        );
        verify(
          () => mockAuthRepository.login('test@example.com', 'wrong_password'),
        ).called(1);
      });

      test('should handle network errors', () async {
        const error = NetworkError('Network unavailable');
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Failure(error));

        await authNotifier.login('test@example.com', 'password');

        expect(
          authNotifier.state,
          const AuthState.error('Network unavailable'),
        );
      });
    });

    group('logout', () {
      test('should set unauthenticated state after logout', () async {
        // First login
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Success(testUser));
        await authNotifier.login('test@example.com', 'password');

        expect(authNotifier.state, const AuthState.authenticated(testUser));

        // Then logout
        when(() => mockAuthRepository.logout())
            .thenAnswer((_) async => const Success(null));

        await authNotifier.logout();

        expect(authNotifier.state, const AuthState.unauthenticated());
        verify(() => mockAuthRepository.logout()).called(1);
      });
    });

    group('refresh', () {
      test('should reload current user', () async {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Success(testUser));

        await authNotifier.refresh();

        expect(authNotifier.state, const AuthState.authenticated(testUser));
        verify(() => mockAuthRepository.getCurrentUser()).called(greaterThan(0));
      });

      test('should set unauthenticated if no user', () async {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Failure(UnauthorizedError()));

        await authNotifier.refresh();

        expect(authNotifier.state, const AuthState.unauthenticated());
      });
    });
  });

  group('AuthState pattern matching', () {
    test('should support when pattern matching', () {
      const state = AuthState.authenticated(
        User(
          id: '1',
          email: 'test@example.com',
          role: UserRole.user,
        ),
      );

      final result = state.when(
        initial: () => 'initial',
        loading: () => 'loading',
        authenticated: (user) => 'authenticated: ${user.email}',
        unauthenticated: () => 'unauthenticated',
        error: (message) => 'error: $message',
      );

      expect(result, 'authenticated: test@example.com');
    });

    test('should support maybeWhen pattern matching', () {
      const state = AuthState.loading();

      final result = state.maybeWhen(
        loading: () => 'loading',
        orElse: () => 'other',
      );

      expect(result, 'loading');
    });
  });

  group('currentUserProvider', () {
    test('should return user when authenticated', () {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      const state = AuthState.authenticated(testUser);
      final user = state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      expect(user, testUser);
    });

    test('should return null when not authenticated', () {
      const state = AuthState.unauthenticated();
      final user = state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      expect(user, null);
    });

    test('should return null when loading', () {
      const state = AuthState.loading();
      final user = state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      expect(user, null);
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
      const userNoRole = User(
        id: '1',
        email: 'user@example.com',
      );

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

      container.read(adminViewAsUserProvider.notifier).state = true;

      expect(container.read(isAdminProvider), false);
    });

    test('should return false for regular user regardless of override', () {
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWithValue(regularUser)],
      );
      addTearDown(container.dispose);

      container.read(adminViewAsUserProvider.notifier).state = true;

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

      container.read(adminViewAsUserProvider.notifier).state = true;

      expect(container.read(adminViewAsUserProvider), true);
    });
  });
}
