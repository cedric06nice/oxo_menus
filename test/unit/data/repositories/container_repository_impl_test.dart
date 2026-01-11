import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

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
  late ContainerRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = ContainerRepositoryImpl(dataSource: mockDataSource);
  });

  group('ContainerRepositoryImpl', () {
    group('create', () {
      const input = CreateContainerInput(
        pageId: 'page-1',
        index: 0,
        name: 'Header Section',
      );

      final createdJson = {
        'id': 'container-new',
        'page_id': 'page-1',
        'index': 0,
        'name': 'Header Section',
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create container and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem('container', any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'container-new');
        expect(result.valueOrNull!.pageId, 'page-1');
        expect(result.valueOrNull!.name, 'Header Section');
        expect(result.valueOrNull!.index, 0);

        verify(() => mockDataSource.createItem('container', any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem('container', any())).thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('getAllForPage', () {
      const pageId = 'page-1';
      final containersJson = [
        {
          'id': 'container-1',
          'page_id': pageId,
          'name': 'Header',
          'index': 0,
        },
        {
          'id': 'container-2',
          'page_id': pageId,
          'name': 'Body',
          'index': 1,
        },
      ];

      test('should return list of containers for page', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'container',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => containersJson);

        // Act
        final result = await repository.getAllForPage(pageId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 'container-1');
        expect(result.valueOrNull![1].id, 'container-2');

        final captured = verify(() => mockDataSource.getItems(
              'container',
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify filter includes page_id
        expect(captured[0], isNotNull);
        expect(captured[0]['page_id'], isNotNull);
      });

      test('should return empty list when no containers found', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'container',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForPage(pageId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const containerId = 'container-1';
      final containerJson = {
        'id': containerId,
        'page_id': 'page-1',
        'name': 'Header',
        'index': 0,
        'layout_json': {
          'direction': 'row',
          'alignment': 'center',
        },
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Container entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem('container', containerId,
                fields: any(named: 'fields')))
            .thenAnswer((_) async => containerJson);

        // Act
        final result = await repository.getById(containerId);

        // Assert
        expect(result.isSuccess, true);
        final container = result.valueOrNull!;
        expect(container.id, containerId);
        expect(container.pageId, 'page-1');
        expect(container.name, 'Header');
        expect(container.index, 0);
        expect(container.layout, isNotNull);

        verify(() => mockDataSource.getItem('container', containerId,
            fields: any(named: 'fields'))).called(1);
      });

      test('should return NotFoundError when container does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.getItem('container', containerId,
                fields: any(named: 'fields')))
            .thenThrow(MockDirectusException(
          code: 'NOT_FOUND',
          message: 'Container not found',
        ));

        // Act
        final result = await repository.getById(containerId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdateContainerInput(
        id: 'container-1',
        name: 'Updated Header',
      );

      final updatedJson = {
        'id': 'container-1',
        'page_id': 'page-1',
        'name': 'Updated Header',
        'index': 0,
      };

      test('should update container and return entity', () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', 'container-1', any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'container-1');
        expect(result.valueOrNull!.name, 'Updated Header');

        verify(() => mockDataSource.updateItem('container', 'container-1', any()))
            .called(1);
      });

      test('should return NotFoundError when container does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', 'container-1', any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Container not found',
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
      const containerId = 'container-1';

      test('should delete container successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('container', containerId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(containerId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem('container', containerId))
            .called(1);
      });

      test('should return NotFoundError when container does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.deleteItem('container', containerId))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Container not found',
          ),
        );

        // Act
        final result = await repository.delete(containerId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const containerId = 'container-1';
      const newIndex = 2;

      final updatedJson = {
        'id': containerId,
        'page_id': 'page-1',
        'name': 'Header',
        'index': newIndex,
      };

      test('should update container index successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', containerId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(containerId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
                () => mockDataSource.updateItem('container', containerId, captureAny()))
            .captured;

        expect(captured[0]['index'], newIndex);
      });

      test('should return NotFoundError when container does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', containerId, any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Container not found',
          ),
        );

        // Act
        final result = await repository.reorder(containerId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('moveTo', () {
      const containerId = 'container-1';
      const newPageId = 'page-2';
      const newIndex = 1;

      final updatedJson = {
        'id': containerId,
        'page_id': newPageId,
        'name': 'Header',
        'index': newIndex,
      };

      test('should move container to new page successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', containerId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.moveTo(containerId, newPageId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
                () => mockDataSource.updateItem('container', containerId, captureAny()))
            .captured;

        expect(captured[0]['page_id'], newPageId);
        expect(captured[0]['index'], newIndex);
      });

      test('should return ValidationError when new page does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.updateItem('container', containerId, any()))
            .thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Page not found',
          ),
        );

        // Act
        final result = await repository.moveTo(containerId, newPageId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });
  });
}
