import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';

void main() {
  group('DomainError', () {
    group('base class', () {
      test('should expose message field', () {
        const error = InvalidCredentialsError('test message');

        expect(error.message, 'test message');
      });

      test('should expose details field as null when not provided', () {
        const error = NetworkError('some error');

        expect(error.details, isNull);
      });

      test('should expose details field as non-null when provided', () {
        const error = ValidationError('invalid', details: {'key': 'value'});

        expect(error.details, isNotNull);
      });

      test('should include type name in toString', () {
        const error = NetworkError('connection refused');

        expect(error.toString(), contains('NetworkError'));
      });

      test('should include message in toString', () {
        const error = NetworkError('connection refused');

        expect(error.toString(), contains('connection refused'));
      });

      test('should include details in toString when details is non-null', () {
        const error = ValidationError('bad input', details: 'extra info');

        final str = error.toString();
        expect(str, contains('details'));
        expect(str, contains('extra info'));
      });

      test('should omit details section in toString when details is null', () {
        const error = NotFoundError('not found');

        expect(error.toString(), isNot(contains('details')));
      });

      test('should be equal to itself via identity', () {
        const error = ServerError('oops');

        expect(error == error, isTrue);
      });

      test(
        'should equal another instance of the same type with same message',
        () {
          const a = NotFoundError('missing');
          const b = NotFoundError('missing');

          expect(a, equals(b));
        },
      );

      test('should have matching hashCode for equal errors', () {
        const a = NotFoundError('missing');
        const b = NotFoundError('missing');

        expect(a.hashCode, equals(b.hashCode));
      });

      test(
        'should not equal an instance of a different type with the same message',
        () {
          const a = NetworkError('error');
          const b = ServerError('error');

          expect(a, isNot(equals(b)));
        },
      );

      test('should not equal an instance with a different message', () {
        const a = NotFoundError('first');
        const b = NotFoundError('second');

        expect(a, isNot(equals(b)));
      });

      test(
        'should include same-type, different-message errors in inequality',
        () {
          const a = NotFoundError('alpha');
          const b = NotFoundError('beta');

          expect(a.hashCode == b.hashCode, isFalse);
        },
      );
    });

    group('InvalidCredentialsError', () {
      test('should have default message when constructed without argument', () {
        const error = InvalidCredentialsError();

        expect(error.message, 'Invalid credentials');
      });

      test('should use custom message when provided', () {
        const error = InvalidCredentialsError('Wrong email or password');

        expect(error.message, 'Wrong email or password');
      });

      test('should be a DomainError', () {
        const error = InvalidCredentialsError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = InvalidCredentialsError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = InvalidCredentialsError();

        expect(error.toString(), contains('InvalidCredentialsError'));
      });

      test('should equal another with same message', () {
        const a = InvalidCredentialsError('bad creds');
        const b = InvalidCredentialsError('bad creds');

        expect(a, equals(b));
      });

      test(
        'should not equal InvalidCredentialsError with different message',
        () {
          const a = InvalidCredentialsError('oops');
          const b = InvalidCredentialsError('nope');

          expect(a, isNot(equals(b)));
        },
      );
    });

    group('TokenExpiredError', () {
      test('should have default message when constructed without argument', () {
        const error = TokenExpiredError();

        expect(error.message, 'Token expired');
      });

      test('should use custom message when provided', () {
        const error = TokenExpiredError(
          'Session has expired, please log in again',
        );

        expect(error.message, 'Session has expired, please log in again');
      });

      test('should be a DomainError', () {
        const error = TokenExpiredError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = TokenExpiredError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = TokenExpiredError();

        expect(error.toString(), contains('TokenExpiredError'));
      });

      test('should equal another with same message', () {
        const a = TokenExpiredError('expired');
        const b = TokenExpiredError('expired');

        expect(a, equals(b));
      });
    });

    group('UnauthorizedError', () {
      test('should have default message when constructed without argument', () {
        const error = UnauthorizedError();

        expect(error.message, 'Unauthorized');
      });

      test('should use custom message when provided', () {
        const error = UnauthorizedError('Access denied');

        expect(error.message, 'Access denied');
      });

      test('should be a DomainError', () {
        const error = UnauthorizedError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = UnauthorizedError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = UnauthorizedError();

        expect(error.toString(), contains('UnauthorizedError'));
      });

      test('should equal another with same message', () {
        const a = UnauthorizedError('denied');
        const b = UnauthorizedError('denied');

        expect(a, equals(b));
      });
    });

    group('RateLimitError', () {
      test('should have default message when constructed without argument', () {
        const error = RateLimitError();

        expect(error.message, 'Too many requests');
      });

      test('should use custom message when provided', () {
        const error = RateLimitError('Please slow down');

        expect(error.message, 'Please slow down');
      });

      test('should be a DomainError', () {
        const error = RateLimitError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = RateLimitError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = RateLimitError();

        expect(error.toString(), contains('RateLimitError'));
      });

      test('should equal another with same message', () {
        const a = RateLimitError('slow down');
        const b = RateLimitError('slow down');

        expect(a, equals(b));
      });
    });

    group('NetworkError', () {
      test('should have default message when constructed without argument', () {
        const error = NetworkError();

        expect(error.message, 'Network error');
      });

      test('should use custom message when provided', () {
        const error = NetworkError('Connection timeout');

        expect(error.message, 'Connection timeout');
      });

      test('should be a DomainError', () {
        const error = NetworkError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = NetworkError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = NetworkError();

        expect(error.toString(), contains('NetworkError'));
      });

      test('should equal another with same message', () {
        const a = NetworkError('timeout');
        const b = NetworkError('timeout');

        expect(a, equals(b));
      });
    });

    group('NetworkUnavailableError', () {
      test('should have default message when constructed without argument', () {
        const error = NetworkUnavailableError();

        expect(error.message, 'Network unavailable');
      });

      test('should use custom message when provided', () {
        const error = NetworkUnavailableError('No internet connection');

        expect(error.message, 'No internet connection');
      });

      test('should be a DomainError', () {
        const error = NetworkUnavailableError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = NetworkUnavailableError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = NetworkUnavailableError();

        expect(error.toString(), contains('NetworkUnavailableError'));
      });

      test('should equal another with same message', () {
        const a = NetworkUnavailableError('offline');
        const b = NetworkUnavailableError('offline');

        expect(a, equals(b));
      });
    });

    group('NotFoundError', () {
      test('should have default message when constructed without argument', () {
        const error = NotFoundError();

        expect(error.message, 'Resource not found');
      });

      test('should use custom message when provided', () {
        const error = NotFoundError('Menu not found');

        expect(error.message, 'Menu not found');
      });

      test('should be a DomainError', () {
        const error = NotFoundError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = NotFoundError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = NotFoundError();

        expect(error.toString(), contains('NotFoundError'));
      });

      test('should equal another with same message', () {
        const a = NotFoundError('gone');
        const b = NotFoundError('gone');

        expect(a, equals(b));
      });
    });

    group('ValidationError', () {
      test('should use the provided message', () {
        const error = ValidationError('Name is required');

        expect(error.message, 'Name is required');
      });

      test('should have null details when no details provided', () {
        const error = ValidationError('Invalid input');

        expect(error.details, isNull);
      });

      test('should store details when provided as a map', () {
        const error = ValidationError(
          'Validation failed',
          details: {'field': 'name', 'rule': 'required'},
        );

        expect(error.details['field'], 'name');
        expect(error.details['rule'], 'required');
      });

      test('should store details when provided as a string', () {
        const error = ValidationError(
          'Bad input',
          details: 'must be non-empty',
        );

        expect(error.details, 'must be non-empty');
      });

      test('should be a DomainError', () {
        const error = ValidationError('invalid');

        expect(error, isA<DomainError>());
      });

      test('should include type name in toString', () {
        const error = ValidationError('invalid email');

        expect(error.toString(), contains('ValidationError'));
      });

      test('should include message in toString', () {
        const error = ValidationError('invalid email');

        expect(error.toString(), contains('invalid email'));
      });

      test('should include details in toString when details is provided', () {
        const error = ValidationError('bad', details: 'must be positive');

        expect(error.toString(), contains('must be positive'));
      });

      test('should equal another with same message and null details', () {
        const a = ValidationError('required');
        const b = ValidationError('required');

        expect(a, equals(b));
      });

      test('should equal another with same message and equal details', () {
        const a = ValidationError('invalid', details: {'x': 1});
        const b = ValidationError('invalid', details: {'x': 1});

        expect(a, equals(b));
      });

      test(
        'should not equal another with same message but different details',
        () {
          const a = ValidationError('invalid', details: {'x': 1});
          const b = ValidationError('invalid', details: {'x': 2});

          expect(a, isNot(equals(b)));
        },
      );

      test(
        'should not equal another with different message but same details',
        () {
          const a = ValidationError('one', details: {'x': 1});
          const b = ValidationError('two', details: {'x': 1});

          expect(a, isNot(equals(b)));
        },
      );

      test('should have matching hashCode for equal errors with details', () {
        const a = ValidationError('invalid', details: {'x': 1});
        const b = ValidationError('invalid', details: {'x': 1});

        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('ServerError', () {
      test('should have default message when constructed without argument', () {
        const error = ServerError();

        expect(error.message, 'Server error');
      });

      test('should use custom message when provided', () {
        const error = ServerError('Internal server error');

        expect(error.message, 'Internal server error');
      });

      test('should be a DomainError', () {
        const error = ServerError();

        expect(error, isA<DomainError>());
      });

      test('should have null details', () {
        const error = ServerError();

        expect(error.details, isNull);
      });

      test('should include type name in toString', () {
        const error = ServerError();

        expect(error.toString(), contains('ServerError'));
      });

      test('should equal another with same message', () {
        const a = ServerError('crashed');
        const b = ServerError('crashed');

        expect(a, equals(b));
      });
    });

    group('UnknownError', () {
      test(
        'should have default message when constructed without arguments',
        () {
          const error = UnknownError();

          expect(error.message, 'Unknown error');
        },
      );

      test('should use custom message when provided', () {
        const error = UnknownError('Something unexpected happened');

        expect(error.message, 'Something unexpected happened');
      });

      test('should have null details when no details provided', () {
        const error = UnknownError();

        expect(error.details, isNull);
      });

      test('should store details when provided', () {
        const error = UnknownError('failure', {'code': 500});

        expect(error.details, {'code': 500});
      });

      test('should be a DomainError', () {
        const error = UnknownError();

        expect(error, isA<DomainError>());
      });

      test('should include type name in toString', () {
        const error = UnknownError();

        expect(error.toString(), contains('UnknownError'));
      });

      test('should include message in toString', () {
        const error = UnknownError('Something went wrong');

        expect(error.toString(), contains('Something went wrong'));
      });

      test('should include details in toString when details is non-null', () {
        const error = UnknownError('fail', 'extra context');

        expect(error.toString(), contains('extra context'));
      });

      test('should equal another with same message and null details', () {
        const a = UnknownError('oops');
        const b = UnknownError('oops');

        expect(a, equals(b));
      });

      test('should equal another with same message and equal details', () {
        const a = UnknownError('oops', {'code': 500});
        const b = UnknownError('oops', {'code': 500});

        expect(a, equals(b));
      });

      test('should not equal another with different details', () {
        const a = UnknownError('fail', {'x': 1});
        const b = UnknownError('fail', {'x': 2});

        expect(a, isNot(equals(b)));
      });

      test('should have matching hashCode for equal errors', () {
        const a = UnknownError('fail', {'code': 500});
        const b = UnknownError('fail', {'code': 500});

        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('cross-type inequality', () {
      test('should not equal NetworkError vs NetworkUnavailableError', () {
        const a = NetworkError('offline');
        const b = NetworkUnavailableError('offline');

        expect(a, isNot(equals(b)));
      });

      test(
        'should not equal ServerError vs UnknownError with same message',
        () {
          const a = ServerError('error');
          const b = UnknownError('error');

          expect(a, isNot(equals(b)));
        },
      );

      test(
        'should not equal TokenExpiredError vs UnauthorizedError with same message',
        () {
          const a = TokenExpiredError('session expired');
          const b = UnauthorizedError('session expired');

          expect(a, isNot(equals(b)));
        },
      );

      test(
        'should not equal InvalidCredentialsError vs RateLimitError with same message',
        () {
          const a = InvalidCredentialsError('denied');
          const b = RateLimitError('denied');

          expect(a, isNot(equals(b)));
        },
      );
    });
  });
}
