import 'dart:convert';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';

// ---------------------------------------------------------------------------
// Helper — creates a DirectusApiError backed by a real HTTP response body.
// ---------------------------------------------------------------------------
DirectusApiError _makeApiError(
  String code,
  String message, {
  int statusCode = 400,
}) {
  final body = jsonEncode({
    'errors': [
      {
        'message': message,
        'extensions': {'code': code},
      },
    ],
  });
  return DirectusApiError(response: http.Response(body, statusCode));
}

// ---------------------------------------------------------------------------
// Duck-typed fake that mimics any object whose runtimeType contains
// "DirectusException" (the legacy / third-party duck-typing path).
// We name it with the exact class token the mapper checks for.
// ---------------------------------------------------------------------------
// ignore_for_file: camel_case_types
class _FakeDirectusException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? extensions;

  const _FakeDirectusException({
    required this.code,
    required this.message,
    this.extensions,
  });

  @override
  String toString() => 'DirectusException: $code - $message';
}

class _FakeNetworkException implements Exception {
  final String message;

  const _FakeNetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

void main() {
  group('mapDirectusError', () {
    // -----------------------------------------------------------------------
    // DirectusException (from DirectusDataSource — concrete class)
    // -----------------------------------------------------------------------
    group('DirectusException (from DirectusDataSource)', () {
      test(
        'should map INVALID_CREDENTIALS code to InvalidCredentialsError',
        () {
          // Arrange
          final error = DirectusException(
            code: 'INVALID_CREDENTIALS',
            message: 'Bad credentials',
          );

          // Act
          final result = mapDirectusError(error);

          // Assert
          expect(result, isA<InvalidCredentialsError>());
          expect(result.message, 'Bad credentials');
        },
      );

      test('should map INVALID_PAYLOAD code to InvalidCredentialsError', () {
        // Arrange
        final error = DirectusException(
          code: 'INVALID_PAYLOAD',
          message: 'Invalid payload',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<InvalidCredentialsError>());
        expect(result.message, 'Invalid payload');
      });

      test('should map TOKEN_EXPIRED code to TokenExpiredError', () {
        // Arrange
        final error = DirectusException(
          code: 'TOKEN_EXPIRED',
          message: 'Token has expired',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<TokenExpiredError>());
        expect(result.message, 'Token has expired');
      });

      test('should map FORBIDDEN code to UnauthorizedError', () {
        // Arrange
        final error = DirectusException(
          code: 'FORBIDDEN',
          message: 'Forbidden',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnauthorizedError>());
        expect(result.message, 'Forbidden');
      });

      test('should map NOT_AUTHENTICATED code to UnauthorizedError', () {
        // Arrange
        final error = DirectusException(
          code: 'NOT_AUTHENTICATED',
          message: 'Not authenticated',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnauthorizedError>());
      });

      test('should map NOT_FOUND code to NotFoundError', () {
        // Arrange
        final error = DirectusException(
          code: 'NOT_FOUND',
          message: 'Not found',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<NotFoundError>());
        expect(result.message, 'Not found');
      });

      test('should map INVALID_QUERY code to ValidationError', () {
        // Arrange
        final error = DirectusException(
          code: 'INVALID_QUERY',
          message: 'Bad query',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
        expect(result.message, 'Bad query');
      });

      test('should map RECORD_NOT_UNIQUE code to ValidationError', () {
        // Arrange
        final error = DirectusException(
          code: 'RECORD_NOT_UNIQUE',
          message: 'Duplicate record',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY code to ValidationError', () {
        // Arrange
        final error = DirectusException(
          code: 'INVALID_FOREIGN_KEY',
          message: 'Bad FK',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map REQUESTS_EXCEEDED code to RateLimitError', () {
        // Arrange
        final error = DirectusException(
          code: 'REQUESTS_EXCEEDED',
          message: 'Too many requests',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<RateLimitError>());
        expect(result.message, 'Too many requests');
      });

      test('should map CREATE_FAILED code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'CREATE_FAILED',
          message: 'Create failed',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map UPDATE_FAILED code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'UPDATE_FAILED',
          message: 'Update failed',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map DELETE_FAILED code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'DELETE_FAILED',
          message: 'Delete failed',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map LOGIN_ERROR code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'LOGIN_ERROR',
          message: 'Login error',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map DOWNLOAD_FAILED code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'DOWNLOAD_FAILED',
          message: 'Download failed',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map FETCH_USER_FAILED code to ServerError', () {
        // Arrange
        final error = DirectusException(
          code: 'FETCH_USER_FAILED',
          message: 'Failed to fetch user',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map unknown code to UnknownError', () {
        // Arrange
        final error = DirectusException(
          code: 'SOMETHING_COMPLETELY_DIFFERENT',
          message: 'Unexpected',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, 'Unexpected');
      });
    });

    // -----------------------------------------------------------------------
    // DirectusApiError (from directus_api_manager package)
    // -----------------------------------------------------------------------
    group('DirectusApiError (from directus_api_manager)', () {
      test(
        'should map INVALID_CREDENTIALS code to InvalidCredentialsError',
        () {
          // Arrange
          final error = _makeApiError('INVALID_CREDENTIALS', 'Bad creds');

          // Act
          final result = mapDirectusError(error);

          // Assert
          expect(result, isA<InvalidCredentialsError>());
          expect(result.message, 'Bad creds');
        },
      );

      test('should map INVALID_PAYLOAD code to InvalidCredentialsError', () {
        // Arrange
        final error = _makeApiError('INVALID_PAYLOAD', 'Malformed body');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<InvalidCredentialsError>());
      });

      test('should map TOKEN_EXPIRED code to TokenExpiredError', () {
        // Arrange
        final error = _makeApiError(
          'TOKEN_EXPIRED',
          'Token expired',
          statusCode: 401,
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<TokenExpiredError>());
        expect(result.message, 'Token expired');
      });

      test('should map FORBIDDEN code to UnauthorizedError', () {
        // Arrange
        final error = _makeApiError(
          'FORBIDDEN',
          'Access denied',
          statusCode: 403,
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnauthorizedError>());
      });

      test('should map NOT_FOUND code to NotFoundError', () {
        // Arrange
        final error = _makeApiError('NOT_FOUND', 'Not found', statusCode: 404);

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<NotFoundError>());
        expect(result.message, 'Not found');
      });

      test('should map RECORD_NOT_FOUND code to NotFoundError', () {
        // Arrange
        final error = _makeApiError(
          'RECORD_NOT_FOUND',
          'Record not found',
          statusCode: 404,
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<NotFoundError>());
      });

      test('should map INVALID_QUERY code to ValidationError', () {
        // Arrange
        final error = _makeApiError('INVALID_QUERY', 'Bad query params');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map RECORD_NOT_UNIQUE code to ValidationError', () {
        // Arrange
        final error = _makeApiError('RECORD_NOT_UNIQUE', 'Duplicate');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY code to ValidationError', () {
        // Arrange
        final error = _makeApiError('INVALID_FOREIGN_KEY', 'Invalid FK');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map any unknown API code to ServerError', () {
        // Arrange
        final error = _makeApiError(
          'INTERNAL_ERROR',
          'Server blew up',
          statusCode: 500,
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
      });

      test(
        'should handle DirectusApiError with no response body gracefully',
        () {
          // Arrange
          final error = DirectusApiError(
            customMessage: 'No response available',
          );

          // Act
          final result = mapDirectusError(error);

          // Assert
          expect(result, isA<ServerError>());
        },
      );
    });

    // -----------------------------------------------------------------------
    // Duck-typed legacy Directus exception (runtimeType contains
    // "DirectusException" but is not the concrete class).
    // -----------------------------------------------------------------------
    group('duck-typed DirectusException (legacy fallback path)', () {
      test('should map INVALID_CREDENTIALS to InvalidCredentialsError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<InvalidCredentialsError>());
        expect(result.message, 'Invalid email or password');
      });

      test('should map INVALID_PAYLOAD to InvalidCredentialsError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'INVALID_PAYLOAD',
          message: 'Bad payload',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<InvalidCredentialsError>());
      });

      test('should map TOKEN_EXPIRED to TokenExpiredError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'TOKEN_EXPIRED',
          message: 'Token expired',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<TokenExpiredError>());
        expect(result.message, 'Token expired');
      });

      test('should map FORBIDDEN to UnauthorizedError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'FORBIDDEN',
          message: 'Access forbidden',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnauthorizedError>());
      });

