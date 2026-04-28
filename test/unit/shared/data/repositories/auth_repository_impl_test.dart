import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/auth_repository_impl.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

// ---------------------------------------------------------------------------
// Shared raw JSON fixtures
// ---------------------------------------------------------------------------

const _userJson = <String, dynamic>{
  'id': 'user-1',
  'email': 'test@example.com',
  'first_name': 'Test',
  'last_name': 'User',
  'role': 'admin',
};

const _loginResponse = <String, dynamic>{
  'user': _userJson,
  'access_token': 'access-abc',
  'refresh_token': 'refresh-abc',
};

void main() {
  late _FakeDirectusDataSource fake;
  late AuthRepositoryImpl repository;

  setUp(() {
    fake = _FakeDirectusDataSource();
    repository = AuthRepositoryImpl(dataSource: fake);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test(
        'should return Success<User> when data source returns a valid response',
        () async {
          // Arrange
          fake.loginResult = _loginResponse;

          // Act
          final result = await repository.login('test@example.com', 'secret');

          // Assert
          expect(result.isSuccess, isTrue);
          final user = result.valueOrNull!;
          expect(user.id, 'user-1');
          expect(user.email, 'test@example.com');
          expect(user.firstName, 'Test');
          expect(user.lastName, 'User');
          expect(user.role, UserRole.admin);
        },
      );

      test('should forward the credentials to the data source', () async {
        // Arrange
        fake.loginResult = _loginResponse;

        // Act
        await repository.login('user@bar.com', 'pass123');

        // Assert
        expect(fake.lastLoginEmail, 'user@bar.com');
        expect(fake.lastLoginPassword, 'pass123');
      });

      test(
        'should return Failure<UnknownError> when login response lacks user key',
        () async {
          // Arrange
          fake.loginResult = {'access_token': 'tok', 'refresh_token': 'ref'};

          // Act
          final result = await repository.login('test@example.com', 'secret');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should return Failure<InvalidCredentialsError> when data source throws INVALID_CREDENTIALS',
        () async {
          // Arrange
          fake.loginError = DirectusException(
            code: 'INVALID_CREDENTIALS',
            message: 'Bad credentials',
          );

          // Act
          final result = await repository.login('test@example.com', 'wrong');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<InvalidCredentialsError>());
        },
      );

      test(
        'should return Failure<RateLimitError> when data source throws REQUESTS_EXCEEDED',
        () async {
          // Arrange
          fake.loginError = DirectusException(
            code: 'REQUESTS_EXCEEDED',
            message: 'Too many attempts',
          );

          // Act
          final result = await repository.login('test@example.com', 'pass');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<RateLimitError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws a generic exception',
        () async {
          // Arrange
          fake.loginError = Exception('Network error');

          // Act
          final result = await repository.login('test@example.com', 'pass');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('logout', () {
      test('should return Success<void> after data source logout', () async {
        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should call data source logout exactly once', () async {
        // Act
        await repository.logout();

        // Assert
        expect(fake.logoutCallCount, 1);
      });
    });

    group('getCurrentUser', () {
      test(
        'should return Success<User> when data source returns user data',
        () async {
          // Arrange
          fake.currentUserResult = _userJson;

          // Act
          final result = await repository.getCurrentUser();

          // Assert
          expect(result.isSuccess, isTrue);
          final user = result.valueOrNull!;
          expect(user.id, 'user-1');
          expect(user.email, 'test@example.com');
          expect(user.role, UserRole.admin);
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws FORBIDDEN',
        () async {
          // Arrange
          fake.currentUserError = DirectusException(
            code: 'FORBIDDEN',
            message: 'Access denied',
          );

          // Act
          final result = await repository.getCurrentUser();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );

      test(
        'should return Failure<TokenExpiredError> when data source throws TOKEN_EXPIRED',
        () async {
          // Arrange
          fake.currentUserError = DirectusException(
            code: 'TOKEN_EXPIRED',
            message: 'Expired',
          );

          // Act
          final result = await repository.getCurrentUser();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<TokenExpiredError>());
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws NOT_AUTHENTICATED',
        () async {
          // Arrange
          fake.currentUserError = DirectusException(
            code: 'NOT_AUTHENTICATED',
            message: 'Not authenticated',
          );

          // Act
          final result = await repository.getCurrentUser();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );
    });

    group('refreshSession', () {
      test(
        'should return Success<void> when data source refresh succeeds',
        () async {
          // Act
          final result = await repository.refreshSession();

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should call data source refreshSession exactly once', () async {
        // Act
        await repository.refreshSession();

        // Assert
        expect(fake.refreshSessionCallCount, 1);
      });

      test(
        'should return Failure<TokenExpiredError> when data source throws TOKEN_EXPIRED',
        () async {
          // Arrange
          fake.refreshSessionError = DirectusException(
            code: 'TOKEN_EXPIRED',
            message: 'Token expired',
          );

          // Act
          final result = await repository.refreshSession();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<TokenExpiredError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.refreshSessionError = Exception('network failure');

          // Act
          final result = await repository.refreshSession();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('tryRestoreSession', () {
      test(
        'should return Success<User> when restore returns true and getCurrentUser returns data',
        () async {
          // Arrange
          fake.tryRestoreSessionResult = true;
          fake.currentUserResult = _userJson;

          // Act
          final result = await repository.tryRestoreSession();

          // Assert
          expect(result.isSuccess, isTrue);
          final user = result.valueOrNull!;
          expect(user.id, 'user-1');
          expect(user.email, 'test@example.com');
        },
      );

      test(
        'should return Failure<TokenExpiredError> when data source returns false',
        () async {
          // Arrange
          fake.tryRestoreSessionResult = false;

          // Act
          final result = await repository.tryRestoreSession();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<TokenExpiredError>());
        },
      );

      test(
        'should return Failure<UnknownError> when getCurrentUser throws after successful restore',
        () async {
          // Arrange
          fake.tryRestoreSessionResult = true;
          fake.currentUserError = Exception('Storage error');

          // Act
          final result = await repository.tryRestoreSession();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should not call getCurrentUser when restore returns false',
        () async {
          // Arrange
          fake.tryRestoreSessionResult = false;

          // Act
          await repository.tryRestoreSession();

          // Assert
          expect(fake.getCurrentUserCallCount, 0);
        },
      );
    });

    group('requestPasswordReset', () {
      test(
        'should return Success<void> when data source call succeeds',
        () async {
          // Act
          final result = await repository.requestPasswordReset(
            'test@example.com',
          );

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should forward email and resetUrl to data source', () async {
        // Act
        await repository.requestPasswordReset(
          'test@example.com',
          resetUrl: 'https://app.example.com/reset',
        );

        // Assert
        expect(fake.lastRequestPasswordResetEmail, 'test@example.com');
        expect(
          fake.lastRequestPasswordResetUrl,
          'https://app.example.com/reset',
        );
      });

      test('should pass null resetUrl when none is provided', () async {
        // Act
        await repository.requestPasswordReset('test@example.com');

        // Assert
        expect(fake.lastRequestPasswordResetUrl, isNull);
      });

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.requestPasswordResetError = Exception('Email service down');

          // Act
          final result = await repository.requestPasswordReset(
            'test@example.com',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should return Failure<RateLimitError> when data source throws REQUESTS_EXCEEDED',
        () async {
          // Arrange
          fake.requestPasswordResetError = DirectusException(
            code: 'REQUESTS_EXCEEDED',
            message: 'Too many requests',
          );

          // Act
          final result = await repository.requestPasswordReset(
            'test@example.com',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<RateLimitError>());
        },
      );
    });

    group('confirmPasswordReset', () {
      test(
        'should return Success<void> when data source call succeeds',
        () async {
          // Act
          final result = await repository.confirmPasswordReset(
            token: 'tok-123',
            password: 'NewPass1!',
          );

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should forward token and password to data source', () async {
        // Act
        await repository.confirmPasswordReset(
          token: 'tok-123',
          password: 'NewPass1!',
        );

        // Assert
        expect(fake.lastConfirmToken, 'tok-123');
        expect(fake.lastConfirmPassword, 'NewPass1!');
      });

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.confirmPasswordResetError = Exception('Network error');

          // Act
          final result = await repository.confirmPasswordReset(
            token: 'bad-token',
            password: 'pass',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws PASSWORD_RESET_FAILED',
        () async {
          // Arrange – PASSWORD_RESET_FAILED is not in the switch, falls to UnknownError
          fake.confirmPasswordResetError = DirectusException(
            code: 'PASSWORD_RESET_FAILED',
            message: 'Token invalid',
          );

          // Act
          final result = await repository.confirmPasswordReset(
            token: 'bad-token',
            password: 'pass',
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal fake implementing the full DirectusDataSource surface.
// Each test configures only the stubs it needs; anything not configured
// completes normally (success no-op).
// ---------------------------------------------------------------------------

class _FakeDirectusDataSource implements DirectusDataSource {
  // --- auth stubs ---
  Map<String, dynamic>? loginResult;
  Object? loginError;
  String? lastLoginEmail;
  String? lastLoginPassword;

  int logoutCallCount = 0;

  Map<String, dynamic>? currentUserResult;
  Object? currentUserError;
  int getCurrentUserCallCount = 0;

  int refreshSessionCallCount = 0;
  Object? refreshSessionError;

  bool tryRestoreSessionResult = true;
  Object? tryRestoreSessionError;

  String? lastRequestPasswordResetEmail;
  String? lastRequestPasswordResetUrl;
  Object? requestPasswordResetError;

  String? lastConfirmToken;
  String? lastConfirmPassword;
  Object? confirmPasswordResetError;

  @override
  String? get currentAccessToken => null;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    if (loginError != null) throw loginError!;
    if (loginResult != null) return loginResult!;
    return {'user': {}, 'access_token': '', 'refresh_token': ''};
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    getCurrentUserCallCount++;
    if (currentUserError != null) throw currentUserError!;
    if (currentUserResult != null) return currentUserResult!;
    return {};
  }

  @override
  Future<void> refreshSession() async {
    refreshSessionCallCount++;
    if (refreshSessionError != null) throw refreshSessionError!;
  }

  @override
  Future<bool> tryRestoreSession() async {
    if (tryRestoreSessionError != null) throw tryRestoreSessionError!;
    return tryRestoreSessionResult;
  }

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async {
    lastRequestPasswordResetEmail = email;
    lastRequestPasswordResetUrl = resetUrl;
    if (requestPasswordResetError != null) throw requestPasswordResetError!;
    return true;
  }

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    lastConfirmToken = token;
    lastConfirmPassword = password;
    if (confirmPasswordResetError != null) throw confirmPasswordResetError!;
    return true;
  }

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async => throw UnimplementedError('getItem not used in this test');

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async => throw UnimplementedError('getItems not used in this test');

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async => throw UnimplementedError('createItem not used in this test');

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async => throw UnimplementedError('updateItem not used in this test');

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async =>
      throw UnimplementedError('deleteItem not used in this test');

  @override
  Future<String> uploadFile(Uint8List bytes, String filename) async =>
      throw UnimplementedError('uploadFile not used in this test');

  @override
  Future<String> replaceFile(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async => throw UnimplementedError('replaceFile not used in this test');

  @override
  Future<List<Map<String, dynamic>>> listFiles({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
  }) async => throw UnimplementedError('listFiles not used in this test');

  @override
  Future<Uint8List> downloadFileBytes(String fileId) async =>
      throw UnimplementedError('downloadFileBytes not used in this test');

  @override
  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async =>
      throw UnimplementedError('startSubscription not used in this test');

  @override
  Future<void> stopSubscription(String subscriptionUid) async =>
      throw UnimplementedError('stopSubscription not used in this test');
}
