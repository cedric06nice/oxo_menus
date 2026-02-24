import 'dart:convert';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';

DirectusApiError _makeApiError(
  String code,
  String message, {
  int statusCode = 400,
}) {
  final body = jsonEncode({
    'errors': [
      {
        'extensions': {'code': code},
        'message': message,
      },
    ],
  });
  final response = http.Response(body, statusCode);
  return DirectusApiError(response: response);
}

// Mock exception classes to simulate Directus exceptions (duck-typing path)
class MockDirectusException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? extensions;

  MockDirectusException({
    required this.code,
    required this.message,
    this.extensions,
  });

  @override
  String toString() => 'DirectusException: $code - $message';
}

class MockNetworkException implements Exception {
  final String message;

  MockNetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

void main() {
  group('ErrorMapper', () {
    group('mapDirectusError', () {
      test('should map INVALID_CREDENTIALS to InvalidCredentialsError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<InvalidCredentialsError>());
        expect(error.message, contains('Invalid email or password'));
      });

      test('should map INVALID_PAYLOAD to InvalidCredentialsError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'INVALID_PAYLOAD',
          message: 'Invalid payload',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<InvalidCredentialsError>());
      });

      test('should map TOKEN_EXPIRED to TokenExpiredError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'TOKEN_EXPIRED',
          message: 'Token has expired',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<TokenExpiredError>());
        expect(error.message, contains('Token has expired'));
      });

