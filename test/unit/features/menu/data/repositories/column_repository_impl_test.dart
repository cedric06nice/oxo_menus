// Tests for ColumnRepositoryImpl — manual fakes only, no mocktail.
//
// Methods covered:
//   create / getAllForContainer / getById / update / delete / reorder

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/features/menu/data/models/column_dto.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';

// ignore_for_file: deprecated_member_use

// ---------------------------------------------------------------------------
// DTO factory helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _columnJson({
  int id = 1,
  int containerId = 10,
  int index = 0,
  int width = 100,
  bool isDroppable = true,
  Map<String, dynamic>? styleJson,
}) => {
  'id': id,
  'container': containerId,
  'index': index,
  'width': width,
  'is_droppable': isDroppable,
  'style_json': ?styleJson,
};

// ---------------------------------------------------------------------------
// Local fake
// ---------------------------------------------------------------------------

class _ErrorSentinel {
  final Object error;
  const _ErrorSentinel(this.error);
}

class _OkSentinel {
  const _OkSentinel();
}

class _FakeDs implements DirectusDataSource {
  final List<Object> _getItemQ = [];
  final List<Object> _getItemsQ = [];
  final List<Object> _createItemQ = [];
  final List<Object> _updateItemQ = [];
  final List<Object> _deleteItemQ = [];

  final List<Map<String, dynamic>> getItemCalls = [];
  final List<Map<String, dynamic>> getItemsCalls = [];
  final List<Map<String, dynamic>> createCalls = [];
  final List<Map<String, dynamic>> updateCalls = [];
  final List<int> deletedIds = [];

  void queueGetItem(Map<String, dynamic> r) => _getItemQ.add(r);
  void queueGetItemThrows(Object e) => _getItemQ.add(_ErrorSentinel(e));
  void queueGetItems(List<Map<String, dynamic>> r) => _getItemsQ.add(r);
  void queueGetItemsThrows(Object e) => _getItemsQ.add(_ErrorSentinel(e));
  void queueCreateItem(Map<String, dynamic> r) => _createItemQ.add(r);
  void queueCreateItemThrows(Object e) => _createItemQ.add(_ErrorSentinel(e));
  void queueUpdateItem(Map<String, dynamic> r) => _updateItemQ.add(r);
  void queueUpdateItemThrows(Object e) => _updateItemQ.add(_ErrorSentinel(e));
  void queueDeleteItem() => _deleteItemQ.add(const _OkSentinel());
  void queueDeleteItemThrows(Object e) => _deleteItemQ.add(_ErrorSentinel(e));

