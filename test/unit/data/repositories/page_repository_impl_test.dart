// Tests for PageRepositoryImpl — manual fakes only, no mocktail.
//
// Every method on PageRepositoryImpl is covered:
//   create / getAllForMenu / getById / update / delete / reorder
//
// The local _FakeDs implements DirectusDataSource by delegating CRUD
// operations to queued responses while routing all other methods through
// noSuchMethod (they are never called by this repo).

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

// ---------------------------------------------------------------------------
// Minimal DTO factory helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _pageJson({
  int id = 1,
  int menuId = 10,
  int index = 0,
  String status = 'draft',
  String type = 'content',
}) => {
  'id': id,
  'menu': menuId,
  'index': index,
  'status': status,
  'type': type,
};

// ---------------------------------------------------------------------------
// Local fake: implements DirectusDataSource using queued responses.
//
// Only the four methods actually called by PageRepositoryImpl are overridden.
// All other public members are delegated to noSuchMethod so the compiler is
// satisfied without platform-channel setup.
// ---------------------------------------------------------------------------

class _FakeDs implements DirectusDataSource {
  // ---- Response queues ----

  // Responses (or throwers) for getItem<PageDto> — consumed in FIFO order.
  final List<Object> _getItemResponses = [];

  // Responses (or throwers) for getItems<PageDto>.
  final List<Object> _getItemsResponses = [];

  // Responses (or throwers) for createItem<PageDto>.
  final List<Object> _createItemResponses = [];

  // Responses (or throwers) for updateItem<PageDto>.
  final List<Object> _updateItemResponses = [];

  // Responses (or throwers) for deleteItem<PageDto>.
  final List<Object> _deleteItemResponses = [];

  // ---- Call log ----
  final List<Map<String, dynamic>> createCalls = [];
  final List<Map<String, dynamic>> updateCalls = [];
  final List<int> deletedIds = [];
  final List<Map<String, dynamic>> getItemCalls = [];
  final List<Map<String, dynamic>> getItemsCalls = [];

  // ---- Staging helpers ----

  void queueGetItem(Map<String, dynamic> response) =>
      _getItemResponses.add(response);

  void queueGetItemThrows(Object error) =>
      _getItemResponses.add(_throwerWrap(error));

  void queueGetItems(List<Map<String, dynamic>> response) =>
      _getItemsResponses.add(response);

  void queueGetItemsThrows(Object error) =>
      _getItemsResponses.add(_throwerWrap(error));

  void queueCreateItem(Map<String, dynamic> response) =>
      _createItemResponses.add(response);

  void queueCreateItemThrows(Object error) =>
      _createItemResponses.add(_throwerWrap(error));

  void queueUpdateItem(Map<String, dynamic> response) =>
      _updateItemResponses.add(response);

  void queueUpdateItemThrows(Object error) =>
      _updateItemResponses.add(_throwerWrap(error));

  void queueDeleteItem() => _deleteItemResponses.add(const _OkSentinel());

  void queueDeleteItemThrows(Object error) =>
      _deleteItemResponses.add(_throwerWrap(error));

  // ---- Private helpers ----

  static _ErrorSentinel _throwerWrap(Object error) => _ErrorSentinel(error);

  T _consume<T>(List<Object> queue, String name) {
    if (queue.isEmpty) {
      throw StateError('_FakeDs: no queued response for $name');
    }
    final next = queue.removeAt(0);
    if (next is _ErrorSentinel) throw next.error;
    return next as T;
  }

