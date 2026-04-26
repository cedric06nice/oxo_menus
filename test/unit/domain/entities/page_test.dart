import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import '../../../fakes/builders/page_builder.dart';

void main() {
  group('PageType enum', () {
    group('values', () {
      test('should have exactly three cases', () {
        expect(PageType.values.length, 3);
      });

      test('should include content case', () {
        expect(PageType.values, contains(PageType.content));
      });

      test('should include header case', () {
        expect(PageType.values, contains(PageType.header));
      });

      test('should include footer case', () {
        expect(PageType.values, contains(PageType.footer));
      });
    });

    group('name', () {
      test('should have name "content" for content case', () {
        expect(PageType.content.name, 'content');
      });

      test('should have name "header" for header case', () {
        expect(PageType.header.name, 'header');
      });

      test('should have name "footer" for footer case', () {
        expect(PageType.footer.name, 'footer');
      });
    });

    group('equality', () {
      test('should not be equal to a different case', () {
        expect(PageType.content, isNot(equals(PageType.header)));
        expect(PageType.header, isNot(equals(PageType.footer)));
      });
    });
  });

  group('Page', () {
    group('construction', () {
      test(
        'should create page with correct required fields when all required fields are provided',
        () {
          // Arrange & Act
          const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

          // Assert
          expect(page.id, 1);
          expect(page.menuId, 1);
          expect(page.name, 'Page 1');
          expect(page.index, 0);
        },
      );

      test(
        'should default type to PageType.content when type is not specified',
        () {
          // Arrange & Act
          const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

          // Assert
          expect(page.type, PageType.content);
        },
      );

      test('should default dateCreated to null when not specified', () {
        // Arrange & Act
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Assert
        expect(page.dateCreated, isNull);
      });

      test('should default dateUpdated to null when not specified', () {
        // Arrange & Act
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Assert
        expect(page.dateUpdated, isNull);
      });

      test(
        'should store PageType.header when type is explicitly set to header',
        () {
          // Arrange & Act
          const page = Page(
            id: 1,
            menuId: 1,
            name: 'Header',
            index: 0,
            type: PageType.header,
          );

          // Assert
          expect(page.type, PageType.header);
        },
      );

      test(
        'should store PageType.footer when type is explicitly set to footer',
        () {
          // Arrange & Act
          const page = Page(
            id: 1,
            menuId: 1,
            name: 'Footer',
            index: 0,
            type: PageType.footer,
          );

          // Assert
          expect(page.type, PageType.footer);
        },
      );

      test(
        'should store dateCreated and dateUpdated when both are provided',
        () {
          // Arrange
          final created = DateTime(2024, 1, 10);
          final updated = DateTime(2024, 1, 20);

          // Act
          final page = Page(
            id: 1,
            menuId: 1,
            name: 'Page 1',
            index: 0,
            dateCreated: created,
            dateUpdated: updated,
          );

          // Assert
          expect(page.dateCreated, created);
          expect(page.dateUpdated, updated);
        },
      );
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);
        const b = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);
        const b = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);
        const b = Page(id: 2, menuId: 1, name: 'Page 1', index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when menuId differs', () {
        // Arrange
        const a = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);
        const b = Page(id: 1, menuId: 2, name: 'Page 1', index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when type differs', () {
        // Arrange
        const a = Page(
          id: 1,
          menuId: 1,
          name: 'P',
          index: 0,
          type: PageType.content,
        );
        const b = Page(
          id: 1,
          menuId: 1,
          name: 'P',
          index: 0,
          type: PageType.header,
        );

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Act
        final updated = page.copyWith(name: 'Updated Page');

        // Assert
        expect(updated.name, 'Updated Page');
        expect(updated.id, 1);
      });

      test('should update index when copyWith is called with a new index', () {
        // Arrange
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Act
        final updated = page.copyWith(index: 2);

        // Assert
        expect(updated.index, 2);
      });

      test('should update type when copyWith is called with a new type', () {
        // Arrange
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Act
        final updated = page.copyWith(type: PageType.footer);

        // Assert
        expect(updated.type, PageType.footer);
      });

      test('should preserve unchanged fields when only index is updated', () {
        // Arrange
        final page = buildPage(id: 5, menuId: 3, name: 'My Page', index: 1);

        // Act
        final updated = page.copyWith(index: 4);

        // Assert
        expect(updated.id, 5);
        expect(updated.menuId, 3);
        expect(updated.name, 'My Page');
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Act
        final result = page.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize id, menuId, name and index to JSON', () {
        // Arrange
        const page = Page(id: 1, menuId: 1, name: 'Page 1', index: 0);

        // Act
        final json = page.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['menuId'], 1);
        expect(json['name'], 'Page 1');
        expect(json['index'], 0);
      });

      test('should deserialize page from JSON with correct field values', () {
        // Arrange
        final json = {'id': 1, 'menuId': 1, 'name': 'Page 1', 'index': 0};

        // Act
        final page = Page.fromJson(json);

        // Assert
        expect(page.id, 1);
        expect(page.menuId, 1);
        expect(page.name, 'Page 1');
        expect(page.index, 0);
      });

      test('should deserialize type from JSON string value', () {
        // Arrange
        final json = {
          'id': 1,
          'menuId': 1,
          'name': 'Header',
          'index': 0,
          'type': 'header',
        };

        // Act
        final page = Page.fromJson(json);

        // Assert
        expect(page.type, PageType.header);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = Page(
          id: 3,
          menuId: 7,
          name: 'Content Page',
          index: 1,
          type: PageType.content,
        );

        // Act
        final restored = Page.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
