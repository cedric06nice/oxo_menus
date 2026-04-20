import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';

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
    pages: [
      for (var i = 0; i < pageCount; i++)
        PageWithContainers(
          page: entity.Page(
            id: menuId * 100 + i,
            menuId: menuId,
            name: 'p$i',
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
                      props: const {'text': 'hi'},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    ],
  );
}

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

  group('composeBundleRenderOrder', () {
    test(
      'emits every tree with showAllergens=false, then every tree with showAllergens=true, '
      'preserving input order within each half',
      () {
        final tree1 = _tree(menuId: 1, name: 'Mains');
        final tree2 = _tree(menuId: 2, name: 'Desserts');

        final order = composeBundleRenderOrder(
          trees: [tree1, tree2],
          base: const MenuDisplayOptions(),
        );

        expect(order.map((t) => t.menu.id).toList(), [1, 2, 1, 2]);
        expect(order[0].menu.displayOptions?.showAllergens, false);
        expect(order[1].menu.displayOptions?.showAllergens, false);
        expect(order[2].menu.displayOptions?.showAllergens, true);
        expect(order[3].menu.displayOptions?.showAllergens, true);
      },
    );

    test('respects showPrices from the base options on both halves', () {
      final tree = _tree(menuId: 1, name: 'Mains');

      final order = composeBundleRenderOrder(
        trees: [tree],
        base: const MenuDisplayOptions(showPrices: false),
      );

      expect(order[0].menu.displayOptions?.showPrices, false);
      expect(order[1].menu.displayOptions?.showPrices, false);
    });
  });

  group('buildBundleDocument', () {
    test(
      'returns valid PDF bytes for a multi-menu bundle with watermark',
      () async {
        final tree1 = _tree(menuId: 1, name: 'Mains', pageCount: 2);
        final tree2 = _tree(menuId: 2, name: 'Desserts', pageCount: 1);

        final bytes = await builder.buildBundleDocument(
          trees: [tree1, tree2],
          baseOptions: const MenuDisplayOptions(),
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: const {},
          watermarkText: 'SAMPLE MENU',
        );

        expect(bytes, isNotEmpty);
        // %PDF magic
        expect(bytes[0], 0x25);
        expect(bytes[1], 0x50);
        expect(bytes[2], 0x44);
        expect(bytes[3], 0x46);
      },
    );

    test('returns valid PDF bytes when trees list is empty', () async {
      final bytes = await builder.buildBundleDocument(
        trees: const [],
        baseOptions: const MenuDisplayOptions(),
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: const {},
        watermarkText: 'SAMPLE MENU',
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25); // %PDF
    });
  });
}
