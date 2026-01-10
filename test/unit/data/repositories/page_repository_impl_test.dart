import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

// Mock exception classes
class MockDirectusException implements Exception {
  final String code;
  final String message;

  MockDirectusException({required this.code, required this.message});

  @override
  String toString() => 'DirectusException: $code - $message';
}

void main() {
  late PageRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = PageRepositoryImpl(dataSource: mockDataSource);
  });

  group('PageRepositoryImpl', () {
    group('create', () {
      const input = CreatePageInput(
        menuId: 'menu-1',
        name: 'Page 1',
        index: 0,
      );

      final createdJson = {
        'id': 'page-new',
        'menu_id': 'menu-1',
        'name': 'Page 1',
        'index': 0,
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create page and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem('page', any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'page-new');
        expect(result.valueOrNull!.menuId, 'menu-1');
        expect(result.valueOrNull!.name, 'Page 1');
        expect(result.valueOrNull!.index, 0);

        verify(() => mockDataSource.createItem('page', any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem('page', any())).thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Menu not found',
          ),
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('getAllForMenu', () {
      const menuId = 'menu-1';
      final pagesJson = [
        {
          'id': 'page-1',
          'menu_id': menuId,
          'name': 'Page 1',
          'index': 0,
        },
        {
          'id': 'page-2',
          'menu_id': menuId,
          'name': 'Page 2',
          'index': 1,
        },
      ];

      test('should return list of pages for menu', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'page',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => pagesJson);

        // Act
        final result = await repository.getAllForMenu(menuId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 'page-1');
        expect(result.valueOrNull![1].id, 'page-2');

        final captured = verify(() => mockDataSource.getItems(
              'page',
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify filter includes menu_id
        expect(captured[0], isNotNull);
        expect(captured[0]['menu_id'], isNotNull);
      });

      test('should return empty list when no pages found', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'page',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForMenu(menuId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const pageId = 'page-1';
      final pageJson = {
        'id': pageId,
        'menu_id': 'menu-1',
        'name': 'Page 1',
        'index': 0,
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Page entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem('page', pageId, fields: any(named: 'fields')))
            .thenAnswer((_) async => pageJson);

        // Act
        final result = await repository.getById(pageId);

        // Assert
        expect(result.isSuccess, true);
        final page = result.valueOrNull!;
        expect(page.id, pageId);
        expect(page.menuId, 'menu-1');
        expect(page.name, 'Page 1');
        expect(page.index, 0);

        verify(() => mockDataSource.getItem('page', pageId, fields: any(named: 'fields')))
            .called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(() => mockDataSource.getItem('page', pageId, fields: any(named: 'fields')))
            .thenThrow(MockDirectusException(
          code: 'NOT_FOUND',
          message: 'Page not found',
        ));

        // Act
        final result = await repository.getById(pageId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdatePageInput(
        id: 'page-1',
        name: 'Updated Page',
      );

      final updatedJson = {
        'id': 'page-1',
        'menu_id': 'menu-1',
        'name': 'Updated Page',
        'index': 0,
      };

      test('should update page and return entity', () async {
        // Arrange
        when(() => mockDataSource.updateItem('page', 'page-1', any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'page-1');
        expect(result.valueOrNull!.name, 'Updated Page');

        verify(() => mockDataSource.updateItem('page', 'page-1', any())).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('page', 'page-1', any())).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('delete', () {
      const pageId = 'page-1';

      test('should delete page successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('page', pageId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(pageId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem('page', pageId)).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('page', pageId)).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.delete(pageId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const pageId = 'page-1';
      const newIndex = 2;

      final updatedJson = {
        'id': pageId,
        'menu_id': 'menu-1',
        'name': 'Page 1',
        'index': newIndex,
      };

      test('should update page index successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('page', pageId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(pageId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(() => mockDataSource.updateItem('page', pageId, captureAny()))
            .captured;

        expect(captured[0]['index'], newIndex);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('page', pageId, any())).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.reorder(pageId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });
  });
}
