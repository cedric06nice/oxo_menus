import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/data/repositories/size_repository_impl.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late SizeRepositoryImpl repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = SizeRepositoryImpl(dataSource: mockDataSource);
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
            {'id': 1, 'name': 'A4', 'width': 210.0, 'height': 297.0},
            {'id': 2, 'name': 'Letter', 'width': 215.9, 'height': 279.4},
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
          (_) async => {'id': 1, 'name': 'A4', 'width': 210.0, 'height': 297.0},
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
  });
}
