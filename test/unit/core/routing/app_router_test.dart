import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AppRouter - Route Configuration', () {
    testWidgets('should have /login route', (tester) async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be on login page by default
      expect(find.text('OXO Menus'), findsOneWidget);
    });

    testWidgets('should have /home route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Home Page - Coming Soon'), findsOneWidget);
    });

    testWidgets('should have /menus route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to menus
      router.go('/menus');
      await tester.pumpAndSettle();

      // Should show menus page
      expect(find.text('Menus'), findsOneWidget);
    });

    testWidgets('should have /menus/:id route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to menu editor
      router.go('/menus/menu-123');
      await tester.pumpAndSettle();

      // Should show menu editor page
      expect(find.text('Menu Editor - Coming Soon'), findsOneWidget);
    });

    testWidgets('should have /admin/templates route for admins', (tester) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin templates
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should show admin templates page
      expect(find.text('Admin Templates - Coming Soon'), findsOneWidget);
    });

    testWidgets('should have /admin/templates/:id route for admins', (tester) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin template editor
      router.go('/admin/templates/template-123');
      await tester.pumpAndSettle();

      // Should show admin template editor page
      expect(find.text('Admin Template Editor - Coming Soon'), findsOneWidget);
    });
  });

  group('AppRouter - Auth Guards', () {
    testWidgets('should redirect unauthenticated users to login', (tester) async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Failure(UnauthorizedError()));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to protected route
      router.go('/menus');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('should redirect authenticated users away from login', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to login
      router.go('/login');
      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Home Page - Coming Soon'), findsOneWidget);
    });
  });

  group('AppRouter - Admin Guards', () {
    testWidgets('should block non-admin users from admin routes', (tester) async {
      const testUser = User(
        id: '1',
        email: 'user@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to admin route
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Home Page - Coming Soon'), findsOneWidget);
      expect(find.text('Admin Templates - Coming Soon'), findsNothing);
    });

    testWidgets('should allow admin users to access admin routes', (tester) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin route
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should show admin page
      expect(find.text('Admin Templates - Coming Soon'), findsOneWidget);
    });
  });

  group('AppRouter - Deep Linking', () {
    testWidgets('should support deep linking to menu detail', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate deep link by programmatically navigating
      router.go('/menus/menu-123');
      await tester.pumpAndSettle();

      // Should navigate directly to menu editor
      expect(find.text('Menu Editor - Coming Soon'), findsOneWidget);
    });

    testWidgets('should support deep linking to admin template editor', (tester) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate deep link by programmatically navigating
      router.go('/admin/templates/template-123');
      await tester.pumpAndSettle();

      // Should navigate directly to admin template editor
      expect(find.text('Admin Template Editor - Coming Soon'), findsOneWidget);
    });

    testWidgets('should redirect deep link to login if unauthenticated', (tester) async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Failure(UnauthorizedError()));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to protected route via deep link
      router.go('/menus/menu-123');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });
  });
}
