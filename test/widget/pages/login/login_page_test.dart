import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/presentation/pages/login/login_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage', () {
    testWidgets('should display app title', (tester) async {
      // Mock getCurrentUser to return unauthenticated
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('OXO Menus'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clear email, enter password
      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);

      // Login should not have been called
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    testWidgets('should validate empty password', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter email, clear password
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '');

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter your password'), findsOneWidget);

      // Login should not have been called
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    testWidgets('should call login with correct credentials', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => const Success(testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter email and password
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify login was called with correct credentials
      verify(
        () => mockAuthRepository.login('test@example.com', 'password123'),
      ).called(1);
    });

    testWidgets('should successfully login and call repository', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => const Success(testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify login was called
      verify(
        () => mockAuthRepository.login('test@example.com', 'password123'),
      ).called(1);
    });

    testWidgets('should display error message on login failure', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));
      when(() => mockAuthRepository.login(any(), any())).thenAnswer(
        (_) async =>
            const Failure(InvalidCredentialsError('Invalid credentials')),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrong_password',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should hide password text', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find TextField widget inside TextFormField
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(TextField),
        ),
      );

      expect(textField.obscureText, isTrue);
    });

    testWidgets('should have email keyboard type for email field', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find TextField widget inside TextFormField
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(TextField),
        ),
      );

      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should have empty fields initially', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(TextField),
        ),
      );
      final passwordField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(TextField),
        ),
      );

      expect(emailField.controller?.text, isEmpty);
      expect(passwordField.controller?.text, isEmpty);
    });

    testWidgets('should constrain form width for responsive layout', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final constrainedBox = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('email_field')),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrainedBox.constraints.maxWidth, 400);
    });

    testWidgets('should display subtitle text', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Menu Template Builder'), findsOneWidget);
    });

    testWidgets('should wrap form fields in a Card', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Card should contain the email field
      expect(
        find.ancestor(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display email icon in email field', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byIcon(Icons.email_outlined),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display lock icon in password field', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byIcon(Icons.lock_outlined),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use FilledButton for login', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.text('Login'),
          matching: find.byType(FilledButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should not show error initially', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsNothing);
    });
  });
}
