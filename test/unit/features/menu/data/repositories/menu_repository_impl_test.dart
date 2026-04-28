import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

// ---------------------------------------------------------------------------
// Shared minimal menu JSON fixtures
// ---------------------------------------------------------------------------

Map<String, dynamic> _minimalMenuJson({
  int id = 1,
  String name = 'Test Menu',
  String status = 'published',
  String version = '1.0.0',
}) => {'id': id, 'name': name, 'status': status, 'version': version};

void main() {
  late _FakeMenuDataSource fake;
  late MenuRepositoryImpl repository;

  setUp(() {
    fake = _FakeMenuDataSource();
    repository = MenuRepositoryImpl(dataSource: fake);
  });

  group('MenuRepositoryImpl', () {
    group('getById', () {
      test(
        'should return Success<Menu> when data source returns a menu',
        () async {
          // Arrange
          fake.getItemResult = _minimalMenuJson();

          // Act
          final result = await repository.getById(1);

          // Assert
          expect(result.isSuccess, isTrue);
          final menu = result.valueOrNull!;
          expect(menu.id, 1);
          expect(menu.name, 'Test Menu');
          expect(menu.status, Status.published);
          expect(menu.version, '1.0.0');
        },
      );

      test('should call getItem with the provided id', () async {
        // Arrange
        fake.getItemResult = _minimalMenuJson(id: 42);

        // Act
        await repository.getById(42);

        // Assert
        expect(fake.lastGetItemId, 42);
      });

      test('should request a rich fields list when fetching by id', () async {
        // Arrange
        fake.getItemResult = _minimalMenuJson();

        // Act
        await repository.getById(1);

        // Assert
        expect(fake.lastGetItemFields, isNotNull);
        expect(fake.lastGetItemFields, contains('allowed_widget_types'));
        expect(fake.lastGetItemFields, contains('allowed_widgets'));
        expect(fake.lastGetItemFields, contains('pages.id'));
      });

      test('should map allowed_widget_types list from response', () async {
        // Arrange
        fake.getItemResult = {
          ..._minimalMenuJson(),
          'allowed_widget_types': ['dish', 'text'],
        };

        // Act
        final result = await repository.getById(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.allowedWidgetTypes, {'dish', 'text'});
      });

      test('should map allowed_widgets with alignment from response', () async {
        // Arrange
        fake.getItemResult = {
          ..._minimalMenuJson(),
          'allowed_widgets': [
            {'type': 'dish', 'alignment': 'center', 'enabled': true},
            {'type': 'text', 'alignment': 'end', 'enabled': true},
          ],
        };

        // Act
        final result = await repository.getById(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final configs = result.valueOrNull!.allowedWidgets;
        expect(configs, hasLength(2));
        expect(configs[0].type, 'dish');
        expect(configs[0].alignment, WidgetAlignment.center);
        expect(configs[1].type, 'text');
        expect(configs[1].alignment, WidgetAlignment.end);
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.getItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Menu not found',
          );

          // Act
          final result = await repository.getById(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
          expect(result.errorOrNull!.message, contains('Menu not found'));
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.getItemError = Exception('Network error');

          // Act
          final result = await repository.getById(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('listAll', () {
      test('should return Success<List<Menu>> with mapped entities', () async {
        // Arrange
        fake.getItemsResult = [
          _minimalMenuJson(id: 1, name: 'Menu 1'),
          _minimalMenuJson(id: 2, name: 'Menu 2'),
        ];

        // Act
        final result = await repository.listAll();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, hasLength(2));
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);
      });

      test(
        'should pass published status filter when onlyPublished is true',
        () async {
          // Arrange
          fake.getItemsResult = [];

          // Act
          await repository.listAll(onlyPublished: true);

          // Assert
          final filter = fake.lastGetItemsFilter;
          expect(filter, isNotNull);
          expect(filter!['status'], isNotNull);
          expect(filter['status']['_eq'], 'published');
        },
      );

      test('should pass null filter when onlyPublished is false', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.listAll(onlyPublished: false);

        // Assert
        expect(fake.lastGetItemsFilter, isNull);
      });

      test('should include area filter when areaIds is provided', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.listAll(onlyPublished: false, areaIds: [1, 2]);

        // Assert
        final filter = fake.lastGetItemsFilter;
        expect(filter, isNotNull);
        expect(filter!['area']['_in'], [1, 2]);
      });

      test('should combine published and area filters as a flat map', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.listAll(onlyPublished: true, areaIds: [1]);

        // Assert
        final filter = fake.lastGetItemsFilter;
        expect(filter, {
          'status': {'_eq': 'published'},
          'area': {
            '_in': [1],
          },
        });
      });

      test(
        'should return empty list without calling data source when areaIds is empty',
        () async {
          // Act
          final result = await repository.listAll(areaIds: []);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
          expect(fake.getItemsCallCount, 0);
        },
      );

      test(
        'should return empty list without calling data source when areaIds is empty and onlyPublished is false',
        () async {
          // Act
          final result = await repository.listAll(
            onlyPublished: false,
            areaIds: [],
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
          expect(fake.getItemsCallCount, 0);
        },
      );

      test('should include sort by -date_updated', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.listAll();

        // Assert
        expect(fake.lastGetItemsSort, contains('-date_updated'));
      });

      test('should request allowed_widget_types field in listAll', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.listAll();

        // Assert
        expect(fake.lastGetItemsFields, contains('allowed_widget_types'));
      });

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.getItemsError = Exception('server error');

          // Act
          final result = await repository.listAll();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );

      test(
        'should return empty list when data source returns no menus',
        () async {
          // Arrange
          fake.getItemsResult = [];

          // Act
          final result = await repository.listAll();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );
    });

    group('create', () {
      const input = CreateMenuInput(
        name: 'New Menu',
        version: '1.0.0',
        status: Status.draft,
      );

      test('should return Success<Menu> with the created entity', () async {
        // Arrange
        fake.createItemResult = _minimalMenuJson(
          id: 99,
          name: 'New Menu',
          status: 'draft',
          version: '1.0.0',
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.id, 99);
        expect(result.valueOrNull!.name, 'New Menu');
        expect(result.valueOrNull!.status, Status.draft);
      });

      test('should call createItem exactly once', () async {
        // Arrange
        fake.createItemResult = _minimalMenuJson(
          id: 1,
          name: 'New Menu',
          status: 'draft',
        );

        // Act
        await repository.create(input);

        // Assert
        expect(fake.createItemCallCount, 1);
      });

      test(
        'should return Failure<ValidationError> when data source throws RECORD_NOT_UNIQUE',
        () async {
          // Arrange
          fake.createItemError = DirectusException(
            code: 'RECORD_NOT_UNIQUE',
            message: 'Menu already exists',
          );

          // Act
          final result = await repository.create(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test(
        'should return Failure<ServerError> when data source throws CREATE_FAILED',
        () async {
          // Arrange
          fake.createItemError = DirectusException(
            code: 'CREATE_FAILED',
            message: 'Failed',
          );

          // Act
          final result = await repository.create(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    group('update', () {
      const input = UpdateMenuInput(
        id: 1,
        name: 'Updated Menu',
        status: Status.published,
      );

      test(
        'should fetch existing item then update and return entity',
        () async {
          // Arrange
          fake.getItemResult = _minimalMenuJson(status: 'draft');
          fake.updateItemResult = _minimalMenuJson(
            name: 'Updated Menu',
            status: 'published',
          );

          // Act
          final result = await repository.update(input);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, 'Updated Menu');
          expect(result.valueOrNull!.status, Status.published);
        },
      );

      test('should call getItem then updateItem in sequence', () async {
        // Arrange
        fake.getItemResult = _minimalMenuJson();
        fake.updateItemResult = _minimalMenuJson(name: 'Updated Menu');

        // Act
        await repository.update(input);

        // Assert
        expect(fake.lastGetItemId, input.id);
        expect(fake.updateItemCallCount, 1);
      });

      test(
        'should return Failure<NotFoundError> when getItem throws NOT_FOUND',
        () async {
          // Arrange
          fake.getItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Menu not found',
          );

          // Act
          final result = await repository.update(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure<ServerError> when updateItem throws UPDATE_FAILED',
        () async {
          // Arrange
          fake.getItemResult = _minimalMenuJson();
          fake.updateItemError = DirectusException(
            code: 'UPDATE_FAILED',
            message: 'Update failed',
          );

          // Act
          final result = await repository.update(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    group('delete', () {
      test(
        'should return Success<void> when data source deletes successfully',
        () async {
          // Act
          final result = await repository.delete(1);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should call deleteItem with the provided id', () async {
        // Act
        await repository.delete(42);

        // Assert
        expect(fake.lastDeleteItemId, 42);
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.deleteItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Menu not found',
          );

          // Act
          final result = await repository.delete(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.deleteItemError = Exception('Database error');

          // Act
          final result = await repository.delete(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Manual fake
// ---------------------------------------------------------------------------

class _FakeMenuDataSource implements DirectusDataSource {
  // getItem stubs
  Map<String, dynamic>? getItemResult;
  Object? getItemError;
  int? lastGetItemId;
  List<String>? lastGetItemFields;

  // getItems stubs
  List<Map<String, dynamic>>? getItemsResult;
  Object? getItemsError;
  int getItemsCallCount = 0;
  Map<String, dynamic>? lastGetItemsFilter;
  List<String>? lastGetItemsFields;
  List<String>? lastGetItemsSort;

  // createItem stubs
  Map<String, dynamic>? createItemResult;
  Object? createItemError;
  int createItemCallCount = 0;

  // updateItem stubs
  Map<String, dynamic>? updateItemResult;
  Object? updateItemError;
  int updateItemCallCount = 0;

  // deleteItem stubs
  Object? deleteItemError;
  int? lastDeleteItemId;

  @override
  String? get currentAccessToken => null;

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async {
    lastGetItemId = id;
    lastGetItemFields = fields;
    if (getItemError != null) throw getItemError!;
    if (getItemResult != null) return getItemResult!;
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    getItemsCallCount++;
    lastGetItemsFilter = filter;
    lastGetItemsFields = fields;
    lastGetItemsSort = sort;
    if (getItemsError != null) throw getItemsError!;
    if (getItemsResult != null) return getItemsResult!;
    return [];
  }

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    createItemCallCount++;
    if (createItemError != null) throw createItemError!;
    if (createItemResult != null) return createItemResult!;
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    updateItemCallCount++;
    if (updateItemError != null) throw updateItemError!;
    if (updateItemResult != null) return updateItemResult!;
    return {};
  }

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    lastDeleteItemId = id;
    if (deleteItemError != null) throw deleteItemError!;
  }

  // Unused auth/file methods — complete without error for isolation
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async => {};

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> getCurrentUser() async => {};

  @override
  Future<void> refreshSession() async {}

  @override
  Future<bool> tryRestoreSession() async => false;

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async => true;

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async => true;

  @override
  Future<String> uploadFile(Uint8List bytes, String filename) async =>
      throw UnimplementedError();

  @override
  Future<String> replaceFile(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> listFiles({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
  }) async => throw UnimplementedError();

  @override
  Future<Uint8List> downloadFileBytes(String fileId) async =>
      throw UnimplementedError();

  @override
  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async => throw UnimplementedError();

  @override
  Future<void> stopSubscription(String subscriptionUid) async =>
      throw UnimplementedError();
}
