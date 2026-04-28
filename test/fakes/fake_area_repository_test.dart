import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

import 'fake_area_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeAreaRepository', () {
    late FakeAreaRepository repo;

    setUp(() {
      repo = FakeAreaRepository();
    });

    // -----------------------------------------------------------------------
    // getAll
    // -----------------------------------------------------------------------

    group('getAll', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.getAll(), throwsA(isA<StateError>()));
      });

      test('should return preset list when configured', () async {
        final areas = [
          const Area(id: 1, name: 'Dining'),
          const Area(id: 2, name: 'Bar'),
        ];
        repo.whenGetAll(success(areas));

        final result = await repo.getAll();

        expect(result, equals(Success<List<Area>, DomainError>(areas)));
      });

      test(
        'should return empty list when configured with empty list',
        () async {
          repo.whenGetAll(success([]));

          final result = await repo.getAll();

          expect(result.valueOrNull, isEmpty);
        },
      );

      test('should return failure when configured with error', () async {
        repo.whenGetAll(failure(network()));

        final result = await repo.getAll();

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
      });

      test('should record getAll call', () async {
        repo.whenGetAll(success([]));

        await repo.getAll();

        expect(repo.getAllCalls.length, equals(1));
      });

      test('should accumulate multiple getAll calls in order', () async {
        repo.whenGetAll(success([]));

        await repo.getAll();
        await repo.getAll();

        expect(repo.getAllCalls.length, equals(2));
      });
    });
  });
}
