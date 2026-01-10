import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Tests', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    testWidgets('complete login flow - successful authentication',
        (tester) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
      );

      // Mock initial state as unauthenticated
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Failure(UnauthorizedError()));

      // Mock successful login
      when(() => mockAuthRepository.login('admin@example.com', 'password123'))
          .thenAnswer((_) async => const Success(testUser));

      // Launch app with mocked repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on the login page
      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify login was called
      verify(() => mockAuthRepository.login('admin@example.com', 'password123'))
          .called(1);

      // Verify we're redirected to home page
      expect(find.text('Home Page - Coming Soon'), findsOneWidget);
    });

    testWidgets('login flow - failed authentication shows error',
        (tester) async {
      // Mock initial state as unauthenticated
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Failure(UnauthorizedError()));

      // Mock failed login
      when(() => mockAuthRepository.login(any(), any())).thenAnswer(
        (_) async => const Failure(
          InvalidCredentialsError('Invalid email or password'),
        ),
      );

      // Launch app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Invalid email or password'), findsOneWidget);

      // Verify we're still on login page
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('login flow - form validation prevents empty submission',
        (tester) async {
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
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit without entering credentials
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Verify validation errors are shown
      expect(find.text('Please enter your email'), findsOneWidget);

      // Verify login was not called
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    testWidgets('auth guard - authenticated user redirected from login',
        (tester) async {
      const testUser = User(
        id: '1',
        email: 'user@example.com',
        role: UserRole.user,
      );

      // Mock already authenticated user
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
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be redirected to home page
      expect(find.text('Home Page - Coming Soon'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsNothing);
    });
  });
}
