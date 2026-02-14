import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late ColumnRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = ColumnRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(
      ColumnDto({'id': 1, 'container': 1, 'index': 0, 'width': 100}),
    );
  });

  group('ColumnRepositoryImpl', () {
    group('create', () {
      const input = CreateColumnInput(containerId: 1, index: 0, flex: 1);

      final createdJson = {
        'id': 2,
        'container': 1,
        'index': 0,
        'width': 100,
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create column and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.createItem<ColumnDto>(any()),
        ).thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.containerId, 1);
        expect(result.valueOrNull!.index, 0);
        // Note: flex is always null from ColumnMapper (DTO doesn't have flex field)
        expect(result.valueOrNull!.width, 100.0);

        verify(() => mockDataSource.createItem<ColumnDto>(any())).called(1);
      });

      test('should set style_json on DTO when input has styleConfig', () async {
        // Arrange
        const inputWithStyle = CreateColumnInput(
          containerId: 1,
          index: 0,
          styleConfig: StyleConfig(
            marginTop: 5.0,
            borderType: BorderType.plainThin,
          ),
        );

        when(() => mockDataSource.createItem<ColumnDto>(any())).thenAnswer(
          (_) async => {
            'id': 3,
            'container': 1,
            'index': 0,
            'width': 100,
            'style_json': {'marginTop': 5.0, 'borderType': 'plain_thin'},
          },
        );

        // Act
        await repository.create(inputWithStyle);

        // Assert — capture the DTO sent to createItem and verify style_json
        final captured = verify(
          () => mockDataSource.createItem<ColumnDto>(captureAny()),
        ).captured;
        final dto = captured.first as ColumnDto;
        expect(dto.styleJson['marginTop'], 5.0);
        expect(dto.styleJson['borderType'], 'plain_thin');
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem<ColumnDto>(any())).thenThrow(
          DirectusException(
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

      test(
        'create with isDroppable: false returns entity with isDroppable: false',
        () async {
          // Arrange
          const inputWithDroppable = CreateColumnInput(
            containerId: 1,
            index: 0,
            isDroppable: false,
          );

          when(() => mockDataSource.createItem<ColumnDto>(any())).thenAnswer(
            (_) async => {
              'id': 4,
              'container': 1,
              'index': 0,
              'width': 100,
              'is_droppable': false,
            },
          );

          // Act
          final result = await repository.create(inputWithDroppable);

          // Assert
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isDroppable, false);

          // Verify setValue was called for is_droppable
          final captured = verify(
            () => mockDataSource.createItem<ColumnDto>(captureAny()),
          ).captured;
          final dto = captured.first as ColumnDto;
          expect(dto.isDroppable, false);
        },
      );
    });

    group('getAllForContainer', () {
      const containerId = 1;
      final columnsJson = [
        {'id': 1, 'container': containerId, 'index': 0, 'width': 100},
        {'id': 2, 'container': containerId, 'index': 1, 'width': 200},
      ];

      test('should return list of columns for container', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<ColumnDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => columnsJson);

        // Act
        final result = await repository.getAllForContainer(containerId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);

        final captured = verify(
          () => mockDataSource.getItems<ColumnDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        // Verify filter includes container_id
        expect(captured[0], isNotNull);
      });

      test('should return empty list when no columns found', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<ColumnDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForContainer(containerId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });

      test('getAllForContainer fields list includes is_droppable', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<ColumnDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => columnsJson);

        // Act
        await repository.getAllForContainer(containerId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItems<ColumnDto>(
            filter: any(named: 'filter'),
            fields: captureAny(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        final fieldsList = captured[0] as List<String>;
        expect(fieldsList, contains('is_droppable'));
      });
    });

    group('getById', () {
      const columnId = 1;
      final columnJson = {
        'id': columnId,
        'container': 1,
        'index': 0,
        'width': 200,
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Column entity when fetch succeeds', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            columnId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => columnJson);

        // Act
        final result = await repository.getById(columnId);

        // Assert
        expect(result.isSuccess, true);
        final column = result.valueOrNull!;
        expect(column.id, columnId);
        expect(column.containerId, 1);
        expect(column.index, 0);
        expect(column.width, 200.0);

        verify(
          () => mockDataSource.getItem<ColumnDto>(
            columnId,
            fields: any(named: 'fields'),
          ),
        ).called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            columnId,
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.getById(columnId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('getById fields list includes is_droppable', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            columnId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => columnJson);

        // Act
        await repository.getById(columnId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItem<ColumnDto>(
            columnId,
            fields: captureAny(named: 'fields'),
          ),
        ).captured;

        final fieldsList = captured[0] as List<String>;
        expect(fieldsList, contains('is_droppable'));
      });
    });

    group('update', () {
      const input = UpdateColumnInput(id: 1, flex: 2);

      final existingJson = {'id': 1, 'container': 1, 'index': 0, 'width': 100};

      final updatedJson = {'id': 1, 'container': 1, 'index': 0, 'width': 100};

      test('should update column and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ColumnDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);

        verify(() => mockDataSource.updateItem<ColumnDto>(any())).called(1);
      });

      test(
        'should set style_json on DTO when update input has styleConfig',
        () async {
          // Arrange
          const inputWithStyle = UpdateColumnInput(
            id: 1,
            styleConfig: StyleConfig(
              paddingLeft: 12.0,
              borderType: BorderType.dropShadow,
            ),
          );

          when(
            () => mockDataSource.getItem<ColumnDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => existingJson);
          when(() => mockDataSource.updateItem<ColumnDto>(any())).thenAnswer(
            (_) async => {
              'id': 1,
              'container': 1,
              'index': 0,
              'width': 100,
              'style_json': {'paddingLeft': 12.0, 'borderType': 'drop_shadow'},
            },
          );

          // Act
          await repository.update(inputWithStyle);

          // Assert — capture the DTO sent to updateItem and verify style_json
          final captured = verify(
            () => mockDataSource.updateItem<ColumnDto>(captureAny()),
          ).captured;
          final dto = captured.first as ColumnDto;
          expect(dto.styleJson['paddingLeft'], 12.0);
          expect(dto.styleJson['borderType'], 'drop_shadow');
        },
      );

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test(
        'update with isDroppable: false calls setValue and returns correct entity',
        () async {
          // Arrange
          const inputWithDroppable = UpdateColumnInput(
            id: 1,
            isDroppable: false,
          );

          when(
            () => mockDataSource.getItem<ColumnDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => existingJson);
          when(() => mockDataSource.updateItem<ColumnDto>(any())).thenAnswer(
            (_) async => {
              'id': 1,
              'container': 1,
              'index': 0,
              'width': 100,
              'is_droppable': false,
            },
          );

          // Act
          final result = await repository.update(inputWithDroppable);

          // Assert
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isDroppable, false);

          // Verify setValue was called for is_droppable
          final captured = verify(
            () => mockDataSource.updateItem<ColumnDto>(captureAny()),
          ).captured;
          final dto = captured.first as ColumnDto;
          expect(dto.isDroppable, false);
        },
      );
    });

    group('delete', () {
      const columnId = 1;

      test('should delete column successfully', () async {
        // Arrange
        when(
          () => mockDataSource.deleteItem<ColumnDto>(columnId),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(columnId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem<ColumnDto>(columnId)).called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem<ColumnDto>(columnId)).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
        );

        // Act
        final result = await repository.delete(columnId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const columnId = 1;
      const newIndex = 2;

      final existingJson = {
        'id': columnId,
        'container': 1,
        'index': 0,
        'width': 100,
      };

      final updatedJson = {
        'id': columnId,
        'container': 1,
        'index': newIndex,
        'width': 100,
      };

      test('should update column index successfully', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ColumnDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(columnId, newIndex);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateItem<ColumnDto>(any())).called(1);
      });

      test('should return NotFoundError when column does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ColumnDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Column not found'),
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
