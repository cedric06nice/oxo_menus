import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../../fakes/fake_auth_repository.dart';
import '../../../../../fakes/result_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
    // AuthNotifier calls tryRestoreSession on init — wire a default response.
    fakeAuthRepo.defaultTryRestoreSessionResponse = failure<User>(
      const UnauthorizedError(),
    );
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
      child: const MaterialApp(home: ForgotPasswordPage()),
    );
  }

  group('ForgotPasswordPage', () {
    testWidgets(
      'should display email field and send button when page is rendered',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
        expect(find.byKey(const Key('send_reset_button')), findsOneWidget);
      },
    );

    testWidgets('should display page title when rendered', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('should display back to login link when page is rendered', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('back_to_login')), findsOneWidget);
    });

    testWidgets(
      'should show validation error when email is empty and submit tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your email'), findsOneWidget);
      },
    );

    testWidgets(
      'should not call requestPasswordReset when email is empty and submit tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pump();

        // Assert
        expect(fakeAuthRepo.requestPasswordResetCalls, isEmpty);
      },
    );

    testWidgets(
      'should show success message when reset email sent successfully',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenRequestPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('forgot_email_field')),
          'test@example.com',
        );

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Check your email for a reset link'), findsOneWidget);
      },
    );

    testWidgets(
      'should show error message when reset request fails with server error',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenRequestPasswordReset(
          failure<void>(const ServerError('Failed to send')),
        );
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('forgot_email_field')),
          'test@example.com',
        );

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Failed to send'), findsOneWidget);
      },
    );

    testWidgets(
      'should call requestPasswordReset with entered email when submitted',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenRequestPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('forgot_email_field')),
          'user@test.com',
        );

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeAuthRepo.requestPasswordResetCalls, hasLength(1));
        expect(
          fakeAuthRepo.requestPasswordResetCalls.first.email,
          'user@test.com',
        );
      },
    );

    testWidgets(
      'should not show success or error messages initially when rendered',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Check your email for a reset link'), findsNothing);
        expect(find.text('Failed to send'), findsNothing);
      },
    );

    testWidgets(
      'should clear validation error after valid email entered and submitted',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // First: trigger validation error with empty field
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pump();
        expect(find.text('Please enter your email'), findsOneWidget);

        fakeAuthRepo.whenRequestPasswordReset(success<void>(null));

        // Now enter a valid email and re-submit
        await tester.enterText(
          find.byKey(const Key('forgot_email_field')),
          'test@example.com',
        );

        // Act
        await tester.tap(find.byKey(const Key('send_reset_button')));
        await tester.pumpAndSettle();

        // Assert — validation error should be gone, success message shown
        expect(find.text('Please enter your email'), findsNothing);
        expect(find.text('Check your email for a reset link'), findsOneWidget);
      },
    );
  });
}
