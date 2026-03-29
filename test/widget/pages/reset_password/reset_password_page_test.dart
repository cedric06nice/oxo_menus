import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/pages/reset_password/reset_password_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.tryRestoreSession(),
    ).thenAnswer((_) async => const Failure(UnauthorizedError()));
  });

  Widget createWidgetUnderTest({String? token}) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
      child: MaterialApp(home: ResetPasswordPage(token: token)),
    );
  }

  group('ResetPasswordPage', () {
    testWidgets('displays password fields and button when token provided', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new_password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
      expect(find.byKey(const Key('reset_password_button')), findsOneWidget);
    });

    testWidgets('shows error when no token provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });

    testWidgets('validates empty password', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.text('Please enter a new password'), findsOneWidget);
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'password1',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'password2',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows success message on successful reset', (tester) async {
      when(
        () => mockAuthRepository.confirmPasswordReset(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(createWidgetUnderTest(token: 'valid-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'newPassword1!',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'newPassword1!',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Password reset successfully'), findsOneWidget);
      expect(find.byKey(const Key('go_to_login_button')), findsOneWidget);
    });

    testWidgets('shows error message on failed reset', (tester) async {
      when(
        () => mockAuthRepository.confirmPasswordReset(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure(ValidationError('Invalid or expired token')),
      );

      await tester.pumpWidget(createWidgetUnderTest(token: 'expired-token'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'newPassword1!',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'newPassword1!',
      );
      await tester.tap(find.byKey(const Key('reset_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid or expired token'), findsOneWidget);
    });
  });
}
