import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create Success with value', () {
        const result = Success<int, String>(42);

        expect(result, isA<Success<int, String>>());
        expect(result.value, 42);
      });

      test('should have isSuccess return true', () {
        const result = Success<int, String>(42);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
      });

      test('should return value from valueOrNull', () {
        const result = Success<int, String>(42);

        expect(result.valueOrNull, 42);
      });

      test('should return null from errorOrNull', () {
        const result = Success<int, String>(42);

        expect(result.errorOrNull, null);
      });

      test('should call onSuccess in fold', () {
        const result = Success<int, String>(42);

        final folded = result.fold(
          onSuccess: (value) => 'Success: $value',
          onFailure: (error) => 'Failure: $error',
        );

        expect(folded, 'Success: 42');
      });
    });

    group('Failure', () {
      test('should create Failure with error', () {
        const result = Failure<int, String>('error message');

        expect(result, isA<Failure<int, String>>());
        expect(result.error, 'error message');
      });

      test('should have isFailure return true', () {
        const result = Failure<int, String>('error message');

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
      });

      test('should return null from valueOrNull', () {
        const result = Failure<int, String>('error message');

        expect(result.valueOrNull, null);
      });

      test('should return error from errorOrNull', () {
        const result = Failure<int, String>('error message');

        expect(result.errorOrNull, 'error message');
      });

      test('should call onFailure in fold', () {
        const result = Failure<int, String>('error message');

        final folded = result.fold(
          onSuccess: (value) => 'Success: $value',
          onFailure: (error) => 'Failure: $error',
        );

        expect(folded, 'Failure: error message');
      });
    });

    group('Pattern matching', () {
      test('should work with switch expressions', () {
        const Result<int, String> result = Success(42);

        final message = switch (result) {
          Success(:final value) => 'Got value: $value',
          Failure(:final error) => 'Got error: $error',
        };

        expect(message, 'Got value: 42');
      });

      test('should work with switch expressions for Failure', () {
        const Result<int, String> result = Failure('oops');

        final message = switch (result) {
          Success(:final value) => 'Got value: $value',
          Failure(:final error) => 'Got error: $error',
        };

        expect(message, 'Got error: oops');
      });
    });

    group('Equality', () {
      test('Success instances with same value should be equal', () {
        const result1 = Success<int, String>(42);
        const result2 = Success<int, String>(42);

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('Success instances with different values should not be equal', () {
        const result1 = Success<int, String>(42);
        const result2 = Success<int, String>(43);

        expect(result1, isNot(equals(result2)));
      });

      test('Failure instances with same error should be equal', () {
        const result1 = Failure<int, String>('error');
        const result2 = Failure<int, String>('error');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('Failure instances with different errors should not be equal', () {
        const result1 = Failure<int, String>('error1');
        const result2 = Failure<int, String>('error2');

        expect(result1, isNot(equals(result2)));
      });

      test('Success and Failure should not be equal', () {
        const result1 = Success<int, String>(42);
        const result2 = Failure<int, String>('error');

        expect(result1, isNot(equals(result2)));
      });
    });
  });
}
