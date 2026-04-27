import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

import 'column_builder.dart';
import 'container_builder.dart';
import 'menu_builder.dart';
import 'menu_bundle_builder.dart';
import 'page_builder.dart';
import 'size_builder.dart';
import 'user_builder.dart';
import 'widget_instance_builder.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Menu builder
  // ---------------------------------------------------------------------------
  group('buildMenu()', () {
    test('should return a Menu with sensible defaults', () {
      // Act
      final menu = buildMenu();

      // Assert
      expect(menu, isA<Menu>());
      expect(menu.id, equals(1));
      expect(menu.name, equals('Test Menu'));
      expect(menu.status, equals(Status.draft));
      expect(menu.version, equals('1'));
    });

    test('should override name when provided', () {
      // Act
      final menu = buildMenu(name: 'Dinner Menu');

      // Assert
      expect(menu.name, equals('Dinner Menu'));
    });

    test('should override status when provided', () {
      // Act
      final menu = buildMenu(status: Status.published);

      // Assert
      expect(menu.status, equals(Status.published));
    });

    test('should default allowedWidgets to empty list', () {
      // Act
      final menu = buildMenu();

      // Assert
      expect(menu.allowedWidgets, isEmpty);
    });

    test('should allow setting dateCreated', () {
      // Arrange
      final date = DateTime(2024, 1, 15);

      // Act
      final menu = buildMenu(dateCreated: date);

      // Assert
      expect(menu.dateCreated, equals(date));
    });
  });

  // ---------------------------------------------------------------------------
  // Page builder
  // ---------------------------------------------------------------------------
  group('buildPage()', () {
    test('should return a Page with sensible defaults', () {
      // Act
      final page = buildPage();

      // Assert
      expect(page, isA<Page>());
      expect(page.id, equals(1));
      expect(page.menuId, equals(1));
      expect(page.index, equals(0));
      expect(page.type, equals(PageType.content));
    });

    test('should override menuId when provided', () {
      // Act
      final page = buildPage(menuId: 42);

      // Assert
      expect(page.menuId, equals(42));
    });

    test('should override type when provided', () {
      // Act
      final page = buildPage(type: PageType.header);

      // Assert
      expect(page.type, equals(PageType.header));
    });
  });

  // ---------------------------------------------------------------------------
  // Container builder
  // ---------------------------------------------------------------------------
  group('buildContainer()', () {
    test('should return a Container with sensible defaults', () {
      // Act
      final container = buildContainer();

      // Assert
      expect(container, isA<Container>());
      expect(container.id, equals(1));
      expect(container.pageId, equals(1));
      expect(container.index, equals(0));
    });

    test('should override pageId when provided', () {
      // Act
      final container = buildContainer(pageId: 7);

      // Assert
      expect(container.pageId, equals(7));
    });

    test('should default name to null', () {
      // Act
      final container = buildContainer();

      // Assert
      expect(container.name, isNull);
    });

    test('should accept a custom name', () {
      // Act
      final container = buildContainer(name: 'Header Section');

      // Assert
      expect(container.name, equals('Header Section'));
    });
  });

  // ---------------------------------------------------------------------------
  // Column builder
  // ---------------------------------------------------------------------------
  group('buildColumn()', () {
    test('should return a Column with sensible defaults', () {
      // Act
      final column = buildColumn();

      // Assert
      expect(column, isA<Column>());
      expect(column.id, equals(1));
      expect(column.containerId, equals(1));
      expect(column.index, equals(0));
      expect(column.isDroppable, isTrue);
    });

    test('should override containerId when provided', () {
      // Act
      final column = buildColumn(containerId: 9);

      // Assert
      expect(column.containerId, equals(9));
    });

    test('should allow setting isDroppable to false', () {
      // Act
      final column = buildColumn(isDroppable: false);

      // Assert
      expect(column.isDroppable, isFalse);
    });

    test('should allow setting flex', () {
      // Act
      final column = buildColumn(flex: 2);

      // Assert
      expect(column.flex, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // WidgetInstance builder
  // ---------------------------------------------------------------------------
  group('buildWidgetInstance()', () {
    test('should return a WidgetInstance with sensible defaults', () {
      // Act
      final widget = buildWidgetInstance();

      // Assert
      expect(widget, isA<WidgetInstance>());
      expect(widget.id, equals(1));
      expect(widget.columnId, equals(1));
      expect(widget.type, equals('dish'));
      expect(widget.version, equals('1'));
      expect(widget.index, equals(0));
      expect(widget.props, isEmpty);
      expect(widget.isTemplate, isFalse);
      expect(widget.lockedForEdition, isFalse);
    });

    test('should override type when provided', () {
      // Act
      final widget = buildWidgetInstance(type: 'wine');

      // Assert
      expect(widget.type, equals('wine'));
    });

    test('should override props when provided', () {
      // Arrange
      final props = {'name': 'Soup', 'price': 5.50};

      // Act
      final widget = buildWidgetInstance(props: props);

      // Assert
      expect(widget.props, equals(props));
    });

    test('should set editingBy when provided', () {
      // Act
      final widget = buildWidgetInstance(editingBy: 'user-42');

      // Assert
      expect(widget.editingBy, equals('user-42'));
    });
  });

  // ---------------------------------------------------------------------------
  // User builder
  // ---------------------------------------------------------------------------
  group('buildUser()', () {
    test('should return a User with sensible non-admin defaults', () {
      // Act
      final user = buildUser();

      // Assert
      expect(user, isA<User>());
      expect(user.id, equals('user-1'));
      expect(user.email, equals('test@example.com'));
      expect(user.role, equals(UserRole.user));
      expect(user.areas, isEmpty);
    });

    test('should override email when provided', () {
      // Act
      final user = buildUser(email: 'chef@restaurant.com');

      // Assert
      expect(user.email, equals('chef@restaurant.com'));
    });
  });

  group('buildAdminUser()', () {
    test('should return a User with admin role', () {
      // Act
      final admin = buildAdminUser();

      // Assert
      expect(admin.role, equals(UserRole.admin));
    });

    test('should use admin-1 as the default id', () {
      // Act
      final admin = buildAdminUser();

      // Assert
      expect(admin.id, equals('admin-1'));
    });
  });

  // ---------------------------------------------------------------------------
  // Size builder
  // ---------------------------------------------------------------------------
  group('buildSize()', () {
    test('should return a Size with sensible defaults', () {
      // Act
      final size = buildSize();

      // Assert
      expect(size, isA<Size>());
      expect(size.id, equals(1));
      expect(size.name, equals('A4'));
      expect(size.width, equals(210.0));
      expect(size.height, equals(297.0));
      expect(size.status, equals(Status.published));
      expect(size.direction, equals('portrait'));
    });

    test('should override dimensions when provided', () {
      // Act
      final size = buildSize(width: 148.0, height: 210.0, name: 'A5');

      // Assert
      expect(size.width, equals(148.0));
      expect(size.height, equals(210.0));
      expect(size.name, equals('A5'));
    });

    test('should allow status to be overridden', () {
      // Act
      final size = buildSize(status: Status.draft);

      // Assert
      expect(size.status, equals(Status.draft));
    });
  });

  // ---------------------------------------------------------------------------
  // MenuBundle builder
  // ---------------------------------------------------------------------------
  group('buildMenuBundle()', () {
    test('should return a MenuBundle with sensible defaults', () {
      // Act
      final bundle = buildMenuBundle();

      // Assert
      expect(bundle, isA<MenuBundle>());
      expect(bundle.id, equals(1));
      expect(bundle.name, equals('Test Bundle'));
      expect(bundle.menuIds, isEmpty);
      expect(bundle.pdfFileId, isNull);
    });

    test('should override name when provided', () {
      // Act
      final bundle = buildMenuBundle(name: 'Weekend Specials');

      // Assert
      expect(bundle.name, equals('Weekend Specials'));
    });

    test('should carry the provided menuIds', () {
      // Act
      final bundle = buildMenuBundle(menuIds: [1, 2, 3]);

      // Assert
      expect(bundle.menuIds, equals([1, 2, 3]));
    });

    test('should allow setting a pdfFileId', () {
      // Act
      final bundle = buildMenuBundle(pdfFileId: 'file-uuid-abc');

      // Assert
      expect(bundle.pdfFileId, equals('file-uuid-abc'));
    });
  });
}
