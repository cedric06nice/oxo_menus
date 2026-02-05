import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late MenuRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = MenuRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(MenuDto({
      'id': 1,
      'name': 'fallback',
      'status': 'draft',
      'version': '1.0.0',
    }));
  });

  group('MenuRepositoryImpl', () {
    group('getById', () {
      const menuId = 1;
      final menuJson = {
        'id': menuId,
        'name': 'Test Menu',
        'status': 'published',
        'version': '1.0.0',
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
        'user_created': 'user-123',
        'user_updated': 'user-456',
        'style_json': {
          'fontFamily': 'Arial',
          'fontSize': 14.0,
        },
        'area': 1, // int ID maps to 'dining' in MenuDto
        'size': {
          'id': 1,
          'name': 'A4',
          'width': 210.0,
          'height': 297.0,
        },
      };

      test('should return Menu entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem<MenuDto>(menuId, fields: any(named: 'fields')))
            .thenAnswer((_) async => menuJson);

        // Act
        final result = await repository.getById(menuId);

        // Assert
        expect(result.isSuccess, true);
        final menu = result.valueOrNull!;
        expect(menu.id, menuId);
        expect(menu.name, 'Test Menu');
        expect(menu.status, Status.published);
        expect(menu.version, '1.0.0');
        expect(menu.styleConfig, isNotNull);
        expect(menu.pageSize, isNotNull);

        verify(() => mockDataSource.getItem<MenuDto>(menuId, fields: any(named: 'fields')))
            .called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange
        when(() => mockDataSource.getItem<MenuDto>(menuId, fields: any(named: 'fields')))
            .thenThrow(DirectusException(
          code: 'NOT_FOUND',
          message: 'Menu not found',
        ));

        // Act
        final result = await repository.getById(menuId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
        expect(result.errorOrNull!.message, contains('Menu not found'));
      });

      test('should return UnknownError when network fails', () async {
        // Arrange
        when(() => mockDataSource.getItem<MenuDto>(menuId, fields: any(named: 'fields')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getById(menuId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });

    group('listAll', () {
      final menusJson = [
        {
          'id': 1,
          'name': 'Menu 1',
          'status': 'published',
          'version': '1.0.0',
        },
        {
          'id': 2,
          'name': 'Menu 2',
          'status': 'published',
          'version': '1.0.0',
        },
      ];

      test('should return list of menus when onlyPublished is true', () async {
        // Arrange
        when(() => mockDataSource.getItems<MenuDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => menusJson);

        // Act
        final result = await repository.listAll(onlyPublished: true);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);

        final captured = verify(() => mockDataSource.getItems<MenuDto>(
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify filter includes published status
        expect(captured[0], isNotNull);
        expect(captured[0]['status'], isNotNull);
      });

      test('should return all menus when onlyPublished is false', () async {
        // Arrange
        when(() => mockDataSource.getItems<MenuDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => menusJson);

        // Act
        final result = await repository.listAll(onlyPublished: false);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);

        final captured = verify(() => mockDataSource.getItems<MenuDto>(
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify no filter when onlyPublished is false
        expect(captured[0], isNull);
      });
    });

    group('create', () {
      const input = CreateMenuInput(
        name: 'New Menu',
        version: '1.0.0',
        status: Status.draft,
      );

      final createdJson = {
        'id': 2,
        'name': 'New Menu',
        'status': 'draft',
        'version': '1.0.0',
      };

      test('should create menu and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem<MenuDto>(any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.name, 'New Menu');
        expect(result.valueOrNull!.status, Status.draft);

        verify(() => mockDataSource.createItem<MenuDto>(any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem<MenuDto>(any())).thenThrow(
          DirectusException(
            code: 'RECORD_NOT_UNIQUE',
            message: 'Menu already exists',
          ),
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('update', () {
      const input = UpdateMenuInput(
        id: 1,
        name: 'Updated Menu',
        status: Status.published,
      );

      final existingJson = {
        'id': 1,
        'name': 'Original Menu',
        'status': 'draft',
        'version': '1.0.0',
      };

      final updatedJson = {
        'id': 1,
        'name': 'Updated Menu',
        'status': 'published',
        'version': '1.0.0',
      };

      test('should update menu and return entity', () async {
        // Arrange
        when(() => mockDataSource.getItem<MenuDto>(any(),
                fields: any(named: 'fields')))
            .thenAnswer((_) async => existingJson);
        when(() => mockDataSource.updateItem<MenuDto>(any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        expect(result.valueOrNull!.name, 'Updated Menu');
        expect(result.valueOrNull!.status, Status.published);

        verify(() => mockDataSource.updateItem<MenuDto>(any())).called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange - getItem throws because menu doesn't exist
        when(() => mockDataSource.getItem<MenuDto>(any(),
                fields: any(named: 'fields')))
            .thenThrow(DirectusException(
          code: 'NOT_FOUND',
          message: 'Menu not found',
        ));

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('delete', () {
      const menuId = 1;

      test('should delete menu successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem<MenuDto>(menuId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(menuId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem<MenuDto>(menuId)).called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem<MenuDto>(menuId)).thenThrow(
          DirectusException(
            code: 'NOT_FOUND',
            message: 'Menu not found',
          ),
        );

        // Act
        final result = await repository.delete(menuId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });
  });
}
