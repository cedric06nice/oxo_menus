import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';

// Mock exception classes to simulate Directus exceptions
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
  });
}
