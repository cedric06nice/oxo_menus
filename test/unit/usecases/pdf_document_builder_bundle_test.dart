import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';

import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' as entity;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [MenuTree] with [pageCount] pages, each containing a single text
/// widget. Uses [menuId] for namespaced IDs to avoid collisions in multi-tree
/// tests.
MenuTree _tree({
  required int menuId,
  required String name,
  MenuDisplayOptions? displayOptions,
  int pageCount = 1,
}) {
  return MenuTree(
    menu: Menu(
      id: menuId,
      name: name,
      status: Status.published,
      version: '1.0.0',
      displayOptions: displayOptions,
    ),
    pages: List.generate(
      pageCount,
      (i) => PageWithContainers(
        page: entity.Page(
          id: menuId * 100 + i,
          menuId: menuId,
          name: 'Page $i',
          index: i,
        ),
        containers: [
          ContainerWithColumns(
            container: entity.Container(
              id: menuId * 1000 + i,
              pageId: menuId * 100 + i,
              index: 0,
            ),
            columns: [
              ColumnWithWidgets(
                column: entity.Column(
                  id: menuId * 10000 + i,
                  containerId: menuId * 1000 + i,
                  index: 0,
                  flex: 1,
                ),
                widgets: [
                  WidgetInstance(
                    id: menuId * 100000 + i,
                    columnId: menuId * 10000 + i,
                    type: 'text',
                    version: '1.0.0',
                    index: 0,
                    props: const {'text': 'Menu item text'},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

bool _isPdfBytes(Uint8List bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46;

// ---------------------------------------------------------------------------
// Tests
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

  setUp(() => builder = const PdfDocumentBuilder());

  Future<Uint8List> buildBundle({
    required List<MenuTree> trees,
    MenuDisplayOptions? baseOptions,
    String watermark = 'SAMPLE',
  }) {
    return builder.buildBundleDocument(
      trees: trees,
      baseOptions: baseOptions ?? const MenuDisplayOptions(),
      baseFontData: baseFontData,
      boldFontData: boldFontData,
      sectionFontData: sectionFontData,
      imageCache: const {},
      watermarkText: watermark,
    );
  }

  // ---------------------------------------------------------------------------
  // composeBundleRenderOrder
  // ---------------------------------------------------------------------------

  group('composeBundleRenderOrder', () {
    test(
      'should emit every tree with showAllergens=false followed by every tree with showAllergens=true',
      () {
        final tree1 = _tree(menuId: 1, name: 'Mains');
        final tree2 = _tree(menuId: 2, name: 'Desserts');

        final order = composeBundleRenderOrder(
          trees: [tree1, tree2],
          base: const MenuDisplayOptions(),
        );

        expect(order.map((t) => t.menu.id).toList(), [1, 2, 1, 2]);
        expect(order[0].menu.displayOptions?.showAllergens, isFalse);
        expect(order[1].menu.displayOptions?.showAllergens, isFalse);
        expect(order[2].menu.displayOptions?.showAllergens, isTrue);
        expect(order[3].menu.displayOptions?.showAllergens, isTrue);
      },
    );

    test('should preserve input menu order within the no-allergen half', () {
      final tree1 = _tree(menuId: 1, name: 'Mains');
      final tree2 = _tree(menuId: 2, name: 'Desserts');
      final tree3 = _tree(menuId: 3, name: 'Drinks');

      final order = composeBundleRenderOrder(
        trees: [tree1, tree2, tree3],
        base: const MenuDisplayOptions(),
      );

      expect(order[0].menu.id, 1);
      expect(order[1].menu.id, 2);
      expect(order[2].menu.id, 3);
    });

    test('should preserve input menu order within the with-allergen half', () {
      final tree1 = _tree(menuId: 1, name: 'Mains');
      final tree2 = _tree(menuId: 2, name: 'Desserts');

      final order = composeBundleRenderOrder(
        trees: [tree1, tree2],
        base: const MenuDisplayOptions(),
      );

      expect(order[2].menu.id, 1);
      expect(order[3].menu.id, 2);
    });

    test(
      'should propagate showPrices:false from base options to all four slots',
      () {
        final tree = _tree(menuId: 1, name: 'M');

        final order = composeBundleRenderOrder(
          trees: [tree],
          base: const MenuDisplayOptions(showPrices: false),
        );

        expect(order[0].menu.displayOptions?.showPrices, isFalse);
        expect(order[1].menu.displayOptions?.showPrices, isFalse);
      },
    );

    test('should return an empty list when trees list is empty', () {
      final order = composeBundleRenderOrder(
        trees: const [],
        base: const MenuDisplayOptions(),
      );

      expect(order, isEmpty);
    });

    test(
      'should return two entries (without, then with allergens) for a single-tree input',
      () {
        final tree = _tree(menuId: 1, name: 'Solo');

        final order = composeBundleRenderOrder(
          trees: [tree],
          base: const MenuDisplayOptions(),
        );

        expect(order.length, 2);
        expect(order[0].menu.displayOptions?.showAllergens, isFalse);
        expect(order[1].menu.displayOptions?.showAllergens, isTrue);
      },
    );

    test('should produce 2N entries for N input trees', () {
      final trees = List.generate(
        4,
        (i) => _tree(menuId: i + 1, name: 'Menu ${i + 1}'),
      );

      final order = composeBundleRenderOrder(
        trees: trees,
        base: const MenuDisplayOptions(),
      );

      expect(order.length, 8);
    });
  });

  // ---------------------------------------------------------------------------
  // buildBundleDocument
  // ---------------------------------------------------------------------------

  group('PdfDocumentBuilder.buildBundleDocument', () {
    test('should return valid PDF bytes for a single-tree bundle', () async {
      final tree = _tree(menuId: 1, name: 'Mains');

      final bytes = await buildBundle(trees: [tree]);

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should return valid PDF bytes for a multi-tree bundle with watermark',
      () async {
        final tree1 = _tree(menuId: 1, name: 'Mains', pageCount: 2);
        final tree2 = _tree(menuId: 2, name: 'Desserts', pageCount: 1);

        final bytes = await buildBundle(
          trees: [tree1, tree2],
          watermark: 'SAMPLE MENU',
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test('should return valid PDF bytes when trees list is empty', () async {
      final bytes = await buildBundle(trees: const []);

      expect(_isPdfBytes(bytes), isTrue);
    });

    test(
      'should produce a larger document for more trees than for fewer trees',
      () async {
        final singleTree = [_tree(menuId: 1, name: 'Solo')];
        final threeTrees = [
          _tree(menuId: 1, name: 'A'),
          _tree(menuId: 2, name: 'B'),
          _tree(menuId: 3, name: 'C'),
        ];

        final singleBytes = await buildBundle(trees: singleTree);
        final threeBytes = await buildBundle(trees: threeTrees);

        expect(threeBytes.length, greaterThan(singleBytes.length));
      },
    );

    test(
      'should apply base options showPrices:false to all rendered trees',
      () async {
        // We cannot inspect PDF content; we verify it builds successfully
        // with the option propagated.
        final bytes = await buildBundle(
          trees: [_tree(menuId: 1, name: 'M')],
          baseOptions: const MenuDisplayOptions(showPrices: false),
        );

        expect(_isPdfBytes(bytes), isTrue);
      },
    );

    test(
      'should produce valid PDF when each tree has multiple pages',
      () async {
        final trees = List.generate(
          3,
          (i) => _tree(menuId: i + 1, name: 'Menu ${i + 1}', pageCount: 3),
        );

        final bytes = await buildBundle(trees: trees);

        expect(_isPdfBytes(bytes), isTrue);
      },
    );
  });
}