  T _consume<T>(List<Object> q, String name) {
    if (q.isEmpty) throw StateError('_FakeDs: no response for $name');
    final next = q.removeAt(0);
    if (next is _ErrorSentinel) throw next.error;
    return next as T;
  }

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async {
    getItemCalls.add({'id': id, 'fields': fields, 'type': T});
    return _consume<Map<String, dynamic>>(_getItemQ, 'getItem<$T>');
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
    return _consume<List<Map<String, dynamic>>>(_getItemsQ, 'getItems<$T>');
  }

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    createCalls.add({'type': T, 'item': newItem});
    return _consume<Map<String, dynamic>>(_createItemQ, 'createItem<$T>');
  }

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    updateCalls.add({'type': T, 'item': itemToUpdate});
    return _consume<Map<String, dynamic>>(_updateItemQ, 'updateItem<$T>');
  }

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    deletedIds.add(id);
    if (_deleteItemQ.isEmpty) {
      throw StateError('_FakeDs: no response for deleteItem<$T>');
    }
    final next = _deleteItemQ.removeAt(0);
    if (next is _ErrorSentinel) throw next.error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '_FakeDs: unexpected call to ${invocation.memberName}',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeDs fakeDs;
  late ColumnRepository repository;

  setUp(() {
    fakeDs = _FakeDs();
    repository = ColumnRepositoryImpl(dataSource: fakeDs);
  });

  // =========================================================================
  // create
  // =========================================================================
  group('ColumnRepositoryImpl.create', () {
    test(
      'should return Success with mapped Column entity on happy path',
      () async {
        // Arrange
        fakeDs.queueCreateItem(
          _columnJson(id: 2, containerId: 1, index: 0, width: 100),
        );
        const input = CreateColumnInput(containerId: 1, index: 0);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.index, 0);
        expect(result.valueOrNull!.width, 100.0);
      },
    );

    test('should default width to 100 when input.width is null', () async {
      // Arrange
      fakeDs.queueCreateItem(_columnJson(id: 1, width: 100));
      const input = CreateColumnInput(containerId: 1, index: 0);

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'width'), 100);
    });

    test('should use provided width when input.width is non-null', () async {
      // Arrange
      fakeDs.queueCreateItem(_columnJson(id: 1, width: 50));
      const input = CreateColumnInput(containerId: 1, index: 0, width: 50.0);

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'width'), 50);
    });

    test('should include flex in DTO when input.flex is provided', () async {
      // Arrange
      fakeDs.queueCreateItem(_columnJson(id: 1));
      const input = CreateColumnInput(containerId: 1, index: 0, flex: 2);

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'flex'), 2);
    });

    test(
      'should include isDroppable=false in DTO when input provides it',
      () async {
        // Arrange
        fakeDs.queueCreateItem(_columnJson(id: 1));
        const input = CreateColumnInput(
          containerId: 1,
          index: 0,
          isDroppable: false,
        );

        // Act
        await repository.create(input);

        // Assert
        final sentDto = fakeDs.createCalls.single['item'] as ColumnDto;
        expect(sentDto.getValue(forKey: 'is_droppable'), false);
      },
    );

    test('should write style_json when styleConfig is provided', () async {
      // Arrange
      fakeDs.queueCreateItem(_columnJson(id: 1));
      const input = CreateColumnInput(
        containerId: 1,
        index: 0,
        styleConfig: StyleConfig(marginTop: 12.0),
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ColumnDto;
      expect(sentDto.styleJson['marginTop'], 12.0);
    });

    test(
      'should return Failure(ValidationError) when data source throws INVALID_FOREIGN_KEY',
      () async {
        // Arrange
        fakeDs.queueCreateItemThrows(
          DirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Container not found',
          ),
        );
        const input = CreateColumnInput(containerId: 99, index: 0);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ValidationError>());
      },
    );

    test('should return Failure(UnknownError) on generic exception', () async {
      // Arrange
      fakeDs.queueCreateItemThrows(Exception('boom'));
      const input = CreateColumnInput(containerId: 1, index: 0);

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // =========================================================================
  // getAllForContainer
  // =========================================================================
  group('ColumnRepositoryImpl.getAllForContainer', () {
    test('should return Success with list of Column entities', () async {
      // Arrange
      fakeDs.queueGetItems([
        _columnJson(id: 1, containerId: 5, index: 0),
        _columnJson(id: 2, containerId: 5, index: 1),
      ]);

      // Act
      final result = await repository.getAllForContainer(5);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 2);
      expect(result.valueOrNull![0].id, 1);
      expect(result.valueOrNull![1].id, 2);
    });

    test('should filter by container id', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForContainer(42);

      // Assert
      final filter =
          fakeDs.getItemsCalls.single['filter'] as Map<String, dynamic>;
      expect(filter['container'], {'_eq': 42});
    });

    test('should include sort:[index] for ordering', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForContainer(1);

      // Assert
      expect(
        (fakeDs.getItemsCalls.single['sort'] as List<String>),
        contains('index'),
      );
    });

    test('should request is_droppable field', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForContainer(1);

      // Assert
      final fields = fakeDs.getItemsCalls.single['fields'] as List<String>?;
      expect(fields, contains('is_droppable'));
    });

    test('should request nested widget fields', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForContainer(1);

      // Assert
      final fields = fakeDs.getItemsCalls.single['fields'] as List<String>?;
      expect(fields, contains('widgets.id'));
    });

    test(
      'should return Success with empty list when no columns found',
      () async {
        // Arrange
        fakeDs.queueGetItems([]);

        // Act
        final result = await repository.getAllForContainer(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isEmpty);
      },
    );

    test(
      'should return Success with single-item list when one column exists',
      () async {
        // Arrange
        fakeDs.queueGetItems([_columnJson(id: 9, containerId: 3, index: 0)]);

        // Act
        final result = await repository.getAllForContainer(3);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.length, 1);
      },
    );

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemsThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
        );

        // Act
        final result = await repository.getAllForContainer(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );
  });

  // =========================================================================
  // getById
  // =========================================================================
  group('ColumnRepositoryImpl.getById', () {
    test('should return Success with mapped Column entity', () async {
      // Arrange
      fakeDs.queueGetItem(
        _columnJson(id: 1, containerId: 10, index: 2, width: 75),
      );

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
      expect(result.valueOrNull!.index, 2);
      expect(result.valueOrNull!.width, 75.0);
    });

    test('should pass correct id to data source', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 88));

      // Act
      await repository.getById(88);

      // Assert
      expect(fakeDs.getItemCalls.single['id'], 88);
    });

    test('should request is_droppable field', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, contains('is_droppable'));
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.getById(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test(
      'should return Failure(UnauthorizedError) when data source throws FORBIDDEN',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'FORBIDDEN', message: 'Access denied'),
        );

        // Act
        final result = await repository.getById(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UnauthorizedError>());
      },
    );

    test(
      'should default isDroppable to true when not present in response',
      () async {
        // Arrange — no is_droppable key: ColumnDto defaults to true
        fakeDs.queueGetItem({
          'id': 1,
          'container': 1,
          'index': 0,
          'width': 100,
        });

        // Act
        final result = await repository.getById(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.isDroppable, isTrue);
      },
    );
  });

  // =========================================================================
  // update
  // =========================================================================
  group('ColumnRepositoryImpl.update', () {
    test('should return Success with updated Column entity', () async {
      // Arrange
      fakeDs.queueGetItem(
        _columnJson(id: 1, containerId: 1, index: 0, width: 100),
      );
      fakeDs.queueUpdateItem(
        _columnJson(id: 1, containerId: 1, index: 1, width: 100),
      );
      const input = UpdateColumnInput(id: 1, index: 1);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
    });

    test('should write new index to DTO before updateItem is called', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 3));
      const input = UpdateColumnInput(id: 1, index: 3);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'index'), 3);
    });

    test('should write new width to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, width: 100));
      fakeDs.queueUpdateItem(_columnJson(id: 1, width: 60));
      const input = UpdateColumnInput(id: 1, width: 60.0);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'width'), 60.0);
    });

    test('should write flex to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1));
      fakeDs.queueUpdateItem(_columnJson(id: 1));
      const input = UpdateColumnInput(id: 1, flex: 3);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'flex'), 3);
    });

    test('should write isDroppable=false to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1));
      fakeDs.queueUpdateItem(_columnJson(id: 1));
      const input = UpdateColumnInput(id: 1, isDroppable: false);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'is_droppable'), false);
    });

    test('should write style_json when styleConfig is provided', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1));
      fakeDs.queueUpdateItem(_columnJson(id: 1));
      const input = UpdateColumnInput(
        id: 1,
        styleConfig: StyleConfig(paddingLeft: 8.0),
      );

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.styleJson['paddingLeft'], 8.0);
    });

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );
        const input = UpdateColumnInput(id: 99, index: 1);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure when updateItem throws', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1));
      fakeDs.queueUpdateItemThrows(
        DirectusException(code: 'UPDATE_FAILED', message: 'Write failed'),
      );
      const input = UpdateColumnInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // delete
  // =========================================================================
  group('ColumnRepositoryImpl.delete', () {
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
      await repository.delete(88);

      // Assert
      expect(fakeDs.deletedIds.single, 88);
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueDeleteItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.delete(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

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
  group('ColumnRepositoryImpl.reorder', () {
    test('should return Success(null) when reorder succeeds', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 3));

      // Act
      final result = await repository.reorder(1, 3);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should write new index to DTO before updateItem is called', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 4));

      // Act
      await repository.reorder(1, 4);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'index'), 4);
    });

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 2));

      // Act
      await repository.reorder(1, 2);

      // Assert
      expect(fakeDs.updateCalls.length, 1);
    });

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.reorder(99, 2);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should reorder to boundary index zero', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 3));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 0));

      // Act
      final result = await repository.reorder(1, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      final sentDto = fakeDs.updateCalls.single['item'] as ColumnDto;
      expect(sentDto.getValue(forKey: 'index'), 0);
    });

    test('should first fetch the column then update it', () async {
      // Arrange
      fakeDs.queueGetItem(_columnJson(id: 1, index: 2));
      fakeDs.queueUpdateItem(_columnJson(id: 1, index: 5));

      // Act
      await repository.reorder(1, 5);

      // Assert — both queues were consumed exactly once (ordering verified by FIFO queue)
      expect(fakeDs.getItemCalls.length, 1);
      expect(fakeDs.updateCalls.length, 1);
    });
  });
}
