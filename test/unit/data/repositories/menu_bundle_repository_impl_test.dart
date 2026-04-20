import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/menu_bundle_dto.dart';
import 'package:oxo_menus/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late MockDirectusDataSource dataSource;
  late MenuBundleRepository repository;

  setUpAll(() {
    registerFallbackValue(MenuBundleDto({'id': 0, 'name': ''}));
  });

  setUp(() {
    dataSource = MockDirectusDataSource();
    repository = MenuBundleRepositoryImpl(dataSource: dataSource);
  });

  group('MenuBundleRepositoryImpl', () {
    group('getAll', () {
      test('returns mapped MenuBundle list on success', () async {
        when(
          () => dataSource.getItems<MenuBundleDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'name': 'A',
              'menu_ids': [10],
            },
            {
              'id': 2,
              'name': 'B',
              'menu_ids': [20, 30],
            },
          ],
        );

        final result = await repository.getAll();

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].name, 'A');
        expect(result.valueOrNull![1].menuIds, [20, 30]);
      });

      test('maps thrown errors to Failure', () async {
        when(
          () => dataSource.getItems<MenuBundleDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('boom'));

        final result = await repository.getAll();

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    group('getById', () {
      test('returns mapped bundle on success', () async {
        when(
          () => dataSource.getItem<MenuBundleDto>(
            1,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer(
          (_) async => {
            'id': 1,
            'name': 'A',
            'menu_ids': [10, 20],
          },
        );

        final result = await repository.getById(1);

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        expect(result.valueOrNull!.menuIds, [10, 20]);
      });
    });

    group('findByIncludedMenu', () {
      test(
        'returns every bundle whose menuIds list contains the target menu id',
        () async {
          when(
            () => dataSource.getItems<MenuBundleDto>(
              fields: any(named: 'fields'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer(
            (_) async => [
              {
                'id': 1,
                'name': 'A',
                'menu_ids': [10, 20],
              },
              {
                'id': 2,
                'name': 'B',
                'menu_ids': [30],
              },
              {
                'id': 3,
                'name': 'C',
                'menu_ids': [10],
              },
            ],
          );

          final result = await repository.findByIncludedMenu(10);

          expect(result.isSuccess, true);
          expect(result.valueOrNull!.map((b) => b.id).toList(), [1, 3]);
        },
      );

      test('returns empty list when no bundle contains the menu id', () async {
        when(
          () => dataSource.getItems<MenuBundleDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'name': 'A',
              'menu_ids': [30],
            },
          ],
        );

        final result = await repository.findByIncludedMenu(10);

        expect(result.isSuccess, true);
        expect(result.valueOrNull, isEmpty);
      });

      test('propagates failure from getAll', () async {
        when(
          () => dataSource.getItems<MenuBundleDto>(
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('boom'));

        final result = await repository.findByIncludedMenu(10);

        expect(result.isFailure, true);
      });
    });

    group('create', () {
      test('creates and returns mapped bundle', () async {
        when(() => dataSource.createItem<MenuBundleDto>(any())).thenAnswer(
          (_) async => {
            'id': 99,
            'name': 'NEW',
            'menu_ids': [1, 2],
          },
        );

        final result = await repository.create(
          const CreateMenuBundleInput(name: 'NEW', menuIds: [1, 2]),
        );

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 99);
        expect(result.valueOrNull!.menuIds, [1, 2]);
      });
    });

    group('update', () {
      test(
        'fetches existing bundle, applies patch, returns mapped bundle',
        () async {
          when(
            () => dataSource.getItem<MenuBundleDto>(
              1,
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => {
              'id': 1,
              'name': 'OLD',
              'menu_ids': [1],
            },
          );
          when(() => dataSource.updateItem<MenuBundleDto>(any())).thenAnswer(
            (_) async => {
              'id': 1,
              'name': 'NEW',
              'menu_ids': [1, 2],
            },
          );

          final result = await repository.update(
            const UpdateMenuBundleInput(id: 1, name: 'NEW', menuIds: [1, 2]),
          );

          expect(result.isSuccess, true);
          expect(result.valueOrNull!.name, 'NEW');
          expect(result.valueOrNull!.menuIds, [1, 2]);
        },
      );
    });

    group('delete', () {
      test('delegates to dataSource.deleteItem', () async {
        when(
          () => dataSource.deleteItem<MenuBundleDto>(5),
        ).thenAnswer((_) async {});

        final result = await repository.delete(5);

        expect(result.isSuccess, true);
        verify(() => dataSource.deleteItem<MenuBundleDto>(5)).called(1);
      });
    });
  });
}