      test('should map NOT_FOUND to NotFoundError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'NOT_FOUND',
          message: 'Resource not found',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<NotFoundError>());
        expect(result.message, 'Resource not found');
      });

      test(
        'should map INVALID_QUERY to ValidationError with extensions in details',
        () {
          // Arrange
          final error = _FakeDirectusException(
            code: 'INVALID_QUERY',
            message: 'Invalid query parameters',
            extensions: {'field': 'email'},
          );

          // Act
          final result = mapDirectusError(error);

          // Assert
          expect(result, isA<ValidationError>());
          expect(result.message, 'Invalid query parameters');
          expect(result.details, isNotNull);
        },
      );

      test('should map RECORD_NOT_UNIQUE to ValidationError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'RECORD_NOT_UNIQUE',
          message: 'Record already exists',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY to ValidationError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'INVALID_FOREIGN_KEY',
          message: 'Invalid foreign key reference',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ValidationError>());
      });

      test('should map unknown code to ServerError', () {
        // Arrange
        final error = _FakeDirectusException(
          code: 'SOME_UNKNOWN_CODE',
          message: 'Something went wrong',
        );

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<ServerError>());
        expect(result.message, 'Something went wrong');
      });
    });

    // -----------------------------------------------------------------------
    // Duck-typed NetworkException
    // -----------------------------------------------------------------------
    group('duck-typed NetworkException', () {
      test('should map NetworkException to NetworkError', () {
        // Arrange
        final error = _FakeNetworkException('Connection refused');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<NetworkError>());
        expect(result.message, contains('Connection refused'));
      });

      test(
        'should include exception description in the NetworkError message',
        () {
          // Arrange
          final error = _FakeNetworkException('DNS lookup failed');

          // Act
          final result = mapDirectusError(error);

          // Assert
          expect(result, isA<NetworkError>());
          expect(result.message, contains('DNS lookup failed'));
        },
      );
    });

    // -----------------------------------------------------------------------
    // Fallback — completely unknown error types
    // -----------------------------------------------------------------------
    group('unknown / fallback error types', () {
      test('should map generic Exception to UnknownError', () {
        // Arrange
        final error = Exception('Something generic went wrong');

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, contains('Something generic went wrong'));
      });

      test('should map plain String to UnknownError', () {
        // Arrange
        const error = 'Just a plain string error';

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, contains('Just a plain string error'));
      });

      test('should map arbitrary object to UnknownError', () {
        // Arrange
        final error = {'random': 'object'};

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnknownError>());
      });

      test('should map int error value to UnknownError', () {
        // Arrange
        const error = 42;

        // Act
        final result = mapDirectusError(error);

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, contains('42'));
      });
    });
  });
}
