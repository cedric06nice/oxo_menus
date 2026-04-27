// Tests for ContainerRepositoryImpl — manual fakes only, no mocktail.
//
// Methods covered:
//   create / getAllForPage / getAllForContainer / getById / update / delete /
//   reorder / moveTo

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/features/menu/data/models/container_dto.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';

// ---------------------------------------------------------------------------
// Minimal DTO factory helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _containerJson({
  int id = 1,
  int pageId = 10,
  int index = 0,
  String status = 'published',
  String? direction,
  Map<String, dynamic>? styleJson,
  int? parentContainer,
}) => {
  'id': id,
  'page': pageId,
  'index': index,
  'status': status,
  'direction': ?direction,
  'style_json': ?styleJson,
  'parent_container': ?parentContainer,
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
    if (q.isEmpty) throw StateError('_FakeDs: no queued response for $name');
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
      throw StateError('_FakeDs: no queued response for deleteItem<$T>');
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
  late ContainerRepository repository;

  setUp(() {
    fakeDs = _FakeDs();
    repository = ContainerRepositoryImpl(dataSource: fakeDs);
  });

  // =========================================================================
  // create
  // =========================================================================
  group('ContainerRepositoryImpl.create', () {
    test(
      'should return Success with mapped Container entity on happy path',
      () async {
        // Arrange
        fakeDs.queueCreateItem(_containerJson(id: 2, pageId: 1, index: 0));
        const input = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.pageId, 1);
        expect(result.valueOrNull!.index, 0);
      },
    );

    test('should generate name as Container {id} via mapper', () async {
      // Arrange
      fakeDs.queueCreateItem(_containerJson(id: 7, pageId: 1, index: 0));
      const input = CreateContainerInput(pageId: 1, index: 0, direction: 'row');

      // Act
      final result = await repository.create(input);

      // Assert — ContainerMapper generates "Container {id}"
      expect(result.valueOrNull!.name, 'Container 7');
    });

    test('should set status=published in DTO sent to createItem', () async {
      // Arrange
      fakeDs.queueCreateItem(_containerJson(id: 1));
      const input = CreateContainerInput(pageId: 1, index: 0, direction: 'row');

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
      expect(sentDto.getValue(forKey: 'status'), 'published');
    });

    test('should include name in DTO when input has name', () async {
      // Arrange
      fakeDs.queueCreateItem(_containerJson(id: 1));
      const input = CreateContainerInput(
        pageId: 1,
        index: 0,
        direction: 'row',
        name: 'My Header',
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
      expect(sentDto.getValue(forKey: 'name'), 'My Header');
    });

    test(
      'should include parentContainerId in DTO when creating child container',
      () async {
        // Arrange
        fakeDs.queueCreateItem(_containerJson(id: 3, parentContainer: 5));
        const input = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
          parentContainerId: 5,
        );

        // Act
        await repository.create(input);

        // Assert
        final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
        expect(sentDto.getValue(forKey: 'parent_container'), 5);
      },
    );

    test('should merge layout into style_json field in sent DTO', () async {
      // Arrange
      fakeDs.queueCreateItem(
        _containerJson(
          id: 1,
          styleJson: {'direction': 'row', 'mainAxisAlignment': 'spaceBetween'},
        ),
      );
      const input = CreateContainerInput(
        pageId: 1,
        index: 0,
        direction: 'row',
        layout: LayoutConfig(
          direction: 'row',
          mainAxisAlignment: 'spaceBetween',
        ),
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
      expect(sentDto.styleJson['mainAxisAlignment'], 'spaceBetween');
      expect(sentDto.styleJson['direction'], 'row');
    });

    test(
      'should merge styleConfig into style_json field in sent DTO',
      () async {
        // Arrange
        fakeDs.queueCreateItem(
          _containerJson(id: 1, styleJson: {'marginTop': 10.0}),
        );
        const input = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
          styleConfig: StyleConfig(marginTop: 10.0),
        );

        // Act
        await repository.create(input);

        // Assert
        final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
        expect(sentDto.styleJson['marginTop'], 10.0);
      },
    );

    test(
      'should merge both layout and styleConfig into same style_json',
      () async {
        // Arrange
        fakeDs.queueCreateItem(_containerJson(id: 1));
        const input = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
          layout: LayoutConfig(mainAxisAlignment: 'spaceEvenly'),
          styleConfig: StyleConfig(marginTop: 5.0),
        );

        // Act
        await repository.create(input);

        // Assert
        final sentDto = fakeDs.createCalls.single['item'] as ContainerDto;
        expect(sentDto.styleJson['mainAxisAlignment'], 'spaceEvenly');
        expect(sentDto.styleJson['marginTop'], 5.0);
      },
    );

    test(
      'should return Failure(ValidationError) when data source throws INVALID_FOREIGN_KEY',
      () async {
        // Arrange
        fakeDs.queueCreateItemThrows(
          DirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Page not found',
          ),
        );
        const input = CreateContainerInput(
          pageId: 99,
          index: 0,
          direction: 'row',
        );

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
      const input = CreateContainerInput(pageId: 1, index: 0, direction: 'row');

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // =========================================================================
  // getAllForPage
  // =========================================================================
  group('ContainerRepositoryImpl.getAllForPage', () {
    test('should return Success with list of Container entities', () async {
      // Arrange
      fakeDs.queueGetItems([
        _containerJson(id: 1, pageId: 5, index: 0),
        _containerJson(id: 2, pageId: 5, index: 1),
      ]);

      // Act
      final result = await repository.getAllForPage(5);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 2);
      expect(result.valueOrNull![0].id, 1);
      expect(result.valueOrNull![1].id, 2);
    });

    test('should filter by page id', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForPage(42);

      // Assert
      final filter =
          fakeDs.getItemsCalls.single['filter'] as Map<String, dynamic>;
      expect(filter['page'], {'_eq': 42});
    });

    test(
      'should filter to only top-level containers (parent_container _null)',
      () async {
        // Arrange
        fakeDs.queueGetItems([]);

        // Act
        await repository.getAllForPage(1);

        // Assert
        final filter =
            fakeDs.getItemsCalls.single['filter'] as Map<String, dynamic>;
        expect(filter['parent_container'], {'_null': true});
      },
    );

    test('should include sort:[index] for ordering', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForPage(1);

      // Assert
      expect(
        (fakeDs.getItemsCalls.single['sort'] as List<String>),
        contains('index'),
      );
    });

    test(
      'should return Success with empty list when no containers found',
      () async {
        // Arrange
        fakeDs.queueGetItems([]);

        // Act
        final result = await repository.getAllForPage(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isEmpty);
      },
    );

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemsThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
        );

        // Act
        final result = await repository.getAllForPage(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );
  });

  // =========================================================================
  // getAllForContainer
  // =========================================================================
  group('ContainerRepositoryImpl.getAllForContainer', () {
    test('should return Success with child containers', () async {
      // Arrange
      fakeDs.queueGetItems([
        _containerJson(id: 10, pageId: 1, index: 0, parentContainer: 5),
        _containerJson(id: 11, pageId: 1, index: 1, parentContainer: 5),
      ]);

      // Act
      final result = await repository.getAllForContainer(5);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 2);
      expect(result.valueOrNull![0].id, 10);
      expect(result.valueOrNull![1].id, 11);
    });

    test('should filter by parent_container id', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForContainer(55);

      // Assert
      final filter =
          fakeDs.getItemsCalls.single['filter'] as Map<String, dynamic>;
      expect(filter['parent_container'], {'_eq': 55});
    });

    test(
      'should return Success with empty list when parent has no children',
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

    test('should return Failure when data source throws', () async {
      // Arrange
      fakeDs.queueGetItemsThrows(Exception('server error'));

      // Act
      final result = await repository.getAllForContainer(1);

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getById
  // =========================================================================
  group('ContainerRepositoryImpl.getById', () {
    test('should return Success with mapped Container entity', () async {
      // Arrange
      fakeDs.queueGetItem(
        _containerJson(
          id: 1,
          pageId: 1,
          index: 0,
          styleJson: {'direction': 'row'},
        ),
      );

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
      expect(result.valueOrNull!.pageId, 1);
      expect(result.valueOrNull!.layout, isNotNull);
    });

    test('should pass the correct id to data source', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 33));

      // Act
      await repository.getById(33);

      // Assert
      expect(fakeDs.getItemCalls.single['id'], 33);
    });

    test('should request page and parent_container fields', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, contains('page'));
      expect(fields, contains('parent_container'));
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
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

    test('should map null style_json to null layout and styleConfig', () async {
      // Arrange — no style_json key in response
      fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.layout, isNull);
      expect(result.valueOrNull!.styleConfig, isNull);
    });
  });

  // =========================================================================
  // update
  // =========================================================================
  group('ContainerRepositoryImpl.update', () {
    test('should return Success with updated Container entity', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, pageId: 1, index: 2));
      const input = UpdateContainerInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
    });

    test('should write new index to DTO before updateItem is called', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, index: 5));
      const input = UpdateContainerInput(id: 1, index: 5);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
      expect(sentDto.getValue(forKey: 'index'), 5);
    });

    test('should update styleConfig in style_json when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1));
      fakeDs.queueUpdateItem(_containerJson(id: 1));
      const input = UpdateContainerInput(
        id: 1,
        styleConfig: StyleConfig(paddingLeft: 8.0),
      );

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
      expect(sentDto.styleJson['paddingLeft'], 8.0);
    });

    test('should store layout fields in style_json on update', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1));
      fakeDs.queueUpdateItem(_containerJson(id: 1));
      const input = UpdateContainerInput(
        id: 1,
        layout: LayoutConfig(mainAxisAlignment: 'center'),
      );

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
      expect(sentDto.styleJson['mainAxisAlignment'], 'center');
    });

    test(
      'should merge layout and styleConfig into single style_json on update',
      () async {
        // Arrange
        fakeDs.queueGetItem(_containerJson(id: 1));
        fakeDs.queueUpdateItem(_containerJson(id: 1));
        const input = UpdateContainerInput(
          id: 1,
          layout: LayoutConfig(mainAxisAlignment: 'spaceBetween'),
          styleConfig: StyleConfig(paddingLeft: 5.0),
        );

        // Act
        await repository.update(input);

        // Assert
        final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
        expect(sentDto.styleJson['mainAxisAlignment'], 'spaceBetween');
        expect(sentDto.styleJson['paddingLeft'], 5.0);
      },
    );

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
        );
        const input = UpdateContainerInput(id: 99, index: 1);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure when updateItem throws', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1));
      fakeDs.queueUpdateItemThrows(
        DirectusException(code: 'UPDATE_FAILED', message: 'Write failed'),
      );
      const input = UpdateContainerInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // delete
  // =========================================================================
  group('ContainerRepositoryImpl.delete', () {
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

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueDeleteItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
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
  group('ContainerRepositoryImpl.reorder', () {
    test('should return Success(null) when reorder succeeds', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, index: 3));

      // Act
      final result = await repository.reorder(1, 3);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test(
      'should write the new index to the DTO before updateItem is called',
      () async {
        // Arrange
        fakeDs.queueGetItem(_containerJson(id: 1, index: 0));
        fakeDs.queueUpdateItem(_containerJson(id: 1, index: 4));

        // Act
        await repository.reorder(1, 4);

        // Assert
        final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
        expect(sentDto.getValue(forKey: 'index'), 4);
      },
    );

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, index: 2));

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
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
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
      fakeDs.queueGetItem(_containerJson(id: 1, index: 3));
      fakeDs.queueUpdateItem(_containerJson(id: 1, index: 0));

      // Act
      final result = await repository.reorder(1, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
      expect(sentDto.getValue(forKey: 'index'), 0);
    });
  });

  // =========================================================================
  // moveTo
  // =========================================================================
  group('ContainerRepositoryImpl.moveTo', () {
    test('should return Success(null) when moveTo succeeds', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, pageId: 2, index: 1));

      // Act
      final result = await repository.moveTo(1, 2, 1);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test(
      'should write new page_id and index to DTO before updateItem is called',
      () async {
        // Arrange
        fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));
        fakeDs.queueUpdateItem(_containerJson(id: 1, pageId: 3, index: 2));

        // Act
        await repository.moveTo(1, 3, 2);

        // Assert
        final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
        expect(sentDto.getValue(forKey: 'page_id'), 3);
        expect(sentDto.getValue(forKey: 'index'), 2);
      },
    );

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));
      fakeDs.queueUpdateItem(_containerJson(id: 1, pageId: 2, index: 0));

      // Act
      await repository.moveTo(1, 2, 0);

      // Assert
      expect(fakeDs.updateCalls.length, 1);
    });

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Container not found'),
        );

        // Act
        final result = await repository.moveTo(99, 2, 0);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test(
      'should return Failure(ValidationError) when updateItem throws INVALID_FOREIGN_KEY',
      () async {
        // Arrange
        fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 0));
        fakeDs.queueUpdateItemThrows(
          DirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.moveTo(1, 99, 0);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ValidationError>());
      },
    );

    test('should move to index zero (boundary)', () async {
      // Arrange
      fakeDs.queueGetItem(_containerJson(id: 1, pageId: 1, index: 3));
      fakeDs.queueUpdateItem(_containerJson(id: 1, pageId: 2, index: 0));

      // Act
      final result = await repository.moveTo(1, 2, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      final sentDto = fakeDs.updateCalls.single['item'] as ContainerDto;
      expect(sentDto.getValue(forKey: 'index'), 0);
    });
  });
}
