import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';

void main() {
  group('Menu Entity', () {
    test('should create Menu with required fields', () {
      const menu = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      expect(menu.id, 1);
      expect(menu.name, 'Test Menu');
      expect(menu.status, Status.draft);
      expect(menu.version, '1.0.0');
      expect(menu.dateCreated, null);
      expect(menu.dateUpdated, null);
      expect(menu.userCreated, null);
      expect(menu.userUpdated, null);
      expect(menu.styleConfig, null);
      expect(menu.pageSize, null);
      expect(menu.area, null);
    });

    test('should create Menu with all fields', () {
      final now = DateTime.now();
      const styleConfig = StyleConfig(
        fontFamily: 'Arial',
        fontSize: 14.0,
        primaryColor: '#000000',
      );
      const pageSize = PageSize(
        name: 'A4',
        width: 210.0,
        height: 297.0,
      );

      final menu = Menu(
        id: 1,
        name: 'Complete Menu',
        status: Status.published,
        version: '2.0.0',
        dateCreated: now,
        dateUpdated: now,
        userCreated: 'user-1',
        userUpdated: 'user-2',
        styleConfig: styleConfig,
        pageSize: pageSize,
        area: 'Restaurant',
      );

      expect(menu.id, 1);
      expect(menu.name, 'Complete Menu');
      expect(menu.status, Status.published);
      expect(menu.version, '2.0.0');
      expect(menu.dateCreated, now);
      expect(menu.dateUpdated, now);
      expect(menu.userCreated, 'user-1');
      expect(menu.userUpdated, 'user-2');
      expect(menu.styleConfig, styleConfig);
      expect(menu.pageSize, pageSize);
      expect(menu.area, 'Restaurant');
    });

    test('should support copyWith', () {
      const menu = Menu(
        id: 1,
        name: 'Original',
        status: Status.draft,
        version: '1.0.0',
      );

      final updated = menu.copyWith(
        name: 'Updated',
        status: Status.published,
      );

      expect(updated.id, 1);
      expect(updated.name, 'Updated');
      expect(updated.status, Status.published);
      expect(updated.version, '1.0.0');
    });

    test('should support equality', () {
      const menu1 = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      const menu2 = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      expect(menu1, equals(menu2));
      expect(menu1.hashCode, equals(menu2.hashCode));
    });

    test('should not be equal with different values', () {
      const menu1 = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      const menu2 = Menu(
        id: 2,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      expect(menu1, isNot(equals(menu2)));
    });

    test('should serialize to JSON', () {
      const menu = Menu(
        id: 1,
        name: 'Test Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      final json = menu.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test Menu');
      expect(json['status'], 'draft');
      expect(json['version'], '1.0.0');
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 1,
        'name': 'Test Menu',
        'status': 'published',
        'version': '1.0.0',
      };

      final menu = Menu.fromJson(json);

      expect(menu.id, 1);
      expect(menu.name, 'Test Menu');
      expect(menu.status, Status.published);
      expect(menu.version, '1.0.0');
    });
  });

  group('Status', () {
    test('should have correct JSON values', () {
      expect(Status.draft.name, 'draft');
      expect(Status.published.name, 'published');
      expect(Status.archived.name, 'archived');
    });
  });

  group('StyleConfig', () {
    test('should create StyleConfig with all fields', () {
      const config = StyleConfig(
        fontFamily: 'Arial',
        fontSize: 14.0,
        primaryColor: '#000000',
        secondaryColor: '#FFFFFF',
        backgroundColor: '#F0F0F0',
        marginTop: 10.0,
        marginBottom: 10.0,
        marginLeft: 15.0,
        marginRight: 15.0,
        padding: 8.0,
      );

      expect(config.fontFamily, 'Arial');
      expect(config.fontSize, 14.0);
      expect(config.primaryColor, '#000000');
      expect(config.secondaryColor, '#FFFFFF');
      expect(config.backgroundColor, '#F0F0F0');
      expect(config.marginTop, 10.0);
      expect(config.marginBottom, 10.0);
      expect(config.marginLeft, 15.0);
      expect(config.marginRight, 15.0);
      expect(config.padding, 8.0);
    });

    test('should support copyWith', () {
      const config = StyleConfig(
        fontFamily: 'Arial',
        fontSize: 14.0,
      );

      final updated = config.copyWith(fontSize: 16.0);

      expect(updated.fontFamily, 'Arial');
      expect(updated.fontSize, 16.0);
    });

    test('should serialize to JSON', () {
      const config = StyleConfig(
        fontFamily: 'Arial',
        fontSize: 14.0,
        primaryColor: '#000000',
      );

      final json = config.toJson();

      expect(json['fontFamily'], 'Arial');
      expect(json['fontSize'], 14.0);
      expect(json['primaryColor'], '#000000');
    });

    test('should deserialize from JSON', () {
      final json = {
        'fontFamily': 'Arial',
        'fontSize': 14.0,
        'primaryColor': '#000000',
      };

      final config = StyleConfig.fromJson(json);

      expect(config.fontFamily, 'Arial');
      expect(config.fontSize, 14.0);
      expect(config.primaryColor, '#000000');
    });

    test('should create StyleConfig with per-side padding fields', () {
      const config = StyleConfig(
        paddingTop: 10.0,
        paddingBottom: 12.0,
        paddingLeft: 8.0,
        paddingRight: 8.0,
      );

      expect(config.paddingTop, 10.0);
      expect(config.paddingBottom, 12.0);
      expect(config.paddingLeft, 8.0);
      expect(config.paddingRight, 8.0);
    });

    test('should default per-side padding fields to null', () {
      const config = StyleConfig();

      expect(config.paddingTop, isNull);
      expect(config.paddingBottom, isNull);
      expect(config.paddingLeft, isNull);
      expect(config.paddingRight, isNull);
    });

    test('should support copyWith for per-side padding', () {
      const config = StyleConfig(padding: 16.0);

      final updated = config.copyWith(
        paddingTop: 20.0,
        paddingBottom: 24.0,
      );

      expect(updated.padding, 16.0);
      expect(updated.paddingTop, 20.0);
      expect(updated.paddingBottom, 24.0);
      expect(updated.paddingLeft, isNull);
      expect(updated.paddingRight, isNull);
    });

    test('should serialize per-side padding to JSON', () {
      const config = StyleConfig(
        paddingTop: 10.0,
        paddingBottom: 12.0,
        paddingLeft: 8.0,
        paddingRight: 8.0,
      );

      final json = config.toJson();

      expect(json['paddingTop'], 10.0);
      expect(json['paddingBottom'], 12.0);
      expect(json['paddingLeft'], 8.0);
      expect(json['paddingRight'], 8.0);
    });

    test('should deserialize per-side padding from JSON', () {
      final json = {
        'paddingTop': 10.0,
        'paddingBottom': 12.0,
        'paddingLeft': 8.0,
        'paddingRight': 8.0,
      };

      final config = StyleConfig.fromJson(json);

      expect(config.paddingTop, 10.0);
      expect(config.paddingBottom, 12.0);
      expect(config.paddingLeft, 8.0);
      expect(config.paddingRight, 8.0);
    });

    test('should create StyleConfig with borderType', () {
      const config = StyleConfig(borderType: BorderType.plainThin);

      expect(config.borderType, BorderType.plainThin);
    });

    test('should default borderType to null', () {
      const config = StyleConfig();

      expect(config.borderType, isNull);
    });

    test('should support copyWith for borderType', () {
      const config = StyleConfig(borderType: BorderType.none);

      final updated = config.copyWith(borderType: BorderType.dropShadow);

      expect(updated.borderType, BorderType.dropShadow);
    });

    test('should serialize borderType to JSON', () {
      const config = StyleConfig(borderType: BorderType.plainThick);

      final json = config.toJson();

      expect(json['borderType'], 'plain_thick');
    });

    test('should deserialize borderType from JSON', () {
      final json = {'borderType': 'double_offset'};

      final config = StyleConfig.fromJson(json);

      expect(config.borderType, BorderType.doubleOffset);
    });
  });

  group('PageSize', () {
    test('should create PageSize with required fields', () {
      const pageSize = PageSize(
        name: 'A4',
        width: 210.0,
        height: 297.0,
      );

      expect(pageSize.name, 'A4');
      expect(pageSize.width, 210.0);
      expect(pageSize.height, 297.0);
    });

    test('should support copyWith', () {
      const pageSize = PageSize(
        name: 'A4',
        width: 210.0,
        height: 297.0,
      );

      final updated = pageSize.copyWith(name: 'Letter');

      expect(updated.name, 'Letter');
      expect(updated.width, 210.0);
      expect(updated.height, 297.0);
    });

    test('should serialize to JSON', () {
      const pageSize = PageSize(
        name: 'A4',
        width: 210.0,
        height: 297.0,
      );

      final json = pageSize.toJson();

      expect(json['name'], 'A4');
      expect(json['width'], 210.0);
      expect(json['height'], 297.0);
    });

    test('should deserialize from JSON', () {
      final json = {
        'name': 'A4',
        'width': 210.0,
        'height': 297.0,
      };

      final pageSize = PageSize.fromJson(json);

      expect(pageSize.name, 'A4');
      expect(pageSize.width, 210.0);
      expect(pageSize.height, 297.0);
    });
  });
}
