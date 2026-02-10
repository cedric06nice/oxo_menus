import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/page.dart';

void main() {
  group('PageType Enum', () {
    test('should have content, header, footer values', () {
      expect(PageType.values, contains(PageType.content));
      expect(PageType.values, contains(PageType.header));
      expect(PageType.values, contains(PageType.footer));
    });
  });

  group('Page Entity', () {
    test('should create Page with type field', () {
      const page = Page(
        id: 1,
        menuId: 1,
        name: 'Header',
        index: 0,
        type: PageType.header,
      );

      expect(page.type, PageType.header);
    });

    test('should default to PageType.content when type is omitted', () {
      const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      expect(page.type, PageType.content);
    });

    test('should create Page with required fields', () {
      const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      expect(page.id, 1);
      expect(page.menuId, 1);
      expect(page.name, 'Page 1');
      expect(page.index, 0);
      expect(page.dateCreated, null);
      expect(page.dateUpdated, null);
    });

    test('should create Page with all fields', () {
      final now = DateTime.now();
      final page = Page(
        id: 1,
        menuId: 1,
        name: 'First Page',
        index: 0,
        dateCreated: now,
        dateUpdated: now,
      );

      expect(page.id, 1);
      expect(page.menuId, 1);
      expect(page.name, 'First Page');
      expect(page.index, 0);
      expect(page.dateCreated, now);
      expect(page.dateUpdated, now);
    });

    test('should support copyWith', () {
      const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      final updated = page.copyWith(name: 'Updated Page', index: 1);

      expect(updated.id, 1);
      expect(updated.menuId, 1);
      expect(updated.name, 'Updated Page');
      expect(updated.index, 1);
    });

    test('should support equality', () {
      const page1 = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      const page2 = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      expect(page1, equals(page2));
      expect(page1.hashCode, equals(page2.hashCode));
    });

    test('should serialize to JSON', () {
      const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

      final json = page.toJson();

      expect(json['id'], 1);
      expect(json['menuId'], 1);
      expect(json['name'], 'Page 1');
      expect(json['index'], 0);
    });

    test('should deserialize from JSON', () {
      final json = {'id': 1, 'menuId': 1, 'name': 'Page 1', 'index': 0};

      final page = Page.fromJson(json);

      expect(page.id, 1);
      expect(page.menuId, 1);
      expect(page.name, 'Page 1');
      expect(page.index, 0);
    });
  });
}
