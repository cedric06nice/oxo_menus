import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
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
                          'dietary': 'vegetarian',
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
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
            page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
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
                          'dietary': null,
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

    group('page format resolution', () {
      MenuTree menuWithPageSize(PageSize? pageSize) {
        return MenuTree(
          menu: Menu(
            id: 1,
            name: 'Format Test',
            status: Status.published,
            version: '1.0.0',
            pageSize: pageSize,
          ),
          pages: const [],
        );
      }

      test('should succeed with a4 page size', () async {
        final result = await useCase.execute(
          menuWithPageSize(const PageSize(name: 'a4', width: 210, height: 297)),
        );
        expect(result.isSuccess, true);
      });

      test('should succeed with letter page size', () async {
        final result = await useCase.execute(
          menuWithPageSize(
            const PageSize(name: 'letter', width: 216, height: 279),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should succeed with custom page size', () async {
        final result = await useCase.execute(
          menuWithPageSize(
            const PageSize(name: 'custom', width: 100, height: 200),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should succeed with null pageSize (A4 default)', () async {
        final result = await useCase.execute(menuWithPageSize(null));
        expect(result.isSuccess, true);
      });
    });

    group('per-container and per-column styleConfig', () {
      test(
        'should generate PDF with container styleConfig (margin + border)',
        () async {
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Container Style Test',
              status: Status.published,
              version: '1.0.0',
            ),
            pages: [
              PageWithContainers(
                page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
                containers: [
                  ContainerWithColumns(
                    container: entity.Container(
                      id: 1,
                      pageId: 1,
                      index: 0,
                      styleConfig: StyleConfig(
                        marginTop: 10.0,
                        marginBottom: 20.0,
                        paddingLeft: 8.0,
                        paddingRight: 8.0,
                        borderType: BorderType.plainThin,
                      ),
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
                              'text': 'Hello',
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

          final result = await useCase.execute(menuTree);
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );

      test(
        'should generate PDF with column styleConfig (padding + border)',
        () async {
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Column Style Test',
              status: Status.published,
              version: '1.0.0',
            ),
            pages: [
              PageWithContainers(
                page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
                containers: [
                  ContainerWithColumns(
                    container: entity.Container(id: 1, pageId: 1, index: 0),
                    columns: [
                      ColumnWithWidgets(
                        column: entity.Column(
                          id: 1,
                          containerId: 1,
                          index: 0,
                          flex: 1,
                          styleConfig: StyleConfig(
                            paddingTop: 10.0,
                            paddingBottom: 10.0,
                            paddingLeft: 6.0,
                            paddingRight: 6.0,
                            borderType: BorderType.dropShadow,
                          ),
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 1,
                            columnId: 1,
                            type: 'text',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'text': 'Styled Column',
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

          final result = await useCase.execute(menuTree);
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );

      test(
        'should generate PDF with both container and column styleConfig',
        () async {
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Both Style Test',
              status: Status.published,
              version: '1.0.0',
              styleConfig: StyleConfig(borderType: BorderType.plainThick),
            ),
            pages: [
              PageWithContainers(
                page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
                containers: [
                  ContainerWithColumns(
                    container: entity.Container(
                      id: 1,
                      pageId: 1,
                      index: 0,
                      styleConfig: StyleConfig(
                        marginBottom: 24.0,
                        borderType: BorderType.doubleOffset,
                      ),
                    ),
                    columns: [
                      ColumnWithWidgets(
                        column: entity.Column(
                          id: 1,
                          containerId: 1,
                          index: 0,
                          flex: 1,
                          styleConfig: StyleConfig(
                            paddingLeft: 12.0,
                            paddingRight: 12.0,
                            borderType: BorderType.plainThin,
                          ),
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 1,
                            columnId: 1,
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Styled Dish',
                              'price': 15.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
                              'dietary': null,
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

          final result = await useCase.execute(menuTree);
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );
    });

    group('styleConfig and widget prop variations', () {
      WidgetInstance makeDish({
        bool showPrice = true,
        bool showAllergens = true,
        List<String> allergens = const [],
        DietaryType? dietary,
      }) {
        return WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '3.0.0',
          index: 0,
          props: {
            'name': 'Test Dish',
            'price': 9.99,
            'showPrice': showPrice,
            'showAllergens': showAllergens,
            'allergens': allergens,
            'dietary': dietary?.name,
          },
        );
      }

      MenuTree menuWithStyleAndWidget(
        StyleConfig? styleConfig,
        WidgetInstance widget,
      ) {
        return MenuTree(
          menu: Menu(
            id: 1,
            name: 'Style Test',
            status: Status.published,
            version: '1.0.0',
            styleConfig: styleConfig,
          ),
          pages: [
            PageWithContainers(
              page: const entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: const entity.Container(id: 1, pageId: 1, index: 0),
                  columns: [
                    ColumnWithWidgets(
                      column: const entity.Column(
                        id: 1,
                        containerId: 1,
                        index: 0,
                        flex: 1,
                      ),
                      widgets: [widget],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }

      test('should handle null styleConfig without crashing', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(null, makeDish()),
        );
        expect(result.isSuccess, true);
      });

      test('should handle custom fontSize and padding', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            const StyleConfig(fontSize: 20.0, padding: 24.0),
            makeDish(),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should render dish with showPrice false', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(null, makeDish(showPrice: false)),
        );
        expect(result.isSuccess, true);
      });

      test('should render dish with showAllergens false', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(null, makeDish(showAllergens: false)),
        );
        expect(result.isSuccess, true);
      });

      test('should render dish with empty allergens and dietary', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(null, makeDish(allergens: [])),
        );
        expect(result.isSuccess, true);
      });

      test('should render dish with dietary type', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            null,
            makeDish(dietary: DietaryType.vegan),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should generate PDF with per-side padding and margins', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            const StyleConfig(
              marginTop: 40.0,
              marginBottom: 40.0,
              marginLeft: 30.0,
              marginRight: 30.0,
              paddingTop: 10.0,
              paddingBottom: 10.0,
              paddingLeft: 10.0,
              paddingRight: 10.0,
            ),
            makeDish(),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should generate PDF with border type plainThick', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            const StyleConfig(borderType: BorderType.plainThick),
            makeDish(),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should generate PDF with border type doubleOffset', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            const StyleConfig(borderType: BorderType.doubleOffset),
            makeDish(),
          ),
        );
        expect(result.isSuccess, true);
      });

      test('should generate PDF with border type dropShadow', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(
            const StyleConfig(borderType: BorderType.dropShadow),
            makeDish(),
          ),
        );
        expect(result.isSuccess, true);
      });
    });
  });
}