  // ---- Overridden CRUD methods ----

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async {
    getItemCalls.add({'id': id, 'fields': fields, 'type': T});
    return _consume<Map<String, dynamic>>(_getItemResponses, 'getItem<$T>');
  }

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    getItemsCalls.add({
      'type': T,
      'filter': filter,
      'fields': fields,
      'sort': sort,
    });
    return _consume<List<Map<String, dynamic>>>(
      _getItemsResponses,
      'getItems<$T>',
    );
  }

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    createCalls.add({'type': T, 'item': newItem});
    return _consume<Map<String, dynamic>>(_createItemResponses, 'createItem<$T>');
  }

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    updateCalls.add({'type': T, 'item': itemToUpdate});
    return _consume<Map<String, dynamic>>(_updateItemResponses, 'updateItem<$T>');
  }

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    deletedIds.add(id);
    final next = _deleteItemResponses.isEmpty
        ? throw StateError('_FakeDs: no queued response for deleteItem<$T>')
        : _deleteItemResponses.removeAt(0);
    if (next is _ErrorSentinel) throw next.error;
  }

  // ---- noSuchMethod handles all other DirectusDataSource members ----

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(
        '_FakeDs: unexpected call to '
        '${invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '')}',
      );
}

class _OkSentinel {
  const _OkSentinel();
}

class _ErrorSentinel {
  final Object error;
  const _ErrorSentinel(this.error);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeDs fakeDs;
  late PageRepository repository;

  setUp(() {
    fakeDs = _FakeDs();
    repository = PageRepositoryImpl(dataSource: fakeDs);
  });

  // =========================================================================
  // create
  // =========================================================================
  group('PageRepositoryImpl.create', () {
    test('should return Success with mapped Page entity on happy path', () async {
      // Arrange
      fakeDs.queueCreateItem(_pageJson(id: 2, menuId: 1, index: 0));
      const input = CreatePageInput(menuId: 1, name: 'P', index: 0);

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 2);
      expect(result.valueOrNull!.menuId, 1);
      expect(result.valueOrNull!.index, 0);
    });

    test('should persist type=header in DTO sent to createItem', () async {
      // Arrange
      fakeDs.queueCreateItem(_pageJson(id: 3, menuId: 1, index: 0, type: 'header'));
      const input = CreatePageInput(
        menuId: 1,
        name: 'H',
        index: 0,
        type: PageType.header,
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'type'), 'header');
    });