      test('should map FORBIDDEN to UnauthorizedError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'FORBIDDEN',
          message: 'Access forbidden',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<UnauthorizedError>());
        expect(error.message, contains('Access forbidden'));
      });

      test('should map NOT_FOUND to NotFoundError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'NOT_FOUND',
          message: 'Resource not found',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<NotFoundError>());
        expect(error.message, contains('Resource not found'));
      });

      test('should map INVALID_QUERY to ValidationError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'INVALID_QUERY',
          message: 'Invalid query parameters',
          extensions: {'field': 'email'},
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<ValidationError>());
        expect(error.message, contains('Invalid query parameters'));
        expect(error.details, isNotNull);
      });

      test('should map RECORD_NOT_UNIQUE to ValidationError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'RECORD_NOT_UNIQUE',
          message: 'Record already exists',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY to ValidationError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'INVALID_FOREIGN_KEY',
          message: 'Invalid foreign key reference',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<ValidationError>());
      });

      test('should map unknown Directus error codes to ServerError', () {
        // Arrange
        final exception = MockDirectusException(
          code: 'UNKNOWN_ERROR',
          message: 'Something went wrong',
        );

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<ServerError>());
        expect(error.message, contains('Something went wrong'));
      });

      test('should map NetworkException to NetworkError', () {
        // Arrange
        final exception = MockNetworkException('Connection failed');

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<NetworkError>());
        expect(error.message, contains('Connection failed'));
      });

      test('should map generic Exception to UnknownError', () {
        // Arrange
        final exception = Exception('Generic error');

        // Act
        final error = mapDirectusError(exception);

        // Assert
        expect(error, isA<UnknownError>());
        expect(error.message, contains('Generic error'));
      });

      test('should map String error to UnknownError', () {
        // Arrange
        const error = 'String error message';

        // Act
        final domainError = mapDirectusError(error);

        // Assert
        expect(domainError, isA<UnknownError>());
        expect(domainError.message, contains('String error message'));
      });
    });

    group('DirectusException (from DirectusDataSource)', () {
      test('should map INVALID_CREDENTIALS to InvalidCredentialsError', () {
        final error = DirectusException(
          code: 'INVALID_CREDENTIALS',
          message: 'Bad credentials',
        );
        expect(mapDirectusError(error), isA<InvalidCredentialsError>());
      });

      test('should map INVALID_PAYLOAD to InvalidCredentialsError', () {
        final error = DirectusException(
          code: 'INVALID_PAYLOAD',
          message: 'Invalid payload',
        );
        expect(mapDirectusError(error), isA<InvalidCredentialsError>());
      });

      test('should map TOKEN_EXPIRED to TokenExpiredError', () {
        final error = DirectusException(
          code: 'TOKEN_EXPIRED',
          message: 'Expired',
        );
        expect(mapDirectusError(error), isA<TokenExpiredError>());
      });

      test('should map FORBIDDEN to UnauthorizedError', () {
        final error = DirectusException(
          code: 'FORBIDDEN',
          message: 'Forbidden',
        );
        expect(mapDirectusError(error), isA<UnauthorizedError>());
      });

      test('should map NOT_AUTHENTICATED to UnauthorizedError', () {
        final error = DirectusException(
          code: 'NOT_AUTHENTICATED',
          message: 'Not authenticated',
        );
        expect(mapDirectusError(error), isA<UnauthorizedError>());
      });

      test('should map NOT_FOUND to NotFoundError', () {
        final error = DirectusException(
          code: 'NOT_FOUND',
          message: 'Not found',
        );
        expect(mapDirectusError(error), isA<NotFoundError>());
      });

      test('should map INVALID_QUERY to ValidationError', () {
        final error = DirectusException(
          code: 'INVALID_QUERY',
          message: 'Bad query',
        );
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map RECORD_NOT_UNIQUE to ValidationError', () {
        final error = DirectusException(
          code: 'RECORD_NOT_UNIQUE',
          message: 'Duplicate',
        );
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY to ValidationError', () {
        final error = DirectusException(
          code: 'INVALID_FOREIGN_KEY',
          message: 'Bad FK',
        );
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map CREATE_FAILED to ServerError', () {
        final error = DirectusException(
          code: 'CREATE_FAILED',
          message: 'Create failed',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map UPDATE_FAILED to ServerError', () {
        final error = DirectusException(
          code: 'UPDATE_FAILED',
          message: 'Update failed',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map DELETE_FAILED to ServerError', () {
        final error = DirectusException(
          code: 'DELETE_FAILED',
          message: 'Delete failed',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map LOGIN_ERROR to ServerError', () {
        final error = DirectusException(
          code: 'LOGIN_ERROR',
          message: 'Login error',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map DOWNLOAD_FAILED to ServerError', () {
        final error = DirectusException(
          code: 'DOWNLOAD_FAILED',
          message: 'Download failed',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map REQUESTS_EXCEEDED to RateLimitError', () {
        final error = DirectusException(
          code: 'REQUESTS_EXCEEDED',
          message: 'Too many requests',
        );
        final result = mapDirectusError(error);
        expect(result, isA<RateLimitError>());
        expect(result.message, 'Too many requests');
      });

      test('should map FETCH_USER_FAILED to ServerError', () {
        final error = DirectusException(
          code: 'FETCH_USER_FAILED',
          message: 'Failed to fetch user: 404',
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should map unknown code to UnknownError', () {
        final error = DirectusException(
          code: 'SOMETHING_ELSE',
          message: 'Unknown',
        );
        expect(mapDirectusError(error), isA<UnknownError>());
      });
    });

    group('DirectusApiError (from directus_api_manager)', () {
      test('should map INVALID_CREDENTIALS to InvalidCredentialsError', () {
        final error = _makeApiError('INVALID_CREDENTIALS', 'Bad creds');
        expect(mapDirectusError(error), isA<InvalidCredentialsError>());
      });

      test('should map INVALID_PAYLOAD to InvalidCredentialsError', () {
        final error = _makeApiError('INVALID_PAYLOAD', 'Invalid payload');
        expect(mapDirectusError(error), isA<InvalidCredentialsError>());
      });

      test('should map TOKEN_EXPIRED to TokenExpiredError', () {
        final error = _makeApiError(
          'TOKEN_EXPIRED',
          'Expired',
          statusCode: 401,
        );
        expect(mapDirectusError(error), isA<TokenExpiredError>());
      });

      test('should map FORBIDDEN to UnauthorizedError', () {
        final error = _makeApiError('FORBIDDEN', 'Forbidden', statusCode: 403);
        expect(mapDirectusError(error), isA<UnauthorizedError>());
      });

      test('should map NOT_FOUND to NotFoundError', () {
        final error = _makeApiError('NOT_FOUND', 'Not found', statusCode: 404);
        expect(mapDirectusError(error), isA<NotFoundError>());
      });

      test('should map RECORD_NOT_FOUND to NotFoundError', () {
        final error = _makeApiError(
          'RECORD_NOT_FOUND',
          'Not found',
          statusCode: 404,
        );
        expect(mapDirectusError(error), isA<NotFoundError>());
      });

      test('should map INVALID_QUERY to ValidationError', () {
        final error = _makeApiError('INVALID_QUERY', 'Bad query');
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map RECORD_NOT_UNIQUE to ValidationError', () {
        final error = _makeApiError('RECORD_NOT_UNIQUE', 'Duplicate');
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map INVALID_FOREIGN_KEY to ValidationError', () {
        final error = _makeApiError('INVALID_FOREIGN_KEY', 'Bad FK');
        expect(mapDirectusError(error), isA<ValidationError>());
      });

      test('should map unknown code to ServerError', () {
        final error = _makeApiError(
          'INTERNAL_ERROR',
          'Internal',
          statusCode: 500,
        );
        expect(mapDirectusError(error), isA<ServerError>());
      });

      test('should handle missing response gracefully', () {
        final error = DirectusApiError(customMessage: 'No response');
        final result = mapDirectusError(error);
        expect(result, isA<ServerError>());
      });
    });
  });
}
