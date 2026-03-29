import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/presentation/widgets/canvas/template_canvas.dart';

void main() {
  group('TemplateCanvas', () {
    testWidgets('should display empty state when no pages', (tester) async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
        pages: [],
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TemplateCanvas(menuTree: menuTree)),
        ),
      );

      // Assert
      expect(find.text('No pages in this menu'), findsOneWidget);
    });

    testWidgets('should render single page without PageView', (tester) async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TemplateCanvas(menuTree: menuTree, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(PageCanvas), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('should render multiple pages with PageView', (tester) async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [],
          ),
          PageWithContainers(
            page: entity.Page(id: 2, menuId: 1, name: 'Page 2', index: 1),
            containers: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TemplateCanvas(menuTree: menuTree, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PageView), findsOneWidget);
    });
  });

  group('PageCanvas', () {
    testWidgets('should display page name in editable mode', (tester) async {
      // Arrange
      const pageData = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Test Page', index: 0),
        containers: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PageCanvas(page: pageData, isEditable: true)),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('should not display page name in non-editable mode', (
      tester,
    ) async {
      // Arrange
      const pageData = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Test Page', index: 0),
        containers: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PageCanvas(page: pageData, isEditable: false)),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Page'), findsNothing);
    });

    testWidgets('should render containers', (tester) async {
      // Arrange
      const pageData = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Test Page', index: 0),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 1,
              pageId: 1,
              index: 0,
              name: 'Container 1',
            ),
            columns: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PageCanvas(page: pageData, isEditable: true)),
          ),
        ),
      );

      // Assert
      expect(find.byType(ContainerCanvas), findsOneWidget);
      expect(find.text('Container 1'), findsOneWidget);
    });
  });

  group('ContainerCanvas', () {
    testWidgets('should display container name in editable mode', (
      tester,
    ) async {
      // Arrange
      const containerData = ContainerWithColumns(
        container: entity.Container(
          id: 1,
          pageId: 1,
          index: 0,
          name: 'Test Container',
        ),
        columns: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContainerCanvas(container: containerData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Container'), findsOneWidget);
    });

    testWidgets('should not display container name in non-editable mode', (
      tester,
    ) async {
      // Arrange
      const containerData = ContainerWithColumns(
        container: entity.Container(
          id: 1,
          pageId: 1,
          index: 0,
          name: 'Test Container',
        ),
        columns: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContainerCanvas(
                container: containerData,
                isEditable: false,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Container'), findsNothing);
    });

    testWidgets('should render columns in a row', (tester) async {
      // Arrange
      const containerData = ContainerWithColumns(
        container: entity.Container(id: 1, pageId: 1, index: 0),
        columns: [
          ColumnWithWidgets(
            column: entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
            widgets: [],
          ),
          ColumnWithWidgets(
            column: entity.Column(id: 2, containerId: 1, index: 1, flex: 2),
            widgets: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContainerCanvas(container: containerData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ColumnCanvas), findsNWidgets(2));
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should respect column flex values', (tester) async {
      // Arrange
      const containerData = ContainerWithColumns(
        container: entity.Container(id: 1, pageId: 1, index: 0),
        columns: [
          ColumnWithWidgets(
            column: entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
            widgets: [],
          ),
          ColumnWithWidgets(
            column: entity.Column(id: 2, containerId: 1, index: 1, flex: 3),
            widgets: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContainerCanvas(container: containerData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      final expandedWidgets = tester.widgetList<Expanded>(
        find.byType(Expanded),
      );
      expect(expandedWidgets.length, 2);
      expect(expandedWidgets.elementAt(0).flex, 1);
      expect(expandedWidgets.elementAt(1).flex, 3);
    });
  });

  group('ColumnCanvas', () {
    testWidgets('should display empty state in editable mode when no widgets', (
      tester,
    ) async {
      // Arrange
      const columnData = ColumnWithWidgets(
        column: entity.Column(id: 1, containerId: 1, index: 0),
        widgets: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ColumnCanvas(column: columnData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Empty column'), findsOneWidget);
    });

    testWidgets('should not display empty state in non-editable mode', (
      tester,
    ) async {
      // Arrange
      const columnData = ColumnWithWidgets(
        column: entity.Column(id: 1, containerId: 1, index: 0),
        widgets: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ColumnCanvas(column: columnData, isEditable: false),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Empty column'), findsNothing);
    });

    testWidgets('should have visible border in editable mode', (tester) async {
      // Arrange
      const columnData = ColumnWithWidgets(
        column: entity.Column(id: 1, containerId: 1, index: 0),
        widgets: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ColumnCanvas(column: columnData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.color,
        isNot(Colors.transparent),
      );
    });

    testWidgets('should have transparent border in non-editable mode', (
      tester,
    ) async {
      // Arrange
      const columnData = ColumnWithWidgets(
        column: entity.Column(id: 1, containerId: 1, index: 0),
        widgets: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ColumnCanvas(column: columnData, isEditable: false),
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border as Border).top.color, Colors.transparent);
    });

    testWidgets('should render widgets', (tester) async {
      // Arrange
      const columnData = ColumnWithWidgets(
        column: entity.Column(id: 1, containerId: 1, index: 0),
        widgets: [
          WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1.0.0',
            index: 0,
            props: {'text': 'Test Text'},
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ColumnCanvas(column: columnData, isEditable: false),
            ),
          ),
        ),
      );

      // Assert
      // WidgetRenderer should be present
      expect(find.byType(ColumnCanvas), findsOneWidget);
    });
  });

  group('ColumnCanvas - Vertical Alignment', () {
    testWidgets(
      'should use MainAxisAlignment.start when verticalAlignment is top',
      (tester) async {
        const columnData = ColumnWithWidgets(
          column: entity.Column(
            id: 1,
            containerId: 1,
            index: 0,
            styleConfig: StyleConfig(verticalAlignment: VerticalAlignment.top),
          ),
          widgets: [],
        );

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ColumnCanvas(column: columnData, isEditable: false),
              ),
            ),
          ),
        );

        final column = tester.widgetList<Column>(find.byType(Column)).last;
        expect(column.mainAxisAlignment, MainAxisAlignment.start);
      },
    );

    testWidgets(
      'should use MainAxisAlignment.center when verticalAlignment is center',
      (tester) async {
        const columnData = ColumnWithWidgets(
          column: entity.Column(
            id: 1,
            containerId: 1,
            index: 0,
            styleConfig: StyleConfig(
              verticalAlignment: VerticalAlignment.center,
            ),
          ),
          widgets: [],
        );

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ColumnCanvas(column: columnData, isEditable: false),
              ),
            ),
          ),
        );

        final column = tester.widgetList<Column>(find.byType(Column)).last;
        expect(column.mainAxisAlignment, MainAxisAlignment.center);
      },
    );

    testWidgets(
      'should use MainAxisAlignment.end when verticalAlignment is bottom',
      (tester) async {
        const columnData = ColumnWithWidgets(
          column: entity.Column(
            id: 1,
            containerId: 1,
            index: 0,
            styleConfig: StyleConfig(
              verticalAlignment: VerticalAlignment.bottom,
            ),
          ),
          widgets: [],
        );

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ColumnCanvas(column: columnData, isEditable: false),
              ),
            ),
          ),
        );

        final column = tester.widgetList<Column>(find.byType(Column)).last;
        expect(column.mainAxisAlignment, MainAxisAlignment.end);
      },
    );

    testWidgets(
      'should default to MainAxisAlignment.start when no verticalAlignment',
      (tester) async {
        const columnData = ColumnWithWidgets(
          column: entity.Column(id: 1, containerId: 1, index: 0),
          widgets: [],
        );

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ColumnCanvas(column: columnData, isEditable: false),
              ),
            ),
          ),
        );

        final column = tester.widgetList<Column>(find.byType(Column)).last;
        expect(column.mainAxisAlignment, MainAxisAlignment.start);
      },
    );
  });

  group('PageCanvas - Header/Footer', () {
    testWidgets('should render header containers above content', (
      tester,
    ) async {
      // Arrange
      const headerPage = PageWithContainers(
        page: entity.Page(
          id: 99,
          menuId: 1,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 101,
              pageId: 99,
              index: 0,
              name: 'Header Container',
            ),
            columns: [],
          ),
        ],
      );

      const contentPage = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Content Page', index: 0),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 1,
              pageId: 1,
              index: 0,
              name: 'Content Container',
            ),
            columns: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PageCanvas(
                page: contentPage,
                headerPage: headerPage,
                isEditable: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Header Container'), findsOneWidget);
      expect(find.text('Content Container'), findsOneWidget);

      // Verify header appears before content
      final headerFinder = find.text('Header Container');
      final contentFinder = find.text('Content Container');
      final headerY = tester.getTopLeft(headerFinder).dy;
      final contentY = tester.getTopLeft(contentFinder).dy;
      expect(headerY, lessThan(contentY));
    });

    testWidgets('should render footer containers below content', (
      tester,
    ) async {
      // Arrange
      const footerPage = PageWithContainers(
        page: entity.Page(
          id: 98,
          menuId: 1,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 102,
              pageId: 98,
              index: 0,
              name: 'Footer Container',
            ),
            columns: [],
          ),
        ],
      );

      const contentPage = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Content Page', index: 0),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 1,
              pageId: 1,
              index: 0,
              name: 'Content Container',
            ),
            columns: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PageCanvas(
                page: contentPage,
                footerPage: footerPage,
                isEditable: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Footer Container'), findsOneWidget);
      expect(find.text('Content Container'), findsOneWidget);

      // Verify footer appears after content
      final contentFinder = find.text('Content Container');
      final footerFinder = find.text('Footer Container');
      final contentY = tester.getTopLeft(contentFinder).dy;
      final footerY = tester.getTopLeft(footerFinder).dy;
      expect(footerY, greaterThan(contentY));
    });

    testWidgets('should render both header and footer with content', (
      tester,
    ) async {
      // Arrange
      const headerPage = PageWithContainers(
        page: entity.Page(
          id: 99,
          menuId: 1,
          name: 'Header',
          index: 0,
          type: entity.PageType.header,
        ),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 101,
              pageId: 99,
              index: 0,
              name: 'Header Container',
            ),
            columns: [],
          ),
        ],
      );

      const footerPage = PageWithContainers(
        page: entity.Page(
          id: 98,
          menuId: 1,
          name: 'Footer',
          index: 0,
          type: entity.PageType.footer,
        ),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 102,
              pageId: 98,
              index: 0,
              name: 'Footer Container',
            ),
            columns: [],
          ),
        ],
      );

      const contentPage = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Content Page', index: 0),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: 1,
              pageId: 1,
              index: 0,
              name: 'Content Container',
            ),
            columns: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PageCanvas(
                page: contentPage,
                headerPage: headerPage,
                footerPage: footerPage,
                isEditable: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Header Container'), findsOneWidget);
      expect(find.text('Content Container'), findsOneWidget);
      expect(find.text('Footer Container'), findsOneWidget);

      // Verify order: header < content < footer
      final headerY = tester.getTopLeft(find.text('Header Container')).dy;
      final contentY = tester.getTopLeft(find.text('Content Container')).dy;
      final footerY = tester.getTopLeft(find.text('Footer Container')).dy;

      expect(headerY, lessThan(contentY));
      expect(contentY, lessThan(footerY));
    });
  });

  group('Responsive Layout', () {
    testWidgets('should use IntrinsicHeight for columns', (tester) async {
      // Arrange
      const containerData = ContainerWithColumns(
        container: entity.Container(id: 1, pageId: 1, index: 0),
        columns: [
          ColumnWithWidgets(
            column: entity.Column(id: 1, containerId: 1, index: 0, flex: 1),
            widgets: [],
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContainerCanvas(container: containerData, isEditable: true),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(IntrinsicHeight), findsOneWidget);
    });

    testWidgets(
      'should render nested child containers in a Column for column direction',
      (tester) async {
        final containerData = ContainerWithColumns(
          container: const entity.Container(
            id: 1,
            pageId: 1,
            index: 0,
            layout: entity.LayoutConfig(
              direction: 'column',
              mainAxisAlignment: 'center',
            ),
          ),
          columns: const [],
          children: [
            ContainerWithColumns(
              container: const entity.Container(
                id: 2,
                pageId: 1,
                index: 0,
                parentContainerId: 1,
              ),
              columns: const [],
            ),
            ContainerWithColumns(
              container: const entity.Container(
                id: 3,
                pageId: 1,
                index: 1,
                parentContainerId: 1,
              ),
              columns: const [],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ContainerCanvas(
                  container: containerData,
                  isEditable: false,
                ),
              ),
            ),
          ),
        );

        // Should find 3 ContainerCanvas widgets (parent + 2 children)
        expect(find.byType(ContainerCanvas), findsNWidgets(3));
      },
    );

    testWidgets(
      'should render nested child containers in a Row for row direction',
      (tester) async {
        final containerData = ContainerWithColumns(
          container: const entity.Container(
            id: 1,
            pageId: 1,
            index: 0,
            layout: entity.LayoutConfig(
              direction: 'row',
              mainAxisAlignment: 'spaceBetween',
            ),
          ),
          columns: const [],
          children: [
            ContainerWithColumns(
              container: const entity.Container(
                id: 2,
                pageId: 1,
                index: 0,
                parentContainerId: 1,
              ),
              columns: const [],
            ),
            ContainerWithColumns(
              container: const entity.Container(
                id: 3,
                pageId: 1,
                index: 1,
                parentContainerId: 1,
              ),
              columns: const [],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ContainerCanvas(
                  container: containerData,
                  isEditable: false,
                ),
              ),
            ),
          ),
        );

        // Should find 3 ContainerCanvas widgets
        expect(find.byType(ContainerCanvas), findsNWidgets(3));
      },
    );

    testWidgets('should use SingleChildScrollView for page', (tester) async {
      // Arrange
      const pageData = PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Test Page', index: 0),
        containers: [],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PageCanvas(page: pageData, isEditable: true)),
          ),
        ),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
