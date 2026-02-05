import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/menu_mapper.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

void main() {
  group('MenuMapper', () {
    group('toEntity', () {
      test('should convert MenuDto to Menu entity with all fields', () {
        // Arrange
        final json = {
          "id": 1,
          "status": "published",
          "date_created": "2025-11-13T10:25:31.922Z",
          "date_updated": "2025-11-13T10:25:31.922Z",
          "user_created": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "user_updated": "f8205fcc-3816-4a93-9010-76df1a1f4a90",
          "name": "Restaurant A La Carte",
          "style_json": {
            'fontFamily': 'Arial',
            'fontSize': 14.0,
            'primaryColor': '#000000',
            'secondaryColor': '#FFFFFF',
            'backgroundColor': '#F5F5F5',
            'marginTop': 10.0,
            'marginBottom': 10.0,
            'marginLeft': 15.0,
            'marginRight': 15.0,
            'padding': 8.0,
          },
          "version": "1.0.0",
          "area": 1,
          "size": 1,
          "versions": [],
          "pages": [1],
        };
        final dto = MenuDto(json);

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1);
        expect(entity.status, Status.published);
        expect(entity.name, 'Restaurant A La Carte');
        expect(entity.version, '1.0.0');
        expect(entity.dateCreated, isA<DateTime>());
        expect(entity.dateCreated, DateTime.parse("2025-11-13T10:25:31.922Z"));
        expect(entity.dateUpdated, isA<DateTime>());
        expect(entity.dateUpdated, DateTime.parse("2025-11-13T10:25:31.922Z"));
        expect(entity.userCreated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(entity.userUpdated, 'f8205fcc-3816-4a93-9010-76df1a1f4a90');
        expect(entity.pageSize, isNull);
        expect(entity.area, null);

        // StyleConfig
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.fontFamily, 'Arial');
        expect(entity.styleConfig!.fontSize, 14.0);
        expect(entity.styleConfig!.primaryColor, '#000000');
        expect(entity.styleConfig!.secondaryColor, '#FFFFFF');
        expect(entity.styleConfig!.backgroundColor, '#F5F5F5');
        expect(entity.styleConfig!.marginTop, 10.0);
        expect(entity.styleConfig!.marginBottom, 10.0);
        expect(entity.styleConfig!.marginLeft, 15.0);
        expect(entity.styleConfig!.marginRight, 15.0);
        expect(entity.styleConfig!.padding, 8.0);
      });

      test('should convert MenuDto with minimal fields', () {
        // Arrange
        final dto = MenuDto({
          'id': 2,
          'status': 'draft',
          'name': 'Simple Menu',
          'version': '1.0.0',
        });

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.id, 2);
        expect(entity.status, Status.draft);
        expect(entity.name, 'Simple Menu');
        expect(entity.version, '1.0.0');
        expect(entity.styleConfig, isNull);
        expect(entity.pageSize, isNull);
        expect(entity.area, isNull);
      });

      test('should map status strings correctly', () {
        // Draft
        final draftDto = MenuDto({
          'id': 1,
          'status': 'draft',
          'name': 'Menu',
          'version': '1.0.0',
        });
        expect(MenuMapper.toEntity(draftDto).status, Status.draft);

        // Published
        final publishedDto = MenuDto({
          'id': 2,
          'status': 'published',
          'name': 'Menu',
          'version': '1.0.0',
        });
        expect(MenuMapper.toEntity(publishedDto).status, Status.published);

        // Archived
        final archivedDto = MenuDto({
          'id': 3,
          'status': 'archived',
          'name': 'Menu',
          'version': '1.0.0',
        });

        expect(MenuMapper.toEntity(draftDto).status, Status.draft);
        expect(MenuMapper.toEntity(publishedDto).status, Status.published);
        expect(MenuMapper.toEntity(archivedDto).status, Status.archived);
      });
    });

    group('toDto', () {
      test('should convert Menu entity to MenuDto with all fields', () {
        // Arrange
        final entity = Menu(
          id: 1,
          status: Status.published,
          dateCreated: DateTime.parse('2024-01-15T10:30:00Z'),
          dateUpdated: DateTime.parse('2024-01-16T15:45:00Z'),
          userCreated: 'user-123',
          userUpdated: 'user-456',
          name: 'Test Menu',
          version: '1.0.0',
          styleConfig: const StyleConfig(
            fontFamily: 'Arial',
            fontSize: 14.0,
            primaryColor: '#000000',
          ),
          area: 'dining',
          pageSize: const PageSize(name: 'A4', width: 210.0, height: 297.0),
        );

        // Act
        final dto = MenuMapper.toDto(entity);

        // Assert
        expect(dto.id, '1');
        expect(dto.status, 'published');
        expect(dto.name, 'Test Menu');
        expect(dto.version, '1.0.0');
        expect(dto.styleJson['fontFamily'], 'Arial');
        // Check raw size data (using getter would fail as it expects 'id' in the map)
        final rawSize = dto.getRawData()['size'] as Map<String, dynamic>?;
        expect(rawSize?['name'], 'A4');
      });
    });

    group('toCreateDto', () {
      test('should convert CreateMenuInput to Directus format', () {
        // Arrange
        const input = CreateMenuInput(
          name: 'New Menu',
          version: '1.0.0',
          status: Status.draft,
          styleConfig: StyleConfig(fontFamily: 'Arial', fontSize: 14.0),
          pageSize: PageSize(name: 'A4', width: 210.0, height: 297.0),
          area: 'dining',
        );

        // Act
        final dto = MenuMapper.toCreateDto(input);

        // Assert
        expect(dto['name'], 'New Menu');
        expect(dto['version'], '1.0.0');
        expect(dto['status'], 'draft');
        expect(dto['style_json'], isNotNull);
        expect(dto['style_json']['fontFamily'], 'Arial');
        expect(dto['size'], isNotNull);
        expect(dto['size']['name'], 'A4');
        expect(dto['area'], 1); // Now converted from 'dining' string to 1 int
      });

      test('should convert CreateMenuInput with minimal fields', () {
        // Arrange
        const input = CreateMenuInput(name: 'Simple Menu', version: '1.0.0');

        // Act
        final dto = MenuMapper.toCreateDto(input);

        // Assert
        expect(dto['name'], 'Simple Menu');
        expect(dto['version'], '1.0.0');
        expect(dto['status'], 'draft'); // Default status
        expect(dto.containsKey('style_json'), false);
        expect(dto.containsKey('size'), false);
        expect(dto.containsKey('area'), false);
      });
    });

    group('toUpdateDto', () {
      test('should convert UpdateMenuInput to Directus format', () {
        // Arrange
        const input = UpdateMenuInput(
          id: 1,
          name: 'Updated Menu',
          status: Status.published,
          styleConfig: StyleConfig(fontSize: 16.0),
        );

        // Act
        final dto = MenuMapper.toUpdateDto(input);

        // Assert
        expect(dto['name'], 'Updated Menu');
        expect(dto['status'], 'published');
        expect(dto['style_json'], isNotNull);
        expect(dto['style_json']['fontSize'], 16.0);
        expect(dto.containsKey('id'), false); // ID should not be in update data
      });

      test('should only include non-null fields', () {
        // Arrange
        const input = UpdateMenuInput(id: 1, name: 'Updated Menu');

        // Act
        final dto = MenuMapper.toUpdateDto(input);

        // Assert
        expect(dto['name'], 'Updated Menu');
        expect(dto.containsKey('version'), false);
        expect(dto.containsKey('status'), false);
        expect(dto.containsKey('style_json'), false);
      });
    });
  });
}
