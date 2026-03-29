import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late ContainerRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = ContainerRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(
      ContainerDto({'id': 1, 'page': 1, 'index': 0, 'status': 'draft'}),
    );
  });

  group('ContainerRepositoryImpl', () {
    group('create', () {
      const input = CreateContainerInput(
        pageId: 1,
        index: 0,
        name: 'Header Section',
        direction: 'row',
      );

      final createdJson = {
        'id': 2,
        'page': 1,
        'index': 0,
        'status': 'draft',
        'date_created': '2024-01-15T10:30:00Z',
      };

      test('should create container and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.createItem<ContainerDto>(any()),
        ).thenAnswer((_) async => createdJson);

        // Act
        final result = await repository.create(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 2);
        expect(result.valueOrNull!.pageId, 1);
        // ContainerMapper generates name as "Container {id}"
        expect(result.valueOrNull!.name, 'Container 2');
        expect(result.valueOrNull!.index, 0);

        verify(() => mockDataSource.createItem<ContainerDto>(any())).called(1);
      });

      test('should set style_json on DTO when input has styleConfig', () async {
        // Arrange
        const inputWithStyle = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
          styleConfig: StyleConfig(
            marginTop: 10.0,
            borderType: BorderType.plainThin,
          ),
        );

        when(() => mockDataSource.createItem<ContainerDto>(any())).thenAnswer(
          (_) async => {
            'id': 3,
            'page': 1,
            'index': 0,
            'status': 'published',
            'style_json': {'marginTop': 10.0, 'borderType': 'plain_thin'},
          },
        );

        // Act
        await repository.create(inputWithStyle);

        // Assert — capture the DTO sent to createItem and verify style_json
        final captured = verify(
          () => mockDataSource.createItem<ContainerDto>(captureAny()),
        ).captured;
        final dto = captured.first as ContainerDto;
        expect(dto.styleJson['marginTop'], 10.0);
        expect(dto.styleJson['borderType'], 'plain_thin');
      });

      test(
        'should pass parentContainerId when creating child container',
        () async {
          const childInput = CreateContainerInput(
            pageId: 1,
            index: 0,
            direction: 'row',
            parentContainerId: 5,
          );

          when(() => mockDataSource.createItem<ContainerDto>(any())).thenAnswer(
            (_) async => {
              'id': 3,
              'page': 1,
              'index': 0,
              'status': 'published',
              'parent_container': 5,
            },
          );

          final result = await repository.create(childInput);

          expect(result.isSuccess, true);

          final captured = verify(
            () => mockDataSource.createItem<ContainerDto>(captureAny()),
          ).captured;
          final dto = captured.first as ContainerDto;
          expect(dto.parentContainerId, 5);
        },
      );

      test('should store layout in style_json, not layout_json', () async {
        const inputWithLayout = CreateContainerInput(
          pageId: 1,
          index: 0,
          direction: 'row',
          layout: LayoutConfig(
            direction: 'row',
            mainAxisAlignment: 'spaceBetween',
          ),
        );

        when(() => mockDataSource.createItem<ContainerDto>(any())).thenAnswer(
          (_) async => {
            'id': 4,
            'page': 1,
            'index': 0,
            'status': 'published',
            'style_json': {
              'direction': 'row',
              'mainAxisAlignment': 'spaceBetween',
            },
          },
        );

        await repository.create(inputWithLayout);

        final captured = verify(
          () => mockDataSource.createItem<ContainerDto>(captureAny()),
        ).captured;
        final dto = captured.first as ContainerDto;
        expect(dto.styleJson['mainAxisAlignment'], 'spaceBetween');
        expect(dto.styleJson['direction'], 'row');
      });

      test(
        'should merge layout and styleConfig into style_json on create',
        () async {
          const inputWithBoth = CreateContainerInput(
            pageId: 1,
            index: 0,
            direction: 'row',
            layout: LayoutConfig(mainAxisAlignment: 'spaceEvenly'),
            styleConfig: StyleConfig(marginTop: 10.0),
          );

          when(() => mockDataSource.createItem<ContainerDto>(any())).thenAnswer(
            (_) async => {
              'id': 5,
              'page': 1,
              'index': 0,
              'status': 'published',
              'style_json': {
                'mainAxisAlignment': 'spaceEvenly',
                'marginTop': 10.0,
              },
            },
          );

          await repository.create(inputWithBoth);

          final captured = verify(
            () => mockDataSource.createItem<ContainerDto>(captureAny()),
          ).captured;
          final dto = captured.first as ContainerDto;
          expect(dto.styleJson['mainAxisAlignment'], 'spaceEvenly');
          expect(dto.styleJson['marginTop'], 10.0);
        },
      );

      test('should return ValidationError when creation fails', () async {
        // Arrange
        when(() => mockDataSource.createItem<ContainerDto>(any())).thenThrow(
          DirectusException(
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
      const pageId = 1;
      final containersJson = [
        {'id': 1, 'page': pageId, 'index': 0, 'status': 'draft'},
        {'id': 2, 'page': pageId, 'index': 1, 'status': 'draft'},
      ];

      test('should return list of containers for page', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => containersJson);

        // Act
        final result = await repository.getAllForPage(pageId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 1);
        expect(result.valueOrNull![1].id, 2);

        final captured = verify(
          () => mockDataSource.getItems<ContainerDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        // Verify filter includes page_id
        expect(captured[0], isNotNull);
      });

      test('should filter to only top-level containers', () async {
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => containersJson);

        await repository.getAllForPage(pageId);

        final captured = verify(
          () => mockDataSource.getItems<ContainerDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        final filter = captured[0] as Map<String, dynamic>;
        expect(filter['parent_container'], {'_null': true});
      });

      test('should return empty list when no containers found', () async {
        // Arrange
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllForPage(pageId);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 0);
      });
    });

    group('getAllForContainer', () {
      const parentId = 1;
      final childJson = [
        {
          'id': 10,
          'page': 1,
          'index': 0,
          'status': 'published',
          'parent_container': parentId,
        },
        {
          'id': 11,
          'page': 1,
          'index': 1,
          'status': 'published',
          'parent_container': parentId,
        },
      ];

      test('should return child containers for parent', () async {
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => childJson);

        final result = await repository.getAllForContainer(parentId);

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.length, 2);
        expect(result.valueOrNull![0].id, 10);
        expect(result.valueOrNull![1].id, 11);
      });

      test('should filter by parent_container', () async {
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => childJson);

        await repository.getAllForContainer(parentId);

        final captured = verify(
          () => mockDataSource.getItems<ContainerDto>(
            filter: captureAny(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).captured;

        final filter = captured[0] as Map<String, dynamic>;
        expect(filter['parent_container'], {'_eq': parentId});
      });

      test('should return empty list when no children', () async {
        when(
          () => mockDataSource.getItems<ContainerDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.getAllForContainer(parentId);

        expect(result.isSuccess, true);
        expect(result.valueOrNull!, isEmpty);
      });
    });

    group('getById', () {
      const containerId = 1;
      final containerJson = {
        'id': containerId,
        'page': 1,
        'index': 0,
        'status': 'draft',
        // ContainerMapper reads layout from style_json
        'style_json': {'direction': 'row', 'alignment': 'center'},
        'date_created': '2024-01-15T10:30:00Z',
        'date_updated': '2024-01-16T15:45:00Z',
      };

      test('should return Container entity when fetch succeeds', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ContainerDto>(
            containerId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => containerJson);

        // Act
        final result = await repository.getById(containerId);

        // Assert
        expect(result.isSuccess, true);
        final container = result.valueOrNull!;
        expect(container.id, containerId);
        expect(container.pageId, 1);
        // ContainerMapper generates name as "Container {id}"
        expect(container.name, 'Container $containerId');
        expect(container.index, 0);
        expect(container.layout, isNotNull);

        verify(
          () => mockDataSource.getItem<ContainerDto>(
            containerId,
            fields: any(named: 'fields'),
          ),
        ).called(1);
      });

      test('should request page and parent_container fields', () async {
        when(
          () => mockDataSource.getItem<ContainerDto>(
            containerId,
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => containerJson);

        await repository.getById(containerId);

        final captured =
            verify(
                  () => mockDataSource.getItem<ContainerDto>(
                    containerId,
                    fields: captureAny(named: 'fields'),
                  ),
                ).captured.first
                as List<String>;

        expect(captured, contains('page'));
        expect(captured, contains('parent_container'));
      });

      test(
        'should return NotFoundError when container does not exist',
        () async {
          // Arrange
          when(
            () => mockDataSource.getItem<ContainerDto>(
              containerId,
              fields: any(named: 'fields'),
            ),
          ).thenThrow(
            DirectusException(
              code: 'NOT_FOUND',
              message: 'Container not found',
            ),
          );

          // Act
          final result = await repository.getById(containerId);

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    group('update', () {
      const input = UpdateContainerInput(id: 1, name: 'Updated Header');

      final existingJson = {'id': 1, 'page': 1, 'index': 0, 'status': 'draft'};

      final updatedJson = {'id': 1, 'page': 1, 'index': 0, 'status': 'draft'};

      test('should update container and return entity', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ContainerDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ContainerDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.update(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.id, 1);
        // ContainerMapper generates name as "Container {id}"
        expect(result.valueOrNull!.name, 'Container 1');

        verify(() => mockDataSource.updateItem<ContainerDto>(any())).called(1);
      });

      test(
        'should set style_json on DTO when update input has styleConfig',
        () async {
          // Arrange
          const inputWithStyle = UpdateContainerInput(
            id: 1,
            styleConfig: StyleConfig(
              paddingLeft: 8.0,
              borderType: BorderType.dropShadow,
            ),
          );

          when(
            () => mockDataSource.getItem<ContainerDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => existingJson);
          when(() => mockDataSource.updateItem<ContainerDto>(any())).thenAnswer(
            (_) async => {
              'id': 1,
              'page': 1,
              'index': 0,
              'status': 'draft',
              'style_json': {'paddingLeft': 8.0, 'borderType': 'drop_shadow'},
            },
          );

          // Act
          await repository.update(inputWithStyle);

          // Assert — capture the DTO sent to updateItem and verify style_json
          final captured = verify(
            () => mockDataSource.updateItem<ContainerDto>(captureAny()),
          ).captured;
          final dto = captured.first as ContainerDto;
          expect(dto.styleJson['paddingLeft'], 8.0);
          expect(dto.styleJson['borderType'], 'drop_shadow');
        },
      );

      test('should store layout in style_json on update', () async {
        const inputWithLayout = UpdateContainerInput(
          id: 1,
          layout: LayoutConfig(mainAxisAlignment: 'center'),
        );

        when(
          () => mockDataSource.getItem<ContainerDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ContainerDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        await repository.update(inputWithLayout);

        final captured = verify(
          () => mockDataSource.updateItem<ContainerDto>(captureAny()),
        ).captured;
        final dto = captured.first as ContainerDto;
        expect(dto.styleJson['mainAxisAlignment'], 'center');
      });

      test('should merge layout into existing style_json on update', () async {
        const inputWithBoth = UpdateContainerInput(
          id: 1,
          layout: LayoutConfig(mainAxisAlignment: 'spaceBetween'),
          styleConfig: StyleConfig(paddingLeft: 5.0),
        );

        when(
          () => mockDataSource.getItem<ContainerDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ContainerDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        await repository.update(inputWithBoth);

        final captured = verify(
          () => mockDataSource.updateItem<ContainerDto>(captureAny()),
        ).captured;
        final dto = captured.first as ContainerDto;
        expect(dto.styleJson['mainAxisAlignment'], 'spaceBetween');
        expect(dto.styleJson['paddingLeft'], 5.0);
      });

      test(
        'should return NotFoundError when container does not exist',
        () async {
          // Arrange
          when(
            () => mockDataSource.getItem<ContainerDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenThrow(
            DirectusException(
              code: 'NOT_FOUND',
              message: 'Container not found',
            ),
          );

          // Act
          final result = await repository.update(input);

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    group('delete', () {
      const containerId = 1;

      test('should delete container successfully', () async {
        // Arrange
        when(
          () => mockDataSource.deleteItem<ContainerDto>(containerId),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.delete(containerId);

        // Assert
        expect(result.isSuccess, true);
        verify(
          () => mockDataSource.deleteItem<ContainerDto>(containerId),
        ).called(1);
      });

      test(
        'should return NotFoundError when container does not exist',
        () async {
          // Arrange
          when(
            () => mockDataSource.deleteItem<ContainerDto>(containerId),
          ).thenThrow(
            DirectusException(
              code: 'NOT_FOUND',
              message: 'Container not found',
            ),
          );

          // Act
          final result = await repository.delete(containerId);

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    group('reorder', () {
      const containerId = 1;
      const newIndex = 2;

      final existingJson = {
        'id': containerId,
        'page': 1,
        'index': 0,
        'status': 'draft',
      };

      final updatedJson = {
        'id': containerId,
        'page': 1,
        'index': newIndex,
        'status': 'draft',
      };

      test('should update container index successfully', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ContainerDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ContainerDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.reorder(containerId, newIndex);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateItem<ContainerDto>(any())).called(1);
      });

      test(
        'should return NotFoundError when container does not exist',
        () async {
          // Arrange
          when(
            () => mockDataSource.getItem<ContainerDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenThrow(
            DirectusException(
              code: 'NOT_FOUND',
              message: 'Container not found',
            ),
          );

          // Act
          final result = await repository.reorder(containerId, newIndex);

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    group('moveTo', () {
      const containerId = 1;
      const newPageId = 2;
      const newIndex = 1;

      final existingJson = {
        'id': containerId,
        'page': 1,
        'index': 0,
        'status': 'draft',
      };

      final updatedJson = {
        'id': containerId,
        'page': newPageId,
        'index': newIndex,
        'status': 'draft',
      };

      test('should move container to new page successfully', () async {
        // Arrange
        when(
          () => mockDataSource.getItem<ContainerDto>(
            any(),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => existingJson);
        when(
          () => mockDataSource.updateItem<ContainerDto>(any()),
        ).thenAnswer((_) async => updatedJson);

        // Act
        final result = await repository.moveTo(
          containerId,
          newPageId,
          newIndex,
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateItem<ContainerDto>(any())).called(1);
      });

      test(
        'should return ValidationError when new page does not exist',
        () async {
          // Arrange
          when(
            () => mockDataSource.getItem<ContainerDto>(
              any(),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer((_) async => existingJson);
          when(() => mockDataSource.updateItem<ContainerDto>(any())).thenThrow(
            DirectusException(
              code: 'INVALID_FOREIGN_KEY',
              message: 'Page not found',
            ),
          );

          // Act
          final result = await repository.moveTo(
            containerId,
            newPageId,
            newIndex,
          );

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<ValidationError>());
        },
      );
    });
  });
}
