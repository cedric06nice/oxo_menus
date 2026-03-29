import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/providers/password_reset_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Default mock for tryRestoreSession (called by authProvider on init)
    when(
      () => mockAuthRepository.tryRestoreSession(),
    ).thenAnswer((_) async => const Failure(UnauthorizedError()));
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
  });

  tearDown(() => container.dispose());

  PasswordResetNotifier readNotifier() =>
      container.read(passwordResetProvider.notifier);
  PasswordResetState readState() => container.read(passwordResetProvider);

  group('PasswordResetNotifier', () {
    test('build() returns initial state', () {
      expect(readState(), const PasswordResetState.initial());
    });

    group('requestReset', () {
      test('transitions to emailSent on success', () async {
        when(
          () => mockAuthRepository.requestPasswordReset(
            any(),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().requestReset('test@example.com');

        expect(readState(), const PasswordResetState.emailSent());
        verify(
          () => mockAuthRepository.requestPasswordReset(
            'test@example.com',
            resetUrl: any(named: 'resetUrl'),
          ),
        ).called(1);
      });

      test('transitions to error on failure', () async {
        when(
          () => mockAuthRepository.requestPasswordReset(
            any(),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer(
          (_) async => const Failure(ServerError('Failed to send reset email')),
        );

        await readNotifier().requestReset('test@example.com');

        expect(
          readState(),
          isA<PasswordResetState>().having(
            (s) => s.maybeWhen(error: (msg) => msg, orElse: () => ''),
            'error message',
            'Failed to send reset email',
          ),
        );
      });

      test('transitions to loading during request', () async {
        final stateChanges = <PasswordResetState>[];
        container.listen(
          passwordResetProvider,
          (_, next) => stateChanges.add(next),
          fireImmediately: false,
        );

        when(
          () => mockAuthRepository.requestPasswordReset(
            any(),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().requestReset('test@example.com');

        expect(stateChanges.first, const PasswordResetState.loading());
        expect(stateChanges.last, const PasswordResetState.emailSent());
      });
    });

    group('confirmReset', () {
      test('transitions to passwordChanged on success', () async {
        when(
          () => mockAuthRepository.confirmPasswordReset(
            token: any(named: 'token'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().confirmReset(
          token: 'reset-token-123',
          password: 'newPassword1!',
        );

        expect(readState(), const PasswordResetState.passwordChanged());
        verify(
          () => mockAuthRepository.confirmPasswordReset(
            token: 'reset-token-123',
            password: 'newPassword1!',
          ),
        ).called(1);
      });

      test('transitions to error on failure', () async {
        when(
          () => mockAuthRepository.confirmPasswordReset(
            token: any(named: 'token'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async =>
              const Failure(ValidationError('Invalid or expired token')),
        );

        await readNotifier().confirmReset(
          token: 'expired-token',
          password: 'newPassword1!',
        );

        expect(
          readState(),
          isA<PasswordResetState>().having(
            (s) => s.maybeWhen(error: (msg) => msg, orElse: () => ''),
            'error message',
            'Invalid or expired token',
          ),
        );
      });

      test('transitions to loading during request', () async {
        final stateChanges = <PasswordResetState>[];
        container.listen(
          passwordResetProvider,
          (_, next) => stateChanges.add(next),
          fireImmediately: false,
        );

        when(
          () => mockAuthRepository.confirmPasswordReset(
            token: any(named: 'token'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().confirmReset(token: 'token', password: 'password');

        expect(stateChanges.first, const PasswordResetState.loading());
        expect(stateChanges.last, const PasswordResetState.passwordChanged());
      });
    });

    group('reset', () {
      test('returns to initial state', () async {
        when(
          () => mockAuthRepository.requestPasswordReset(
            any(),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().requestReset('test@example.com');
        expect(readState(), const PasswordResetState.emailSent());

        readNotifier().reset();
        expect(readState(), const PasswordResetState.initial());
      });
    });
  });
}
