import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/auth/presentation/pages/login_page.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../../fakes/fake_auth_repository.dart';
import '../../../../../fakes/builders/user_builder.dart';
import '../../../../../fakes/result_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
    // Default: no active session — notifier settles into unauthenticated.
    fakeAuthRepo.defaultTryRestoreSessionResponse = failure<User>(
      const UnauthorizedError(),
    );
  });

  Widget buildTestApp({TargetPlatform? platform}) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
      child: MaterialApp(
        theme: platform != null ? ThemeData(platform: platform) : null,
        home: const LoginPage(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LoginPage — material (default platform)
  // ---------------------------------------------------------------------------

  group('LoginPage', () {
    testWidgets('should display app title when page is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('OXO'), findsOneWidget);
    });

    testWidgets('should display subtitle text when page is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Menu Template Builder'), findsOneWidget);
    });

    testWidgets(
      'should display email and password fields when page is rendered',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('email_field')), findsOneWidget);
        expect(find.byKey(const Key('password_field')), findsOneWidget);
      },
    );

    testWidgets('should display login button when page is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('should have empty email field initially', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Act
      final emailField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(TextField),
        ),
      );

      // Assert
      expect(emailField.controller?.text, isEmpty);
    });

    testWidgets('should have empty password field initially', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Act
      final passwordField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(TextField),
        ),
      );

      // Assert
      expect(passwordField.controller?.text, isEmpty);
    });

    testWidgets('should not show error message initially', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsNothing);
    });

    testWidgets(
      'should show validation error when email is empty and login tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('email_field')), '');
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your email'), findsOneWidget);
      },
    );

    testWidgets('should not call login when email is empty and login tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(fakeAuthRepo.loginCalls, isEmpty);
    });

    testWidgets(
      'should show validation error when password is empty and login tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(find.byKey(const Key('password_field')), '');

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your password'), findsOneWidget);
      },
    );

    testWidgets(
      'should not call login when password is empty and login tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(find.byKey(const Key('password_field')), '');

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Assert
        expect(fakeAuthRepo.loginCalls, isEmpty);
      },
    );

    testWidgets('should call login with correct credentials when submitted', (
      tester,
    ) async {
      // Arrange
      fakeAuthRepo.whenLogin(Success(buildUser()));
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeAuthRepo.loginCalls, hasLength(1));
      expect(fakeAuthRepo.loginCalls.first.email, 'test@example.com');
      expect(fakeAuthRepo.loginCalls.first.password, 'password123');
    });

    testWidgets(
      'should display error message when login fails with invalid credentials',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenLogin(
          failure<User>(const InvalidCredentialsError('Invalid credentials')),
        );
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrong_password',
        );

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Invalid credentials'), findsOneWidget);
      },
    );

    testWidgets('should hide password text when password field is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Act
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(TextField),
        ),
      );

      // Assert
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should use email keyboard type for email field', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Act
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(TextField),
        ),
      );

      // Assert
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets(
      'should constrain form width for responsive layout when rendered',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Act
        final constrainedBox = tester.widget<ConstrainedBox>(
          find
              .ancestor(
                of: find.byKey(const Key('email_field')),
                matching: find.byType(ConstrainedBox),
              )
              .first,
        );

        // Assert
        expect(constrainedBox.constraints.maxWidth, 400);
      },
    );

    testWidgets('should wrap form fields in a Card when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.ancestor(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display email icon in email field when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byIcon(Icons.email_outlined),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display lock icon in password field when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byIcon(Icons.lock_outlined),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use FilledButton for login button when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.ancestor(
          of: find.text('Login'),
          matching: find.byType(FilledButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display forgot password link when page is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('forgot_password_link')), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('should not use Form widget for validation when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Form), findsNothing);
    });

    testWidgets(
      'should show loading indicator during login when credentials submitted',
      (tester) async {
        // Arrange — use a fake that never resolves login so loading state persists
        final pendingFake = _PendingLoginFakeAuthRepository(
          defaultTryRestoreResponse: failure<User>(const UnauthorizedError()),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(pendingFake)],
            child: const MaterialApp(home: LoginPage()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Assert — CircularProgressIndicator shown while loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete to release the pending future so no leaks
        pendingFake.completeLogin(failure<User>(const UnauthorizedError()));
        await tester.pumpAndSettle();
      },
    );
  });

  // ---------------------------------------------------------------------------
  // LoginPage logo
  // ---------------------------------------------------------------------------

  group('LoginPage logo', () {
    testWidgets('should display tower logo image above title when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('tower_logo')), findsOneWidget);
    });

    testWidgets('should use black tower image in light mode', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final image = tester.widget<Image>(find.byKey(const Key('tower_logo')));
      final assetImage = image.image as AssetImage;

      // Assert
      expect(assetImage.assetName, 'assets/images/OXOTowerDrawingBlack.png');
    });

    testWidgets('should use white tower image in dark mode', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final image = tester.widget<Image>(find.byKey(const Key('tower_logo')));
      final assetImage = image.image as AssetImage;

      // Assert
      expect(assetImage.assetName, 'assets/images/OXOTowerDrawingWhite.png');
    });

    testWidgets('should place logo above the OXO Menus title when rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Act
      final logoOffset = tester.getCenter(find.byKey(const Key('tower_logo')));
      final titleOffset = tester.getCenter(find.textContaining('OXO'));

      // Assert
      expect(logoOffset.dy, lessThan(titleOffset.dy));
    });
  });

  // ---------------------------------------------------------------------------
  // LoginPage iOS
  // ---------------------------------------------------------------------------

  group('LoginPage iOS', () {
    testWidgets('should use CupertinoTextField for email on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(CupertinoTextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use CupertinoTextField for password on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(CupertinoTextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use CupertinoButton for login on iOS', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('login_button')),
          matching: find.byType(CupertinoButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show validation error when email is empty on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should not call login when email is empty on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(fakeAuthRepo.loginCalls, isEmpty);
    });

    testWidgets('should show validation error when password is empty on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '');

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should not call login when password is empty on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '');

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(fakeAuthRepo.loginCalls, isEmpty);
    });

    testWidgets('should show CupertinoActivityIndicator during login on iOS', (
      tester,
    ) async {
      // Arrange — use a fake that hangs on login
      final pendingFake = _PendingLoginFakeAuthRepository(
        defaultTryRestoreResponse: failure<User>(const UnauthorizedError()),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(pendingFake)],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Cleanup
      pendingFake.completeLogin(failure<User>(const UnauthorizedError()));
      await tester.pumpAndSettle();
    });

    testWidgets('should disable autocorrect on email field on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Act
      final cupertinoField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );

      // Assert
      expect(cupertinoField.autocorrect, isFalse);
    });

    testWidgets('should disable autocorrect on password field on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Act
      final cupertinoField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );

      // Assert
      expect(cupertinoField.autocorrect, isFalse);
    });

    testWidgets('should hide password text on iOS', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Act
      final cupertinoField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );

      // Assert
      expect(cupertinoField.obscureText, isTrue);
    });

    testWidgets('should have email placeholder on iOS', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Act
      final cupertinoField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );

      // Assert
      expect(cupertinoField.placeholder, 'Email');
    });

    testWidgets(
      'should call login with correct credentials on iOS when form submitted',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenLogin(Success(buildUser()));
        await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        // Act
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeAuthRepo.loginCalls, hasLength(1));
        expect(fakeAuthRepo.loginCalls.first.email, 'test@example.com');
        expect(fakeAuthRepo.loginCalls.first.password, 'password123');
      },
    );

    testWidgets('should display error message on login failure on iOS', (
      tester,
    ) async {
      // Arrange
      fakeAuthRepo.whenLogin(
        failure<User>(const InvalidCredentialsError('Invalid credentials')),
      );
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrong_password',
      );

      // Act
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should display CupertinoIcons.mail in email field on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byIcon(CupertinoIcons.mail),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display CupertinoIcons.lock in password field on iOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('password_field')),
          matching: find.byIcon(CupertinoIcons.lock),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should wrap fields in a Card on iOS', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.ancestor(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // LoginPage macOS
  // ---------------------------------------------------------------------------

  group('LoginPage macOS', () {
    testWidgets('should use CupertinoTextField for email on macOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.macOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(CupertinoTextField),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use CupertinoButton for login on macOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.macOS));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.descendant(
          of: find.byKey(const Key('login_button')),
          matching: find.byType(CupertinoButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should disable autocorrect on email field on macOS', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(platform: TargetPlatform.macOS));
      await tester.pumpAndSettle();

      // Act
      final cupertinoField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('email_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );

      // Assert
      expect(cupertinoField.autocorrect, isFalse);
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// A [FakeAuthRepository] variant whose [login] call never completes until
/// [completeLogin] is called.  Used to assert loading-state UI.
class _PendingLoginFakeAuthRepository extends FakeAuthRepository {
  _PendingLoginFakeAuthRepository({
    required Result<User, DomainError> defaultTryRestoreResponse,
  }) {
    defaultTryRestoreSessionResponse = defaultTryRestoreResponse;
  }

  Completer<Result<User, DomainError>>? _loginCompleter;

  /// Resolves the pending [login] future with [result].
  void completeLogin(Result<User, DomainError> result) {
    _loginCompleter?.complete(result);
  }

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    calls.add(LoginCall(email: email, password: password));
    _loginCompleter = Completer<Result<User, DomainError>>();
    return _loginCompleter!.future;
  }
}
