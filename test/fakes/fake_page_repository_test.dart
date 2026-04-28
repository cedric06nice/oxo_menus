import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';

import 'fake_page_repository.dart';
import 'result_helpers.dart';

Page _testPage({int id = 1, int menuId = 10}) =>
    Page(id: id, menuId: menuId, name: 'Page $id', index: id - 1);

void main() {
  group('FakePageRepository', () {
    late FakePageRepository repo;

    setUp(() {
      repo = FakePageRepository();
    });

    // -----------------------------------------------------------------------
    // create
    // -----------------------------------------------------------------------

    group('create', () {
      test('should throw StateError when no response is configured', () async {
        const input = CreatePageInput(menuId: 10, name: 'Intro', index: 0);
        expect(() => repo.create(input), throwsA(isA<StateError>()));
      });

      test('should return new page when configured with success', () async {
        final page = _testPage();
        repo.whenCreate(success(page));

        const input = CreatePageInput(menuId: 10, name: 'Intro', index: 0);
        final result = await repo.create(input);

        expect(result, equals(Success<Page, DomainError>(page)));
      });

      test('should record create call with correct input', () async {
        repo.whenCreate(success(_testPage()));

        const input = CreatePageInput(
          menuId: 10,
          name: 'Intro',
          index: 0,
          type: PageType.header,
        );
        await repo.create(input);

        expect(repo.createCalls.first.input, equals(input));
      });
    });

    // -----------------------------------------------------------------------
    // getAllForMenu
    // -----------------------------------------------------------------------

    group('getAllForMenu', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.getAllForMenu(10), throwsA(isA<StateError>()));
      });

      test('should return page list when configured with success', () async {
        final pages = [_testPage(id: 1), _testPage(id: 2)];
        repo.whenGetAllForMenu(success(pages));

        final result = await repo.getAllForMenu(10);

        expect(result, equals(Success<List<Page>, DomainError>(pages)));
      });

      test(
        'should return empty list when configured with empty list',
        () async {
          repo.whenGetAllForMenu(success([]));

          final result = await repo.getAllForMenu(10);

          expect(result.valueOrNull, isEmpty);
        },
      );

      test('should record getAllForMenu call with correct menuId', () async {
        repo.whenGetAllForMenu(success([]));

        await repo.getAllForMenu(42);

        expect(repo.getAllForMenuCalls.first.menuId, equals(42));
      });
    });

    // -----------------------------------------------------------------------
    // getById
    // -----------------------------------------------------------------------

    group('getById', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.getById(1), throwsA(isA<StateError>()));
      });

      test('should return page when configured with success', () async {
        final page = _testPage();
        repo.whenGetById(success(page));

        final result = await repo.getById(1);

        expect(result, equals(Success<Page, DomainError>(page)));
      });

      test(
        'should return not-found failure when configured with error',
        () async {
          repo.whenGetById(failure(notFound()));

          final result = await repo.getById(99);

          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test('should record getById call with correct id', () async {
        repo.whenGetById(success(_testPage()));

        await repo.getById(7);

        expect(repo.getByIdCalls.first.id, equals(7));
      });
    });

    // -----------------------------------------------------------------------
    // update
    // -----------------------------------------------------------------------

    group('update', () {
      test('should throw StateError when no response is configured', () async {
        const input = UpdatePageInput(id: 1, name: 'Renamed');
        expect(() => repo.update(input), throwsA(isA<StateError>()));
      });

      test('should return updated page when configured with success', () async {
        final page = _testPage();
        repo.whenUpdate(success(page));

        const input = UpdatePageInput(id: 1, name: 'Renamed');
        final result = await repo.update(input);

        expect(result, equals(Success<Page, DomainError>(page)));
      });

      test('should record update call with correct input', () async {
        repo.whenUpdate(success(_testPage()));

        const input = UpdatePageInput(id: 3, name: 'New Name');
        await repo.update(input);

        expect(repo.updateCalls.first.input, equals(input));
      });
    });

    // -----------------------------------------------------------------------
    // delete
    // -----------------------------------------------------------------------

    group('delete', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.delete(1), throwsA(isA<StateError>()));
      });

      test('should return success when configured', () async {
        repo.whenDelete(success(null));

        final result = await repo.delete(1);

        expect(result.isSuccess, isTrue);
      });

      test('should record delete call with correct id', () async {
        repo.whenDelete(success(null));

        await repo.delete(99);

        expect(repo.deleteCalls.first.id, equals(99));
      });
    });

    // -----------------------------------------------------------------------
    // reorder
    // -----------------------------------------------------------------------

    group('reorder', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.reorder(1, 2), throwsA(isA<StateError>()));
      });

      test('should return success when configured', () async {
        repo.whenReorder(success(null));

        final result = await repo.reorder(1, 3);

        expect(result.isSuccess, isTrue);
      });

      test(
        'should record reorder call with correct pageId and newIndex',
        () async {
          repo.whenReorder(success(null));

          await repo.reorder(5, 2);

          final recorded = repo.reorderCalls;
          expect(recorded.length, equals(1));
          expect(recorded.first.pageId, equals(5));
          expect(recorded.first.newIndex, equals(2));
        },
      );
    });
  });
}
