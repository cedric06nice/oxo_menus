import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';

void main() {
  late GeneratePdfUseCase useCase;

  setUp(() {
    useCase = const GeneratePdfUseCase();
  });

  group('GeneratePdfUseCase', () {
    test('should generate PDF for empty menu', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Empty Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should generate PDF with single page', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Single Page Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should generate PDF with dish widgets', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Menu with Dishes',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'dish',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'name': 'Pasta Carbonara',
                          'price': 12.50,
                          'description': 'Classic Italian pasta',
                          'showPrice': true,
                          'showAllergens': true,
                          'allergens': ['Dairy', 'Gluten'],
                          'dietary': ['Vegetarian'],
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should generate PDF with text widgets', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Menu with Text',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'text': 'Welcome to our restaurant',
                          'align': 'center',
                          'bold': true,
                          'italic': false,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should generate PDF with section widgets', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Menu with Sections',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'section',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'title': 'Appetizers',
                          'uppercase': true,
                          'showDivider': true,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should generate PDF with multiple columns', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Multi-Column Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'text': 'Column 1',
                          'align': 'left',
                          'bold': false,
                          'italic': false,
                        },
                      ),
                    ],
                  ),
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 2,
                      containerId: 1,
                      index: 1,
                      flex: 2,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 2,
                        columnId: 2,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'text': 'Column 2',
                          'align': 'left',
                          'bold': false,
                          'italic': false,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });

    test('should apply default page format when pageSize is null', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Default Size Menu',
          status: Status.published,
          version: '1.0.0',
          pageSize: null,
        ),
        pages: [],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
    });

    test('should handle unknown widget types gracefully', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Menu with Unknown Widget',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'unknown_type',
                        version: '1.0.0',
                        index: 0,
                        props: {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
    });

    test('should generate PDF with complex layout', () async {
      // Arrange
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Complex Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [
          PageWithContainers(
            page: entity.Page(
              id: 1,
              menuId: 1,
              name: 'Page 1',
              index: 0,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(
                  id: 1,
                  pageId: 1,
                  index: 0,
                  name: 'Main Courses',
                ),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 1,
                      containerId: 1,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'section',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'title': 'Pasta',
                          'uppercase': true,
                          'showDivider': true,
                        },
                      ),
                      WidgetInstance(
                        id: 2,
                        columnId: 1,
                        type: 'dish',
                        version: '1.0.0',
                        index: 1,
                        props: {
                          'name': 'Spaghetti Carbonara',
                          'price': 14.50,
                          'description': 'Traditional Italian pasta',
                          'showPrice': true,
                          'showAllergens': true,
                          'allergens': ['Dairy', 'Gluten', 'Eggs'],
                          'dietary': [],
                        },
                      ),
                    ],
                  ),
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 2,
                      containerId: 1,
                      index: 1,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 3,
                        columnId: 2,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'text': 'All dishes freshly prepared',
                          'align': 'center',
                          'bold': true,
                          'italic': true,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act
      final result = await useCase.execute(menuTree);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull, isNotNull);
      expect(result.valueOrNull!.isNotEmpty, true);
    });
  });
}
