import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PdfDocumentBuilder builder;
  late ByteData baseFontData;
  late ByteData boldFontData;
  late ByteData sectionFontData;

  setUpAll(() async {
    baseFontData = await rootBundle.load('assets/fonts/FuturaStd-Light.ttf');
    boldFontData = await rootBundle.load('assets/fonts/FuturaStd-Book.ttf');
    sectionFontData = await rootBundle.load(
      'assets/fonts/LibreBaskerville-Regular.ttf',
    );
  });

  setUp(() {
    builder = const PdfDocumentBuilder();
  });

  group('PdfDocumentBuilder', () {
    test('should return valid non-empty PDF bytes for empty menu', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Empty Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        pages: [],
      );

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
      // PDF magic bytes: %PDF
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('should produce valid PDF with dish widget', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Dish Menu',
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
                          'name': 'Test Dish',
                          'price': 12.5,
                          'description': 'A tasty dish',
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test('should produce valid PDF with text and section widgets', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Text Menu',
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
                          'title': 'Starters',
                          'uppercase': true,
                          'showDivider': true,
                        },
                      ),
                      WidgetInstance(
                        id: 2,
                        columnId: 1,
                        type: 'text',
                        version: '1.0.0',
                        index: 1,
                        props: {
                          'text': 'Welcome to our restaurant',
                          'fontSize': 14.0,
                          'bold': false,
                          'italic': false,
                          'align': 'center',
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test('should produce valid PDF with wine widget', () async {
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
                          'name': 'Chateau Test',
                          'price': 45.0,
                          'description': 'Full bodied red',
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test('should produce valid PDF with dish_to_share widget', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Sharing Menu',
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
                        type: 'dish_to_share',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'name': 'Mezze Platter',
                          'price': 18.5,
                          'description': 'Selection of dips',
                          'servings': 2,
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test(
      'should produce valid PDF with dish_to_share without servings',
      () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Sharing Menu',
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
                          type: 'dish_to_share',
                          version: '1.0.0',
                          index: 0,
                          props: {'name': 'Sharing Board', 'price': 24.0},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test('should produce valid PDF with set_menu_dish widget', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Set Menu',
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
                        type: 'set_menu_dish',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'name': 'Beef Wellington',
                          'description': 'With truffle jus',
                          'hasSupplement': true,
                          'supplementPrice': 7.5,
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test(
      'should produce valid PDF with set_menu_dish without supplement',
      () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Set Menu',
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
                          type: 'set_menu_dish',
                          version: '1.0.0',
                          index: 0,
                          props: {'name': 'Soup of the Day'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test('should produce valid PDF with set_menu_title widget', () async {
      const menuTree = MenuTree(
        menu: Menu(
          id: 1,
          name: 'Set Menu',
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
                        type: 'set_menu_title',
                        version: '1.0.0',
                        index: 0,
                        props: {
                          'title': 'Set Lunch Menu',
                          'subtitle': 'Seasonal dishes',
                          'priceLabel1': '3 Courses',
                          'price1': 45.0,
                          'priceLabel2': '4 Courses',
                          'price2': 55.0,
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

      final bytes = await builder.buildDocument(
        menuTree: menuTree,
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: {},
      );

      expect(bytes, isNotEmpty);
    });

    test(
      'should produce valid PDF with set_menu_title without prices',
      () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Set Menu',
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
                          type: 'set_menu_title',
                          version: '1.0.0',
                          index: 0,
                          props: {'title': 'Tasting Menu'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test(
      'should produce valid PDF with dish widget with very long name',
      () async {
        const longName =
            'Slow-Braised Heritage Beef Short Rib with Truffle Pomme Puree, '
            'Seasonal Root Vegetables, and a Rich Red Wine Jus Reduction Glaze';
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Overflow Menu',
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
                            'name': longName,
                            'price': 42.5,
                            'description': 'A signature dish',
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

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test(
      'should produce valid PDF with wine widget with very long name',
      () async {
        const longName =
            'Domaine de la Romanée-Conti Grand Cru Monopole Pinot Noir '
            'Burgundy Côte de Nuits Premier Selection Vintage Reserve';
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Wine Overflow',
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
                            'name': longName,
                            'price': 850.0,
                            'vintage': 2015,
                            'description': 'Exceptional vintage',
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

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test(
      'should produce valid PDF with dish_to_share widget with very long name',
      () async {
        const longName =
            'Mediterranean Grand Seafood Platter with King Prawns, Oysters, '
            'Lobster Tails, Smoked Salmon, and Champagne Butter Sauce';
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Sharing Overflow',
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
                          type: 'dish_to_share',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'name': longName,
                            'price': 65.0,
                            'description': 'For the table',
                            'servings': 4,
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

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test(
      'should produce valid PDF with set_menu_dish widget with very long name',
      () async {
        const longName =
            'Pan-Seared Wild Scottish Salmon with Crushed Jersey Royals, '
            'Wilted Samphire, Lemon and Caper Beurre Blanc Sauce';
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Set Menu Overflow',
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
                          type: 'set_menu_dish',
                          version: '1.0.0',
                          index: 0,
                          props: {
                            'name': longName,
                            'description': 'Main course',
                            'hasSupplement': true,
                            'supplementPrice': 12.0,
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

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
      },
    );

    test(
      'should produce valid PDF with column verticalAlignment set',
      () async {
        const menuTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Aligned Menu',
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
                        styleConfig: StyleConfig(
                          verticalAlignment: VerticalAlignment.center,
                        ),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1.0.0',
                          index: 0,
                          props: {'text': 'Centered text'},
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
                          verticalAlignment: VerticalAlignment.bottom,
                        ),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 2,
                          columnId: 2,
                          type: 'text',
                          version: '1.0.0',
                          index: 0,
                          props: {'text': 'Bottom text'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
        expect(bytes[0], 0x25); // %PDF
        expect(bytes[1], 0x50);
      },
    );

    test(
      'should produce valid PDF with nested containers and mainAxisAlignment',
      () async {
        final menuTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Nested Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: const entity.Page(
                id: 1,
                menuId: 1,
                name: 'Page 1',
                index: 0,
              ),
              containers: [
                ContainerWithColumns(
                  container: const entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: entity.LayoutConfig(
                      direction: 'column',
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
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 1,
                            containerId: 2,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 1,
                              columnId: 1,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Child 1'},
                            ),
                          ],
                        ),
                      ],
                    ),
                    ContainerWithColumns(
                      container: const entity.Container(
                        id: 3,
                        pageId: 1,
                        index: 1,
                        parentContainerId: 1,
                      ),
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 2,
                            containerId: 3,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 2,
                              columnId: 2,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Child 2'},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
        expect(bytes[0], 0x25); // %PDF
        expect(bytes[1], 0x50);
      },
    );

    test(
      'should produce valid PDF with row-direction nested containers',
      () async {
        final menuTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Row Nested Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: const entity.Page(
                id: 1,
                menuId: 1,
                name: 'Page 1',
                index: 0,
              ),
              containers: [
                ContainerWithColumns(
                  container: const entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: entity.LayoutConfig(
                      direction: 'row',
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
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 1,
                            containerId: 2,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 1,
                              columnId: 1,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Left'},
                            ),
                          ],
                        ),
                      ],
                    ),
                    ContainerWithColumns(
                      container: const entity.Container(
                        id: 3,
                        pageId: 1,
                        index: 1,
                        parentContainerId: 1,
                      ),
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 2,
                            containerId: 3,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 2,
                              columnId: 2,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Right'},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
        expect(bytes[0], 0x25); // %PDF
        expect(bytes[1], 0x50);
      },
    );

    test(
      'should produce valid PDF with column spaceEvenly alignment',
      () async {
        final menuTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'SpaceEvenly Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: const entity.Page(
                id: 1,
                menuId: 1,
                name: 'Page 1',
                index: 0,
              ),
              containers: [
                ContainerWithColumns(
                  container: const entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: entity.LayoutConfig(
                      direction: 'column',
                      mainAxisAlignment: 'spaceEvenly',
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
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 1,
                            containerId: 2,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 1,
                              columnId: 1,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Top'},
                            ),
                          ],
                        ),
                      ],
                    ),
                    ContainerWithColumns(
                      container: const entity.Container(
                        id: 3,
                        pageId: 1,
                        index: 1,
                        parentContainerId: 1,
                      ),
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 2,
                            containerId: 3,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 2,
                              columnId: 2,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Bottom'},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
        expect(bytes[0], 0x25); // %PDF
        expect(bytes[1], 0x50);
      },
    );

    test(
      'should produce valid PDF with column spaceAround alignment',
      () async {
        final menuTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'SpaceAround Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          pages: [
            PageWithContainers(
              page: const entity.Page(
                id: 1,
                menuId: 1,
                name: 'Page 1',
                index: 0,
              ),
              containers: [
                ContainerWithColumns(
                  container: const entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: entity.LayoutConfig(
                      direction: 'column',
                      mainAxisAlignment: 'spaceAround',
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
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 1,
                            containerId: 2,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 1,
                              columnId: 1,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Top'},
                            ),
                          ],
                        ),
                      ],
                    ),
                    ContainerWithColumns(
                      container: const entity.Container(
                        id: 3,
                        pageId: 1,
                        index: 1,
                        parentContainerId: 1,
                      ),
                      columns: [
                        ColumnWithWidgets(
                          column: const entity.Column(
                            id: 2,
                            containerId: 3,
                            index: 0,
                          ),
                          widgets: const [
                            WidgetInstance(
                              id: 2,
                              columnId: 2,
                              type: 'text',
                              version: '1.0.0',
                              index: 0,
                              props: {'text': 'Bottom'},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: {},
        );

        expect(bytes, isNotEmpty);
        expect(bytes[0], 0x25); // %PDF
        expect(bytes[1], 0x50);
      },
    );

    group('section widget alignment', () {
      const sectionWidget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'section',
        version: '1.0.0',
        index: 0,
        props: {'title': 'Starters', 'uppercase': true, 'showDivider': true},
      );

      pw.Column columnForAlignment(WidgetAlignment alignment) {
        final sectionFont = pw.Font.ttf(sectionFontData);
        final widget = builder.debugBuildSection(
          sectionWidget,
          null,
          sectionFont,
          alignment,
        );
        final container = widget as pw.Container;
        return container.child as pw.Column;
      }

      test('start alignment maps to start cross-axis and left text', () {
        final column = columnForAlignment(WidgetAlignment.start);
        expect(column.crossAxisAlignment, pw.CrossAxisAlignment.start);
        final title = column.children.first as pw.Text;
        expect(title.textAlign, pw.TextAlign.left);
      });

      test('center alignment maps to center cross-axis and center text', () {
        final column = columnForAlignment(WidgetAlignment.center);
        expect(column.crossAxisAlignment, pw.CrossAxisAlignment.center);
        final title = column.children.first as pw.Text;
        expect(title.textAlign, pw.TextAlign.center);
      });

      test('end alignment maps to end cross-axis and right text', () {
        final column = columnForAlignment(WidgetAlignment.end);
        expect(column.crossAxisAlignment, pw.CrossAxisAlignment.end);
        final title = column.children.first as pw.Text;
        expect(title.textAlign, pw.TextAlign.right);
      });

      test('justified degrades to start for sections (no price line)', () {
        final column = columnForAlignment(WidgetAlignment.justified);
        expect(column.crossAxisAlignment, pw.CrossAxisAlignment.start);
        final title = column.children.first as pw.Text;
        expect(title.textAlign, pw.TextAlign.left);
      });

      test(
        'buildDocument honours center alignment configured via allowedWidgets',
        () async {
          final menuTree = MenuTree(
            menu: Menu(
              id: 1,
              name: 'Aligned Menu',
              status: Status.published,
              version: '1.0.0',
              allowedWidgets: const [
                WidgetTypeConfig(
                  type: 'section',
                  alignment: WidgetAlignment.center,
                ),
              ],
            ),
            pages: const [
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
                        widgets: [sectionWidget],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );

          final bytes = await builder.buildDocument(
            menuTree: menuTree,
            baseFontData: baseFontData,
            boldFontData: boldFontData,
            sectionFontData: sectionFontData,
            imageCache: {},
          );

          expect(bytes, isNotEmpty);
          expect(bytes[0], 0x25); // %PDF
        },
      );
    });
  });
}
