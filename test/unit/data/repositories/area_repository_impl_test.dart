import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/area_dto.dart';
import 'package:oxo_menus/data/repositories/area_repository_impl.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late AreaRepositoryImpl repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = AreaRepositoryImpl(dataSource: mockDataSource);
  });

  group('AreaRepositoryImpl', () {
    group('getAll', () {
      test('should return list of Area entities on success', () async {
        when(
          () => mockDataSource.getItems<AreaDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => [
            {'id': 1, 'name': 'Dining'},
            {'id': 2, 'name': 'Bar'},
            {'id': 3, 'name': 'Terrace'},
          ],
        );

        final result = await repository.getAll();

        expect(result, isA<Success>());
        final areas = (result as Success).value;
        expect(areas, hasLength(3));
        expect(areas[0].id, 1);
        expect(areas[0].name, 'Dining');
        expect(areas[1].id, 2);
        expect(areas[1].name, 'Bar');
        expect(areas[2].id, 3);
        expect(areas[2].name, 'Terrace');
      });

      test('should return empty list when no areas exist', () async {
        when(
          () => mockDataSource.getItems<AreaDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.getAll();

        expect(result, isA<Success>());
        final areas = (result as Success).value;
        expect(areas, isEmpty);
      });

      test('should return Failure on error', () async {
        when(
          () => mockDataSource.getItems<AreaDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getAll();

        expect(result, isA<Failure>());
      });
    });
  });
}
