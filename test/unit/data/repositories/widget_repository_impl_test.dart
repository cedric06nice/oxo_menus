// Tests for WidgetRepositoryImpl — manual fakes only, no mocktail.
//
// Methods covered:
//   create / getAllForColumn / getById / update / delete / reorder / moveTo
//
// The reorder and moveTo operations call getItems<WidgetDto> multiple times
// with different filter arguments. The _FakeDs supports multiple queued
// getItems responses consumed in FIFO order.

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

// ---------------------------------------------------------------------------
// DTO factory helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _widgetJson({
  int id = 1,
  int columnId = 10,
  int index = 0,
  String typeKey = 'dish',
  String version = '1.0.0',
  Map<String, dynamic>? props,
  Map<String, dynamic>? styleJson,
  bool isTemplate = false,
  bool lockedForEdition = false,
  String? editingBy,
}) =>
    {
      'id': id,
      'column': columnId,
      'index': index,
      'type_key': typeKey,
      'version': version,
      'props_json': props ?? {},
      'status': 'published',
      'style_json': ?styleJson,
      'is_template': isTemplate,
      'locked_for_edition': lockedForEdition,
      'editing_by': ?editingBy,
    };

// Minimal json for index-only operations (reorder helpers)
Map<String, dynamic> _indexJson(int id, int index) => {
  'id': id,
  'index': index,
  'column': 10,
  'type_key': 'dish',
  'version': '1.0.0',
  'props_json': <String, dynamic>{},
};

