import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/menu_mapper.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
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
          sizeId: 3,
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
        expect(dto['size'], 3);
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

    group('CreateMenuInput allowedWidgetTypes', () {
      test('should hold allowedWidgetTypes', () {
        const input = CreateMenuInput(
          name: 'Menu',
          version: '1.0.0',
          allowedWidgetTypes: ['dish', 'text'],
        );

        expect(input.allowedWidgetTypes, ['dish', 'text']);
      });

      test('should default allowedWidgetTypes to null', () {
        const input = CreateMenuInput(name: 'Menu', version: '1.0.0');

        expect(input.allowedWidgetTypes, isNull);
      });
    });

    group('UpdateMenuInput allowedWidgetTypes', () {
      test('should hold allowedWidgetTypes', () {
        const input = UpdateMenuInput(id: 1, allowedWidgetTypes: ['section']);

        expect(input.allowedWidgetTypes, ['section']);
      });

      test('should default allowedWidgetTypes to null', () {
        const input = UpdateMenuInput(id: 1);

        expect(input.allowedWidgetTypes, isNull);
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

      test('should serialize per-side padding in style_json', () {
        // Arrange
        const input = UpdateMenuInput(
          id: 1,
          styleConfig: StyleConfig(
            paddingTop: 10.0,
            paddingBottom: 12.0,
            paddingLeft: 8.0,
            paddingRight: 8.0,
          ),
        );

        // Act
        final dto = MenuMapper.toUpdateDto(input);

        // Assert
        expect(dto['style_json']['paddingTop'], 10.0);
        expect(dto['style_json']['paddingBottom'], 12.0);
        expect(dto['style_json']['paddingLeft'], 8.0);
        expect(dto['style_json']['paddingRight'], 8.0);
      });

      test('should serialize borderType in style_json', () {
        // Arrange
        const input = UpdateMenuInput(
          id: 1,
          styleConfig: StyleConfig(borderType: BorderType.dropShadow),
        );

        // Act
        final dto = MenuMapper.toUpdateDto(input);

        // Assert
        expect(dto['style_json']['borderType'], 'drop_shadow');
      });
    });

    group('allowedWidgetTypes mapping', () {
      test('toEntity - maps allowed_widget_types list to entity field', () {
        final dto = MenuDto({
          'id': 1,
          'status': 'draft',
          'name': 'Menu',
          'version': '1.0.0',
          'allowed_widget_types': ['dish', 'text'],
        });

        final entity = MenuMapper.toEntity(dto);

        expect(entity.allowedWidgetTypes, ['dish', 'text']);
      });

      test('toEntity - maps null allowed_widget_types to empty list', () {
        final dto = MenuDto({
          'id': 1,
          'status': 'draft',
          'name': 'Menu',
          'version': '1.0.0',
        });

        final entity = MenuMapper.toEntity(dto);

        expect(entity.allowedWidgetTypes, <String>[]);
      });

      test('toCreateDto - includes allowed_widget_types when non-null', () {
        const input = CreateMenuInput(
          name: 'Menu',
          version: '1.0.0',
          allowedWidgetTypes: ['dish', 'section'],
        );

        final dto = MenuMapper.toCreateDto(input);

        expect(dto['allowed_widget_types'], ['dish', 'section']);
      });

      test('toCreateDto - omits allowed_widget_types when null', () {
        const input = CreateMenuInput(name: 'Menu', version: '1.0.0');

        final dto = MenuMapper.toCreateDto(input);

        expect(dto.containsKey('allowed_widget_types'), false);
      });

      test('toUpdateDto - includes allowed_widget_types when non-null', () {
        const input = UpdateMenuInput(id: 1, allowedWidgetTypes: ['text']);

        final dto = MenuMapper.toUpdateDto(input);

        expect(dto['allowed_widget_types'], ['text']);
      });

      test('toUpdateDto - omits allowed_widget_types when null', () {
        const input = UpdateMenuInput(id: 1, name: 'Updated');

        final dto = MenuMapper.toUpdateDto(input);

        expect(dto.containsKey('allowed_widget_types'), false);
      });
    });

    group('per-side padding', () {
      test('should parse per-side padding from styleJson in toEntity', () {
        // Arrange
        final json = {
          'id': 1,
          'status': 'published',
          'name': 'Menu With Padding',
          'version': '1.0.0',
          'style_json': {
            'paddingTop': 10.0,
            'paddingBottom': 12.0,
            'paddingLeft': 8.0,
            'paddingRight': 8.0,
            'marginTop': 20.0,
            'marginBottom': 20.0,
            'marginLeft': 15.0,
            'marginRight': 15.0,
          },
        };
        final dto = MenuDto(json);

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.paddingTop, 10.0);
        expect(entity.styleConfig!.paddingBottom, 12.0);
        expect(entity.styleConfig!.paddingLeft, 8.0);
        expect(entity.styleConfig!.paddingRight, 8.0);
        expect(entity.styleConfig!.marginTop, 20.0);
      });

      test('should parse borderType from styleJson in toEntity', () {
        // Arrange
        final json = {
          'id': 1,
          'status': 'draft',
          'name': 'Border Menu',
          'version': '1.0.0',
          'style_json': {'borderType': 'plain_thin'},
        };
        final dto = MenuDto(json);

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig, isNotNull);
        expect(entity.styleConfig!.borderType, BorderType.plainThin);
      });

      test('should map legacy single padding without per-side values', () {
        // Arrange
        final json = {
          'id': 1,
          'status': 'draft',
          'name': 'Legacy Menu',
          'version': '1.0.0',
          'style_json': {'padding': 16.0},
        };
        final dto = MenuDto(json);

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.styleConfig!.padding, 16.0);
        expect(entity.styleConfig!.paddingTop, isNull);
        expect(entity.styleConfig!.paddingBottom, isNull);
        expect(entity.styleConfig!.paddingLeft, isNull);
        expect(entity.styleConfig!.paddingRight, isNull);
      });
    });

    group('displayOptions mapping', () {
      test(
        'toEntity - DTO with display_options_json maps to Menu.displayOptions',
        () {
          // Arrange
          final json = {
            'id': 1,
            'status': 'draft',
            'name': 'Menu',
            'version': '1.0.0',
            'display_options_json': {
              'showPrices': false,
              'showAllergens': true,
            },
          };
          final dto = MenuDto(json);

          // Act
          final entity = MenuMapper.toEntity(dto);

          // Assert
          expect(entity.displayOptions, isNotNull);
          expect(entity.displayOptions!.showPrices, false);
          expect(entity.displayOptions!.showAllergens, true);
        },
      );

      test('toEntity - DTO without display_options_json maps to null', () {
        // Arrange
        final dto = MenuDto({
          'id': 1,
          'status': 'draft',
          'name': 'Menu',
          'version': '1.0.0',
        });

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.displayOptions, isNull);
      });

      test('toEntity - DTO with empty display_options_json maps to null', () {
        // Arrange
        final json = {
          'id': 1,
          'status': 'draft',
          'name': 'Menu',
          'version': '1.0.0',
          'display_options_json': <String, dynamic>{},
        };
        final dto = MenuDto(json);

        // Act
        final entity = MenuMapper.toEntity(dto);

        // Assert
        expect(entity.displayOptions, isNull);
      });

      test(
        'toCreateDto - CreateMenuInput with displayOptions includes display_options_json',
        () {
          // Arrange
          const input = CreateMenuInput(
            name: 'Menu',
            version: '1.0.0',
            displayOptions: MenuDisplayOptions(
              showPrices: true,
              showAllergens: false,
            ),
          );

          // Act
          final dto = MenuMapper.toCreateDto(input);

          // Assert
          expect(dto['display_options_json'], isNotNull);
          expect(dto['display_options_json']['showPrices'], true);
          expect(dto['display_options_json']['showAllergens'], false);
        },
      );

      test(
        'toCreateDto - CreateMenuInput without displayOptions omits display_options_json',
        () {
          // Arrange
          const input = CreateMenuInput(name: 'Menu', version: '1.0.0');

          // Act
          final dto = MenuMapper.toCreateDto(input);

          // Assert
          expect(dto.containsKey('display_options_json'), false);
        },
      );

      test(
        'toUpdateDto - UpdateMenuInput with displayOptions includes display_options_json',
        () {
          // Arrange
          const input = UpdateMenuInput(
            id: 1,
            displayOptions: MenuDisplayOptions(
              showPrices: false,
              showAllergens: false,
            ),
          );

          // Act
          final dto = MenuMapper.toUpdateDto(input);

          // Assert
          expect(dto['display_options_json'], isNotNull);
          expect(dto['display_options_json']['showPrices'], false);
          expect(dto['display_options_json']['showAllergens'], false);
        },
      );

      test(
        'toUpdateDto - UpdateMenuInput without displayOptions omits display_options_json',
        () {
          // Arrange
          const input = UpdateMenuInput(id: 1, name: 'Updated Menu');

          // Act
          final dto = MenuMapper.toUpdateDto(input);

          // Assert
          expect(dto.containsKey('display_options_json'), false);
        },
      );
    });
  });
}
