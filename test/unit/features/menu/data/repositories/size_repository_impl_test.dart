import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';

// ---------------------------------------------------------------------------
// JSON fixture builder
// ---------------------------------------------------------------------------

Map<String, dynamic> _sizeJson({
  int id = 1,
  String name = 'A4',
  double width = 210.0,
  double height = 297.0,
  String status = 'published',
  String direction = 'portrait',
}) => {
  'id': id,
  'name': name,
  'width': width,
  'height': height,
  'status': status,
  'direction': direction,
};

void main() {
  late _FakeSizeDataSource fake;
  late SizeRepositoryImpl repository;

  setUp(() {
    fake = _FakeSizeDataSource();
    repository = SizeRepositoryImpl(dataSource: fake);
  });

  group('SizeRepositoryImpl', () {
    group('getAll', () {
      test(
        'should return Success<List<Size>> with all mapped entities',
        () async {
          // Arrange
          fake.getItemsResult = [
            _sizeJson(id: 1, name: 'A4'),
            _sizeJson(
              id: 2,
              name: 'Letter',
              width: 215.9,
              height: 279.4,
              status: 'draft',
              direction: 'landscape',
            ),
          ];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, hasLength(2));
          expect(result.valueOrNull![0].name, 'A4');
          expect(result.valueOrNull![1].name, 'Letter');
        },
      );

      test(
        'should return empty list when data source returns no sizes',
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

      test('should request all required fields', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        final fields = fake.lastGetItemsFields;
        expect(
          fields,
          containsAll(['id', 'name', 'width', 'height', 'status', 'direction']),
        );
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
          fake.getItemsError = Exception('Connection failed');

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
      test('should return Success<Size> with the mapped entity', () async {
        // Arrange
        fake.getItemResult = _sizeJson(id: 1, name: 'A4');

        // Act
        final result = await repository.getById(1);

        // Assert
        expect(result.isSuccess, isTrue);
        final size = result.valueOrNull!;
        expect(size.id, 1);
        expect(size.name, 'A4');
        expect(size.width, 210.0);
        expect(size.height, 297.0);
      });

      test('should request all required fields', () async {
        // Arrange
        fake.getItemResult = _sizeJson();

        // Act
        await repository.getById(1);

        // Assert
        final fields = fake.lastGetItemFields;
        expect(
          fields,
          containsAll(['id', 'name', 'width', 'height', 'status', 'direction']),
        );
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.getItemError = DirectusException(
            code: 'NOT_FOUND',
            message: 'Size not found',
          );

          // Act
          final result = await repository.getById(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          fake.getItemError = Exception('Not found');

          // Act
          final result = await repository.getById(99);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<DomainError>());
        },
      );
    });

    group('create', () {
      const input = CreateSizeInput(
        name: 'A5',
        width: 148.0,
        height: 210.0,
        status: Status.draft,
        direction: 'portrait',
      );

      test('should return Success<Size> with the created entity', () async {
        // Arrange
        fake.createItemResult = _sizeJson(
          id: 3,
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: 'draft',
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, isTrue);
        final size = result.valueOrNull!;
        expect(size.id, 3);
        expect(size.name, 'A5');
        expect(size.width, 148.0);
        expect(size.height, 210.0);
        expect(size.status, Status.draft);
        expect(size.direction, 'portrait');
      });

      test('should call createItem exactly once', () async {
        // Arrange
        fake.createItemResult = _sizeJson(id: 3);

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
            message: 'Size already exists',
          );

          // Act
          final result = await repository.create(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws generic exception',
        () async {
          // Arrange
          fake.createItemError = Exception('Create failed');

          // Act
          final result = await repository.create(input);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('update', () {
      const input = UpdateSizeInput(
        id: 1,
        name: 'A4 Updated',
        status: Status.published,
      );

      test(
        'should fetch existing size, apply patch, and return updated entity',
        () async {
          // Arrange
          fake.getItemResult = _sizeJson(name: 'A4', status: 'draft');
          fake.updateItemResult = _sizeJson(
            name: 'A4 Updated',
            status: 'published',
          );

          // Act
          final result = await repository.update(input);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, 'A4 Updated');
          expect(result.valueOrNull!.status, Status.published);
        },
      );

      test('should call getItem then updateItem in sequence', () async {
        // Arrange
        fake.getItemResult = _sizeJson();
        fake.updateItemResult = _sizeJson();

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
            message: 'Size not found',
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
          fake.getItemResult = _sizeJson();
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
            message: 'Size not found',
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
          fake.deleteItemError = Exception('Delete failed');

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

class _FakeSizeDataSource implements DirectusDataSource {
  Map<String, dynamic>? getItemResult;
  Object? getItemError;
  int? lastGetItemId;
  List<String>? lastGetItemFields;

  List<Map<String, dynamic>>? getItemsResult;
  Object? getItemsError;
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