// ---------------------------------------------------------------------------
// Local fake — supports multiple queued responses per method
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
    getItemsCalls.add(
      {'type': T, 'filter': filter, 'fields': fields, 'sort': sort},
    );
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
  late WidgetRepository repository;

  setUp(() {
    fakeDs = _FakeDs();
    repository = WidgetRepositoryImpl(dataSource: fakeDs);
  });

  // =========================================================================
  // create
  // =========================================================================
  group('WidgetRepositoryImpl.create', () {
    test('should return Success with mapped WidgetInstance entity', () async {
      // Arrange
      fakeDs.queueCreateItem(
        _widgetJson(id: 1, columnId: 1, index: 0, props: {'name': 'Pasta'}),
      );
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {'name': 'Pasta'},
      );

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 1);
      expect(result.valueOrNull!.type, 'dish');
      expect(result.valueOrNull!.version, '1.0.0');
      expect(result.valueOrNull!.props['name'], 'Pasta');
    });

    test('should send column, props_json and is_template in DTO', () async {
      // Arrange
      fakeDs.queueCreateItem(_widgetJson(id: 1));
      const input = CreateWidgetInput(
        columnId: 5,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {'price': 12.5},
        isTemplate: true,
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'column'), 5);
      expect((sentDto.getValue(forKey: 'props_json') as Map)['price'], 12.5);
      expect(sentDto.getValue(forKey: 'is_template'), true);
    });

    test('should send lockedForEdition in DTO when provided', () async {
      // Arrange
      fakeDs.queueCreateItem(_widgetJson(id: 1));
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {},
        lockedForEdition: true,
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'locked_for_edition'), true);
    });

    test('should send style_json when style is provided', () async {
      // Arrange
      fakeDs.queueCreateItem(_widgetJson(id: 1));
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {},
        style: WidgetStyle(fontSize: 14.0, color: '#FF0000'),
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as WidgetDto;
      final styleJson = sentDto.getValue(forKey: 'style_json') as Map?;
      expect(styleJson?['fontSize'], 14.0);
      expect(styleJson?['color'], '#FF0000');
    });

    test('should use published status in DTO', () async {
      // Arrange
      fakeDs.queueCreateItem(_widgetJson(id: 1));
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {},
      );

      // Act
      await repository.create(input);

      // Assert
      final sentDto = fakeDs.createCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'status'), 'published');
    });

    test(
      'should return Failure(ValidationError) when data source throws INVALID_FOREIGN_KEY',
      () async {
        // Arrange
        fakeDs.queueCreateItemThrows(
          DirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Column not found',
          ),
        );
        const input = CreateWidgetInput(
          columnId: 99,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {},
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
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {},
      );

      // Act
      final result = await repository.create(input);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // =========================================================================
  // getAllForColumn
  // =========================================================================
  group('WidgetRepositoryImpl.getAllForColumn', () {
    test('should return Success with list of WidgetInstance entities', () async {
      // Arrange
      fakeDs.queueGetItems([
        _widgetJson(id: 1, columnId: 5, index: 0),
        _widgetJson(id: 2, columnId: 5, index: 1),
      ]);

      // Act
      final result = await repository.getAllForColumn(5);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.length, 2);
      expect(result.valueOrNull![0].id, 1);
      expect(result.valueOrNull![1].id, 2);
    });

    test('should filter by column id', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForColumn(42);

      // Assert
      final filter =
          fakeDs.getItemsCalls.single['filter'] as Map<String, dynamic>;
      expect(filter['column'], {'_eq': 42});
    });

    test('should include sort:[index] for ordering', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForColumn(1);

      // Assert
      expect(
        (fakeDs.getItemsCalls.single['sort'] as List<String>),
        contains('index'),
      );
    });

    test('should request editing_by field', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForColumn(1);

      // Assert
      final fields =
          fakeDs.getItemsCalls.single['fields'] as List<String>?;
      expect(fields, contains('editing_by'));
    });

    test('should request editing_since field', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForColumn(1);

      // Assert
      final fields =
          fakeDs.getItemsCalls.single['fields'] as List<String>?;
      expect(fields, contains('editing_since'));
    });

    test('should request locked_for_edition field', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      await repository.getAllForColumn(1);

      // Assert
      final fields =
          fakeDs.getItemsCalls.single['fields'] as List<String>?;
      expect(fields, contains('locked_for_edition'));
    });

    test('should return Success with empty list when no widgets found', () async {
      // Arrange
      fakeDs.queueGetItems([]);

      // Act
      final result = await repository.getAllForColumn(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isEmpty);
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemsThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.getAllForColumn(99);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );
  });

  // =========================================================================
  // getById
  // =========================================================================
  group('WidgetRepositoryImpl.getById', () {
    test('should return Success with mapped WidgetInstance entity', () async {
      // Arrange
      fakeDs.queueGetItem(
        _widgetJson(
          id: 1,
          columnId: 10,
          index: 2,
          props: {'name': 'Pasta Carbonara', 'price': 12.5},
          styleJson: {'fontSize': 14.0},
          editingBy: 'user-abc',
        ),
      );

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      final w = result.valueOrNull!;
      expect(w.id, 1);
      expect(w.columnId, 10);
      expect(w.index, 2);
      expect(w.props['name'], 'Pasta Carbonara');
      expect(w.style, isNotNull);
      expect(w.editingBy, 'user-abc');
    });

    test('should pass correct id to data source', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 99));

      // Act
      await repository.getById(99);

      // Assert
      expect(fakeDs.getItemCalls.single['id'], 99);
    });

    test('should request editing_by field', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, contains('editing_by'));
    });

    test('should request editing_since field', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, contains('editing_since'));
    });

    test('should request locked_for_edition field', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));

      // Act
      await repository.getById(1);

      // Assert
      final fields = fakeDs.getItemCalls.single['fields'] as List<String>?;
      expect(fields, contains('locked_for_edition'));
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
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
  });

  // =========================================================================
  // update
  // =========================================================================
  group('WidgetRepositoryImpl.update', () {
    test('should return Success with updated WidgetInstance entity', () async {
      // Arrange
      fakeDs.queueGetItem(
        _widgetJson(id: 1, props: {'name': 'Old'}),
      );
      fakeDs.queueUpdateItem(
        _widgetJson(id: 1, props: {'name': 'New', 'price': 14.0}),
      );
      const input = UpdateWidgetInput(
        id: 1,
        props: {'name': 'New', 'price': 14.0},
      );

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.props['name'], 'New');
    });

    test('should write props_json to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, props: {'name': 'Updated'}));
      const input = UpdateWidgetInput(id: 1, props: {'name': 'Updated'});

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(
        (sentDto.getValue(forKey: 'props_json') as Map)['name'],
        'Updated',
      );
    });

    test('should write index to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1, index: 0));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, index: 3));
      const input = UpdateWidgetInput(id: 1, index: 3);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'index'), 3);
    });

    test('should write type_key to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1, typeKey: 'dish'));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, typeKey: 'text'));
      const input = UpdateWidgetInput(id: 1, type: 'text');

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'type_key'), 'text');
    });

    test('should write locked_for_edition to DTO when provided', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, lockedForEdition: true));
      const input = UpdateWidgetInput(id: 1, lockedForEdition: true);

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'locked_for_edition'), true);
    });

    test('should not touch locked_for_edition when not in input', () async {
      // Arrange — existing widget has locked_for_edition=false in fetched data;
      // input carries no lockedForEdition override.
      fakeDs.queueGetItem(_widgetJson(id: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 1));
      const input = UpdateWidgetInput(id: 1, index: 2);

      // Act
      await repository.update(input);

      // Assert — DTO retains whatever value was in the fetched data (false).
      // The update method does NOT set locked_for_edition when input.lockedForEdition is null.
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'locked_for_edition'), equals(false));
    });

    test('should write style_json to DTO when style is provided', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 1));
      const input = UpdateWidgetInput(
        id: 1,
        style: WidgetStyle(color: '#FFFFFF', padding: 4.0),
      );

      // Act
      await repository.update(input);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      final styleJson = sentDto.getValue(forKey: 'style_json') as Map?;
      expect(styleJson?['color'], '#FFFFFF');
      expect(styleJson?['padding'], 4.0);
    });

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );
        const input = UpdateWidgetInput(id: 99, index: 1);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure when updateItem throws', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1));
      fakeDs.queueUpdateItemThrows(
        DirectusException(code: 'UPDATE_FAILED', message: 'Write failed'),
      );
      const input = UpdateWidgetInput(id: 1, index: 2);

      // Act
      final result = await repository.update(input);

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // delete
  // =========================================================================
  group('WidgetRepositoryImpl.delete', () {
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
      await repository.delete(42);

      // Assert
      expect(fakeDs.deletedIds.single, 42);
    });

    test(
      'should return Failure(NotFoundError) when data source throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueDeleteItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
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
  //
  // The implementation:
  //   1. getItem(widgetId)          — fetch widget to get oldIndex + columnId
  //   2. getItems(column=columnId)  — fetch all siblings
  //   3. updateItem(×N)             — update affected widgets concurrently
  // =========================================================================
  group('WidgetRepositoryImpl.reorder', () {
    test('should return Success when widget already at target index', () async {
      // Arrange — widget at index 0, moving to index 0 → early Success, no updates
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
      // No getItems or updateItem should be called

      // Act
      final result = await repository.reorder(1, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(fakeDs.getItemsCalls, isEmpty);
      expect(fakeDs.updateCalls, isEmpty);
    });

    test(
      'should shift intermediate widgets when moving down (index 0 → 2)',
      () async {
        // Arrange: 3 widgets at indices 0, 1, 2; widget 1 moves from 0 to 2
        fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
        fakeDs.queueGetItems([
          _indexJson(1, 0), // widget being moved
          _indexJson(2, 1), // needs to shift: 1→0
          _indexJson(3, 2), // needs to shift: 2→1
        ]);
        // Three updates: widget 1 (0→2), widget 2 (1→0), widget 3 (2→1)
        fakeDs.queueUpdateItem(_widgetJson(id: 1, index: 2));
        fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 0));
        fakeDs.queueUpdateItem(_widgetJson(id: 3, index: 1));

        // Act
        final result = await repository.reorder(1, 2);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(fakeDs.updateCalls.length, 3);

        // Verify each widget got the correct new index
        final updates = <int, int>{};
        for (final call in fakeDs.updateCalls) {
          final dto = call['item'] as WidgetDto;
          final id = dto.id is int ? dto.id as int : int.parse(dto.id.toString());
          updates[id] = dto.index;
        }
        expect(updates[1], 2); // moved widget: 0→2
        expect(updates[2], 0); // shifted: 1→0
        expect(updates[3], 1); // shifted: 2→1
      },
    );

    test(
      'should shift intermediate widgets when moving up (index 2 → 0)',
      () async {
        // Arrange: 3 widgets at indices 0, 1, 2; widget 3 moves from 2 to 0
        fakeDs.queueGetItem(_widgetJson(id: 3, columnId: 1, index: 2));
        fakeDs.queueGetItems([
          _indexJson(1, 0), // needs to shift: 0→1
          _indexJson(2, 1), // needs to shift: 1→2
          _indexJson(3, 2), // widget being moved
        ]);
        fakeDs.queueUpdateItem(_widgetJson(id: 3, index: 0));
        fakeDs.queueUpdateItem(_widgetJson(id: 1, index: 1));
        fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 2));

        // Act
        final result = await repository.reorder(3, 0);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(fakeDs.updateCalls.length, 3);

        final updates = <int, int>{};
        for (final call in fakeDs.updateCalls) {
          final dto = call['item'] as WidgetDto;
          final id = dto.id is int ? dto.id as int : int.parse(dto.id.toString());
          updates[id] = dto.index;
        }
        expect(updates[3], 0); // moved widget: 2→0
        expect(updates[1], 1); // shifted: 0→1
        expect(updates[2], 2); // shifted: 1→2
      },
    );

    test(
      'should handle column represented as nested object {"id": N}',
      () async {
        // Arrange — column field is a map, not a plain int
        fakeDs.queueGetItem({
          'id': 1,
          'column': {'id': 5},
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'props_json': <String, dynamic>{},
        });
        fakeDs.queueGetItems([_indexJson(1, 0), _indexJson(2, 1)]);
        fakeDs.queueUpdateItem(_widgetJson(id: 1, index: 1));
        fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 0));

        // Act
        final result = await repository.reorder(1, 1);

        // Assert
        expect(result.isSuccess, isTrue);

        // Verify getItems was called with column filter = 5 (from nested obj)
        final getItemsCall = fakeDs.getItemsCalls.single;
        final filter = getItemsCall['filter'] as Map<String, dynamic>;
        expect(filter['column'], {'_eq': 5});
      },
    );

    test(
      'should return Failure(ValidationError) when widget has null column',
      () async {
        // Arrange
        fakeDs.queueGetItem({
          'id': 1,
          'column': null,
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'props_json': <String, dynamic>{},
        });

        // Act
        final result = await repository.reorder(1, 2);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ValidationError>());
      },
    );

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.reorder(99, 2);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should make no updates when only one widget in column', () async {
      // Arrange: single widget at index 0, moving to index 0 → early exit
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));

      // Act
      final result = await repository.reorder(1, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(fakeDs.updateCalls, isEmpty);
    });

    test('should not update widgets outside the reorder range', () async {
      // Arrange: 4 widgets at 0,1,2,3; move widget 1 from 0 to 1
      // Only widgets 1 (0→1) and 2 (1→0) should be updated; 3 and 4 unaffected
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
      fakeDs.queueGetItems([
        _indexJson(1, 0),
        _indexJson(2, 1),
        _indexJson(3, 2), // outside range
        _indexJson(4, 3), // outside range
      ]);
      fakeDs.queueUpdateItem(_widgetJson(id: 1, index: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 0));

      // Act
      final result = await repository.reorder(1, 1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(fakeDs.updateCalls.length, 2);
    });
  });

  // =========================================================================
  // moveTo
  //
  // The implementation:
  //   1. getItem(widgetId)              — fetch widget to get oldIndex + oldColumnId
  //   2. getItems(column=oldColumnId)   — only if oldColumnId != newColumnId
  //   3. getItems(column=newColumnId)   — always
  //   4. updateItem(×N)                 — concurrent updates
  // =========================================================================
  group('WidgetRepositoryImpl.moveTo', () {
    test(
      'should return Success when moving widget to a different column',
      () async {
        // Arrange: widget 1 at index 0 in column 1 → move to column 2 at index 1
        fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
        // Source column widgets (column 1)
        fakeDs.queueGetItems([
          _indexJson(1, 0), // the widget being moved (skipped in source loop)
          {'id': 2, 'index': 1, 'column': 1, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
        ]);
        // Target column widgets (column 2)
        fakeDs.queueGetItems([
          {'id': 3, 'index': 0, 'column': 2, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
          {'id': 4, 'index': 1, 'column': 2, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
        ]);
        // Updates (concurrent via Future.wait):
        //   widget 2: source column shift (index 1 > oldIndex 0), 1→0
        //   widget 4: target column shift (index 1 >= insertionPoint 1), 1→2
        //   widget 1: moved to column 2 at index 1
        fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 0));
        fakeDs.queueUpdateItem(_widgetJson(id: 4, index: 2));
        fakeDs.queueUpdateItem(_widgetJson(id: 1, columnId: 2, index: 1));

        // Act
        final result = await repository.moveTo(1, 2, 1);

        // Assert
        expect(result.isSuccess, isTrue);
      },
    );

    test('should shift source column widgets after removed widget', () async {
      // Arrange: widget 1 at index 0 in column 1; widget 2 at index 1
      // After removing widget 1: widget 2 should shift from 1 → 0
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
      // Source column
      fakeDs.queueGetItems([
        _indexJson(1, 0), // widget being moved (skipped)
        {'id': 2, 'index': 1, 'column': 1, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
      ]);
      // Target column (empty)
      fakeDs.queueGetItems([]);
      // Updates: widget 2 shifts (1→0), widget 1 moves to new column
      fakeDs.queueUpdateItem(_widgetJson(id: 2, index: 0));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, columnId: 99, index: 0));

      // Act
      final result = await repository.moveTo(1, 99, 0);

      // Assert
      expect(result.isSuccess, isTrue);

      final updates = <int, int>{};
      for (final call in fakeDs.updateCalls) {
        final dto = call['item'] as WidgetDto;
        final id = dto.id is int ? dto.id as int : int.parse(dto.id.toString());
        updates[id] = dto.index;
      }
      expect(updates[2], 0); // widget 2 shifted from 1→0
    });

    test('should shift target column widgets at and after insertion point', () async {
      // Arrange: widget 5 at index 2 in column 3 → move to column 4 at index 0
      // Target has widgets at 0 and 1; both should shift up
      fakeDs.queueGetItem(_widgetJson(id: 5, columnId: 3, index: 2));
      // Source column
      fakeDs.queueGetItems([
        _indexJson(5, 2), // widget being moved (skipped)
        {'id': 6, 'index': 3, 'column': 3, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
      ]);
      // Target column
      fakeDs.queueGetItems([
        {'id': 7, 'index': 0, 'column': 4, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
        {'id': 8, 'index': 1, 'column': 4, 'type_key': 'dish', 'version': '1.0.0', 'props_json': <String, dynamic>{}},
      ]);
      fakeDs.queueUpdateItem(_widgetJson(id: 7, index: 1));
      fakeDs.queueUpdateItem(_widgetJson(id: 8, index: 2));
      fakeDs.queueUpdateItem(_widgetJson(id: 5, columnId: 4, index: 0));
      fakeDs.queueUpdateItem(_widgetJson(id: 6, index: 2));

      // Act
      final result = await repository.moveTo(5, 4, 0);

      // Assert
      expect(result.isSuccess, isTrue);

      final updates = <int, int>{};
      for (final call in fakeDs.updateCalls) {
        final dto = call['item'] as WidgetDto;
        final id = dto.id is int ? dto.id as int : int.parse(dto.id.toString());
        updates[id] = dto.index;
      }
      expect(updates[7], 1); // shifted: 0→1
      expect(updates[8], 2); // shifted: 1→2
    });

    test('should not fetch source column when same as target column', () async {
      // Arrange: moving within same column (oldColumnId == newColumnId)
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
      // Only target column is fetched (source == target is false, so source
      // getItems is skipped)
      fakeDs.queueGetItems([
        _indexJson(1, 0),
        _indexJson(2, 1),
        _indexJson(3, 2),
      ]);
      // Widgets at/after insertion point (index 2) shift up; widget 1 moves
      fakeDs.queueUpdateItem(_widgetJson(id: 3, index: 3));
      fakeDs.queueUpdateItem(_widgetJson(id: 1, columnId: 1, index: 2));

      // Act
      final result = await repository.moveTo(1, 1, 2);

      // Assert
      expect(result.isSuccess, isTrue);
      // Only one getItems call (target only, no source fetch)
      expect(fakeDs.getItemsCalls.length, 1);
    });

    test(
      'should return Failure(ValidationError) when widget has null column',
      () async {
        // Arrange
        fakeDs.queueGetItem({
          'id': 1,
          'column': null,
          'index': 0,
          'type_key': 'dish',
          'version': '1.0.0',
          'props_json': <String, dynamic>{},
        });

        // Act
        final result = await repository.moveTo(1, 2, 0);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ValidationError>());
      },
    );

    test(
      'should return Failure(NotFoundError) when getItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueGetItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.moveTo(99, 2, 0);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure when updateItem throws', () async {
      // Arrange
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 0));
      fakeDs.queueGetItems([]); // source column (empty — different from target)
      fakeDs.queueGetItems([]); // target column (empty)
      fakeDs.queueUpdateItemThrows(
        DirectusException(
          code: 'INVALID_FOREIGN_KEY',
          message: 'Column not found',
        ),
      );

      // Act
      final result = await repository.moveTo(1, 2, 0);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('should move widget to index zero (boundary)', () async {
      // Arrange: widget at index 3 in column 1 → move to column 2 at index 0
      fakeDs.queueGetItem(_widgetJson(id: 1, columnId: 1, index: 3));
      fakeDs.queueGetItems([]); // source (no other widgets)
      fakeDs.queueGetItems([]); // target (empty)
      fakeDs.queueUpdateItem(_widgetJson(id: 1, columnId: 2, index: 0));

      // Act
      final result = await repository.moveTo(1, 2, 0);

      // Assert
      expect(result.isSuccess, isTrue);
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'index'), 0);
      expect(sentDto.getValue(forKey: 'column'), 2);
    });
  });
}
