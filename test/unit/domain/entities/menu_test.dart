import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('Menu Entity', () {
    test('should create Menu with required fields', () {
      const menu = Menu(
        id: '1',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      expect(menu.id, '1');
      expect(menu.name, 'Test Menu');
      expect(menu.status, MenuStatus.draft);
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
        id: '1',
        name: 'Complete Menu',
        status: MenuStatus.published,
        version: '2.0.0',
        dateCreated: now,
        dateUpdated: now,
        userCreated: 'user-1',
        userUpdated: 'user-2',
        styleConfig: styleConfig,
        pageSize: pageSize,
        area: 'Restaurant',
      );

      expect(menu.id, '1');
      expect(menu.name, 'Complete Menu');
      expect(menu.status, MenuStatus.published);
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
        id: '1',
        name: 'Original',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      final updated = menu.copyWith(
        name: 'Updated',
        status: MenuStatus.published,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Updated');
      expect(updated.status, MenuStatus.published);
      expect(updated.version, '1.0.0');
    });

    test('should support equality', () {
      const menu1 = Menu(
        id: '1',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      const menu2 = Menu(
        id: '1',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      expect(menu1, equals(menu2));
      expect(menu1.hashCode, equals(menu2.hashCode));
    });

    test('should not be equal with different values', () {
      const menu1 = Menu(
        id: '1',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      const menu2 = Menu(
        id: '2',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      expect(menu1, isNot(equals(menu2)));
    });

    test('should serialize to JSON', () {
      const menu = Menu(
        id: '1',
        name: 'Test Menu',
        status: MenuStatus.draft,
        version: '1.0.0',
      );

      final json = menu.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Menu');
      expect(json['status'], 'draft');
      expect(json['version'], '1.0.0');
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Menu',
        'status': 'published',
        'version': '1.0.0',
      };

      final menu = Menu.fromJson(json);

      expect(menu.id, '1');
      expect(menu.name, 'Test Menu');
      expect(menu.status, MenuStatus.published);
      expect(menu.version, '1.0.0');
    });
  });

  group('MenuStatus', () {
    test('should have correct JSON values', () {
      expect(MenuStatus.draft.name, 'draft');
      expect(MenuStatus.published.name, 'published');
      expect(MenuStatus.archived.name, 'archived');
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
