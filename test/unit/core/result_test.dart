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

    group('map', () {
      test('should transform Success value', () {
        const Result<int, String> result = Success(42);

        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.valueOrNull, 84);
      });

      test('should pass through Failure unchanged', () {
        const Result<int, String> result = Failure('error');

        final mapped = result.map((value) => value * 2);

        expect(mapped.isFailure, true);
        expect(mapped.errorOrNull, 'error');
      });
    });

    group('mapError', () {
      test('should pass through Success unchanged', () {
        const Result<int, String> result = Success(42);

        final mapped = result.mapError((error) => 'mapped: $error');

        expect(mapped.isSuccess, true);
        expect(mapped.valueOrNull, 42);
      });

      test('should transform Failure error', () {
        const Result<int, String> result = Failure('error');

        final mapped = result.mapError((error) => 'mapped: $error');

        expect(mapped.isFailure, true);
        expect(mapped.errorOrNull, 'mapped: error');
      });
    });

    group('flatMap', () {
      test('should chain Success to another Success', () {
        const Result<int, String> result = Success(42);

        final chained = result.flatMap((value) => Success(value.toString()));

        expect(chained.isSuccess, true);
        expect(chained.valueOrNull, '42');
      });

      test('should chain Success to Failure', () {
        const Result<int, String> result = Success(42);

        final chained =
            result.flatMap<String>((value) => const Failure('failed'));

        expect(chained.isFailure, true);
        expect(chained.errorOrNull, 'failed');
      });

      test('should pass through Failure without calling transform', () {
        const Result<int, String> result = Failure('original error');
        var called = false;

        final chained = result.flatMap((value) {
          called = true;
          return Success(value.toString());
        });

        expect(called, false);
        expect(chained.isFailure, true);
        expect(chained.errorOrNull, 'original error');
      });
    });

    group('toString', () {
      test('Success should have readable toString', () {
        const result = Success<int, String>(42);
        expect(result.toString(), 'Success(42)');
      });

      test('Failure should have readable toString', () {
        const result = Failure<int, String>('oops');
        expect(result.toString(), 'Failure(oops)');
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
