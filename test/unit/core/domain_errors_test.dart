import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';

void main() {
  group('DomainError', () {
    group('Authentication Errors', () {
      test('InvalidCredentialsError should be created with message', () {
        const error = InvalidCredentialsError('Invalid email or password');

        expect(error, isA<DomainError>());
        expect(error.message, 'Invalid email or password');
        expect(error.details, null);
      });

      test('InvalidCredentialsError should have default message', () {
        const error = InvalidCredentialsError();

        expect(error.message, 'Invalid credentials');
      });

      test('TokenExpiredError should be created with message', () {
        const error = TokenExpiredError('Session has expired');

        expect(error, isA<DomainError>());
        expect(error.message, 'Session has expired');
      });

      test('TokenExpiredError should have default message', () {
        const error = TokenExpiredError();

        expect(error.message, 'Token expired');
      });

      test('UnauthorizedError should be created with message', () {
        const error = UnauthorizedError('Access denied');

        expect(error, isA<DomainError>());
        expect(error.message, 'Access denied');
      });

      test('UnauthorizedError should have default message', () {
        const error = UnauthorizedError();

        expect(error.message, 'Unauthorized');
      });
    });

    group('Network Errors', () {
      test('NetworkError should be created with message', () {
        const error = NetworkError('Connection timeout');

        expect(error, isA<DomainError>());
        expect(error.message, 'Connection timeout');
      });

      test('NetworkError should have default message', () {
        const error = NetworkError();

        expect(error.message, 'Network error');
      });

      test('NetworkUnavailableError should be created with message', () {
        const error = NetworkUnavailableError('No internet connection');

        expect(error, isA<DomainError>());
        expect(error.message, 'No internet connection');
      });

      test('NetworkUnavailableError should have default message', () {
        const error = NetworkUnavailableError();

        expect(error.message, 'Network unavailable');
      });
    });

    group('Data Errors', () {
      test('NotFoundError should be created with message', () {
        const error = NotFoundError('Menu not found');

        expect(error, isA<DomainError>());
        expect(error.message, 'Menu not found');
      });

      test('NotFoundError should have default message', () {
        const error = NotFoundError();

        expect(error.message, 'Resource not found');
      });

      test('ValidationError should be created with message and details', () {
        const error = ValidationError(
          'Validation failed',
          details: {'field': 'name', 'error': 'required'},
        );

        expect(error, isA<DomainError>());
        expect(error.message, 'Validation failed');
        expect(error.details, isNotNull);
        expect(error.details['field'], 'name');
        expect(error.details['error'], 'required');
      });

      test('ValidationError should work without details', () {
        const error = ValidationError('Invalid input');

        expect(error.message, 'Invalid input');
        expect(error.details, null);
      });
    });

    group('Server Errors', () {
      test('ServerError should be created with message', () {
        const error = ServerError('Internal server error');

        expect(error, isA<DomainError>());
        expect(error.message, 'Internal server error');
      });

      test('ServerError should have default message', () {
        const error = ServerError();

        expect(error.message, 'Server error');
      });

      test('UnknownError should be created with message and details', () {
        const error = UnknownError('Something went wrong', {'code': 500});

        expect(error, isA<DomainError>());
        expect(error.message, 'Something went wrong');
        expect(error.details, {'code': 500});
      });

      test('UnknownError should have default message', () {
        const error = UnknownError();

        expect(error.message, 'Unknown error');
      });
    });

    group('Equality and Hashcode', () {
      test('Same error types with same messages should be equal', () {
        const error1 = NotFoundError('Not found');
        const error2 = NotFoundError('Not found');

        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('Same error types with different messages should not be equal', () {
        const error1 = NotFoundError('Not found');
        const error2 = NotFoundError('Missing');

        expect(error1, isNot(equals(error2)));
      });

      test('Different error types should not be equal', () {
        const error1 = NotFoundError('Error');
        const error2 = NetworkError('Error');

        expect(error1, isNot(equals(error2)));
      });

      test(
        'Errors with same message but different details should not be equal',
        () {
          const error1 = ValidationError('Invalid', details: {'a': 1});
          const error2 = ValidationError('Invalid', details: {'b': 2});

          expect(error1, isNot(equals(error2)));
        },
      );

      test('Errors with same message and details should be equal', () {
        const error1 = ValidationError('Invalid', details: {'a': 1});
        const error2 = ValidationError('Invalid', details: {'a': 1});

        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });
    });

    group('String representation', () {
      test('should include error type and message in toString', () {
        const error = NotFoundError('Menu not found');

        final str = error.toString();
        expect(str, contains('NotFoundError'));
        expect(str, contains('Menu not found'));
      });

      test('should include details in toString when present', () {
        const error = ValidationError(
          'Validation failed',
          details: {'field': 'email'},
        );

        final str = error.toString();
        expect(str, contains('ValidationError'));
        expect(str, contains('Validation failed'));
        expect(str, contains('details'));
      });
    });
  });
}
