import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

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
  late MenuRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = MenuRepositoryImpl(dataSource: mockDataSource);
  });

  group('MenuRepositoryImpl', () {
    group('getById', () {
      const menuId = 'menu-1';
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
        'area': 'dining',
        'size': {
          'name': 'A4',
          'width': 210.0,
          'height': 297.0,
        },
      };

      test('should return Menu entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem('menu', menuId, fields: any(named: 'fields')))
            .thenAnswer((_) async => menuJson);

        // Act
        final result = await repository.getById(menuId);

        // Assert
        expect(result.isSuccess, true);
        final menu = result.valueOrNull!;
        expect(menu.id, menuId);
        expect(menu.name, 'Test Menu');
        expect(menu.status, MenuStatus.published);
        expect(menu.version, '1.0.0');
        expect(menu.styleConfig, isNotNull);
        expect(menu.pageSize, isNotNull);

        verify(() => mockDataSource.getItem('menu', menuId, fields: any(named: 'fields')))
            .called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange
        when(() => mockDataSource.getItem('menu', menuId, fields: any(named: 'fields')))
            .thenThrow(MockDirectusException(
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

      test('should return NetworkError when network fails', () async {
        // Arrange
        when(() => mockDataSource.getItem('menu', menuId, fields: any(named: 'fields')))
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
          'id': 'menu-1',
          'name': 'Menu 1',
          'status': 'published',
          'version': '1.0.0',
        },
        {
          'id': 'menu-2',
          'name': 'Menu 2',
          'status': 'published',
          'version': '1.0.0',
        },
      ];

      test('should return list of menus when onlyPublished is true', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'menu',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => menusJson);

        // Act
        final result = await repository.listAll(onlyPublished: true);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 'menu-1');
        expect(result.valueOrNull![1].id, 'menu-2');

        final captured = verify(() => mockDataSource.getItems(
              'menu',
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
        when(() => mockDataSource.getItems(
              'menu',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => menusJson);

        // Act
        final result = await repository.listAll(onlyPublished: false);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);

        final captured = verify(() => mockDataSource.getItems(
              'menu',
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
        status: MenuStatus.draft,
      );

      final createdJson = {
        'id': 'menu-new',
        'name': 'New Menu',
        'status': 'draft',
        'version': '1.0.0',
      };

      test('should create menu and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem('menu', any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'menu-new');
        expect(result.valueOrNull!.name, 'New Menu');
        expect(result.valueOrNull!.status, MenuStatus.draft);

        verify(() => mockDataSource.createItem('menu', any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem('menu', any())).thenThrow(
          MockDirectusException(
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
        id: 'menu-1',
        name: 'Updated Menu',
        status: MenuStatus.published,
      );

      final updatedJson = {
        'id': 'menu-1',
        'name': 'Updated Menu',
        'status': 'published',
        'version': '1.0.0',
      };

      test('should update menu and return entity', () async {
        // Arrange
        when(() => mockDataSource.updateItem('menu', 'menu-1', any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'menu-1');
        expect(result.valueOrNull!.name, 'Updated Menu');
        expect(result.valueOrNull!.status, MenuStatus.published);

        verify(() => mockDataSource.updateItem('menu', 'menu-1', any())).called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('menu', 'menu-1', any())).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Menu not found',
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
      const menuId = 'menu-1';

      test('should delete menu successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('menu', menuId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(menuId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem('menu', menuId)).called(1);
      });

      test('should return NotFoundError when menu does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('menu', menuId)).thenThrow(
          MockDirectusException(
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
