import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/area_repository_impl.dart';

void main() {
  late _FakeAreaDataSource fake;
  late AreaRepositoryImpl repository;

  setUp(() {
    fake = _FakeAreaDataSource();
    repository = AreaRepositoryImpl(dataSource: fake);
  });

  group('AreaRepositoryImpl', () {
    group('getAll', () {
      test(
        'should return Success<List<Area>> with all mapped entities',
        () async {
          // Arrange
          fake.getItemsResult = [
            {'id': 1, 'name': 'Dining'},
            {'id': 2, 'name': 'Bar'},
            {'id': 3, 'name': 'Terrace'},
          ];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result, isA<Success>());
          final areas = (result as Success).value;
          expect(areas, hasLength(3));
          expect(areas[0].id, 1);
          expect(areas[0].name, 'Dining');
          expect(areas[1].id, 2);
          expect(areas[1].name, 'Bar');
          expect(areas[2].id, 3);
          expect(areas[2].name, 'Terrace');
        },
      );

      test(
        'should return empty list when data source returns no areas',
        () async {
          // Arrange
          fake.getItemsResult = [];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result, isA<Success>());
          final areas = (result as Success).value;
          expect(areas, isEmpty);
        },
      );

      test('should request id and name fields only', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        final fields = fake.lastGetItemsFields;
        expect(fields, isNotNull);
        expect(fields, contains('id'));
        expect(fields, contains('name'));
      });

      test('should sort by name', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        expect(fake.lastGetItemsSort, contains('name'));
      });

      test('should pass no filter to the data source', () async {
        // Arrange
        fake.getItemsResult = [];

        // Act
        await repository.getAll();

        // Assert
        expect(fake.lastGetItemsFilter, isNull);
      });

      test(
        'should return Failure when data source throws generic exception',
        () async {
          // Arrange
          fake.getItemsError = Exception('Network error');

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result, isA<Failure>());
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

      test(
        'should return Failure<TokenExpiredError> when data source throws TOKEN_EXPIRED',
        () async {
          // Arrange
          fake.getItemsError = DirectusException(
            code: 'TOKEN_EXPIRED',
            message: 'Expired',
          );

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<TokenExpiredError>());
        },
      );

      test(
        'should return a single area when data source returns one item',
        () async {
          // Arrange
          fake.getItemsResult = [
            {'id': 5, 'name': 'Garden'},
          ];

          // Act
          final result = await repository.getAll();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, hasLength(1));
          expect(result.valueOrNull![0].name, 'Garden');
        },
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Manual fake
// ---------------------------------------------------------------------------

class _FakeAreaDataSource implements DirectusDataSource {
  List<Map<String, dynamic>>? getItemsResult;
  Object? getItemsError;
  Map<String, dynamic>? lastGetItemsFilter;
  List<String>? lastGetItemsFields;
  List<String>? lastGetItemsSort;

  @override
  String? get currentAccessToken => null;

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    lastGetItemsFilter = filter;
    lastGetItemsFields = fields;
    lastGetItemsSort = sort;
    if (getItemsError != null) throw getItemsError!;
    if (getItemsResult != null) return getItemsResult!;
    return [];
  }

  // All other methods are not exercised by AreaRepositoryImpl —
  // they throw to make any unexpected calls immediately visible.

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async =>
      throw UnimplementedError('getItem not used by AreaRepositoryImpl');

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async =>
      throw UnimplementedError('createItem not used by AreaRepositoryImpl');

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async =>
      throw UnimplementedError('updateItem not used by AreaRepositoryImpl');

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async =>
      throw UnimplementedError('deleteItem not used by AreaRepositoryImpl');

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout() async => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getCurrentUser() async =>
      throw UnimplementedError();

  @override
  Future<void> refreshSession() async => throw UnimplementedError();

  @override
  Future<bool> tryRestoreSession() async => throw UnimplementedError();

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async => throw UnimplementedError();

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async => throw UnimplementedError();

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
