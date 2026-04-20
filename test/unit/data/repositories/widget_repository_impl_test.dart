import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late WidgetRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = WidgetRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(
      WidgetDto({
        'id': 1,
        'column': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      }),
    );
  });

  group('WidgetRepositoryImpl', () {
    group('create', () {
      const input = CreateWidgetInput(
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {'name': 'Pasta', 'price': 12.50},
      );

      final createdJson = {
        'id': 1,
        'column': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {'name': 'Pasta', 'price': 12.50},
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create widget and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.createItem<WidgetDto>(any()),
        ).thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        expect(result.valueOrNull!.columnId, 1);
        expect(result.valueOrNull!.type, 'dish');
        expect(result.valueOrNull!.version, '1.0.0');
        expect(result.valueOrNull!.index, 0);
        expect(result.valueOrNull!.props['name'], 'Pasta');

        verify(() => mockDataSource.createItem<WidgetDto>(any())).called(1);
      });

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem<WidgetDto>(any())).thenThrow(
          DirectusException(
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

      test('should send locked_for_edition from input', () async {
        // Arrange
        const lockedInput = CreateWidgetInput(
          columnId: 1,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {'name': 'Pasta'},
          lockedForEdition: true,
        );
        when(
          () => mockDataSource.createItem<WidgetDto>(any()),
        ).thenAnswer((_) async => createdJson);

        // Act
        await repository.create(lockedInput);

        // Assert
        final captured = verify(
          () => mockDataSource.createItem<WidgetDto>(captureAny()),
        ).captured;
        final dto = captured.single as WidgetDto;
        expect(dto.getValue(forKey: 'locked_for_edition'), true);
      });
    });

    group('getAllForColumn', () {
      const columnId = 1;
      final widgetsJson = [
        {
          'id': 1,
          'column': columnId,
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': {'name': 'Pasta'},
        },
        {
          'id': 2,
          'column': columnId,
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 1,
          'props_json': {'name': 'Pizza'},
        },
      ];

      test('should return list of widgets for column', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => widgetsJson);

        // Act
        final result = await repository.getAllForColumn(columnId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);

        final captured = verify(
          () => mockDataSource.getItems<WidgetDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        // Verify filter includes column_id
        expect(captured[0], isNotNull);
      });

      test('should request editing_by and editing_since fields', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => widgetsJson);

        // Act
        await repository.getAllForColumn(columnId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: captureAny(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        final fields = captured[0] as List<String>;
        expect(fields, contains('editing_by'));
        expect(fields, contains('editing_since'));
      });

      test('should request locked_for_edition field', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => widgetsJson);

        // Act
        await repository.getAllForColumn(columnId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: captureAny(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        final fields = captured[0] as List<String>;
        expect(fields, contains('locked_for_edition'));
      });

      test('should return empty list when no widgets found', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForColumn(columnId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getById', () {
      const widgetId = 1;
      final widgetJson = {
        'id': widgetId,
        'column': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {
          'name': 'Pasta Carbonara',
          'price': 12.50,
          'allergens': ['gluten', 'dairy'],
        },
        'style_json': {'fontSize': 14.0, 'color': '#000000'},
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return WidgetInstance entity when fetch succeeds', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => widgetJson);

        // Act
        final result = await repository.getById(widgetId);

        // Assert
        expect(result.isSuccess, true);
        final widget = result.valueOrNull!;
        expect(widget.id, widgetId);
        expect(widget.columnId, 1);
        expect(widget.type, 'dish');
        expect(widget.version, '1.0.0');
        expect(widget.index, 0);
        expect(widget.props['name'], 'Pasta Carbonara');
        expect(widget.style, isNotNull);

        verify(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: any(named: 'fields'),
          ),
        ).called(1);
      });

      test('should request editing_by and editing_since fields', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => widgetJson);

        // Act
        await repository.getById(widgetId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: captureAny(named: 'fields'),
          ),
        ).captured;

        final fields = captured[0] as List<String>;
        expect(fields, contains('editing_by'));
        expect(fields, contains('editing_since'));
      });

      test('should request locked_for_edition field', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => widgetJson);

        // Act
        await repository.getById(widgetId);

        // Assert
        final captured = verify(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: captureAny(named: 'fields'),
          ),
        ).captured;

        final fields = captured[0] as List<String>;
        expect(fields, contains('locked_for_edition'));
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            widgetId,
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.getById(widgetId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('update', () {
      const input = UpdateWidgetInput(
        id: 1,
        props: {'name': 'Updated Pasta', 'price': 14.00},
      );

      final existingJson = {
        'id': 1,
        'column': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {'name': 'Pasta', 'price': 12.50},
      };

      final updatedJson = {
        'id': 1,
        'column': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {'name': 'Updated Pasta', 'price': 14.00},
      };

      test('should update widget and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        expect(result.valueOrNull!.props['name'], 'Updated Pasta');

        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(1);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange - getItem throws because widget doesn't exist
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('should send locked_for_edition when provided', () async {
        // Arrange
        const lockedInput = UpdateWidgetInput(id: 1, lockedForEdition: true);
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        await repository.update(lockedInput);

        // Assert
        final captured = verify(
          () => mockDataSource.updateItem<WidgetDto>(captureAny()),
        ).captured;
        final dto = captured.single as WidgetDto;
        expect(dto.getValue(forKey: 'locked_for_edition'), true);
      });

      test('should not touch locked_for_edition when not provided', () async {
        // Arrange - props-only update, no lock change
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        await repository.update(input);

        // Assert
        final captured = verify(
          () => mockDataSource.updateItem<WidgetDto>(captureAny()),
        ).captured;
        final dto = captured.single as WidgetDto;
        // existingJson has no locked_for_edition field, so it should
        // remain absent (or unchanged) after the update.
        expect(dto.getValue(forKey: 'locked_for_edition'), isNull);
      });
    });

    group('delete', () {
      const widgetId = 1;

      test('should delete widget successfully', () async {
        // Arrange
        when(
          () => mockDataSource.deleteItem<WidgetDto>(widgetId),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(widgetId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem<WidgetDto>(widgetId)).called(1);
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(() => mockDataSource.deleteItem<WidgetDto>(widgetId)).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.delete(widgetId);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('reorder', () {
      const widgetId = 1;
      const columnId = 1;
      const newIndex = 2;

      final existingJson = {
        'id': widgetId,
        'column': columnId,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {'name': 'Pasta'},
      };

      final updatedJson = {
        'id': widgetId,
        'column': columnId,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': newIndex,
        'props_json': {'name': 'Pasta'},
      };

      // Other widgets in the same column
      final allWidgetsInColumn = [
        {'id': widgetId, 'index': 0},
        {'id': 2, 'index': 1},
        {'id': 3, 'index': 2},
      ];

      test('should update widget index and shift other widgets', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => allWidgetsInColumn);
        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(widgetId, newIndex);

        // Assert
        expect(result.isSuccess, true);
        // Should update the moved widget and shift widgets at indices 1 and 2
        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(3);
      });

      test('should return success without updates when same index', () async {
        // Arrange - widget already at index 0, trying to move to index 0
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);

        // Act
        final result = await repository.reorder(widgetId, 0);

        // Assert
        expect(result.isSuccess, true);
        verifyNever(() => mockDataSource.updateItem<WidgetDto>(any()));
      });

      test('should return NotFoundError when widget does not exist', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.reorder(widgetId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test(
        'moving down (0→2) should shift intermediate indices correctly',
        () async {
          // Widget 1 at index 0 moves to index 2
          // Expected: widget 2 (1→0), widget 3 (2→1), widget 1 (0→2)
          when(
            () => mockDataSource.getItem<WidgetDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => existingJson);
          when(
            () => mockDataSource.getItems<WidgetDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => allWidgetsInColumn);
          when(
            () => mockDataSource.updateItem<WidgetDto>(any()),
          ).thenAnswer((_) async => updatedJson);

          await repository.reorder(widgetId, 2);

          final captured = verify(
            () => mockDataSource.updateItem<WidgetDto>(captureAny()),
          ).captured;

          // Collect {id: newIndex} from all captured DTOs
          final updates = <int, int>{};
          for (final dto in captured) {
            final d = dto as WidgetDto;
            final id = d.id is int ? d.id as int : int.parse(d.id.toString());
            updates[id] = d.index;
          }

          expect(updates[1], 2); // moved widget: 0→2
          expect(updates[2], 0); // shifted: 1→0
          expect(updates[3], 1); // shifted: 2→1
        },
      );

      test(
        'moving up (2→0) should shift intermediate indices correctly',
        () async {
          // Widget 3 at index 2 moves to index 0
          final widgetAtIndex2Json = {
            'id': 3,
            'column': columnId,
            'type_key': 'dish',
            'version': '1.0.0',
            'index': 2,
            'props_json': {'name': 'Salad'},
          };

          when(
            () => mockDataSource.getItem<WidgetDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => widgetAtIndex2Json);
          when(
            () => mockDataSource.getItems<WidgetDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => allWidgetsInColumn);
          when(
            () => mockDataSource.updateItem<WidgetDto>(any()),
          ).thenAnswer((_) async => widgetAtIndex2Json);

          await repository.reorder(3, 0);

          final captured = verify(
            () => mockDataSource.updateItem<WidgetDto>(captureAny()),
          ).captured;

          final updates = <int, int>{};
          for (final dto in captured) {
            final d = dto as WidgetDto;
            final id = d.id is int ? d.id as int : int.parse(d.id.toString());
            updates[id] = d.index;
          }

          expect(updates[3], 0); // moved widget: 2→0
          expect(updates[1], 1); // shifted: 0→1
          expect(updates[2], 2); // shifted: 1→2
        },
      );

      test('should handle column as nested object {"id": 1}', () async {
        final nestedColumnJson = {
          'id': widgetId,
          'column': {'id': columnId},
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': {'name': 'Pasta'},
        };

        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => nestedColumnJson);
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => allWidgetsInColumn);
        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        final result = await repository.reorder(widgetId, 2);

        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(3);
      });

      test(
        'should return ValidationError when widget has null column',
        () async {
          final nullColumnJson = {
            'id': widgetId,
            'column': null,
            'type_key': 'dish',
            'version': '1.0.0',
            'index': 0,
            'props_json': {'name': 'Pasta'},
          };

          when(
            () => mockDataSource.getItem<WidgetDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => nullColumnJson);

          final result = await repository.reorder(widgetId, 2);

          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );
    });

    group('moveTo', () {
      const widgetId = 1;
      const oldColumnId = 1;
      const newColumnId = 2;
      const newIndex = 1;

      final existingJson = {
        'id': widgetId,
        'column': oldColumnId,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': {'name': 'Pasta'},
      };

      final updatedJson = {
        'id': widgetId,
        'column': newColumnId,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': newIndex,
        'props_json': {'name': 'Pasta'},
      };

      // Widgets in source column
      final sourceColumnWidgets = [
        {'id': widgetId, 'index': 0},
        {'id': 2, 'index': 1},
      ];

      // Widgets in target column
      final targetColumnWidgets = [
        {'id': 3, 'index': 0},
        {'id': 4, 'index': 1},
      ];

      test('should move widget to new column and update indices', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);

        // Mock getItems to return different results based on filter
        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((invocation) async {
          final filter =
              invocation.namedArguments[#filter] as Map<String, dynamic>?;
          if (filter != null) {
            final columnFilter = filter['column'] as Map<String, dynamic>?;
            final columnId = columnFilter?['_eq'];
            if (columnId == oldColumnId) {
              return sourceColumnWidgets;
            } else if (columnId == newColumnId) {
              return targetColumnWidgets;
            }
          }
          return [];
        });

        when(
          () => mockDataSource.updateItem<WidgetDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.moveTo(widgetId, newColumnId, newIndex);

        // Assert
        expect(result.isSuccess, true);
        // Should update: widget 2 in source (shift down), widget 4 in target (shift up), and the moved widget
        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(3);
      });

      test('should return ValidationError when widget has no column', () async {
        // Arrange - widget with no column
        final noColumnJson = {
          'id': widgetId,
          'column': null,
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': {'name': 'Pasta'},
        };
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => noColumnJson);

        // Act
        final result = await repository.moveTo(widgetId, newColumnId, newIndex);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });

      test(
        'should skip source column shifts when moving within same column',
        () async {
          // Moving within same column: source == target, so only target shifts
          final sameColumnJson = {
            'id': widgetId,
            'column': oldColumnId,
            'type_key': 'dish',
            'version': '1.0.0',
            'index': 0,
            'props_json': {'name': 'Pasta'},
          };

          final sameColumnWidgets = [
            {'id': widgetId, 'index': 0},
            {'id': 2, 'index': 1},
            {'id': 3, 'index': 2},
          ];

          when(
            () => mockDataSource.getItem<WidgetDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => sameColumnJson);
          when(
            () => mockDataSource.getItems<WidgetDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => sameColumnWidgets);
          when(
            () => mockDataSource.updateItem<WidgetDto>(any()),
          ).thenAnswer((_) async => sameColumnJson);

          // Move to same column at index 2
          final result = await repository.moveTo(widgetId, oldColumnId, 2);

          expect(result.isSuccess, true);
          // source != target is false, so only target column shifts + the widget itself
          // Target: widget 3 (index 2) shifts to 3, plus the moved widget
          verify(
            () => mockDataSource.updateItem<WidgetDto>(any()),
          ).called(greaterThan(0));
          // Verify getItems called only once (target column only, no source fetch)
          verify(
            () => mockDataSource.getItems<WidgetDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            ),
          ).called(1);
        },
      );

      test('should return error when update fails', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<WidgetDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);

        when(
          () => mockDataSource.getItems<WidgetDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        when(() => mockDataSource.updateItem<WidgetDto>(any())).thenThrow(
          DirectusException(
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
