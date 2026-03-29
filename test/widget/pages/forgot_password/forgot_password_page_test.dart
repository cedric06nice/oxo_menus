import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/pages/forgot_password/forgot_password_page.dart';
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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
      child: const MaterialApp(home: ForgotPasswordPage()),
    );
  }

  group('ForgotPasswordPage', () {
    testWidgets('displays email field and send button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('send_reset_button')), findsOneWidget);
    });

    testWidgets('displays page title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      verifyNever(
        () => mockAuthRepository.requestPasswordReset(
          any(),
          resetUrl: any(named: 'resetUrl'),
        ),
      );
    });

    testWidgets('shows success message when email sent', (tester) async {
      when(
        () => mockAuthRepository.requestPasswordReset(
          any(),
          resetUrl: any(named: 'resetUrl'),
        ),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'test@example.com',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Check your email for a reset link'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(
        () => mockAuthRepository.requestPasswordReset(
          any(),
          resetUrl: any(named: 'resetUrl'),
        ),
      ).thenAnswer((_) async => const Failure(ServerError('Failed to send')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'test@example.com',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send'), findsOneWidget);
    });

    testWidgets('displays back to login link', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('back_to_login')), findsOneWidget);
    });
  });
}
