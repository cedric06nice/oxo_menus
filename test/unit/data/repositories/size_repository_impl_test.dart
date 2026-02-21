import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late SizeRepositoryImpl repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = SizeRepositoryImpl(dataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(SizeDto({'id': 0}));
  });

  group('SizeRepositoryImpl', () {
    group('getAll', () {
      test('should return list of Size entities on success', () async {
        when(
          () => mockDataSource.getItems<SizeDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'name': 'A4',
              'width': 210.0,
              'height': 297.0,
              'status': 'published',
              'direction': 'portrait',
            },
            {
              'id': 2,
              'name': 'Letter',
              'width': 215.9,
              'height': 279.4,
              'status': 'draft',
              'direction': 'landscape',
            },
          ],
        );

        final result = await repository.getAll();

        expect(result.isSuccess, true);
        final sizes = result.valueOrNull!;
        expect(sizes, hasLength(2));
        expect(sizes[0].name, 'A4');
        expect(sizes[1].name, 'Letter');
      });

      test('should return empty list when no sizes exist', () async {
        when(
          () => mockDataSource.getItems<SizeDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final result = await repository.getAll();

        expect(result.isSuccess, true);
        expect(result.valueOrNull, isEmpty);
      });

      test('should return Failure when data source throws', () async {
        when(
          () => mockDataSource.getItems<SizeDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Connection failed'));

        final result = await repository.getAll();

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    group('getById', () {
      test('should return Size entity on success', () async {
        when(
          () =>
              mockDataSource.getItem<SizeDto>(1, fields: any(named: 'fields')),
        ).thenAnswer(
          (_) async => {
            'id': 1,
            'name': 'A4',
            'width': 210.0,
            'height': 297.0,
            'status': 'published',
            'direction': 'portrait',
          },
        );

        final result = await repository.getById(1);

        expect(result.isSuccess, true);
        final size = result.valueOrNull!;
        expect(size.id, 1);
        expect(size.name, 'A4');
        expect(size.width, 210.0);
        expect(size.height, 297.0);
      });

      test('should return Failure when data source throws', () async {
        when(
          () =>
              mockDataSource.getItem<SizeDto>(99, fields: any(named: 'fields')),
        ).thenThrow(Exception('Not found'));

        final result = await repository.getById(99);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    group('create', () {
      test('should create a size and return the entity', () async {
        when(() => mockDataSource.createItem<SizeDto>(any())).thenAnswer(
          (_) async => {
            'id': 3,
            'name': 'A5',
            'width': 148.0,
            'height': 210.0,
            'status': 'draft',
            'direction': 'portrait',
          },
        );

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );

        final result = await repository.create(input);

        expect(result.isSuccess, true);
        final size = result.valueOrNull!;
        expect(size.id, 3);
        expect(size.name, 'A5');
        expect(size.width, 148.0);
        expect(size.height, 210.0);
        expect(size.status, Status.draft);
        expect(size.direction, 'portrait');
      });

      test('should return Failure when data source throws on create', () async {
        when(
          () => mockDataSource.createItem<SizeDto>(any()),
        ).thenThrow(Exception('Create failed'));

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );

        final result = await repository.create(input);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    group('update', () {
      test('should update a size and return the updated entity', () async {
        when(
          () =>
              mockDataSource.getItem<SizeDto>(1, fields: any(named: 'fields')),
        ).thenAnswer(
          (_) async => {
            'id': 1,
            'name': 'A4',
            'width': 210.0,
            'height': 297.0,
            'status': 'draft',
            'direction': 'portrait',
          },
        );

        when(() => mockDataSource.updateItem<SizeDto>(any())).thenAnswer(
          (_) async => {
            'id': 1,
            'name': 'A4 Updated',
            'width': 210.0,
            'height': 297.0,
            'status': 'published',
            'direction': 'portrait',
          },
        );

        const input = UpdateSizeInput(
          id: 1,
          name: 'A4 Updated',
          status: Status.published,
        );

        final result = await repository.update(input);

        expect(result.isSuccess, true);
        final size = result.valueOrNull!;
        expect(size.name, 'A4 Updated');
        expect(size.status, Status.published);
      });

      test('should return Failure when data source throws on update', () async {
        when(
          () =>
              mockDataSource.getItem<SizeDto>(1, fields: any(named: 'fields')),
        ).thenThrow(Exception('Update failed'));

        const input = UpdateSizeInput(id: 1, name: 'Updated');

        final result = await repository.update(input);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    group('delete', () {
      test('should delete a size and return Success', () async {
        when(
          () => mockDataSource.deleteItem<SizeDto>(1),
        ).thenAnswer((_) async {});

        final result = await repository.delete(1);

        expect(result.isSuccess, true);
        verify(() => mockDataSource.deleteItem<SizeDto>(1)).called(1);
      });

      test('should return Failure when data source throws on delete', () async {
        when(
          () => mockDataSource.deleteItem<SizeDto>(99),
        ).thenThrow(Exception('Delete failed'));

        final result = await repository.delete(99);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });
  });
}
