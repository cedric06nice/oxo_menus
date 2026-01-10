import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';

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
  late ColumnRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = ColumnRepositoryImpl(dataSource: mockDataSource);
  });

  group('ColumnRepositoryImpl', () {
    group('create', () {
      const input = CreateColumnInput(
        containerId: 'container-1',
        index: 0,
        flex: 1,
      );

      final createdJson = {
        'id': 'column-new',
        'container_id': 'container-1',
        'index': 0,
        'flex': 1,
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create column and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem('column', any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'column-new');
        expect(result.valueOrNull!.containerId, 'container-1');
        expect(result.valueOrNull!.index, 0);
        expect(result.valueOrNull!.flex, 1);

        verify(() => mockDataSource.createItem('column', any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem('column', any())).thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Container not found',
          ),
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('getAllForContainer', () {
      const containerId = 'container-1';
      final columnsJson = [
        {
          'id': 'column-1',
          'container_id': containerId,
          'index': 0,
          'flex': 1,
        },
        {
          'id': 'column-2',
          'container_id': containerId,
          'index': 1,
          'flex': 2,
        },
      ];

      test('should return list of columns for container', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'column',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => columnsJson);

        // Act
        final result = await repository.getAllForContainer(containerId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 'column-1');
        expect(result.valueOrNull![1].id, 'column-2');

        final captured = verify(() => mockDataSource.getItems(
              'column',
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify filter includes container_id
        expect(captured[0], isNotNull);
        expect(captured[0]['container_id'], isNotNull);
      });

      test('should return empty list when no columns found', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'column',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForContainer(containerId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const columnId = 'column-1';
      final columnJson = {
        'id': columnId,
        'container_id': 'container-1',
        'index': 0,
        'flex': 1,
        'width': 200.0,
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Column entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem('column', columnId,
                fields: any(named: 'fields')))
            .thenAnswer((_) async => columnJson);

        // Act
        final result = await repository.getById(columnId);

        // Assert
        expect(result.isSuccess, true);
        final column = result.valueOrNull!;
        expect(column.id, columnId);
        expect(column.containerId, 'container-1');
        expect(column.index, 0);
        expect(column.flex, 1);
        expect(column.width, 200.0);

        verify(() => mockDataSource.getItem('column', columnId,
            fields: any(named: 'fields'))).called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(() => mockDataSource.getItem('column', columnId,
                fields: any(named: 'fields')))
            .thenThrow(MockDirectusException(
          code: 'NOT_FOUND',
          message: 'Column not found',
        ));

        // Act
        final result = await repository.getById(columnId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdateColumnInput(
        id: 'column-1',
        flex: 2,
      );

      final updatedJson = {
        'id': 'column-1',
        'container_id': 'container-1',
        'index': 0,
        'flex': 2,
      };

      test('should update column and return entity', () async {
        // Arrange
        when(() => mockDataSource.updateItem('column', 'column-1', any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'column-1');
        expect(result.valueOrNull!.flex, 2);

        verify(() => mockDataSource.updateItem('column', 'column-1', any()))
            .called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('column', 'column-1', any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Column not found',
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
      const columnId = 'column-1';

      test('should delete column successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('column', columnId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(columnId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem('column', columnId)).called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('column', columnId)).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Column not found',
          ),
        );

        // Act
        final result = await repository.delete(columnId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const columnId = 'column-1';
      const newIndex = 2;

      final updatedJson = {
        'id': columnId,
        'container_id': 'container-1',
        'index': newIndex,
        'flex': 1,
      };

      test('should update column index successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('column', columnId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(columnId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
                () => mockDataSource.updateItem('column', columnId, captureAny()))
            .captured;

        expect(captured[0]['index'], newIndex);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('column', columnId, any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Column not found',
          ),
        );

        // Act
        final result = await repository.reorder(columnId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });
  });
}
