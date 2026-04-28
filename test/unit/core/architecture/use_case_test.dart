import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';

class _DoubleUseCase extends UseCase<int, int> {
  @override
  Future<Result<int, DomainError>> execute(int input) async {
    return Success(input * 2);
  }
}

class _FailingUseCase extends UseCase<NoInput, int> {
  @override
  Future<Result<int, DomainError>> execute(NoInput input) async {
    return const Failure(NetworkError('boom'));
  }
}

class _ParseIntUseCase extends SyncUseCase<String, int> {
  @override
  Result<int, DomainError> execute(String input) {
    final parsed = int.tryParse(input);
    return parsed == null
        ? const Failure(ValidationError('not an int'))
        : Success(parsed);
  }
}

class _CountdownUseCase extends StreamUseCase<int, int> {
  @override
  Stream<Result<int, DomainError>> execute(int input) async* {
    for (var i = input; i >= 0; i--) {
      yield Success(i);
    }
  }
}

void main() {
  group('UseCase (async)', () {
    test('execute returns Success on happy path', () async {
      final useCase = _DoubleUseCase();

      final result = await useCase.execute(21);

      expect(result, const Success<int, DomainError>(42));
    });

    test('execute returns Failure with DomainError', () async {
      final useCase = _FailingUseCase();

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DomainError>());
    });
  });

  group('SyncUseCase', () {
    test('execute returns Success on valid input', () {
      final useCase = _ParseIntUseCase();

      final result = useCase.execute('42');

      expect(result, const Success<int, DomainError>(42));
    });

    test('execute returns Failure on invalid input', () {
      final useCase = _ParseIntUseCase();

      final result = useCase.execute('nope');

      expect(result.isFailure, isTrue);
    });
  });

  group('StreamUseCase', () {
    test('execute emits a Result stream that completes', () async {
      final useCase = _CountdownUseCase();

      final values = await useCase
          .execute(2)
          .map((r) => r.valueOrNull)
          .toList();

      expect(values, [2, 1, 0]);
    });
  });

  group('NoInput', () {
    test('singleton instance is identical', () {
      expect(identical(NoInput.instance, NoInput.instance), isTrue);
    });

    test('equality and hashCode are stable', () {
      expect(NoInput.instance == NoInput.instance, isTrue);
      expect(NoInput.instance.hashCode, NoInput.instance.hashCode);
    });
  });
}