    test('should persist type=footer in DTO sent to createItem', () async {
      // Arrange
      fakeDs.queueCreateItem(_pageJson(id: 4, menuId: 1, index: 2, type: 'footer'));
      const input = CreatePageInput(
        menuId: 1,
        name: 'F',
        index: 2,
        type: PageType.footer,
      );

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.type, PageType.footer);
    });

    test('should use draft status in DTO sent to createItem', () async {
      // Arrange
      fakeDs.queueCreateItem(_pageJson(id: 1));
      const input = CreatePageInput(menuId: 1, name: 'P', index: 0);

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'status'), 'draft');
    });

    test('should return Failure(ValidationError) when data source throws INVALID_FOREIGN_KEY', () async {
      // Arrange
      fakeDs.queueCreateItemThrows(
        DirectusException(code: 'INVALID_FOREIGN_KEY', message: 'Menu not found'),
      );
      const input = CreatePageInput(menuId: 99, name: 'P', index: 0);

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('should return Failure(UnknownError) when data source throws generic exception', () async {
      // Arrange
      fakeDs.queueCreateItemThrows(Exception('boom'));
      const input = CreatePageInput(menuId: 1, name: 'P', index: 0);

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });

    test('should map returned entity name as Page {index}', () async {
      // Arrange — PageMapper generates name = "Page {index}"
      fakeDs.queueCreateItem(_pageJson(id: 2, menuId: 1, index: 5));
      const input = CreatePageInput(menuId: 1, name: 'ignored', index: 5);

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.valueOrNull!.name, 'Page 5');
    });
  });

  // =========================================================================
  // getAllForMenu
  // =========================================================================
  group('PageRepositoryImpl.getAllForMenu', () {
    test('should return Success with list of Page entities', () async {
      // Arrange
      fakeDs.queueGetItems([
        _pageJson(id: 1, menuId: 5, index: 0),
        _pageJson(id: 2, menuId: 5, index: 1),
      ]);

      // Act
      final result = await repository.getAllForMenu(5);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 2);
      expect(result.valueOrNull![0].id, 1);
      expect(result.valueOrNull![1].id, 2);
    });

    test('should pass menu filter to data source', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForMenu(42);

      // Assert
      final call = fakeDs.getItemsCalls.single;
      final filter = call['filter'] as Map<String, dynamic>;
      expect(filter['menu'], {'_eq': 42});
    });

    test('should include sort:[index] parameter for ordering', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForMenu(1);

      // Assert
      final call = fakeDs.getItemsCalls.single;
      expect((call['sort'] as List<String>), contains('index'));
    });

    test('should include type field in fields list', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForMenu(1);

      // Assert
      final call = fakeDs.getItemsCalls.single;
      expect((call['fields'] as List<String>), contains('type'));
    });

    test('should return Success with empty list when no pages found', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      final result = await repository.getAllForMenu(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isEmpty);
    });

    test('should return Success with single-item list when one page exists', () async {
      // Arrange
      fakeDs.queueGetItems([_pageJson(id: 7, menuId: 3, index: 0)]);

      // Act
      final result = await repository.getAllForMenu(3);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 1);
    });

    test('should map header and content types correctly in list result', () async {
      // Arrange
      fakeDs.queueGetItems([
        _pageJson(id: 1, menuId: 1, index: 0, type: 'header'),
        _pageJson(id: 2, menuId: 1, index: 1, type: 'content'),
      ]);

      // Act
      final result = await repository.getAllForMenu(1);

      // Assert
      expect(result.valueOrNull![0].type, PageType.header);
      expect(result.valueOrNull![1].type, PageType.content);
    });

    test('should return Failure(NotFoundError) when data source throws NOT_FOUND', () async {
      // Arrange
      fakeDs.queueGetItemsThrows(
        DirectusException(code: 'NOT_FOUND', message: 'Menu not found'),
      );

      // Act
      final result = await repository.getAllForMenu(99);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return Failure(UnknownError) on generic exception', () async {
      // Arrange
      fakeDs.queueGetItemsThrows(Exception('network'));

      // Act
      final result = await repository.getAllForMenu(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // =========================================================================
  // getById
  // =========================================================================
  group('PageRepositoryImpl.getById', () {
    test('should return Success with mapped Page entity', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, menuId: 10, index: 3));

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
      expect(result.valueOrNull!.menuId, 10);
      expect(result.valueOrNull!.index, 3);
    });

    test('should pass correct id to data source', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 55));

      // Act
      await repository.getById(55);

      // Assert
      expect(fakeDs.getItemCalls.single['id'], 55);
    });

    test('should request nested container fields', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, isNotNull);
      expect(fields, contains('containers.id'));
    });

    test('should return Failure(NotFoundError) when data source throws NOT_FOUND', () async {
      // Arrange
      fakeDs.queueGetItemThrows(
        DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
      );

      // Act
      final result = await repository.getById(99);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return Failure(UnauthorizedError) when data source throws FORBIDDEN', () async {
      // Arrange
      fakeDs.queueGetItemThrows(
        DirectusException(code: 'FORBIDDEN', message: 'Access denied'),
      );

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
    });

    test('should map unknown type string to PageType.content', () async {
      // Arrange — unmapped type strings default to content
      fakeDs.queueGetItem({
        'id': 1,
        'menu': 1,
        'index': 0,
        'status': 'draft',
        'type': 'nonexistent_type',
      });

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.type, PageType.content);
    });
  });

  // =========================================================================
  // update
  // =========================================================================
  group('PageRepositoryImpl.update', () {
    test('should return Success with updated Page entity', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, menuId: 1, index: 0));
      fakeDs.queueUpdateItem(_pageJson(id: 1, menuId: 1, index: 2));
      const input = UpdatePageInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
    });

    test('should write new index value to DTO before updateItem is called', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, menuId: 1, index: 0));
      fakeDs.queueUpdateItem(_pageJson(id: 1, menuId: 1, index: 5));
      const input = UpdatePageInput(id: 1, index: 5);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'index'), 5);
    });

    test('should preserve existing index when input.index is null', () async {
      // Arrange — existing page has index 3; no index in update input
      fakeDs.queueGetItem(_pageJson(id: 1, menuId: 1, index: 3));
      fakeDs.queueUpdateItem(_pageJson(id: 1, menuId: 1, index: 3));
      const input = UpdatePageInput(id: 1); // no index

      // Act
      await repository.update(input);

      // Assert — DTO sent to updateItem should still have index 3
      final sentDto = fakeDs.updateCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'index'), 3);
    });

    test('should return Failure(NotFoundError) when getItem throws NOT_FOUND', () async {
      // Arrange
      fakeDs.queueGetItemThrows(
        DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
      );
      const input = UpdatePageInput(id: 99, index: 1);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return Failure(ServerError) when updateItem throws UPDATE_FAILED', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1));
      fakeDs.queueUpdateItemThrows(
        DirectusException(code: 'UPDATE_FAILED', message: 'Write failed'),
      );
      const input = UpdatePageInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  // =========================================================================
  // delete
  // =========================================================================
  group('PageRepositoryImpl.delete', () {
    test('should return Success(null) on successful deletion', () async {
      // Arrange
      fakeDs.queueDeleteItem();

      // Act
      final result = await repository.delete(1);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should call deleteItem with the correct id', () async {
      // Arrange
      fakeDs.queueDeleteItem();

      // Act
      await repository.delete(77);

      // Assert
      expect(fakeDs.deletedIds.single, 77);
    });

    test('should return Failure(NotFoundError) when data source throws NOT_FOUND', () async {
      // Arrange
      fakeDs.queueDeleteItemThrows(
        DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
      );

      // Act
      final result = await repository.delete(99);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return Failure(UnknownError) on generic exception', () async {
      // Arrange
      fakeDs.queueDeleteItemThrows(Exception('Unexpected'));

      // Act
      final result = await repository.delete(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // =========================================================================
  // reorder
  // =========================================================================
  group('PageRepositoryImpl.reorder', () {
    test('should return Success(null) when reorder succeeds', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_pageJson(id: 1, index: 3));

      // Act
      final result = await repository.reorder(1, 3);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should write the new index to the DTO before updateItem is called', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_pageJson(id: 1, index: 4));

      // Act
      await repository.reorder(1, 4);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'index'), 4);
    });

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_pageJson(id: 1, index: 2));

      // Act
      await repository.reorder(1, 2);

      // Assert
      expect(fakeDs.updateCalls.length, 1);
    });

    test('should return Failure(NotFoundError) when getItem throws NOT_FOUND', () async {
      // Arrange
      fakeDs.queueGetItemThrows(
        DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
      );

      // Act
      final result = await repository.reorder(99, 2);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return Failure when updateItem throws', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, index: 0));
      fakeDs.queueUpdateItemThrows(
        DirectusException(code: 'UPDATE_FAILED', message: 'Write failed'),
      );

      // Act
      final result = await repository.reorder(1, 2);

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('should reorder to boundary index zero', () async {
      // Arrange
      fakeDs.queueGetItem(_pageJson(id: 1, index: 3));
      fakeDs.queueUpdateItem(_pageJson(id: 1, index: 0));

      // Act
      final result = await repository.reorder(1, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      final sentDto = fakeDs.updateCalls.single['item'] as PageDto;
      expect(sentDto.getValue(forKey: 'index'), 0);
    });

    test('should first fetch the page then update it', () async {
      // Arrange — verifying call order via queue consumption
      fakeDs.queueGetItem(_pageJson(id: 1, index: 2));
      fakeDs.queueUpdateItem(_pageJson(id: 1, index: 5));

      // Act
      await repository.reorder(1, 5);

      // Assert — both calls were consumed exactly once
      expect(fakeDs.getItemCalls.length, 1);
      expect(fakeDs.updateCalls.length, 1);
    });
  });
}
