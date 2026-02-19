import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import '../../helpers/test_image_data.dart';

class MockFileRepository extends Mock implements FileRepository {}

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
        int? calories,
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
            'calories': ?calories,
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
          menuWithStyleAndWidget(null, makeDish(dietary: DietaryType.vegan)),
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

      test(
        'should generate PDF with calories when present and showAllergens true',
        () async {
          final result = await useCase.execute(
            menuWithStyleAndWidget(null, makeDish(calories: 350)),
          );
          expect(result.isSuccess, true);
        },
      );

      test('should generate PDF without calories when null', () async {
        final result = await useCase.execute(
          menuWithStyleAndWidget(null, makeDish()),
        );
        expect(result.isSuccess, true);
      });

      test(
        'should generate PDF without calories when showAllergens false',
        () async {
          final result = await useCase.execute(
            menuWithStyleAndWidget(
              null,
              makeDish(calories: 350, showAllergens: false),
            ),
          );
          expect(result.isSuccess, true);
        },
      );

      test(
        'should generate PDF with long description and calories without overflow',
        () async {
          final longDescription =
              'A beautifully crafted dish featuring slow-roasted heritage tomatoes, '
              'hand-pulled mozzarella di bufala from Campania, fresh basil leaves '
              'picked from our rooftop garden, drizzled with extra virgin olive oil '
              'from a small family estate in Tuscany, and finished with aged '
              'balsamic vinegar from Modena and a sprinkle of Maldon sea salt';
          final result = await useCase.execute(
            menuWithStyleAndWidget(
              null,
              WidgetInstance(
                id: 1,
                columnId: 1,
                type: 'dish',
                version: '3.0.0',
                index: 0,
                props: {
                  'name': 'Heritage Tomato Salad',
                  'price': 14.50,
                  'description': longDescription,
                  'showPrice': true,
                  'showAllergens': true,
                  'allergens': ['Dairy'],
                  'dietary': 'vegetarian',
                  'calories': 285,
                },
              ),
            ),
          );
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );
    });

    group('Image widget rendering', () {
      test('should handle image widget without crashing', () async {
        // Arrange
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Menu with Image',
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
                          type: 'image',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'fileId': 'test-image-123',
                            'align': 'center',
                            'fit': 'contain',
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

    group('Header and Footer rendering', () {
      test('should render header on all content pages', () async {
        // Arrange
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Menu with Header',
            status: Status.published,
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
          headerPage: PageWithContainers(
            page: entity.Page(
              id: 99,
              menuId: 1,
              name: 'Header',
              index: -1,
              type: entity.PageType.header,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 99, pageId: 99, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 99,
                      containerId: 99,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 99,
                        columnId: 99,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'text': 'HEADER',
                          'align': 'center',
                          'bold': true,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // Act
        final result = await useCase.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test('should render footer on all content pages', () async {
        // Arrange
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Menu with Footer',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
              containers: [],
            ),
          ],
          footerPage: PageWithContainers(
            page: entity.Page(
              id: 98,
              menuId: 1,
              name: 'Footer',
              index: -1,
              type: entity.PageType.footer,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 98, pageId: 98, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 98,
                      containerId: 98,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 98,
                        columnId: 98,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {'text': 'FOOTER', 'align': 'center'},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // Act
        final result = await useCase.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test('should render both header and footer on all pages', () async {
        // Arrange
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Menu with Header and Footer',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
              containers: [],
            ),
          ],
          headerPage: PageWithContainers(
            page: entity.Page(
              id: 99,
              menuId: 1,
              name: 'Header',
              index: -1,
              type: entity.PageType.header,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 99, pageId: 99, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 99,
                      containerId: 99,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 99,
                        columnId: 99,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {'text': 'HEADER', 'align': 'center'},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          footerPage: PageWithContainers(
            page: entity.Page(
              id: 98,
              menuId: 1,
              name: 'Footer',
              index: -1,
              type: entity.PageType.footer,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 98, pageId: 98, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 98,
                      containerId: 98,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 98,
                        columnId: 98,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {'text': 'FOOTER', 'align': 'center'},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // Act
        final result = await useCase.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.isNotEmpty, true);
      });
    });

    group('Image fetching', () {
      late MockFileRepository mockFileRepository;
      late GeneratePdfUseCase useCaseWithRepo;

      setUp(() {
        mockFileRepository = MockFileRepository();
        useCaseWithRepo = GeneratePdfUseCase(
          fileRepository: mockFileRepository,
        );
      });

      test('should accept an optional FileRepository parameter', () {
        final mockRepo = MockFileRepository();
        final useCaseLocal = GeneratePdfUseCase(fileRepository: mockRepo);
        expect(useCaseLocal, isNotNull);
      });

      test(
        'should fetch image bytes from FileRepository when present',
        () async {
          // Arrange
          const fileId = 'test-image-uuid';
          when(
            () => mockFileRepository.downloadFile(fileId),
          ).thenAnswer((_) async => Success(kTestPngBytes));

          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Image Test',
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
                            type: 'image',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'fileId': fileId,
                              'align': 'center',
                              'fit': 'contain',
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
          final result = await useCaseWithRepo.execute(menuTree);

          // Assert
          expect(result.isSuccess, true);
          verify(() => mockFileRepository.downloadFile(fileId)).called(1);
        },
      );

      test('should generate PDF successfully with real image bytes', () async {
        // Arrange
        const fileId = 'real-image-uuid';
        when(
          () => mockFileRepository.downloadFile(fileId),
        ).thenAnswer((_) async => Success(kTestPngBytes));

        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Real Image Test',
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
                          type: 'image',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'fileId': fileId,
                            'align': 'center',
                            'fit': 'contain',
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
        final result = await useCaseWithRepo.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test('should render placeholder when image download fails', () async {
        // Arrange
        const fileId = 'failed-image-uuid';
        when(() => mockFileRepository.downloadFile(fileId)).thenAnswer(
          (_) async => const Failure(NotFoundError('File not found')),
        );

        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Failed Image Test',
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
                          type: 'image',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'fileId': fileId,
                            'align': 'center',
                            'fit': 'contain',
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
        final result = await useCaseWithRepo.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.isNotEmpty, true);
        verify(() => mockFileRepository.downloadFile(fileId)).called(1);
      });

      test('should fetch each unique image only once', () async {
        // Arrange
        const fileId = 'shared-image-uuid';
        when(
          () => mockFileRepository.downloadFile(fileId),
        ).thenAnswer((_) async => Success(kTestPngBytes));

        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Dedup Test',
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
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'image',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'fileId': fileId,
                            'align': 'center',
                            'fit': 'contain',
                          },
                        ),
                        WidgetInstance(
                          id: 2,
                          columnId: 1,
                          type: 'image',
                          version: '1.0.0',
                          index: 1,
                          props: {
                            'fileId': fileId,
                            'align': 'left',
                            'fit': 'cover',
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
        final result = await useCaseWithRepo.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockFileRepository.downloadFile(fileId)).called(1);
      });

      test('should fetch images from header and footer pages', () async {
        // Arrange
        const headerImageId = 'header-logo-uuid';
        const footerImageId = 'footer-logo-uuid';
        when(
          () => mockFileRepository.downloadFile(any()),
        ).thenAnswer((_) async => Success(kTestPngBytes));

        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Header/Footer Test',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [],
            ),
          ],
          headerPage: PageWithContainers(
            page: entity.Page(
              id: 99,
              menuId: 1,
              name: 'Header',
              index: -1,
              type: entity.PageType.header,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 99, pageId: 99, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 99,
                      containerId: 99,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 99,
                        columnId: 99,
                        type: 'image',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'fileId': headerImageId,
                          'align': 'center',
                          'fit': 'contain',
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          footerPage: PageWithContainers(
            page: entity.Page(
              id: 98,
              menuId: 1,
              name: 'Footer',
              index: -1,
              type: entity.PageType.footer,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 98, pageId: 98, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 98,
                      containerId: 98,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 98,
                        columnId: 98,
                        type: 'image',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'fileId': footerImageId,
                          'align': 'center',
                          'fit': 'contain',
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // Act
        final result = await useCaseWithRepo.execute(menuTree);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockFileRepository.downloadFile(headerImageId)).called(1);
        verify(() => mockFileRepository.downloadFile(footerImageId)).called(1);
      });
    });

    group('content overflow handling', () {
      List<WidgetInstance> make30Dishes() {
        return List.generate(
          30,
          (i) => WidgetInstance(
            id: i + 1,
            columnId: 1,
            type: 'dish',
            version: '1.0.0',
            index: i,
            props: {
              'name': 'Dish ${i + 1}',
              'price': 10.0 + i,
              'description': 'A delicious dish number ${i + 1}',
              'showPrice': true,
              'showAllergens': true,
              'allergens': ['Gluten', 'Dairy'],
            },
          ),
        );
      }

      PageWithContainers pageWith30Dishes() {
        return PageWithContainers(
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
                  widgets: make30Dishes(),
                ),
              ],
            ),
          ],
        );
      }

      test(
        'should generate PDF with 30 dishes without footer (no clip)',
        () async {
          final menuTree = MenuTree(
            menu: const Menu(
              id: 1,
              name: 'Overflow Test',
              status: Status.published,
              version: '1.0.0',
            ),
            pages: [pageWith30Dishes()],
          );

          final result = await useCase.execute(menuTree);
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );

      test('should generate PDF with 30 dishes and footer (no clip)', () async {
        final menuTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Overflow Footer Test',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [pageWith30Dishes()],
          footerPage: const PageWithContainers(
            page: entity.Page(
              id: 98,
              menuId: 1,
              name: 'Footer',
              index: -1,
              type: entity.PageType.footer,
            ),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 98, pageId: 98, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(
                      id: 98,
                      containerId: 98,
                      index: 0,
                      flex: 1,
                    ),
                    widgets: [
                      WidgetInstance(
                        id: 98,
                        columnId: 98,
                        type: 'text',
                        version: '1.0.0',
                        index: 0,
                        props: {'text': 'FOOTER', 'align': 'center'},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        final result = await useCase.execute(menuTree);
        expect(result.isSuccess, true);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test(
        'should generate PDF with 30 dishes, border and padding style (no clip)',
        () async {
          final menuTree = MenuTree(
            menu: const Menu(
              id: 1,
              name: 'Overflow Styled Test',
              status: Status.published,
              version: '1.0.0',
              styleConfig: StyleConfig(
                borderType: BorderType.doubleOffset,
                padding: 20.0,
                margin: 30.0,
              ),
            ),
            pages: [pageWith30Dishes()],
          );

          final result = await useCase.execute(menuTree);
          expect(result.isSuccess, true);
          expect(result.valueOrNull!.isNotEmpty, true);
        },
      );
    });

    group('Grid-aligned multi-column layout', () {
      test(
        'should generate PDF with uneven widget counts across columns',
        () async {
          // Two columns: col1 has 3 widgets, col2 has 1 widget.
          // The grid layout should pad col2 with empty cells.
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Uneven Columns',
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
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 1,
                            columnId: 1,
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Dish A',
                              'price': 10.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
                            },
                          ),
                          WidgetInstance(
                            id: 2,
                            columnId: 1,
                            type: 'dish',
                            version: '1.0.0',
                            index: 1,
                            props: {
                              'name': 'Dish B',
                              'price': 11.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
                            },
                          ),
                          WidgetInstance(
                            id: 3,
                            columnId: 1,
                            type: 'dish',
                            version: '1.0.0',
                            index: 2,
                            props: {
                              'name': 'Dish C',
                              'price': 12.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
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
                            id: 4,
                            columnId: 2,
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Dish D',
                              'price': 13.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
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
        'should generate PDF with three columns and mixed flex values',
        () async {
          // Three columns with flex 1, 2, 1 — proportional widths in grid.
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Three Col Menu',
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
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 1,
                            columnId: 1,
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Left Dish',
                              'price': 8.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
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
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Center Dish',
                              'price': 15.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
                            },
                          ),
                        ],
                      ),
                      ColumnWithWidgets(
                        column: entity.Column(
                          id: 3,
                          containerId: 1,
                          index: 2,
                          flex: 1,
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 3,
                            columnId: 3,
                            type: 'dish',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Right Dish',
                              'price': 9.0,
                              'showPrice': true,
                              'showAllergens': false,
                              'allergens': [],
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

      test('should generate PDF with styled columns in grid layout', () async {
        // Two columns with padding + border styles applied per cell.
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Styled Grid',
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
                          paddingLeft: 8.0,
                          paddingRight: 8.0,
                          borderType: BorderType.plainThin,
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
                            'text': 'Styled Left',
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
                        flex: 1,
                        styleConfig: StyleConfig(
                          paddingTop: 12.0,
                          paddingBottom: 12.0,
                          borderType: BorderType.dropShadow,
                        ),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 2,
                          columnId: 2,
                          type: 'text',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'text': 'Styled Right',
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
      });

      test('should generate PDF when one column in grid is empty', () async {
        // Two columns: col1 has widgets, col2 is empty.
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Empty Column Grid',
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
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'text': 'Only in col 1',
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
                        flex: 1,
                      ),
                      widgets: [],
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
      });

      test(
        'should generate PDF with null flex values defaulting to equal width',
        () async {
          // Two columns with null flex — both should default to flex 1.
          const menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Null Flex Grid',
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
                          flex: null,
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 1,
                            columnId: 1,
                            type: 'text',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'text': 'Null flex col 1',
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
                          flex: null,
                        ),
                        widgets: [
                          WidgetInstance(
                            id: 2,
                            columnId: 2,
                            type: 'text',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'text': 'Null flex col 2',
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
    });

    group('Wine widget rendering', () {
      test('should generate PDF with wine widget', () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Wine Menu',
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
                          type: 'wine',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'name': 'Chateau Margaux',
                            'price': 12.50,
                            'description': 'Full-bodied Bordeaux',
                            'vintage': 2019,
                            'dietary': 'vegetarian',
                            'containsSulphites': true,
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
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test('should generate PDF with wine widget minimal props', () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Wine Menu Minimal',
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
                          type: 'wine',
                          version: '1.0.0',
                          index: 0,
                          props: {'name': 'House Red', 'price': 8.0},
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
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.isNotEmpty, true);
      });

      test(
        'should generate PDF with wine widget without sulphites when showAllergens false',
        () async {
          final menuTree = MenuTree(
            menu: const Menu(
              id: 1,
              name: 'Wine No Allergens',
              status: Status.published,
              version: '1.0.0',
              displayOptions: MenuDisplayOptions(showAllergens: false),
            ),
            pages: [
              const PageWithContainers(
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
                            type: 'wine',
                            version: '1.0.0',
                            index: 0,
                            props: {
                              'name': 'Merlot',
                              'price': 9.0,
                              'containsSulphites': true,
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
  });
}
