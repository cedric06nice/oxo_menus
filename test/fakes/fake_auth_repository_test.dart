import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';

import 'fake_auth_repository.dart';
import 'result_helpers.dart';
import 'builders/user_builder.dart';

void main() {
  group('FakeAuthRepository', () {
    late FakeAuthRepository repo;

    setUp(() {
      repo = FakeAuthRepository();
    });

    // -----------------------------------------------------------------------
    // login
    // -----------------------------------------------------------------------

    group('login', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.login('a@b.com', 'pw'), throwsA(isA<StateError>()));
      });

      test('should return preset success response when configured', () async {
        final user = buildUser(email: 'a@b.com');
        repo.whenLogin(success(user));

        final result = await repo.login('a@b.com', 'pw');

        expect(result, equals(Success<User, DomainError>(user)));
      });

      test(
        'should record login call with correct email and password',
        () async {
          repo.whenLogin(success(buildUser()));

          await repo.login('a@b.com', 'secret');

          final recorded = repo.loginCalls;
          expect(recorded.length, equals(1));
          expect(recorded.first.email, equals('a@b.com'));
          expect(recorded.first.password, equals('secret'));
        },
      );

      test('should return preset failure when configured', () async {
        repo.whenLogin(failure(invalidCredentials()));

        final result = await repo.login('a@b.com', 'wrong');

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<InvalidCredentialsError>());
      });
    });

    // -----------------------------------------------------------------------
    // logout
    // -----------------------------------------------------------------------

    group('logout', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.logout(), throwsA(isA<StateError>()));
      });

      test('should return preset success when configured', () async {
        repo.whenLogout(success(null));

        final result = await repo.logout();

        expect(result.isSuccess, isTrue);
      });

      test('should record logout call', () async {
        repo.whenLogout(success(null));

        await repo.logout();

        expect(repo.logoutCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // getCurrentUser
    // -----------------------------------------------------------------------

    group('getCurrentUser', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.getCurrentUser(), throwsA(isA<StateError>()));
      });

      test('should return preset user when configured', () async {
        final user = buildAdminUser();
        repo.whenGetCurrentUser(success(user));

        final result = await repo.getCurrentUser();

        expect(result, equals(Success<User, DomainError>(user)));
      });

      test('should record getCurrentUser call', () async {
        repo.whenGetCurrentUser(success(buildUser()));

        await repo.getCurrentUser();

        expect(repo.getCurrentUserCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // refreshSession
    // -----------------------------------------------------------------------

    group('refreshSession', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.refreshSession(), throwsA(isA<StateError>()));
      });

      test('should return preset success when configured', () async {
        repo.whenRefreshSession(success(null));

        final result = await repo.refreshSession();

        expect(result.isSuccess, isTrue);
      });

      test('should record refreshSession call', () async {
        repo.whenRefreshSession(success(null));

        await repo.refreshSession();

        expect(repo.refreshSessionCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // tryRestoreSession
    // -----------------------------------------------------------------------

    group('tryRestoreSession', () {
      test(
        'should return default failure when neither override nor setter is set',
        () async {
          final result = await repo.tryRestoreSession();

          expect(result.isFailure, isTrue);
        },
      );

      test(
        'should return per-call preset when whenTryRestoreSession is set',
        () async {
          final user = buildUser();
          repo.whenTryRestoreSession(success(user));

          final result = await repo.tryRestoreSession();

          expect(result, equals(Success<User, DomainError>(user)));
        },
      );

      test('should return defaultTryRestoreSessionResponse when no per-call '
          'override is set', () async {
        final user = buildAdminUser();
        repo.defaultTryRestoreSessionResponse = success(user);

        final result = await repo.tryRestoreSession();

        expect(result, equals(Success<User, DomainError>(user)));
      });

      test('should record tryRestoreSession call', () async {
        await repo.tryRestoreSession();

        expect(repo.tryRestoreSessionCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // requestPasswordReset
    // -----------------------------------------------------------------------

    group('requestPasswordReset', () {
      test('should throw StateError when no response is configured', () async {
        expect(
          () => repo.requestPasswordReset('a@b.com'),
          throwsA(isA<StateError>()),
        );
      });

      test('should return preset success when configured', () async {
        repo.whenRequestPasswordReset(success(null));

        final result = await repo.requestPasswordReset('a@b.com');

        expect(result.isSuccess, isTrue);
      });

      test(
        'should record call with correct email and optional resetUrl',
        () async {
          repo.whenRequestPasswordReset(success(null));

          await repo.requestPasswordReset(
            'a@b.com',
            resetUrl: 'https://example.com/reset',
          );

          final recorded = repo.requestPasswordResetCalls;
          expect(recorded.length, equals(1));
          expect(recorded.first.email, equals('a@b.com'));
          expect(recorded.first.resetUrl, equals('https://example.com/reset'));
        },
      );
    });

    // -----------------------------------------------------------------------
    // confirmPasswordReset
    // -----------------------------------------------------------------------

    group('confirmPasswordReset', () {
      test('should throw StateError when no response is configured', () async {
        expect(
          () => repo.confirmPasswordReset(token: 'tok', password: 'pw'),
          throwsA(isA<StateError>()),
        );
      });

      test('should return preset success when configured', () async {
        repo.whenConfirmPasswordReset(success(null));

        final result = await repo.confirmPasswordReset(
          token: 'tok',
          password: 'newPw',
        );

        expect(result.isSuccess, isTrue);
      });

      test('should record call with correct token and password', () async {
        repo.whenConfirmPasswordReset(success(null));

        await repo.confirmPasswordReset(token: 'abc123', password: 'newPw');

        final recorded = repo.confirmPasswordResetCalls;
        expect(recorded.length, equals(1));
        expect(recorded.first.token, equals('abc123'));
        expect(recorded.first.password, equals('newPw'));
      });
    });
  });
}
