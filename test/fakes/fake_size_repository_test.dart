import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

import 'fake_size_repository.dart';
import 'result_helpers.dart';

Size _testSize({int id = 1}) => Size(
      id: id,
      name: 'A4',
      width: 210.0,
      height: 297.0,
      status: Status.published,
      direction: 'portrait',
    );

void main() {
  group('FakeSizeRepository', () {
    late FakeSizeRepository repo;

    setUp(() {
      repo = FakeSizeRepository();
    });

    // -----------------------------------------------------------------------
    // getAll
    // -----------------------------------------------------------------------

    group('getAll', () {
      test(
        'should throw StateError when no response is configured',
        () async {
          expect(() => repo.getAll(), throwsA(isA<StateError>()));
        },
      );

      test(
        'should return size list when configured with success',
        () async {
          final sizes = [_testSize(id: 1), _testSize(id: 2)];
          repo.whenGetAll(success(sizes));

          final result = await repo.getAll();

          expect(result, equals(Success<List<Size>, DomainError>(sizes)));
        },
      );

      test(
        'should record getAll call',
        () async {
          repo.whenGetAll(success([]));

          await repo.getAll();

          expect(repo.getAllCalls.length, equals(1));
        },
      );
    });

    // -----------------------------------------------------------------------
    // getById
    // -----------------------------------------------------------------------

    group('getById', () {
      test(
        'should throw StateError when no response is configured',
        () async {
          expect(() => repo.getById(1), throwsA(isA<StateError>()));
        },
      );

      test(
        'should return size when configured with success',
        () async {
          final size = _testSize();
          repo.whenGetById(success(size));

          final result = await repo.getById(1);

          expect(result, equals(Success<Size, DomainError>(size)));
        },
      );

      test(
        'should return not-found failure when configured with error',
        () async {
          repo.whenGetById(failure(notFound()));

          final result = await repo.getById(99);

          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should record getById call with correct id',
        () async {
          repo.whenGetById(success(_testSize()));

          await repo.getById(42);

          expect(repo.getByIdCalls.first.id, equals(42));
        },
      );
    });

    // -----------------------------------------------------------------------
    // create
    // -----------------------------------------------------------------------

    group('create', () {
      test(
        'should throw StateError when no response is configured',
        () async {
          const input = CreateSizeInput(
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.draft,
            direction: 'portrait',
          );
          expect(() => repo.create(input), throwsA(isA<StateError>()));
        },
      );

      test(
        'should return new size when configured with success',
        () async {
          final size = _testSize();
          repo.whenCreate(success(size));

          const input = CreateSizeInput(
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.draft,
            direction: 'portrait',
          );
          final result = await repo.create(input);

          expect(result, equals(Success<Size, DomainError>(size)));
        },
      );

      test(
        'should record create call with correct input',
        () async {
          repo.whenCreate(success(_testSize()));

          const input = CreateSizeInput(
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.draft,
            direction: 'portrait',
          );
          await repo.create(input);

          expect(repo.createCalls.first.input, equals(input));
        },
      );
    });

    // -----------------------------------------------------------------------
    // update
    // -----------------------------------------------------------------------

    group('update', () {
      test(
        'should throw StateError when no response is configured',
        () async {
          const input = UpdateSizeInput(id: 1, name: 'A3');
          expect(() => repo.update(input), throwsA(isA<StateError>()));
        },
      );

      test(
        'should return updated size when configured with success',
        () async {
          final size = _testSize();
          repo.whenUpdate(success(size));

          const input = UpdateSizeInput(id: 1, name: 'Updated');
          final result = await repo.update(input);

          expect(result, equals(Success<Size, DomainError>(size)));
        },
      );

      test(
        'should record update call with correct input',
        () async {
          repo.whenUpdate(success(_testSize()));

          const input = UpdateSizeInput(id: 7, name: 'Changed');
          await repo.update(input);

          expect(repo.updateCalls.first.input, equals(input));
        },
      );
    });

    // -----------------------------------------------------------------------
    // delete
    // -----------------------------------------------------------------------

    group('delete', () {
      test(
        'should throw StateError when no response is configured',
        () async {
          expect(() => repo.delete(1), throwsA(isA<StateError>()));
        },
      );

      test(
        'should return success when configured',
        () async {
          repo.whenDelete(success(null));

          final result = await repo.delete(1);

          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should record delete call with correct id',
        () async {
          repo.whenDelete(success(null));

          await repo.delete(55);

          expect(repo.deleteCalls.first.id, equals(55));
        },
      );
    });
  });
}
