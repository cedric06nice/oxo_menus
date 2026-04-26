import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/reset_password/reset_password_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
    // AuthNotifier calls tryRestoreSession on init — wire a default response.
    fakeAuthRepo.defaultTryRestoreSessionResponse = failure<User>(
      const UnauthorizedError(),
    );
  });

  Widget buildTestApp({String? token}) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
      child: MaterialApp(home: ResetPasswordPage(token: token)),
    );
  }

  group('ResetPasswordPage', () {
    testWidgets(
      'should display password fields and button when valid token provided',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('new_password_field')), findsOneWidget);
        expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
        expect(find.byKey(const Key('reset_password_button')), findsOneWidget);
      },
    );

    testWidgets('should show error when no token provided', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });

    testWidgets('should show error when empty string token provided', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(token: ''));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });

    testWidgets(
      'should show validation error when password is empty and submit tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a new password'), findsOneWidget);
      },
    );

    testWidgets('should show validation error when password is too short', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'short',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'short',
      );

      // Act
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      // Assert
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show validation error when passwords do not match', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'password1',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'password2',
      );

      // Act
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should not call confirmPasswordReset when validation fails', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestApp(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'password1',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'password2',
      );

      // Act
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      // Assert
      expect(fakeAuthRepo.confirmPasswordResetCalls, isEmpty);
    });

    testWidgets(
      'should show success message when password reset successfully',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenConfirmPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'newPassword1!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'newPassword1!',
        );

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Password reset successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'should show go-to-login button when password reset successfully',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenConfirmPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'newPassword1!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'newPassword1!',
        );

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('go_to_login_button')), findsOneWidget);
      },
    );

    testWidgets(
      'should show error message when reset fails with invalid token',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenConfirmPasswordReset(
          failure<void>(const ValidationError('Invalid or expired token')),
        );
        await tester.pumpWidget(buildTestApp(token: 'expired-token'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'newPassword1!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'newPassword1!',
        );

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Invalid or expired token'), findsOneWidget);
      },
    );

    testWidgets(
      'should call confirmPasswordReset with correct token and password',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenConfirmPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp(token: 'my-reset-token'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'SecurePass1!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'SecurePass1!',
        );

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeAuthRepo.confirmPasswordResetCalls, hasLength(1));
        expect(
          fakeAuthRepo.confirmPasswordResetCalls.first.token,
          'my-reset-token',
        );
        expect(
          fakeAuthRepo.confirmPasswordResetCalls.first.password,
          'SecurePass1!',
        );
      },
    );

    testWidgets(
      'should hide form fields and show success UI after successful reset',
      (tester) async {
        // Arrange
        fakeAuthRepo.whenConfirmPasswordReset(success<void>(null));
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_password_field')),
          'newPassword1!',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'newPassword1!',
        );

        // Act
        await tester.tap(find.byKey(const Key('reset_password_button')));
        await tester.pumpAndSettle();

        // Assert — form fields are no longer shown in success state
        expect(find.byKey(const Key('new_password_field')), findsNothing);
        expect(find.byKey(const Key('confirm_password_field')), findsNothing);
        expect(find.byKey(const Key('reset_password_button')), findsNothing);
      },
    );

    testWidgets(
      'should not show success or error messages initially when rendered',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp(token: 'valid-token'));

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Password reset successfully'), findsNothing);
        expect(find.text('Invalid or expired token'), findsNothing);
      },
    );
  });
}
