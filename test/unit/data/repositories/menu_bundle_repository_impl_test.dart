import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

// ---------------------------------------------------------------------------
// Shared JSON fixture builder
// ---------------------------------------------------------------------------

Map<String, dynamic> _bundleJson({
  int id = 1,
  String name = 'Test Bundle',
  List<int> menuIds = const [],
  String? pdfFileId,
}) {
  final map = <String, dynamic>{'id': id, 'name': name, 'menu_ids': menuIds};
  if (pdfFileId != null) {
    map['pdf_file_id'] = pdfFileId;
  }
  return map;
}

void main() {
  late _FakeBundleDataSource fake;
  late MenuBundleRepositoryImpl repository;

  setUp(() {
    fake = _FakeBundleDataSource();
    repository = MenuBundleRepositoryImpl(dataSource: fake);
  });

  group('MenuBundleRepositoryImpl', () {
    group('getAll', () {
      test(
        'should return Success<List<MenuBundle>> with all mapped bundles',
        () async {
          // Arrange
          fake.getItemsResult = [
            _bundleJson(id: 1, name: 'A', menuIds: [10]),
            _bundleJson(id: 2, name: 'B', menuIds: [20, 30]),
          ];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, hasLength(2));
          expect(result.valueOrNull![0].name, 'A');
          expect(result.valueOrNull![1].menuIds, [20, 30]);
        },
      );

      test(
        'should return empty list when data source returns no bundles',
        () async {
          // Arrange
          fake.getItemsResult = [];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test('should request the standard field list', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        final fields = fake.lastGetItemsFields;
        expect(fields, isNotNull);
        expect(fields, containsAll(['id', 'name', 'menu_ids', 'pdf_file_id']));
      });

      test('should sort by name', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        expect(fake.lastGetItemsSort, contains('name'));
      });

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          fake.getItemsError = Exception('server error');

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<DomainError>());
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws FORBIDDEN',
        () async {
          // Arrange
          fake.getItemsError = DirectusException(
            code: 'FORBIDDEN',
            message: 'Access denied',
          );

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );
    });

    group('getById', () {
      test(
        'should return Success<MenuBundle> with the mapped bundle',
        () async {
          // Arrange
          fake.getItemResult = _bundleJson(id: 1, name: 'A', menuIds: [10, 20]);

          // Act
          final result = await repository.getById(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.id, 1);
          expect(result.valueOrNull!.menuIds, [10, 20]);
        },
      );

      test('should call getItem with the provided id', () async {
        // Arrange
        fake.getItemResult = _bundleJson(id: 7);

        // Act
        await repository.getById(7);

        // Assert
        expect(fake.lastGetItemId, 7);
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.getItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Bundle not found',
          );

          // Act
          final result = await repository.getById(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    group('findByIncludedMenu', () {
      test(
        'should return bundles whose menuIds contain the target id',
        () async {
          // Arrange
          fake.getItemsResult = [
            _bundleJson(id: 1, name: 'A', menuIds: [10, 20]),
            _bundleJson(id: 2, name: 'B', menuIds: [30]),
            _bundleJson(id: 3, name: 'C', menuIds: [10]),
          ];

          // Act
          final result = await repository.findByIncludedMenu(10);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.map((b) => b.id).toList(), [1, 3]);
        },
      );

      test(
        'should return empty list when no bundle contains the target id',
        () async {
          // Arrange
          fake.getItemsResult = [
            _bundleJson(id: 1, name: 'A', menuIds: [30]),
          ];

          // Act
          final result = await repository.findByIncludedMenu(10);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test(
        'should return empty list when all bundles have empty menuIds',
        () async {
          // Arrange
          fake.getItemsResult = [
            _bundleJson(id: 1, name: 'A', menuIds: []),
            _bundleJson(id: 2, name: 'B', menuIds: []),
          ];

          // Act
          final result = await repository.findByIncludedMenu(10);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test(
        'should propagate Failure from getAll when data source throws',
        () async {
          // Arrange
          fake.getItemsError = Exception('network error');

          // Act
          final result = await repository.findByIncludedMenu(10);

          // Assert
          expect(result.isFailure, isTrue);
        },
      );
    });

    group('create', () {
      test(
        'should return Success<MenuBundle> with the created entity',
        () async {
          // Arrange
          fake.createItemResult = _bundleJson(
            id: 99,
            name: 'NEW',
            menuIds: [1, 2],
          );

          // Act
          final result = await repository.create(
            const CreateMenuBundleInput(name: 'NEW', menuIds: [1, 2]),
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.id, 99);
          expect(result.valueOrNull!.name, 'NEW');
          expect(result.valueOrNull!.menuIds, [1, 2]);
        },
      );

      test('should call createItem exactly once', () async {
        // Arrange
        fake.createItemResult = _bundleJson();

        // Act
        await repository.create(
          const CreateMenuBundleInput(name: 'Bundle', menuIds: []),
        );

        // Assert
        expect(fake.createItemCallCount, 1);
      });

      test(
        'should return Failure<ServerError> when data source throws CREATE_FAILED',
        () async {
          // Arrange
          fake.createItemError = DirectusException(
            code: 'CREATE_FAILED',
            message: 'Failed',
          );

          // Act
          final result = await repository.create(
            const CreateMenuBundleInput(name: 'Bundle', menuIds: []),
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.createItemError = Exception('network error');

          // Act
          final result = await repository.create(
            const CreateMenuBundleInput(name: 'Bundle', menuIds: []),
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('update', () {
      test(
        'should fetch existing bundle, apply patch, and return updated entity',
        () async {
          // Arrange
          fake.getItemResult = _bundleJson(id: 1, name: 'OLD', menuIds: [1]);
          fake.updateItemResult = _bundleJson(
            id: 1,
            name: 'NEW',
            menuIds: [1, 2],
          );

          // Act
          final result = await repository.update(
            const UpdateMenuBundleInput(id: 1, name: 'NEW', menuIds: [1, 2]),
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, 'NEW');
          expect(result.valueOrNull!.menuIds, [1, 2]);
        },
      );

      test('should call getItem before updateItem', () async {
        // Arrange
        fake.getItemResult = _bundleJson(id: 1);
        fake.updateItemResult = _bundleJson(id: 1);

        // Act
        await repository.update(const UpdateMenuBundleInput(id: 1));

        // Assert
        expect(fake.lastGetItemId, 1);
        expect(fake.updateItemCallCount, 1);
      });

      test(
        'should return Failure<NotFoundError> when getItem throws NOT_FOUND',
        () async {
          // Arrange
          fake.getItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Bundle not found',
          );

          // Act
          final result = await repository.update(
            const UpdateMenuBundleInput(id: 99),
          );

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure<ServerError> when updateItem throws UPDATE_FAILED',
        () async {
          // Arrange
          fake.getItemResult = _bundleJson();
          fake.updateItemError = DirectusException(
            code: 'UPDATE_FAILED',
            message: 'Update failed',
          );

          // Act
          final result = await repository.update(
            const UpdateMenuBundleInput(id: 1),
          );

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
          final result = await repository.delete(5);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should call deleteItem with the provided id', () async {
        // Act
        await repository.delete(5);

        // Assert
        expect(fake.lastDeleteItemId, 5);
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.deleteItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Bundle not found',
          );

          // Act
          final result = await repository.delete(5);

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
          final result = await repository.delete(5);

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

class _FakeBundleDataSource implements DirectusDataSource {
  Map<String, dynamic>? getItemResult;
  Object? getItemError;
  int? lastGetItemId;
  List<String>? lastGetItemFields;

  List<Map<String, dynamic>>? getItemsResult;
  Object? getItemsError;
  int getItemsCallCount = 0;
  List<String>? lastGetItemsFields;
  List<String>? lastGetItemsSort;

  Map<String, dynamic>? createItemResult;
  Object? createItemError;
  int createItemCallCount = 0;

  Map<String, dynamic>? updateItemResult;
  Object? updateItemError;
  int updateItemCallCount = 0;

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
