import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';

import 'result_helpers.dart';

void main() {
  group('result_helpers', () {
    group('success()', () {
      test('should return a Success wrapping the given value', () {
        // Arrange
        const value = 42;

        // Act
        final result = success<int>(value);

        // Assert
        expect(result, isA<Success<int, DomainError>>());
      });

      test('should expose the value via isSuccess', () {
        // Arrange / Act
        final result = success<String>('hello');

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should carry the exact value passed in', () {
        // Arrange
        const items = ['a', 'b'];

        // Act
        final result = success<List<String>>(items);

        // Assert
        expect(result.valueOrNull, equals(items));
      });
    });

    group('failure()', () {
      test('should return a Failure wrapping the given DomainError', () {
        // Arrange
        const error = NotFoundError();

        // Act
        final result = failure<int>(error);

        // Assert
        expect(result, isA<Failure<int, DomainError>>());
      });

      test('should expose the error via isFailure', () {
        // Act
        final result = failure<String>(network());

        // Assert
        expect(result.isFailure, isTrue);
      });

      test('should carry the exact error passed in', () {
        // Arrange
        const error = UnauthorizedError('custom');

        // Act
        final result = failure<void>(error);

        // Assert
        expect(result.errorOrNull, equals(error));
      });
    });

    group('error factories', () {
      test('should create NotFoundError with default message', () {
        // Act
        final error = notFound();

        // Assert
        expect(error, isA<NotFoundError>());
        expect(error.message, equals('Resource not found'));
      });

      test('should create NotFoundError with custom message', () {
        // Act
        final error = notFound('Menu not found');

        // Assert
        expect(error.message, equals('Menu not found'));
      });

      test('should create UnauthorizedError with default message', () {
        // Act
        final error = unauthorized();

        // Assert
        expect(error, isA<UnauthorizedError>());
        expect(error.message, equals('Unauthorized'));
      });

      test('should create NetworkError with default message', () {
        // Act
        final error = network();

        // Assert
        expect(error, isA<NetworkError>());
        expect(error.message, equals('Network error'));
      });

      test('should create NetworkUnavailableError with default message', () {
        // Act
        final error = networkUnavailable();

        // Assert
        expect(error, isA<NetworkUnavailableError>());
      });

      test('should create ServerError with default message', () {
        // Act
        final error = server();

        // Assert
        expect(error, isA<ServerError>());
      });

      test('should create InvalidCredentialsError with default message', () {
        // Act
        final error = invalidCredentials();

        // Assert
        expect(error, isA<InvalidCredentialsError>());
      });

      test('should create TokenExpiredError with default message', () {
        // Act
        final error = tokenExpired();

        // Assert
        expect(error, isA<TokenExpiredError>());
      });

      test(
        'should create ValidationError with message and optional details',
        () {
          // Act
          final error = validation(
            'Name is required',
            details: {'field': 'name'},
          );

          // Assert
          expect(error, isA<ValidationError>());
          expect(error.message, equals('Name is required'));
          expect(error.details, equals({'field': 'name'}));
        },
      );

      test('should create UnknownError with default message', () {
        // Act
        final error = unknown();

        // Assert
        expect(error, isA<UnknownError>());
      });

      test('should create RateLimitError with default message', () {
        // Act
        final error = rateLimit();

        // Assert
        expect(error, isA<RateLimitError>());
      });
    });

    group('failureNotFound()', () {
      test('should return a Failure containing a NotFoundError', () {
        // Act
        final result = failureNotFound<String>();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('should use custom message when provided', () {
        // Act
        final result = failureNotFound<int>('Widget not found');

        // Assert
        expect(
          (result.errorOrNull as NotFoundError).message,
          equals('Widget not found'),
        );
      });
    });

    group('failureUnauthorized()', () {
      test('should return a Failure containing an UnauthorizedError', () {
        // Act
        final result = failureUnauthorized<void>();

        // Assert
        expect(result.errorOrNull, isA<UnauthorizedError>());
      });
    });

    group('failureNetwork()', () {
      test('should return a Failure containing a NetworkError', () {
        // Act
        final result = failureNetwork<List<int>>();

        // Assert
        expect(result.errorOrNull, isA<NetworkError>());
      });
    });

    group('failureServer()', () {
      test('should return a Failure containing a ServerError', () {
        // Act
        final result = failureServer<Map<String, dynamic>>();

        // Assert
        expect(result.errorOrNull, isA<ServerError>());
      });
    });

    group('failureUnknown()', () {
      test('should return a Failure containing an UnknownError', () {
        // Act
        final result = failureUnknown<bool>();

        // Assert
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });
  });
}
