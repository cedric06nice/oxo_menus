import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late PageRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = PageRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(
      PageDto({'id': 1, 'menu': 1, 'index': 0, 'status': 'draft'}),
    );
  });

  group('PageRepositoryImpl', () {
    group('create with type', () {
      test('should pass type header to PageDto.newItem', () async {
        // Arrange
        const input = CreatePageInput(
          menuId: 1,
          name: 'Header',
          index: 0,
          type: PageType.header,
        );
        final createdJson = {
          'id': 2,
          'menu': 1,
          'index': 0,
          'type': 'header',
          'status': 'draft',
        };

        when(() => mockDataSource.createItem<PageDto>(any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.type, PageType.header);

        final captured = verify(
          () => mockDataSource.createItem<PageDto>(captureAny()),
        ).captured.single as PageDto;
        expect(captured.getValue(forKey: 'type'), 'header');
      });

      test('should include type field in getAllForMenu requests', () async {
        // Arrange
        const menuId = 1;
        final pagesJson = [
          {'id': 1, 'menu': menuId, 'index': 0, 'type': 'header', 'status': 'draft'},
          {'id': 2, 'menu': menuId, 'index': 1, 'type': 'content', 'status': 'draft'},
        ];

        when(() => mockDataSource.getItems<PageDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => pagesJson);

        // Act
        final result = await repository.getAllForMenu(menuId);

        // Assert
        expect(result.isSuccess, true);
        final pages = result.valueOrNull!;
        expect(pages[0].type, PageType.header);
        expect(pages[1].type, PageType.content);

        final captured = verify(
          () => mockDataSource.getItems<PageDto>(
            filter: any(named: 'filter'),
            fields: captureAny(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured.single as List<String>;
        expect(captured, contains('type'));
      });
    });

    group('create', () {
      const input = CreatePageInput(menuId: 1, name: 'Page 1', index: 0);

      final createdJson = {
        'id': 2,
        'menu': 1,
        'index': 0,
        'status': 'draft',
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create page and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.createItem<PageDto>(any()),
        ).thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.menuId, 1);
        // PageMapper generates name as "Page {index}"
        expect(result.valueOrNull!.name, 'Page 0');
        expect(result.valueOrNull!.index, 0);

        verify(() => mockDataSource.createItem<PageDto>(any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem<PageDto>(any())).thenThrow(
          DirectusException(
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
      const menuId = 1;
      final pagesJson = [
        {'id': 1, 'menu': menuId, 'index': 0, 'status': 'draft'},
        {'id': 2, 'menu': menuId, 'index': 1, 'status': 'draft'},
      ];

      test('should return list of pages for menu', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<PageDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => pagesJson);

        // Act
        final result = await repository.getAllForMenu(menuId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);

        final captured = verify(
          () => mockDataSource.getItems<PageDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        // Verify filter includes menu
        expect(captured[0], isNotNull);
        expect(captured[0]['menu'], isNotNull);
      });

      test('should return empty list when no pages found', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<PageDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForMenu(menuId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const pageId = 1;
      final pageJson = {
        'id': pageId,
        'menu': 1,
        'index': 0,
        'status': 'draft',
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Page entity when fetch succeeds', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            pageId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => pageJson);

        // Act
        final result = await repository.getById(pageId);

        // Assert
        expect(result.isSuccess, true);
        final page = result.valueOrNull!;
        expect(page.id, pageId);
        expect(page.menuId, 1);
        // PageMapper generates name as "Page {index}"
        expect(page.name, 'Page 0');
        expect(page.index, 0);

        verify(
          () => mockDataSource.getItem<PageDto>(
            pageId,
            fields: any(named: 'fields'),
          ),
        ).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            pageId,
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
        );

        // Act
        final result = await repository.getById(pageId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdatePageInput(id: 1, name: 'Updated Page');

      final existingJson = {'id': 1, 'menu': 1, 'index': 0, 'status': 'draft'};

      final updatedJson = {'id': 1, 'menu': 1, 'index': 0, 'status': 'draft'};

      test('should update page and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<PageDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        // PageMapper generates name as "Page {index}"
        expect(result.valueOrNull!.name, 'Page 0');

        verify(() => mockDataSource.updateItem<PageDto>(any())).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
        );

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('delete', () {
      const pageId = 1;

      test('should delete page successfully', () async {
        // Arrange
        when(
          () => mockDataSource.deleteItem<PageDto>(pageId),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(pageId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem<PageDto>(pageId)).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem<PageDto>(pageId)).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
        );

        // Act
        final result = await repository.delete(pageId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const pageId = 1;
      const newIndex = 2;

      final existingJson = {
        'id': pageId,
        'menu': 1,
        'index': 0,
        'status': 'draft',
      };

      final updatedJson = {
        'id': pageId,
        'menu': 1,
        'index': newIndex,
        'status': 'draft',
      };

      test('should update page index successfully', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<PageDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(pageId, newIndex);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateItem<PageDto>(any())).called(1);
      });

      test('should return NotFoundError when page does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<PageDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Page not found'),
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
