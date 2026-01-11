import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

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
  late WidgetRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = WidgetRepositoryImpl(dataSource: mockDataSource);
  });

  group('WidgetRepositoryImpl', () {
    group('create', () {
      const input = CreateWidgetInput(
        columnId: 'column-1',
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {'name': 'Pasta', 'price': 12.50},
      );

      final createdJson = {
        'id': 'widget-new',
        'column_id': 'column-1',
        'type': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props': {'name': 'Pasta', 'price': 12.50},
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create widget and return entity', () async {
        // Arrange
        when(() => mockDataSource.createItem('widget', any()))
            .thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'widget-new');
        expect(result.valueOrNull!.columnId, 'column-1');
        expect(result.valueOrNull!.type, 'dish');
        expect(result.valueOrNull!.version, '1.0.0');
        expect(result.valueOrNull!.index, 0);
        expect(result.valueOrNull!.props['name'], 'Pasta');

        verify(() => mockDataSource.createItem('widget', any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem('widget', any())).thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Column not found',
          ),
        );

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('getAllForColumn', () {
      const columnId = 'column-1';
      final widgetsJson = [
        {
          'id': 'widget-1',
          'column_id': columnId,
          'type': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props': {'name': 'Pasta'},
        },
        {
          'id': 'widget-2',
          'column_id': columnId,
          'type': 'dish',
          'version': '1.0.0',
          'index': 1,
          'props': {'name': 'Pizza'},
        },
      ];

      test('should return list of widgets for column', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'widget',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => widgetsJson);

        // Act
        final result = await repository.getAllForColumn(columnId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 'widget-1');
        expect(result.valueOrNull![1].id, 'widget-2');

        final captured = verify(() => mockDataSource.getItems(
              'widget',
              filter: captureAny(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).captured;

        // Verify filter includes column_id
        expect(captured[0], isNotNull);
        expect(captured[0]['column_id'], isNotNull);
      });

      test('should return empty list when no widgets found', () async {
        // Arrange
        when(() => mockDataSource.getItems(
              'widget',
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForColumn(columnId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const widgetId = 'widget-1';
      final widgetJson = {
        'id': widgetId,
        'column_id': 'column-1',
        'type': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props': {
          'name': 'Pasta Carbonara',
          'price': 12.50,
          'allergens': ['gluten', 'dairy']
        },
        'style_json': {
          'fontSize': 14.0,
          'color': '#000000',
        },
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return WidgetInstance entity when fetch succeeds', () async {
        // Arrange
        when(() => mockDataSource.getItem('widget', widgetId,
                fields: any(named: 'fields')))
            .thenAnswer((_) async => widgetJson);

        // Act
        final result = await repository.getById(widgetId);

        // Assert
        expect(result.isSuccess, true);
        final widget = result.valueOrNull!;
        expect(widget.id, widgetId);
        expect(widget.columnId, 'column-1');
        expect(widget.type, 'dish');
        expect(widget.version, '1.0.0');
        expect(widget.index, 0);
        expect(widget.props['name'], 'Pasta Carbonara');
        expect(widget.style, isNotNull);

        verify(() => mockDataSource.getItem('widget', widgetId,
            fields: any(named: 'fields'))).called(1);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(() => mockDataSource.getItem('widget', widgetId,
                fields: any(named: 'fields')))
            .thenThrow(MockDirectusException(
          code: 'NOT_FOUND',
          message: 'Widget not found',
        ));

        // Act
        final result = await repository.getById(widgetId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdateWidgetInput(
        id: 'widget-1',
        props: {'name': 'Updated Pasta', 'price': 14.00},
      );

      final updatedJson = {
        'id': 'widget-1',
        'column_id': 'column-1',
        'type': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props': {'name': 'Updated Pasta', 'price': 14.00},
      };

      test('should update widget and return entity', () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', 'widget-1', any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 'widget-1');
        expect(result.valueOrNull!.props['name'], 'Updated Pasta');

        verify(() => mockDataSource.updateItem('widget', 'widget-1', any()))
            .called(1);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', 'widget-1', any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Widget not found',
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
      const widgetId = 'widget-1';

      test('should delete widget successfully', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('widget', widgetId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(widgetId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem('widget', widgetId)).called(1);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem('widget', widgetId)).thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Widget not found',
          ),
        );

        // Act
        final result = await repository.delete(widgetId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const widgetId = 'widget-1';
      const newIndex = 2;

      final updatedJson = {
        'id': widgetId,
        'column_id': 'column-1',
        'type': 'dish',
        'version': '1.0.0',
        'index': newIndex,
        'props': {'name': 'Pasta'},
      };

      test('should update widget index successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', widgetId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(widgetId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
                () => mockDataSource.updateItem('widget', widgetId, captureAny()))
            .captured;

        expect(captured[0]['index'], newIndex);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', widgetId, any()))
            .thenThrow(
          MockDirectusException(
            code: 'NOT_FOUND',
            message: 'Widget not found',
          ),
        );

        // Act
        final result = await repository.reorder(widgetId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('moveTo', () {
      const widgetId = 'widget-1';
      const newColumnId = 'column-2';
      const newIndex = 1;

      final updatedJson = {
        'id': widgetId,
        'column_id': newColumnId,
        'type': 'dish',
        'version': '1.0.0',
        'index': newIndex,
        'props': {'name': 'Pasta'},
      };

      test('should move widget to new column successfully', () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', widgetId, any()))
            .thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.moveTo(widgetId, newColumnId, newIndex);

        // Assert
        expect(result.isSuccess, true);

        final captured = verify(
                () => mockDataSource.updateItem('widget', widgetId, captureAny()))
            .captured;

        expect(captured[0]['column_id'], newColumnId);
        expect(captured[0]['index'], newIndex);
      });

      test('should return ValidationError when new column does not exist',
          () async {
        // Arrange
        when(() => mockDataSource.updateItem('widget', widgetId, any()))
            .thenThrow(
          MockDirectusException(
            code: 'INVALID_FOREIGN_KEY',
            message: 'Column not found',
          ),
        );

        // Act
        final result = await repository.moveTo(widgetId, newColumnId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });
  });
}
