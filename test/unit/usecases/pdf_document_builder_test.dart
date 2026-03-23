import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';

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
  });
}
