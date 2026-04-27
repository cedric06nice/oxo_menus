import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/features/auth/presentation/providers/password_reset_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../../fakes/fake_auth_repository.dart';
import '../../../../../fakes/result_helpers.dart';

void main() {
  group('PasswordResetNotifier', () {
    late FakeAuthRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      // Default: session restore → unauthenticated (satisfies authProvider init)
      fakeRepo.defaultTryRestoreSessionResponse = failureUnauthorized();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() => container.dispose());

    PasswordResetNotifier readNotifier() =>
        container.read(passwordResetProvider.notifier);
    PasswordResetState readState() => container.read(passwordResetProvider);

    test('should return initial state on build', () {
      expect(readState(), const PasswordResetState.initial());
    });

    group('requestReset', () {
      test(
        'should transition to emailSent state when request succeeds',
        () async {
          fakeRepo.whenRequestPasswordReset(success<void>(null));

          await readNotifier().requestReset('user@example.com');

          expect(readState(), const PasswordResetState.emailSent());
        },
      );

      test('should transition to error state when request fails', () async {
        fakeRepo.whenRequestPasswordReset(
          failureServer<void>('Failed to send reset email'),
        );

        await readNotifier().requestReset('user@example.com');

        final state = readState();
        final errorMessage = state.maybeWhen(
          error: (msg) => msg,
          orElse: () => '',
        );
        expect(errorMessage, 'Failed to send reset email');
      });

      test('should pass loading state during request', () async {
        fakeRepo.whenRequestPasswordReset(success<void>(null));
        final states = <PasswordResetState>[];
        container.listen(
          passwordResetProvider,
          (_, next) => states.add(next),
          fireImmediately: false,
        );

        await readNotifier().requestReset('user@example.com');

        expect(states.first, const PasswordResetState.loading());
        expect(states.last, const PasswordResetState.emailSent());
      });

      test('should call requestPasswordReset with correct email', () async {
        fakeRepo.whenRequestPasswordReset(success<void>(null));

        await readNotifier().requestReset('user@example.com');

        expect(fakeRepo.requestPasswordResetCalls, hasLength(1));
        expect(
          fakeRepo.requestPasswordResetCalls.first.email,
          'user@example.com',
        );
      });

      test('should handle network error on request', () async {
        fakeRepo.whenRequestPasswordReset(failureNetwork<void>('offline'));

        await readNotifier().requestReset('user@example.com');

        final errorMessage = readState().maybeWhen(
          error: (msg) => msg,
          orElse: () => '',
        );
        expect(errorMessage, 'offline');
      });
    });

    group('confirmReset', () {
      test(
        'should transition to passwordChanged when confirm succeeds',
        () async {
          fakeRepo.whenConfirmPasswordReset(success<void>(null));

          await readNotifier().confirmReset(
            token: 'reset-token-123',
            password: 'newPassword1!',
          );

          expect(readState(), const PasswordResetState.passwordChanged());
        },
      );

      test('should transition to error when confirm fails', () async {
        fakeRepo.whenConfirmPasswordReset(
          failure<void>(const ValidationError('Invalid or expired token')),
        );

        await readNotifier().confirmReset(
          token: 'expired-token',
          password: 'newPassword1!',
        );

        final errorMessage = readState().maybeWhen(
          error: (msg) => msg,
          orElse: () => '',
        );
        expect(errorMessage, 'Invalid or expired token');
      });

      test('should pass loading state during confirm', () async {
        fakeRepo.whenConfirmPasswordReset(success<void>(null));
        final states = <PasswordResetState>[];
        container.listen(
          passwordResetProvider,
          (_, next) => states.add(next),
          fireImmediately: false,
        );

        await readNotifier().confirmReset(token: 'token', password: 'password');

        expect(states.first, const PasswordResetState.loading());
        expect(states.last, const PasswordResetState.passwordChanged());
      });

      test(
        'should call confirmPasswordReset with correct token and password',
        () async {
          fakeRepo.whenConfirmPasswordReset(success<void>(null));

          await readNotifier().confirmReset(
            token: 'my-token',
            password: 'myPassword1!',
          );

          expect(fakeRepo.confirmPasswordResetCalls, hasLength(1));
          expect(fakeRepo.confirmPasswordResetCalls.first.token, 'my-token');
          expect(
            fakeRepo.confirmPasswordResetCalls.first.password,
            'myPassword1!',
          );
        },
      );
    });

    group('reset', () {
      test('should return to initial state from emailSent', () async {
        fakeRepo.whenRequestPasswordReset(success<void>(null));
        await readNotifier().requestReset('user@example.com');
        expect(readState(), const PasswordResetState.emailSent());

        readNotifier().reset();

        expect(readState(), const PasswordResetState.initial());
      });

      test('should return to initial state from passwordChanged', () async {
        fakeRepo.whenConfirmPasswordReset(success<void>(null));
        await readNotifier().confirmReset(token: 't', password: 'p');
        expect(readState(), const PasswordResetState.passwordChanged());

        readNotifier().reset();

        expect(readState(), const PasswordResetState.initial());
      });

      test('should return to initial state from error', () async {
        fakeRepo.whenRequestPasswordReset(failureServer<void>('Error'));
        await readNotifier().requestReset('user@example.com');

        readNotifier().reset();

        expect(readState(), const PasswordResetState.initial());
      });
    });
  });
}
