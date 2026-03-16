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

  group('WidgetRepository lock operations', () {
    group('lockForEditing', () {
      test('should update widget with editing_by and editing_since', () async {
        when(() => mockDataSource.updateItem<WidgetDto>(any())).thenAnswer(
          (_) async => {
            'id': 1,
            'column': {'id': 10},
            'type_key': 'dish',
            'version': '1.0.0',
            'index': 0,
            'props_json': <String, dynamic>{},
            'editing_by': 'user-abc',
            'editing_since': '2025-01-15T10:30:00.000Z',
          },
        );

        final result = await repository.lockForEditing(1, 'user-abc');

        expect(result.isSuccess, isTrue);
        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(1);
      });

      test('should return Failure on error', () async {
        when(() => mockDataSource.updateItem<WidgetDto>(any())).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        final result = await repository.lockForEditing(999, 'user-abc');

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    group('unlockEditing', () {
      test('should clear editing_by and editing_since', () async {
        when(() => mockDataSource.updateItem<WidgetDto>(any())).thenAnswer(
          (_) async => {
            'id': 1,
            'column': {'id': 10},
            'type_key': 'dish',
            'version': '1.0.0',
            'index': 0,
            'props_json': <String, dynamic>{},
          },
        );

        final result = await repository.unlockEditing(1);

        expect(result.isSuccess, isTrue);
        verify(() => mockDataSource.updateItem<WidgetDto>(any())).called(1);
      });

      test('should return Failure on error', () async {
        when(() => mockDataSource.updateItem<WidgetDto>(any())).thenThrow(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        final result = await repository.unlockEditing(999);

        expect(result.isFailure, isTrue);
      });
    });
  });
}
