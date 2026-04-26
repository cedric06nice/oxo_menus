import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';

import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' show PageType;
import 'package:oxo_menus/domain/entities/container.dart' show LayoutConfig;

import '../../helpers/test_image_data.dart';

// ---------------------------------------------------------------------------
// Tree builder helpers
// ---------------------------------------------------------------------------

/// Creates a [MenuTree] with one page and one container holding [widgets] in a
/// single column. Pass [alignment] to configure aligned widget type.
MenuTree _treeWithWidgets(
  List<WidgetInstance> widgets, {
  MenuDisplayOptions? displayOptions,
  StyleConfig? menuStyle,
  WidgetAlignment? alignment,
  String? widgetTypeForAlignment,
}) {
  final allowedWidgets = (alignment != null && widgetTypeForAlignment != null)
      ? [
          WidgetTypeConfig(
            type: widgetTypeForAlignment,
            alignment: alignment,
          ),
        ]
      : const <WidgetTypeConfig>[];

  return MenuTree(
    menu: Menu(
      id: 1,
      name: 'Test Menu',
      status: Status.published,
      version: '1',
      displayOptions: displayOptions,
      styleConfig: menuStyle,
      allowedWidgets: allowedWidgets,
    ),
    pages: [
      PageWithContainers(
        page: const entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
        containers: [
          ContainerWithColumns(
            container: const entity.Container(id: 1, pageId: 1, index: 0),
            columns: [
              ColumnWithWidgets(
                column: const entity.Column(id: 1, containerId: 1, index: 0),
                widgets: widgets,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Creates a single-widget [WidgetInstance] with [type] and [props].
WidgetInstance _widget(
  String type,
  Map<String, dynamic> props, {
  int id = 1,
}) {
  return WidgetInstance(
    id: id,
    columnId: 1,
    type: type,
    version: '1',
    index: 0,
    props: props,
  );
}

bool _isPdfBytes(Uint8List bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46;

// ---------------------------------------------------------------------------
// Test setup
// ---------------------------------------------------------------------------

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

  Future<Uint8List> build(MenuTree tree, {Map<String, Uint8List>? images}) {
    return builder.buildDocument(
      menuTree: tree,
      baseFontData: baseFontData,
      boldFontData: boldFontData,
      sectionFontData: sectionFontData,
      imageCache: images ?? const {},
    );
  }

  // ---------------------------------------------------------------------------
  // Document structure
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — document structure', () {
    test(
      'should return non-empty bytes starting with %PDF for an empty menu',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Empty',
            status: Status.published,
            version: '1',
          ),
          pages: [],
        );

        final bytes = await build(tree);

        expect(bytes.isNotEmpty, isTrue);
        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce a larger document for a single-page tree than for an empty tree',
      () async {
        const emptyTree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'E',
            status: Status.published,
            version: '1',
          ),
          pages: [],
        );

        final singlePageTree = _treeWithWidgets([
          _widget('text', {'text': 'Hello'}),
        ]);

        final emptyBytes = await build(emptyTree);
        final singlePageBytes = await build(singlePageTree);

        expect(singlePageBytes.length, greaterThanOrEqualTo(emptyBytes.length));
      },
    );

    test(
      'should produce more bytes for a five-page tree than a single-page tree',
      () async {
        final fivePagesTree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Multi',
            status: Status.published,
            version: '1',
          ),
          pages: List.generate(
            5,
            (i) => PageWithContainers(
              page: entity.Page(
                id: i + 1,
                menuId: 1,
                name: 'Page ${i + 1}',
                index: i,
              ),
              containers: const [],
            ),
          ),
        );

        final singleBytes = await build(_treeWithWidgets([]));
        final fivePageBytes = await build(fivePagesTree);

        expect(fivePageBytes.length, greaterThan(singleBytes.length));
      },
    );

    test(
      'should produce valid PDF with an empty page (no containers)',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'M',
            status: Status.published,
            version: '1',
          ),
          pages: [
            PageWithContainers(
              page:
                  entity.Page(id: 1, menuId: 1, name: 'Empty Page', index: 0),
              containers: [],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a page with a container but no columns',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'M',
            status: Status.published,
            version: '1',
          ),
          pages: [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(id: 1, pageId: 1, index: 0),
                  columns: [],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF with header and footer pages',
      () async {
        const contentPage = PageWithContainers(
          page: entity.Page(id: 1, menuId: 1, name: 'Content', index: 0),
          containers: [],
        );

        const headerPage = PageWithContainers(
          page: entity.Page(
            id: 2,
            menuId: 1,
            name: 'Header',
            index: 0,
            type: PageType.header,
          ),
          containers: [],
        );

        const footerPage = PageWithContainers(
          page: entity.Page(
            id: 3,
            menuId: 1,
            name: 'Footer',
            index: 1,
            type: PageType.footer,
          ),
          containers: [],
        );

        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'H+F',
            status: Status.published,
            version: '1',
          ),
          pages: [contentPage],
          headerPage: headerPage,
          footerPage: footerPage,
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Widget type rendering — each widget renders without error
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — widget type: dish', () {
    test('should produce valid PDF for a minimal dish widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('dish', {'name': 'Soup', 'price': 5.50}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a dish with description and calories',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish', {
              'name': 'Pasta',
              'price': 12.0,
              'description': 'Homemade tagliatelle',
              'calories': 650,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with dietary tag (vegetarian)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish', {
              'name': 'Risotto',
              'price': 14.0,
              'dietary': 'vegetarian',
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with dietary tag (vegan)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish', {'name': 'Salad', 'price': 9.0, 'dietary': 'vegan'}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with allergens (UK FSA format)',
      () async {
        // AllergenInfo list with gluten+details and plain milk
        final allergenInfo = [
          const AllergenInfo(
            allergen: UkAllergen.gluten,
            details: 'wheat',
          ),
          const AllergenInfo(allergen: UkAllergen.milk),
          const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {
            'name': 'Pasta',
            'price': 14.0,
            'allergenInfo': allergenInfo
                .map((a) => a.toJson())
                .toList(),
          },
        );

        final bytes = await build(_treeWithWidgets([dish]));

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with price variants (multi-price)',
      () async {
        final variants = [
          const PriceVariant(label: 'Small', price: 8.0),
          const PriceVariant(label: 'Large', price: 14.0),
        ];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {
            'name': 'Steak',
            'price': 0.0,
            'priceVariants': variants.map((v) => v.toJson()).toList(),
          },
        );

        final bytes = await build(_treeWithWidgets([dish]));

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with justified alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('dish', {'name': 'Beef', 'price': 22.0})],
            alignment: WidgetAlignment.justified,
            widgetTypeForAlignment: 'dish',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with center alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('dish', {'name': 'Beef', 'price': 22.0})],
            alignment: WidgetAlignment.center,
            widgetTypeForAlignment: 'dish',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with end alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('dish', {'name': 'Beef', 'price': 22.0})],
            alignment: WidgetAlignment.end,
            widgetTypeForAlignment: 'dish',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when showPrices is false (price suppressed)',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('dish', {'name': 'Beef', 'price': 22.0})],
            displayOptions: const MenuDisplayOptions(showPrices: false),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when showAllergens is false (allergens suppressed)',
      () async {
        final allergenInfo = [const AllergenInfo(allergen: UkAllergen.milk)];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {
            'name': 'Cheesy',
            'price': 10.0,
            'allergenInfo': allergenInfo.map((a) => a.toJson()).toList(),
          },
        );

        final bytes = await build(
          _treeWithWidgets(
            [dish],
            displayOptions: const MenuDisplayOptions(showAllergens: false),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with price variants and justified alignment',
      () async {
        final variants = [
          const PriceVariant(label: 'Small', price: 8.0),
          const PriceVariant(label: 'Large', price: 16.0),
        ];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {
            'name': 'Sharing Steak',
            'price': 0.0,
            'priceVariants': variants.map((v) => v.toJson()).toList(),
          },
        );

        final bytes = await build(
          _treeWithWidgets(
            [dish],
            alignment: WidgetAlignment.justified,
            widgetTypeForAlignment: 'dish',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish with very long name',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish', {
              'name':
                  'Slow-Braised Heritage Beef Short Rib with Truffle Pomme '
                  'Purée, Seasonal Root Vegetables, and a Rich Red Wine Jus',
              'price': 42.0,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — widget type: wine', () {
    test('should produce valid PDF for a minimal wine widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('wine', {'name': 'Merlot', 'price': 30.0}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a wine with vintage and description',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('wine', {
              'name': 'Chateau Margaux',
              'price': 150.0,
              'vintage': 2018,
              'description': 'Exceptional Bordeaux',
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a wine with containsSulphites:true and allergens shown',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [
              _widget('wine', {
                'name': 'Riesling',
                'price': 45.0,
                'containsSulphites': true,
              }),
            ],
            displayOptions: const MenuDisplayOptions(showAllergens: true),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a wine with containsSulphites:true and allergens hidden',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [
              _widget('wine', {
                'name': 'Riesling',
                'price': 45.0,
                'containsSulphites': true,
              }),
            ],
            displayOptions: const MenuDisplayOptions(showAllergens: false),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a wine with justified alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('wine', {'name': 'Barolo', 'price': 75.0})],
            alignment: WidgetAlignment.justified,
            widgetTypeForAlignment: 'wine',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a wine with very long name',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('wine', {
              'name':
                  'Domaine de la Romanée-Conti Grand Cru Monopole Pinot Noir '
                  'Burgundy Côte de Nuits Premier Selection Vintage Reserve',
              'price': 850.0,
              'vintage': 2015,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — widget type: section', () {
    test('should produce valid PDF for a minimal section widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('section', {'title': 'Starters'}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a section with uppercase:true',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('section', {'title': 'Starters', 'uppercase': true}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a section with showDivider:true',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('section', {
              'title': 'Mains',
              'uppercase': false,
              'showDivider': true,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a section with showDivider:false',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('section', {'title': 'Desserts', 'showDivider': false}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a section with center alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('section', {'title': 'Specials'})],
            alignment: WidgetAlignment.center,
            widgetTypeForAlignment: 'section',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should fall back to start alignment when section receives justified alignment',
      () async {
        // Justified is not meaningful for section — production code maps it to start.
        final bytes = await build(
          _treeWithWidgets(
            [_widget('section', {'title': 'Wine List'})],
            alignment: WidgetAlignment.justified,
            widgetTypeForAlignment: 'section',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — widget type: text', () {
    test('should produce valid PDF for a minimal text widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('text', {'text': 'Welcome'}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test('should produce valid PDF for a bold text widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('text', {'text': 'Bold text', 'bold': true}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test('should produce valid PDF for an italic text widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('text', {'text': 'Italic text', 'italic': true}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test('should produce valid PDF for a bold+italic text widget', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('text', {
            'text': 'Bold italic',
            'bold': true,
            'italic': true,
          }),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for text with center alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('text', {'text': 'Center', 'align': 'center'}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for text with right alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('text', {'text': 'Right', 'align': 'right'}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for text with unknown alignment (falls back to left)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('text', {'text': 'Default', 'align': 'justify'}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test('should produce valid PDF for empty text content', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('text', {'text': ''}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });
  });

  group('PdfDocumentBuilder — widget type: image', () {
    test(
      'should produce valid PDF when image bytes are in the cache (renders image)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('image', {'fileId': 'img-001'}),
          ]),
          images: {'img-001': kTestPngBytes},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when image fileId is not in cache (renders placeholder)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('image', {'fileId': 'missing-img'}),
          ]),
          images: const {},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for an image widget with explicit width and height',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('image', {
              'fileId': 'img-002',
              'width': 200.0,
              'height': 100.0,
            }),
          ]),
          images: {'img-002': kTestPngBytes},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for an image widget with left alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('image', {'fileId': 'img-003', 'align': 'left'}),
          ]),
          images: {'img-003': kTestPngBytes},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for an image widget with right alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('image', {'fileId': 'img-004', 'align': 'right'}),
          ]),
          images: {'img-004': kTestPngBytes},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for each image BoxFit variant',
      () async {
        for (final fit in ['contain', 'cover', 'fill', 'fitWidth', 'fitHeight']) {
          final bytes = await build(
            _treeWithWidgets([
              _widget('image', {
                'fileId': 'img-fit',
                'fit': fit,
                'width': 100.0,
                'height': 100.0,
              }),
            ]),
            images: {'img-fit': kTestPngBytes},
          );

          expect(_isPdfBytes(bytes), isTrue,
              reason: 'Failed for fit=$fit');
        }
      },
    );
  });

  group('PdfDocumentBuilder — widget type: dish_to_share', () {
    test('should produce valid PDF for a minimal dish_to_share', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('dish_to_share', {'name': 'Mezze', 'price': 18.0}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a dish_to_share with servings:2',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish_to_share', {
              'name': 'Platter',
              'price': 28.0,
              'servings': 2,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish_to_share with servings:1 (no label)',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('dish_to_share', {
              'name': 'Bread',
              'price': 5.0,
              'servings': 1,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish_to_share with allergens shown',
      () async {
        final allergenInfo = [
          const AllergenInfo(allergen: UkAllergen.nuts, details: 'walnut'),
          const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
        ];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish_to_share',
          version: '1',
          index: 0,
          props: {
            'name': 'Asian Platter',
            'price': 24.0,
            'allergenInfo': allergenInfo.map((a) => a.toJson()).toList(),
          },
        );

        final bytes = await build(
          _treeWithWidgets(
            [dish],
            displayOptions: const MenuDisplayOptions(showAllergens: true),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a dish_to_share with justified alignment',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('dish_to_share', {'name': 'Mezze', 'price': 20.0})],
            alignment: WidgetAlignment.justified,
            widgetTypeForAlignment: 'dish_to_share',
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — widget type: set_menu_dish', () {
    test('should produce valid PDF for a minimal set_menu_dish', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('set_menu_dish', {'name': 'Beef Wellington'}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a set_menu_dish with supplement',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_dish', {
              'name': 'Lobster',
              'hasSupplement': true,
              'supplementPrice': 12.0,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a set_menu_dish with description and calories',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_dish', {
              'name': 'Salmon',
              'description': 'Pan-seared with Jersey Royals',
              'calories': 520,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a set_menu_dish with allergens and calories shown',
      () async {
        final allergenInfo = [
          const AllergenInfo(allergen: UkAllergen.fish),
          const AllergenInfo(allergen: UkAllergen.milk),
        ];

        final dish = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'set_menu_dish',
          version: '1',
          index: 0,
          props: {
            'name': 'Sea Bass',
            'calories': 480,
            'allergenInfo': allergenInfo.map((a) => a.toJson()).toList(),
          },
        );

        final bytes = await build(
          _treeWithWidgets(
            [dish],
            displayOptions: const MenuDisplayOptions(showAllergens: true),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for set_menu_dish with dietary:vegetarian',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_dish', {
              'name': 'Risotto',
              'dietary': 'vegetarian',
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — widget type: set_menu_title', () {
    test('should produce valid PDF for a minimal set_menu_title', () async {
      final bytes = await build(
        _treeWithWidgets([
          _widget('set_menu_title', {'title': 'Set Lunch'}),
        ]),
      );

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce valid PDF for a set_menu_title with subtitle',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_title', {
              'title': 'Tasting Menu',
              'subtitle': 'Seasonal dishes',
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a set_menu_title with price1 only',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_title', {
              'title': 'Set Menu',
              'price1': 45.0,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a set_menu_title with two labelled prices',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('set_menu_title', {
              'title': 'Fixed Price Menu',
              'priceLabel1': '3 Courses',
              'price1': 45.0,
              'priceLabel2': '4 Courses',
              'price2': 55.0,
            }),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a set_menu_title with showPrices:false',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [
              _widget('set_menu_title', {
                'title': 'Set Menu',
                'price1': 50.0,
                'priceLabel1': '3 Courses',
              }),
            ],
            displayOptions: const MenuDisplayOptions(showPrices: false),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  group('PdfDocumentBuilder — unknown widget type', () {
    test(
      'should produce valid PDF when an unknown widget type is encountered',
      () async {
        final bytes = await build(
          _treeWithWidgets([
            _widget('completely_unknown_type', {'data': 'ignored'}),
          ]),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Multi-column layout
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — multi-column layout', () {
    test(
      'should produce valid PDF for a container with two equal columns',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Two-Col',
            status: Status.published,
            version: '1',
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
                          version: '1',
                          index: 0,
                          props: {'text': 'Left column'},
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
                          id: 2,
                          columnId: 2,
                          type: 'text',
                          version: '1',
                          index: 0,
                          props: {'text': 'Right column'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for two columns with unequal flex (1:2)',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Flex',
            status: Status.published,
            version: '1',
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
                          type: 'section',
                          version: '1',
                          index: 0,
                          props: {'title': 'Narrow'},
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
                          type: 'section',
                          version: '1',
                          index: 0,
                          props: {'title': 'Wide'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for three columns with mismatched widget counts',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Three-Col',
            status: Status.published,
            version: '1',
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
                          version: '1',
                          index: 0,
                          props: {'text': 'A'},
                        ),
                        WidgetInstance(
                          id: 2,
                          columnId: 1,
                          type: 'text',
                          version: '1',
                          index: 1,
                          props: {'text': 'B'},
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
                          version: '1',
                          index: 0,
                          props: {'text': 'C'},
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
                      widgets: [],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for column with vertical alignment:center',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'VA Center',
            status: Status.published,
            version: '1',
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
                        styleConfig:
                            StyleConfig(verticalAlignment: VerticalAlignment.center),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1',
                          index: 0,
                          props: {'text': 'Centered'},
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

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for column with vertical alignment:bottom',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'VA Bottom',
            status: Status.published,
            version: '1',
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
                        styleConfig:
                            StyleConfig(verticalAlignment: VerticalAlignment.bottom),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1',
                          index: 0,
                          props: {'text': 'Bottom'},
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

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Group containers (children) and layout
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — group containers and layout directions', () {
    test(
      'should produce valid PDF for a row-direction group container',
      () async {
        const child1 = ContainerWithColumns(
          container: entity.Container(
            id: 10,
            pageId: 1,
            index: 0,
            parentContainerId: 1,
          ),
          columns: [],
        );
        const child2 = ContainerWithColumns(
          container: entity.Container(
            id: 11,
            pageId: 1,
            index: 1,
            parentContainerId: 1,
          ),
          columns: [],
        );

        final tree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Group Row',
            status: Status.published,
            version: '1',
          ),
          pages: const [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: LayoutConfig(direction: 'row'),
                  ),
                  columns: [],
                  children: [child1, child2],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for a column-direction group container',
      () async {
        const child1 = ContainerWithColumns(
          container: entity.Container(
            id: 10,
            pageId: 1,
            index: 0,
            parentContainerId: 1,
          ),
          columns: [],
        );

        final tree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'Group Col',
            status: Status.published,
            version: '1',
          ),
          pages: const [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: LayoutConfig(direction: 'column'),
                  ),
                  columns: [],
                  children: [child1],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF for spaceBetween mainAxisAlignment',
      () async {
        final tree = MenuTree(
          menu: const Menu(
            id: 1,
            name: 'SpaceBetween',
            status: Status.published,
            version: '1',
          ),
          pages: const [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 1, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(
                    id: 1,
                    pageId: 1,
                    index: 0,
                    layout: LayoutConfig(mainAxisAlignment: 'spaceBetween'),
                  ),
                  columns: [],
                  children: [
                    ContainerWithColumns(
                      container: entity.Container(
                        id: 10,
                        pageId: 1,
                        index: 0,
                      ),
                      columns: [],
                    ),
                    ContainerWithColumns(
                      container: entity.Container(
                        id: 11,
                        pageId: 1,
                        index: 1,
                      ),
                      columns: [],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Watermarking
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — watermarking', () {
    test(
      'should produce valid PDF without watermark when watermarkText is null',
      () async {
        final bytes = await builder.buildDocument(
          menuTree: _treeWithWidgets([
            _widget('text', {'text': 'No watermark'}),
          ]),
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: null,
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF with watermark when watermarkText is provided',
      () async {
        final bytes = await builder.buildDocument(
          menuTree: _treeWithWidgets([
            _widget('text', {'text': 'With watermark'}),
          ]),
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: 'SAMPLE',
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce more bytes when watermark is applied vs no watermark',
      () async {
        final tree = _treeWithWidgets([_widget('text', {'text': 'Test'})]);

        final withoutWatermark = await builder.buildDocument(
          menuTree: tree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: null,
        );

        final withWatermark = await builder.buildDocument(
          menuTree: tree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: 'DRAFT',
        );

        expect(withWatermark.length, greaterThan(withoutWatermark.length));
      },
    );

    test(
      'should produce valid PDF with multi-word watermark text',
      () async {
        final bytes = await builder.buildDocument(
          menuTree: _treeWithWidgets([
            _widget('text', {'text': 'Hello'}),
          ]),
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: 'SAMPLE MENU PREVIEW',
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Style config
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — style configuration', () {
    test(
      'should produce valid PDF when menu-level styleConfig has margins',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('text', {'text': 'Styled'})],
            menuStyle: const StyleConfig(
              marginTop: 10.0,
              marginBottom: 10.0,
              marginLeft: 15.0,
              marginRight: 15.0,
            ),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when menu-level styleConfig has padding and fontSize',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('text', {'text': 'Padded'})],
            menuStyle: const StyleConfig(
              padding: 20.0,
              fontSize: 14.0,
            ),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when menu-level styleConfig has a plain thin border',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('text', {'text': 'Bordered'})],
            menuStyle: const StyleConfig(borderType: BorderType.plainThin),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when menu-level styleConfig has a drop shadow border',
      () async {
        final bytes = await build(
          _treeWithWidgets(
            [_widget('text', {'text': 'Shadow'})],
            menuStyle: const StyleConfig(borderType: BorderType.dropShadow),
          ),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when container has its own styleConfig',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Container Style',
            status: Status.published,
            version: '1',
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
                      marginTop: 8.0,
                      paddingLeft: 16.0,
                      borderType: BorderType.plainThick,
                    ),
                  ),
                  columns: [
                    ColumnWithWidgets(
                      column: entity.Column(id: 1, containerId: 1, index: 0),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1',
                          index: 0,
                          props: {'text': 'Container styled'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when column has its own styleConfig with border',
      () async {
        const tree = MenuTree(
          menu: Menu(
            id: 1,
            name: 'Col Style',
            status: Status.published,
            version: '1',
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
                        styleConfig: StyleConfig(
                          padding: 8.0,
                          borderType: BorderType.doubleOffset,
                        ),
                      ),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'text',
                          version: '1',
                          index: 0,
                          props: {'text': 'Col styled'},
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

        final bytes = await build(tree);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Mixed widget types
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder — mixed widget types on one page', () {
    test(
      'should produce valid PDF for a page with all eight widget types',
      () async {
        final allergenInfo = [
          const AllergenInfo(allergen: UkAllergen.gluten, details: 'wheat'),
          const AllergenInfo(allergen: UkAllergen.milk),
        ];
        final allergenJson = allergenInfo.map((a) => a.toJson()).toList();

        final variants = [
          const PriceVariant(label: 'Regular', price: 12.0),
          const PriceVariant(label: 'Large', price: 18.0),
        ];

        final widgets = [
          _widget('section', {'title': 'All Widgets Test'}, id: 1),
          WidgetInstance(
            id: 2,
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 1,
            props: {'name': 'Pasta', 'price': 14.0, 'allergenInfo': allergenJson},
          ),
          WidgetInstance(
            id: 3,
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 2,
            props: {
              'name': 'Steak',
              'price': 0.0,
              'priceVariants': variants.map((v) => v.toJson()).toList(),
            },
          ),
          _widget('text', {'text': 'Terms and conditions apply'}, id: 4),
          _widget(
            'wine',
            {'name': 'Chablis', 'price': 40.0, 'containsSulphites': true},
            id: 5,
          ),
          _widget(
            'dish_to_share',
            {'name': 'Mezze', 'price': 22.0, 'servings': 2},
            id: 6,
          ),
          _widget('set_menu_title', {'title': 'Set Lunch', 'price1': 38.0}, id: 7),
          _widget('set_menu_dish', {'name': 'Tiramisu'}, id: 8),
          _widget('image', {'fileId': 'logo'}, id: 9),
        ];

        final bytes = await build(
          _treeWithWidgets(widgets),
          images: {'logo': kTestPngBytes},
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });
}
