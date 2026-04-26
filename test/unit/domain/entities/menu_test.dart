import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import '../../../fakes/builders/menu_builder.dart';

void main() {
  group('Menu', () {
    group('construction', () {
      test('should create menu with correct required fields when id, name, status and version are provided', () {
        // Arrange & Act
        const menu = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(menu.id, 1);
        expect(menu.name, 'Test Menu');
        expect(menu.status, Status.draft);
        expect(menu.version, '1.0.0');
      });

      test('should default optional fields to null when not specified', () {
        // Arrange & Act
        const menu = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(menu.dateCreated, isNull);
        expect(menu.dateUpdated, isNull);
        expect(menu.userCreated, isNull);
        expect(menu.userUpdated, isNull);
        expect(menu.styleConfig, isNull);
        expect(menu.pageSize, isNull);
        expect(menu.area, isNull);
        expect(menu.displayOptions, isNull);
      });

      test('should default allowedWidgets to empty list when not specified', () {
        // Arrange & Act
        const menu = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(menu.allowedWidgets, isEmpty);
      });

      test('should store all optional fields when all fields are provided', () {
        // Arrange
        final now = DateTime(2024, 6, 1);
        const style = StyleConfig(fontFamily: 'Arial');
        const size = PageSize(name: 'A4', width: 210.0, height: 297.0);
        const area = Area(id: 1, name: 'Dining');
        const displayOpts = MenuDisplayOptions(showPrices: false);

        // Act
        final menu = Menu(
          id: 5,
          name: 'Dinner Menu',
          status: Status.published,
          version: '2.0.0',
          dateCreated: now,
          dateUpdated: now,
          userCreated: 'user-1',
          userUpdated: 'user-2',
          styleConfig: style,
          pageSize: size,
          area: area,
          displayOptions: displayOpts,
        );

        // Assert
        expect(menu.styleConfig, style);
        expect(menu.pageSize, size);
        expect(menu.area, area);
        expect(menu.displayOptions, displayOpts);
        expect(menu.userCreated, 'user-1');
        expect(menu.userUpdated, 'user-2');
        expect(menu.dateCreated, now);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');
        const b = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');
        const b = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');
        const b = Menu(id: 2, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when status differs', () {
        // Arrange
        const a = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');
        const b = Menu(id: 1, name: 'Test Menu', status: Status.published, version: '1.0.0');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const menu = Menu(id: 1, name: 'Original', status: Status.draft, version: '1.0.0');

        // Act
        final updated = menu.copyWith(name: 'Updated');

        // Assert
        expect(updated.name, 'Updated');
        expect(updated.id, 1);
      });

      test('should update status when copyWith is called with a new status', () {
        // Arrange
        const menu = Menu(id: 1, name: 'Original', status: Status.draft, version: '1.0.0');

        // Act
        final updated = menu.copyWith(status: Status.published);

        // Assert
        expect(updated.status, Status.published);
        expect(updated.name, 'Original');
      });

      test('should update allowedWidgets when copyWith is called with a new list', () {
        // Arrange
        const menu = Menu(id: 1, name: 'M', status: Status.draft, version: '1');

        // Act
        final updated = menu.copyWith(
          allowedWidgets: [const WidgetTypeConfig(type: 'dish')],
        );

        // Assert
        expect(updated.allowedWidgets, hasLength(1));
        expect(updated.allowedWidgets.first.type, 'dish');
      });

      test('should preserve id when only name is updated via copyWith', () {
        // Arrange
        final menu = buildMenu(id: 42, name: 'Old');

        // Act
        final updated = menu.copyWith(name: 'New');

        // Assert
        expect(updated.id, 42);
      });
    });

    group('allowedWidgetTypes getter', () {
      test('should return empty set when allowedWidgets is empty', () {
        // Arrange
        const menu = Menu(id: 1, name: 'M', status: Status.draft, version: '1');

        // Assert
        expect(menu.allowedWidgetTypes, isEmpty);
      });

      test('should return only enabled widget type strings when some configs are enabled', () {
        // Arrange
        const menu = Menu(
          id: 1,
          name: 'M',
          status: Status.draft,
          version: '1',
          allowedWidgets: [
            WidgetTypeConfig(type: 'dish'),
            WidgetTypeConfig(type: 'text'),
            WidgetTypeConfig(type: 'section', enabled: false),
          ],
        );

        // Assert
        expect(menu.allowedWidgetTypes, {'dish', 'text'});
        expect(menu.allowedWidgetTypes, isNot(contains('section')));
      });

      test('should return empty set when all widget configs are disabled', () {
        // Arrange
        const menu = Menu(
          id: 1,
          name: 'M',
          status: Status.draft,
          version: '1',
          allowedWidgets: [
            WidgetTypeConfig(type: 'dish', enabled: false),
            WidgetTypeConfig(type: 'text', enabled: false),
          ],
        );

        // Assert
        expect(menu.allowedWidgetTypes, isEmpty);
      });
    });

    group('alignmentFor method', () {
      test('should return the configured alignment when the type exists in allowedWidgets', () {
        // Arrange
        const menu = Menu(
          id: 1,
          name: 'M',
          status: Status.draft,
          version: '1',
          allowedWidgets: [
            WidgetTypeConfig(type: 'dish', alignment: WidgetAlignment.justified),
          ],
        );

        // Assert
        expect(menu.alignmentFor('dish'), WidgetAlignment.justified);
      });

      test('should return WidgetAlignment.start when the type is not in allowedWidgets', () {
        // Arrange
        const menu = Menu(id: 1, name: 'M', status: Status.draft, version: '1');

        // Assert
        expect(menu.alignmentFor('nonexistent'), WidgetAlignment.start);
      });

      test('should return the alignment even when the config is disabled', () {
        // Arrange
        const menu = Menu(
          id: 1,
          name: 'M',
          status: Status.draft,
          version: '1',
          allowedWidgets: [
            WidgetTypeConfig(
              type: 'section',
              alignment: WidgetAlignment.center,
              enabled: false,
            ),
          ],
        );

        // Assert
        expect(menu.alignmentFor('section'), WidgetAlignment.center);
      });

      test('should return the first matching type alignment when multiple configs exist', () {
        // Arrange
        const menu = Menu(
          id: 1,
          name: 'M',
          status: Status.draft,
          version: '1',
          allowedWidgets: [
            WidgetTypeConfig(type: 'dish', alignment: WidgetAlignment.end),
            WidgetTypeConfig(type: 'wine', alignment: WidgetAlignment.center),
          ],
        );

        // Assert
        expect(menu.alignmentFor('dish'), WidgetAlignment.end);
        expect(menu.alignmentFor('wine'), WidgetAlignment.center);
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const menu = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Act
        final result = menu.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        const menu = Menu(id: 1, name: 'Test Menu', status: Status.draft, version: '1.0.0');

        // Act
        final json = menu.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Test Menu');
        expect(json['status'], 'draft');
        expect(json['version'], '1.0.0');
      });

      test('should serialize status as "published" for published status', () {
        // Arrange
        const menu = Menu(id: 1, name: 'M', status: Status.published, version: '1');

        // Act
        final json = menu.toJson();

        // Assert
        expect(json['status'], 'published');
      });

      test('should serialize status as "archived" for archived status', () {
        // Arrange
        const menu = Menu(id: 1, name: 'M', status: Status.archived, version: '1');

        // Act
        final json = menu.toJson();

        // Assert
        expect(json['status'], 'archived');
      });

      test('should deserialize menu from JSON with correct field values', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test Menu',
          'status': 'published',
          'version': '1.0.0',
        };

        // Act
        final menu = Menu.fromJson(json);

        // Assert
        expect(menu.id, 1);
        expect(menu.name, 'Test Menu');
        expect(menu.status, Status.published);
        expect(menu.version, '1.0.0');
      });

      test('should deserialize allowedWidgets from JSON with correct alignment', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'M',
          'status': 'draft',
          'version': '1',
          'allowedWidgets': [
            {'type': 'dish', 'alignment': 'justified'},
            {'type': 'text'},
          ],
        };

        // Act
        final menu = Menu.fromJson(json);

        // Assert
        expect(menu.allowedWidgets, hasLength(2));
        expect(menu.allowedWidgets[0].alignment, WidgetAlignment.justified);
        expect(menu.allowedWidgets[1].alignment, WidgetAlignment.start);
      });

      test('should round-trip through JSON preserving equality for minimal menu', () {
        // Arrange
        const original = Menu(id: 1, name: 'Minimal', status: Status.draft, version: '1');

        // Act
        final restored = Menu.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });

  group('StyleConfig', () {
    group('construction', () {
      test('should create StyleConfig with all fields null by default', () {
        // Arrange & Act
        const config = StyleConfig();

        // Assert
        expect(config.fontFamily, isNull);
        expect(config.fontSize, isNull);
        expect(config.primaryColor, isNull);
        expect(config.secondaryColor, isNull);
        expect(config.backgroundColor, isNull);
        expect(config.margin, isNull);
        expect(config.padding, isNull);
        expect(config.borderType, isNull);
        expect(config.verticalAlignment, isNull);
      });

      test('should store all fields when fully specified', () {
        // Arrange & Act
        const config = StyleConfig(
          fontFamily: 'Arial',
          fontSize: 14.0,
          primaryColor: '#000000',
          secondaryColor: '#FFFFFF',
          backgroundColor: '#F0F0F0',
          margin: 10.0,
          marginTop: 10.0,
          marginBottom: 10.0,
          marginLeft: 15.0,
          marginRight: 15.0,
          padding: 8.0,
          paddingTop: 4.0,
          paddingBottom: 4.0,
          paddingLeft: 6.0,
          paddingRight: 6.0,
          borderType: BorderType.plainThin,
          verticalAlignment: VerticalAlignment.center,
        );

        // Assert
        expect(config.fontFamily, 'Arial');
        expect(config.fontSize, 14.0);
        expect(config.primaryColor, '#000000');
        expect(config.marginTop, 10.0);
        expect(config.paddingLeft, 6.0);
        expect(config.borderType, BorderType.plainThin);
        expect(config.verticalAlignment, VerticalAlignment.center);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = StyleConfig(fontFamily: 'Arial', fontSize: 14.0);
        const b = StyleConfig(fontFamily: 'Arial', fontSize: 14.0);

        // Assert
        expect(a, equals(b));
      });

      test('should not be equal when fontFamily differs', () {
        // Arrange
        const a = StyleConfig(fontFamily: 'Arial');
        const b = StyleConfig(fontFamily: 'Helvetica');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update fontSize when copyWith is called with a new fontSize', () {
        // Arrange
        const config = StyleConfig(fontFamily: 'Arial', fontSize: 14.0);

        // Act
        final updated = config.copyWith(fontSize: 16.0);

        // Assert
        expect(updated.fontFamily, 'Arial');
        expect(updated.fontSize, 16.0);
      });

      test('should update paddingTop when copyWith is called with a new paddingTop', () {
        // Arrange
        const config = StyleConfig(padding: 16.0);

        // Act
        final updated = config.copyWith(paddingTop: 20.0, paddingBottom: 24.0);

        // Assert
        expect(updated.padding, 16.0);
        expect(updated.paddingTop, 20.0);
        expect(updated.paddingBottom, 24.0);
        expect(updated.paddingLeft, isNull);
      });

      test('should update borderType when copyWith is called with a new borderType', () {
        // Arrange
        const config = StyleConfig(borderType: BorderType.none);

        // Act
        final updated = config.copyWith(borderType: BorderType.dropShadow);

        // Assert
        expect(updated.borderType, BorderType.dropShadow);
      });
    });

    group('JSON serialization', () {
      test('should serialize fontFamily, fontSize and primaryColor to JSON', () {
        // Arrange
        const config = StyleConfig(
          fontFamily: 'Arial',
          fontSize: 14.0,
          primaryColor: '#000000',
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['fontFamily'], 'Arial');
        expect(json['fontSize'], 14.0);
        expect(json['primaryColor'], '#000000');
      });

      test('should serialize borderType as its JSON string value', () {
        // Arrange
        const config = StyleConfig(borderType: BorderType.plainThick);

        // Act
        final json = config.toJson();

        // Assert
        expect(json['borderType'], 'plain_thick');
      });

      test('should deserialize borderType from JSON string value', () {
        // Arrange
        final json = {'borderType': 'double_offset'};

        // Act
        final config = StyleConfig.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.doubleOffset);
      });

      test('should serialize per-side padding fields to JSON', () {
        // Arrange
        const config = StyleConfig(
          paddingTop: 10.0,
          paddingBottom: 12.0,
          paddingLeft: 8.0,
          paddingRight: 8.0,
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['paddingTop'], 10.0);
        expect(json['paddingBottom'], 12.0);
        expect(json['paddingLeft'], 8.0);
        expect(json['paddingRight'], 8.0);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = StyleConfig(
          fontFamily: 'Georgia',
          fontSize: 12.0,
          borderType: BorderType.dropShadow,
          verticalAlignment: VerticalAlignment.bottom,
        );

        // Act
        final restored = StyleConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });

  group('PageSize', () {
    group('construction', () {
      test('should create PageSize with correct required fields', () {
        // Arrange & Act
        const size = PageSize(name: 'A4', width: 210.0, height: 297.0);

        // Assert
        expect(size.name, 'A4');
        expect(size.width, 210.0);
        expect(size.height, 297.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = PageSize(name: 'A4', width: 210.0, height: 297.0);
        const b = PageSize(name: 'A4', width: 210.0, height: 297.0);

        // Assert
        expect(a, equals(b));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const a = PageSize(name: 'A4', width: 210.0, height: 297.0);
        const b = PageSize(name: 'A3', width: 210.0, height: 297.0);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const size = PageSize(name: 'A4', width: 210.0, height: 297.0);

        // Act
        final updated = size.copyWith(name: 'Letter');

        // Assert
        expect(updated.name, 'Letter');
        expect(updated.width, 210.0);
        expect(updated.height, 297.0);
      });
    });

    group('JSON serialization', () {
      test('should serialize name, width and height to JSON', () {
        // Arrange
        const size = PageSize(name: 'A4', width: 210.0, height: 297.0);

        // Act
        final json = size.toJson();

        // Assert
        expect(json['name'], 'A4');
        expect(json['width'], 210.0);
        expect(json['height'], 297.0);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = PageSize(name: 'A5', width: 148.0, height: 210.0);

        // Act
        final restored = PageSize.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
