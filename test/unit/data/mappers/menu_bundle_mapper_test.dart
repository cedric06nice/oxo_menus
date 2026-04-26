import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/menu_bundle_mapper.dart';
import 'package:oxo_menus/data/models/menu_bundle_dto.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

void main() {
  group('MenuBundleMapper', () {
    group('toEntity', () {
      test('should map all fields from a fully-populated DTO', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '5',
          'name': 'Summer Menus',
          'menu_ids': [1, 2, 3],
          'pdf_file_id': 'file-abc-123',
          'date_created': '2025-03-01T09:00:00Z',
          'date_updated': '2025-03-02T10:00:00Z',
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.id, 5);
        expect(entity.name, 'Summer Menus');
        expect(entity.menuIds, [1, 2, 3]);
        expect(entity.pdfFileId, 'file-abc-123');
        expect(entity.dateCreated, DateTime.parse('2025-03-01T09:00:00Z'));
        expect(entity.dateUpdated, DateTime.parse('2025-03-02T10:00:00Z'));
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '42',
          'name': 'Bundle',
          'menu_ids': <int>[],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.id, 42);
      });

      test('should parse a large integer id correctly', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '100',
          'name': 'Bundle',
          'menu_ids': <int>[],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.id, 100);
      });

      test('should default menuIds to empty list when field is absent', () {
        // Arrange
        final dto = MenuBundleDto({'id': '1', 'name': 'Bundle'});

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.menuIds, isEmpty);
      });

      test('should default menuIds to empty list when field is null', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': null,
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.menuIds, isEmpty);
      });

      test('should coerce string-encoded menu ids to int', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': ['10', '20', '30'],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.menuIds, [10, 20, 30]);
      });

      test('should coerce double menu ids to int', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': [1.0, 2.0],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.menuIds, [1, 2]);
      });

      test('should map null pdfFileId as null', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': <int>[],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.pdfFileId, isNull);
      });

      test('should map null dateCreated and dateUpdated as null', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': <int>[],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.dateCreated, isNull);
        expect(entity.dateUpdated, isNull);
      });

      test('should handle a single-item menuIds list', () {
        // Arrange
        final dto = MenuBundleDto({
          'id': '1',
          'name': 'Bundle',
          'menu_ids': [99],
        });

        // Act
        final entity = MenuBundleMapper.toEntity(dto);

        // Assert
        expect(entity.menuIds, [99]);
      });
    });

    group('toCreatePayload', () {
      test('should emit name and menu_ids', () {
        // Arrange
        const input = CreateMenuBundleInput(
          name: 'New Bundle',
          menuIds: [4, 5, 6],
        );

        // Act
        final payload = MenuBundleMapper.toCreatePayload(input);

        // Assert
        expect(payload['name'], 'New Bundle');
        expect(payload['menu_ids'], [4, 5, 6]);
        expect(payload, hasLength(2));
      });

      test('should emit empty menu_ids list when none provided', () {
        // Arrange
        const input = CreateMenuBundleInput(name: 'Empty Bundle');

        // Act
        final payload = MenuBundleMapper.toCreatePayload(input);

        // Assert
        expect(payload['menu_ids'], isEmpty);
      });
    });

    group('toUpdatePayload', () {
      test(
        'should include name, menu_ids, and pdfFileId when all provided',
        () {
          // Arrange
          const input = UpdateMenuBundleInput(
            id: 1,
            name: 'Updated Bundle',
            menuIds: [7, 8],
            pdfFileId: 'new-file-id',
          );

          // Act
          final payload = MenuBundleMapper.toUpdatePayload(input);

          // Assert
          expect(payload['name'], 'Updated Bundle');
          expect(payload['menu_ids'], [7, 8]);
          expect(payload['pdf_file_id'], 'new-file-id');
        },
      );

      test('should omit name when name is null', () {
        // Arrange
        const input = UpdateMenuBundleInput(id: 1, menuIds: [1, 2]);

        // Act
        final payload = MenuBundleMapper.toUpdatePayload(input);

        // Assert
        expect(payload.containsKey('name'), false);
      });

      test('should omit menu_ids when menuIds is null', () {
        // Arrange
        const input = UpdateMenuBundleInput(id: 1, name: 'Bundle');

        // Act
        final payload = MenuBundleMapper.toUpdatePayload(input);

        // Assert
        expect(payload.containsKey('menu_ids'), false);
      });

      test('should omit pdf_file_id when pdfFileId is null', () {
        // Arrange
        const input = UpdateMenuBundleInput(id: 1, name: 'Bundle');

        // Act
        final payload = MenuBundleMapper.toUpdatePayload(input);

        // Assert
        expect(payload.containsKey('pdf_file_id'), false);
      });

      test('should return empty map when only id is provided', () {
        // Arrange
        const input = UpdateMenuBundleInput(id: 99);

        // Act
        final payload = MenuBundleMapper.toUpdatePayload(input);

        // Assert
        expect(payload, isEmpty);
      });

      test('should never include id in payload', () {
        // Arrange
        const input = UpdateMenuBundleInput(id: 1, name: 'Bundle');

        // Act
        final payload = MenuBundleMapper.toUpdatePayload(input);

        // Assert
        expect(payload.containsKey('id'), false);
      });
    });
  });
}
