import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should hold the provided value', () {
        const result = Success<int, String>(42);

        expect(result.value, 42);
      });

      test('should be an instance of Result', () {
        const result = Success<int, String>(42);

        expect(result, isA<Result<int, String>>());
      });

      test('should have isSuccess return true', () {
        const result = Success<int, String>(42);

        expect(result.isSuccess, isTrue);
      });

      test('should have isFailure return false', () {
        const result = Success<int, String>(42);

        expect(result.isFailure, isFalse);
      });

      test('should return the value from valueOrNull', () {
        const result = Success<int, String>(99);

        expect(result.valueOrNull, 99);
      });

      test('should return null from errorOrNull', () {
        const result = Success<int, String>(42);

        expect(result.errorOrNull, isNull);
      });

      test('should work with null as the value type', () {
        const result = Success<Null, String>(null);

        expect(result.value, isNull);
        expect(result.isSuccess, isTrue);
      });

      test('should work with a string value', () {
        const result = Success<String, int>('hello');

        expect(result.value, 'hello');
      });

      test('should work with an empty string value', () {
        const result = Success<String, int>('');

        expect(result.value, '');
      });

      test('should work with a list value', () {
        const result = Success<List<int>, String>([1, 2, 3]);

        expect(result.value, [1, 2, 3]);
      });

      test('should produce readable toString', () {
        const result = Success<int, String>(7);

        expect(result.toString(), 'Success(7)');
      });

      test('should equal another Success with the same value', () {
        const a = Success<int, String>(42);
        const b = Success<int, String>(42);

        expect(a, equals(b));
      });

      test('should have matching hashCode for equal instances', () {
        const a = Success<int, String>(42);
        const b = Success<int, String>(42);

        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not equal a Success with a different value', () {
        const a = Success<int, String>(1);
        const b = Success<int, String>(2);

        expect(a, isNot(equals(b)));
      });

      test('should not equal a Failure with an equivalent payload', () {
        const a = Success<int, int>(42);
        const b = Failure<int, int>(42);

        expect(a, isNot(equals(b)));
      });
    });

    group('Failure', () {
      test('should hold the provided error', () {
        const result = Failure<int, String>('something broke');

        expect(result.error, 'something broke');
      });

      test('should be an instance of Result', () {
        const result = Failure<int, String>('error');

        expect(result, isA<Result<int, String>>());
      });

      test('should have isSuccess return false', () {
        const result = Failure<int, String>('error');

        expect(result.isSuccess, isFalse);
      });

      test('should have isFailure return true', () {
        const result = Failure<int, String>('error');

        expect(result.isFailure, isTrue);
      });

      test('should return null from valueOrNull', () {
        const result = Failure<int, String>('error');

        expect(result.valueOrNull, isNull);
      });

      test('should return the error from errorOrNull', () {
        const result = Failure<int, String>('bad thing');

        expect(result.errorOrNull, 'bad thing');
      });

      test('should work with an integer error type', () {
        const result = Failure<String, int>(404);

        expect(result.error, 404);
      });

      test('should produce readable toString', () {
        const result = Failure<int, String>('oops');

        expect(result.toString(), 'Failure(oops)');
      });

      test('should equal another Failure with the same error', () {
        const a = Failure<int, String>('same');
        const b = Failure<int, String>('same');

        expect(a, equals(b));
      });

      test('should have matching hashCode for equal instances', () {
        const a = Failure<int, String>('same');
        const b = Failure<int, String>('same');

        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not equal a Failure with a different error', () {
        const a = Failure<int, String>('first');
        const b = Failure<int, String>('second');

        expect(a, isNot(equals(b)));
      });
    });

    group('fold', () {
      test('should call onSuccess with the value when result is Success', () {
        const result = Success<int, String>(10);

        final outcome = result.fold(
          onSuccess: (v) => 'got $v',
          onFailure: (e) => 'error $e',
        );

        expect(outcome, 'got 10');
      });

      test('should call onFailure with the error when result is Failure', () {
        const result = Failure<int, String>('broke');

        final outcome = result.fold(
          onSuccess: (v) => 'got $v',
          onFailure: (e) => 'error $e',
        );

        expect(outcome, 'error broke');
      });

      test('should not call onFailure when result is Success', () {
        const result = Success<int, String>(1);
        var failureCalled = false;

        result.fold(
          onSuccess: (_) => 'ok',
          onFailure: (_) {
            failureCalled = true;
            return 'fail';
          },
        );

        expect(failureCalled, isFalse);
      });

      test('should not call onSuccess when result is Failure', () {
        const result = Failure<int, String>('e');
        var successCalled = false;

        result.fold(
          onSuccess: (_) {
            successCalled = true;
            return 'ok';
          },
          onFailure: (_) => 'fail',
        );

        expect(successCalled, isFalse);
      });

      test('should support returning a different type from fold', () {
        const result = Success<int, String>(5);

        final doubled = result.fold(
          onSuccess: (v) => v * 2,
          onFailure: (_) => 0,
        );

        expect(doubled, 10);
      });
    });

    group('map', () {
      test('should transform the value when result is Success', () {
        const result = Success<int, String>(4);

        final mapped = result.map((v) => v * v);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, 16);
      });

      test('should pass through the failure unchanged when result is Failure', () {
        const result = Failure<int, String>('original error');

        final mapped = result.map((v) => v * 2);

        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, 'original error');
      });

      test('should change the success type via map', () {
        const result = Success<int, String>(42);

        final mapped = result.map((v) => v.toString());

        expect(mapped, isA<Result<String, String>>());
        expect(mapped.valueOrNull, '42');
      });

      test('should not call transform when result is Failure', () {
        const result = Failure<int, String>('e');
        var called = false;

        result.map((_) {
          called = true;
          return 0;
        });

        expect(called, isFalse);
      });

      test('should chain two map calls on Success', () {
        const result = Success<int, String>(3);

        final chained = result.map((v) => v + 1).map((v) => v * 2);

        expect(chained.valueOrNull, 8);
      });
    });

    group('mapError', () {
      test('should pass through the value unchanged when result is Success', () {
        const result = Success<int, String>(7);

        final mapped = result.mapError((e) => e.length);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, 7);
      });

      test('should transform the error when result is Failure', () {
        const result = Failure<int, String>('error');

        final mapped = result.mapError((e) => e.toUpperCase());

        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, 'ERROR');
      });

      test('should change the error type via mapError', () {
        const result = Failure<int, String>('bad');

        final mapped = result.mapError((e) => e.length);

        expect(mapped, isA<Result<int, int>>());
        expect(mapped.errorOrNull, 3);
      });

      test('should not call transform when result is Success', () {
        const result = Success<int, String>(1);
        var called = false;

        result.mapError((_) {
          called = true;
          return 'mapped';
        });

        expect(called, isFalse);
      });

      test('should chain mapError after map on Failure', () {
        const result = Failure<int, String>('x');

        final chained = result.map((v) => v + 1).mapError((e) => '$e!');

        expect(chained.errorOrNull, 'x!');
      });
    });

    group('flatMap', () {
      test('should chain Success to another Success', () {
        const result = Success<int, String>(5);

        final chained = result.flatMap((v) => Success<String, String>(v.toString()));

        expect(chained.isSuccess, isTrue);
        expect(chained.valueOrNull, '5');
      });

      test('should chain Success to a Failure', () {
        const result = Success<int, String>(5);

        final chained = result.flatMap<String>((_) => const Failure('downstream error'));

        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull, 'downstream error');
      });

      test('should pass through Failure without calling the transform', () {
        const result = Failure<int, String>('upstream');
        var called = false;

        final chained = result.flatMap((v) {
          called = true;
          return Success<String, String>(v.toString());
        });

        expect(called, isFalse);
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull, 'upstream');
      });

      test('should preserve original error when flatMap is called on Failure', () {
        const result = Failure<int, String>('keep this');

        final chained = result.flatMap<double>((_) => const Success(1.0));

        expect(chained.errorOrNull, 'keep this');
      });

      test('should support chaining multiple flatMap calls', () {
        const start = Success<int, String>(2);

        final result = start
            .flatMap((v) => Success<int, String>(v + 3))
            .flatMap((v) => Success<String, String>('value=$v'));

        expect(result.valueOrNull, 'value=5');
      });

      test('should short-circuit the chain on first Failure', () {
        const start = Success<int, String>(1);

        final result = start
            .flatMap<int>((_) => const Failure('first fail'))
            .flatMap((v) => Success<String, String>('$v'));

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, 'first fail');
      });
    });

    group('pattern matching', () {
      test('should match Success in a switch expression', () {
        const Result<int, String> result = Success(10);

        final label = switch (result) {
          Success(:final value) => 'success:$value',
          Failure(:final error) => 'failure:$error',
        };

        expect(label, 'success:10');
      });

      test('should match Failure in a switch expression', () {
        const Result<int, String> result = Failure('nope');

        final label = switch (result) {
          Success(:final value) => 'success:$value',
          Failure(:final error) => 'failure:$error',
        };

        expect(label, 'failure:nope');
      });
    });
  });
}
