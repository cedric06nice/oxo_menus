import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widgets/shared/price_formatter.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

typedef _AlignmentLookup = WidgetAlignment Function(String type);

/// Returns the list of menu trees to render (in order) for an exportable
/// menu bundle: every tree with [MenuDisplayOptions.showAllergens] = false
/// first, then every tree with showAllergens = true. Other options flow from
/// [base]. Each tree's `menu.displayOptions` is rewritten to match so that
/// downstream rendering picks up the correct flags.
List<MenuTree> composeBundleRenderOrder({
  required List<MenuTree> trees,
  required MenuDisplayOptions base,
}) {
  MenuTree withOptions(MenuTree t, MenuDisplayOptions opts) =>
      t.copyWith(menu: t.menu.copyWith(displayOptions: opts));

  final withoutAllergens = base.copyWith(showAllergens: false);
  final withAllergens = base.copyWith(showAllergens: true);

  return [
    for (final t in trees) withOptions(t, withoutAllergens),
    for (final t in trees) withOptions(t, withAllergens),
  ];
}

/// Maps a [WidgetAlignment] to PDF column/text alignment values.
pw.CrossAxisAlignment _pdfCrossAxis(WidgetAlignment a) => switch (a) {
  WidgetAlignment.start => pw.CrossAxisAlignment.start,
  WidgetAlignment.center => pw.CrossAxisAlignment.center,
  WidgetAlignment.end => pw.CrossAxisAlignment.end,
  WidgetAlignment.justified => pw.CrossAxisAlignment.stretch,
};

pw.TextAlign _pdfTextAlign(WidgetAlignment a) => switch (a) {
  WidgetAlignment.start || WidgetAlignment.justified => pw.TextAlign.left,
  WidgetAlignment.center => pw.TextAlign.center,
  WidgetAlignment.end => pw.TextAlign.right,
};

/// Two-cell PDF price row that anchors decimal points on the same x.
pw.Widget _pdfPriceCell(
  double price,
  pw.TextStyle style,
  double baseFontSize, {
  bool showCurrency = true,
}) {
  final parts = formatPriceParts(price);
  final integer = showCurrency
      ? parts.integer
      : parts.integer.replaceFirst('£', '');
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.SizedBox(
        width: baseFontSize * 2.8,
        child: pw.Text(integer, textAlign: pw.TextAlign.right, style: style),
      ),
      pw.SizedBox(
        width: baseFontSize * 1.5,
        child: pw.Text(
          parts.decimal,
          textAlign: pw.TextAlign.left,
          style: style,
        ),
      ),
    ],
  );
}

/// Builds a PDF document from a MenuTree.
///
/// This class is isolate-safe: it holds only a const [PdfStyleResolver]
/// and accepts all data (fonts, images, menu tree) as parameters.
class PdfDocumentBuilder {
  final PdfStyleResolver _resolver;

  const PdfDocumentBuilder({
    PdfStyleResolver resolver = const PdfStyleResolver(),
  }) : _resolver = resolver;

  /// Build a complete PDF document and return its bytes.
  Future<Uint8List> buildDocument({
    required MenuTree menuTree,
    required ByteData baseFontData,
    required ByteData boldFontData,
    required ByteData sectionFontData,
    required Map<String, Uint8List> imageCache,
    String? watermarkText,
  }) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(baseFontData),
      bold: pw.Font.ttf(boldFontData),
    );
    final sectionFont = pw.Font.ttf(sectionFontData);
    final pdf = pw.Document(theme: theme, version: PdfVersion.pdf_1_5);

    _addTreePages(
      pdf: pdf,
      tree: menuTree,
      sectionFont: sectionFont,
      imageCache: imageCache,
      watermarkText: watermarkText,
    );

    return await pdf.save();
  }

  /// Build a PDF document composed of N menus — first every menu rendered
  /// without allergens, then every menu rendered with allergens. Every page
  /// carries the diagonal [watermarkText] overlay.
  Future<Uint8List> buildBundleDocument({
    required List<MenuTree> trees,
    required MenuDisplayOptions baseOptions,
    required ByteData baseFontData,
    required ByteData boldFontData,
    required ByteData sectionFontData,
    required Map<String, Uint8List> imageCache,
    required String watermarkText,
  }) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(baseFontData),
      bold: pw.Font.ttf(boldFontData),
    );
    final sectionFont = pw.Font.ttf(sectionFontData);
    final pdf = pw.Document(theme: theme, version: PdfVersion.pdf_1_5);

    final orderedTrees = composeBundleRenderOrder(
      trees: trees,
      base: baseOptions,
    );

    for (final tree in orderedTrees) {
      _addTreePages(
        pdf: pdf,
        tree: tree,
        sectionFont: sectionFont,
        imageCache: imageCache,
        watermarkText: watermarkText,
      );
    }

    return await pdf.save();
  }

  void _addTreePages({
    required pw.Document pdf,
    required MenuTree tree,
    required pw.Font sectionFont,
    required Map<String, Uint8List> imageCache,
    String? watermarkText,
  }) {
    final styleConfig = tree.menu.styleConfig;
    final displayOptions = tree.menu.displayOptions;
    final pageFormat = _resolver.resolvePageFormat(tree.menu.pageSize);
    final pageMargins = _resolver.resolveContentMargins(styleConfig);
    final alignmentFor = tree.menu.alignmentFor;
    for (final pageData in tree.pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pageMargins,
          build: (context) {
            final page = _buildPageWithHeaderFooter(
              pageData,
              tree.headerPage,
              tree.footerPage,
              styleConfig,
              displayOptions,
              imageCache,
              sectionFont,
              alignmentFor,
            );
            return watermarkText == null
                ? page
                : _wrapWithWatermark(page, watermarkText);
          },
        ),
      );
    }
  }

  pw.Widget _wrapWithWatermark(pw.Widget page, String text) {
    return pw.Stack(
      fit: pw.StackFit.expand,
      children: [
        page,
        pw.Positioned.fill(
          child: pw.Center(
            child: pw.Opacity(
              opacity: 0.22,
              child: pw.Transform.rotate(
                angle: math.pi / 4,
                child: pw.Text(
                  text,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 96,
                    color: PdfColors.grey300,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPageWithHeaderFooter(
    PageWithContainers pageData,
    PageWithContainers? headerPage,
    PageWithContainers? footerPage,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
    _AlignmentLookup alignmentFor,
  ) {
    final contentChildren = <pw.Widget>[];

    if (headerPage != null) {
      contentChildren.addAll(
        headerPage.containers.map((containerData) {
          return _buildContainer(
            containerData,
            styleConfig,
            displayOptions,
            imageCache,
            sectionFont,
            alignmentFor,
          );
        }),
      );
    }

    contentChildren.addAll(
      pageData.containers.map((containerData) {
        return _buildContainer(
          containerData,
          styleConfig,
          displayOptions,
          imageCache,
          sectionFont,
          alignmentFor,
        );
      }),
    );

    final footerChildren = <pw.Widget>[];
    if (footerPage != null) {
      footerChildren.addAll(
        footerPage.containers.map((containerData) {
          return _buildContainer(
            containerData,
            styleConfig,
            displayOptions,
            imageCache,
            sectionFont,
            alignmentFor,
          );
        }),
      );
    }

    final margin = styleConfig != null
        ? _resolver.resolveContentMargins(styleConfig)
        : pw.EdgeInsets.zero;
    final padding = styleConfig != null
        ? _resolver.resolveContentPadding(styleConfig)
        : pw.EdgeInsets.zero;
    final hasFlexContent = contentChildren.any((w) => w is pw.Expanded);
    final needsMaxSize = footerChildren.isNotEmpty || hasFlexContent;

    pw.Widget innerLayout;
    if (needsMaxSize) {
      innerLayout = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.max,
        children: [
          ...contentChildren,
          // Push footer to bottom only when no content container already
          // uses Expanded (space-distributing containers fill the gap)
          if (footerChildren.isNotEmpty && !hasFlexContent)
            pw.Expanded(child: pw.SizedBox()),
          ...footerChildren,
        ],
      );
    } else {
      innerLayout = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: contentChildren,
      );
    }

    final content = pw.Container(padding: padding, child: innerLayout);
    final borderedContent = _resolver.wrapWithBorder(content, styleConfig);

    return pw.Container(margin: margin, child: borderedContent);
  }

  pw.Widget _buildContainer(
    ContainerWithColumns containerData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
    _AlignmentLookup alignmentFor,
  ) {
    final containerStyle = containerData.container.styleConfig;

    final margin = containerStyle != null
        ? _resolver.resolveContentMargins(containerStyle)
        : pw.EdgeInsets.zero;

    final padding = containerStyle != null
        ? _resolver.resolveContentPadding(containerStyle)
        : pw.EdgeInsets.zero;

    pw.Widget content;

    bool needsExpanded = false;

    if (containerData.children.isNotEmpty) {
      // Group container: render child containers
      final childWidgets = containerData.children
          .map(
            (child) => _buildContainer(
              child,
              styleConfig,
              displayOptions,
              imageCache,
              sectionFont,
              alignmentFor,
            ),
          )
          .toList();

      final mainAxisAlignment = _resolveMainAxisAlignment(
        containerData.container.layout?.mainAxisAlignment,
      );
      final direction = containerData.container.layout?.direction;

      if (direction == 'row') {
        content = pw.Container(
          padding: padding,
          child: pw.Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: childWidgets.map((w) => pw.Expanded(child: w)).toList(),
          ),
        );
      } else {
        needsExpanded = _isSpaceDistributing(mainAxisAlignment);
        content = pw.Container(
          padding: padding,
          child: pw.Column(
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: needsExpanded
                ? pw.MainAxisSize.max
                : pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: childWidgets,
          ),
        );
      }
    } else if (containerData.columns.length <= 1) {
      content = pw.Container(
        padding: padding,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (containerData.columns.isNotEmpty)
              _buildColumn(
                containerData.columns.first,
                styleConfig,
                displayOptions,
                imageCache,
                sectionFont,
                alignmentFor,
              ),
          ],
        ),
      );
    } else {
      content = pw.Container(
        padding: padding,
        child: _buildColumnsAsGrid(
          containerData.columns,
          styleConfig,
          displayOptions,
          imageCache,
          sectionFont,
          alignmentFor,
        ),
      );
    }

    final borderedContent = _resolver.wrapWithBorder(content, containerStyle);

    final result = pw.Container(margin: margin, child: borderedContent);
    return needsExpanded ? pw.Expanded(child: result) : result;
  }

  pw.Widget _buildColumnsAsGrid(
    List<ColumnWithWidgets> columns,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
    _AlignmentLookup alignmentFor,
  ) {
    final maxWidgetCount = columns.fold<int>(
      0,
      (max, col) => col.widgets.length > max ? col.widgets.length : max,
    );

    final columnWidths = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < columns.length; i++) {
      columnWidths[i] = pw.FlexColumnWidth(
        (columns[i].column.flex ?? 1).toDouble(),
      );
    }

    final rows = <pw.TableRow>[];
    for (var rowIndex = 0; rowIndex < maxWidgetCount; rowIndex++) {
      final cells = <pw.Widget>[];
      for (final column in columns) {
        pw.Widget cell;
        if (rowIndex < column.widgets.length) {
          cell = _buildWidget(
            column.widgets[rowIndex],
            styleConfig,
            displayOptions,
            imageCache,
            sectionFont,
            alignmentFor,
          );
        } else {
          cell = pw.SizedBox();
        }
        cells.add(_wrapCellWithColumnStyle(cell, column.column.styleConfig));
      }
      rows.add(pw.TableRow(children: cells));
    }

    return pw.Table(
      children: rows,
      columnWidths: columnWidths,
      defaultVerticalAlignment: _resolveTableVerticalAlignment(columns),
    );
  }

  pw.TableCellVerticalAlignment _resolveTableVerticalAlignment(
    List<ColumnWithWidgets> columns,
  ) {
    final va = columns.first.column.styleConfig?.verticalAlignment;
    return switch (va) {
      VerticalAlignment.center => pw.TableCellVerticalAlignment.middle,
      VerticalAlignment.bottom => pw.TableCellVerticalAlignment.bottom,
      _ => pw.TableCellVerticalAlignment.top,
    };
  }

  pw.MainAxisAlignment _resolveMainAxisAlignment(String? value) {
    return switch (value) {
      'end' => pw.MainAxisAlignment.end,
      'center' => pw.MainAxisAlignment.center,
      'spaceBetween' => pw.MainAxisAlignment.spaceBetween,
      'spaceAround' => pw.MainAxisAlignment.spaceAround,
      'spaceEvenly' => pw.MainAxisAlignment.spaceEvenly,
      _ => pw.MainAxisAlignment.start,
    };
  }

  bool _isSpaceDistributing(pw.MainAxisAlignment alignment) {
    return alignment == pw.MainAxisAlignment.spaceBetween ||
        alignment == pw.MainAxisAlignment.spaceAround ||
        alignment == pw.MainAxisAlignment.spaceEvenly;
  }

  pw.Widget _wrapCellWithColumnStyle(pw.Widget child, StyleConfig? style) {
    if (style == null) return child;

    final margin = _resolver.resolveContentMargins(style);
    final padding = _resolver.resolveContentPadding(style);

    pw.Widget content = pw.Padding(padding: padding, child: child);
    content = _resolver.wrapWithBorder(content, style);

    return pw.Container(margin: margin, child: content);
  }

  pw.Widget _buildColumn(
    ColumnWithWidgets columnData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
    _AlignmentLookup alignmentFor,
  ) {
    final columnStyle = columnData.column.styleConfig;

    final margin = columnStyle != null
        ? _resolver.resolveContentMargins(columnStyle)
        : pw.EdgeInsets.zero;

    final padding = columnStyle != null
        ? _resolver.resolveContentPadding(columnStyle)
        : pw.EdgeInsets.zero;

    pw.Widget content = pw.Padding(
      padding: padding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: columnData.widgets.map((widget) {
          return _buildWidget(
            widget,
            styleConfig,
            displayOptions,
            imageCache,
            sectionFont,
            alignmentFor,
          );
        }).toList(),
      ),
    );

    final borderedContent = _resolver.wrapWithBorder(content, columnStyle);

    return pw.Container(margin: margin, child: borderedContent);
  }

  pw.Widget _buildWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
    _AlignmentLookup alignmentFor,
  ) {
    final alignment = alignmentFor(widget.type);
    switch (widget.type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig, displayOptions, alignment);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig, sectionFont, alignment);
      case 'image':
        return _buildImageWidget(widget, styleConfig, imageCache);
      case 'wine':
        return _buildWineWidget(widget, styleConfig, displayOptions, alignment);
      case 'dish_to_share':
        return _buildDishToShareWidget(
          widget,
          styleConfig,
          displayOptions,
          alignment,
        );
      case 'set_menu_dish':
        return _buildSetMenuDishWidget(widget, styleConfig, displayOptions);
      case 'set_menu_title':
        return _buildSetMenuTitleWidget(
          widget,
          styleConfig,
          displayOptions,
          sectionFont,
        );
      default:
        return pw.SizedBox();
    }
  }

  pw.Widget _buildDishWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    WidgetAlignment alignment,
  ) {
    final props = DishProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;
    final textAlign = _pdfTextAlign(alignment);

    final nameStyle = pw.TextStyle(
      fontSize: baseFontSize,
      letterSpacing: 0.55,
      fontWeight: pw.FontWeight.bold,
    );
    final dietaryStyle = pw.TextStyle(
      fontSize: baseFontSize - 3,
      letterSpacing: 0.4,
      fontStyle: pw.FontStyle.normal,
    );
    final priceStyle = pw.TextStyle(
      fontSize: baseFontSize - 2,
      letterSpacing: -0.33,
      fontWeight: pw.FontWeight.bold,
    );

    final hasVariants = props.hasMultiplePrices;

    pw.Widget header;
    if (hasVariants) {
      // Multi-price: name line alone, no inline price.
      final wrapAlign = switch (alignment) {
        WidgetAlignment.center => pw.WrapAlignment.center,
        WidgetAlignment.end => pw.WrapAlignment.end,
        _ => pw.WrapAlignment.start,
      };
      header = pw.Wrap(
        alignment: wrapAlign,
        crossAxisAlignment: pw.WrapCrossAlignment.end,
        children: [
          pw.Text(props.name, textAlign: textAlign, style: nameStyle),
          pw.Text(
            props.dietary?.abbreviation != null
                ? '  ${props.dietary!.abbreviation}'
                : '',
            textAlign: textAlign,
            style: dietaryStyle,
          ),
        ],
      );
    } else if (alignment == WidgetAlignment.justified && showPrice) {
      header = pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              props.dietary?.abbreviation != null
                  ? '${props.name}  ${props.dietary!.abbreviation}'
                  : props.name,
              textAlign: pw.TextAlign.left,
              style: nameStyle,
            ),
          ),
          _pdfPriceCell(props.price, priceStyle, baseFontSize),
        ],
      );
    } else {
      final wrapAlign = switch (alignment) {
        WidgetAlignment.center => pw.WrapAlignment.center,
        WidgetAlignment.end => pw.WrapAlignment.end,
        _ => pw.WrapAlignment.start,
      };
      header = pw.Wrap(
        alignment: wrapAlign,
        crossAxisAlignment: pw.WrapCrossAlignment.end,
        children: [
          pw.Text(props.name, textAlign: textAlign, style: nameStyle),
          pw.Text(
            props.dietary?.abbreviation != null
                ? '  ${props.dietary!.abbreviation}'
                : '',
            textAlign: textAlign,
            style: dietaryStyle,
          ),
          if (showPrice)
            pw.Text(
              '  ${formatPrice(props.price).replaceFirst('£', '')}',
              textAlign: textAlign,
              style: priceStyle,
            ),
        ],
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: _pdfCrossAxis(alignment),
        children: [
          header,
          if (hasVariants && showPrice)
            for (final variant in props.priceVariants)
              if (alignment == WidgetAlignment.justified)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        variant.label,
                        textAlign: pw.TextAlign.left,
                        style: priceStyle,
                      ),
                    ),
                    _pdfPriceCell(variant.price, priceStyle, baseFontSize),
                  ],
                )
              else
                pw.Text(
                  '${variant.label}  ${formatPrice(variant.price).replaceFirst('£', '')}',
                  textAlign: textAlign,
                  style: priceStyle,
                ),
          if (props.description != null && props.description!.isNotEmpty ||
              showAllergens && props.calories != null)
            pw.RichText(
              textAlign: textAlign,
              text: pw.TextSpan(
                children: [
                  if (props.description != null &&
                      props.description!.isNotEmpty)
                    pw.TextSpan(
                      text: props.description!,
                      style: pw.TextStyle(
                        fontSize: baseFontSize,
                        letterSpacing: -0.2,
                      ),
                    ),
                  if (showAllergens && props.calories != null)
                    pw.TextSpan(
                      text: '  ${props.calories}KCAL',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 5,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          if (showAllergens) ...[
            () {
              final formattedAllergens = AllergenFormatter.formatForDisplay(
                props.allergenInfo,
              );
              if (formattedAllergens.isEmpty) {
                return pw.SizedBox.shrink();
              }
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  formattedAllergens,
                  textAlign: textAlign,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 3,
                    letterSpacing: 0.6,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildWineWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    WidgetAlignment alignment,
  ) {
    final props = WineProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;
    final textAlign = _pdfTextAlign(alignment);

    final nameStyle = pw.TextStyle(
      fontSize: baseFontSize,
      letterSpacing: 0.55,
      fontWeight: pw.FontWeight.bold,
    );
    final priceStyle = pw.TextStyle(
      fontSize: baseFontSize - 2,
      letterSpacing: -0.33,
      fontWeight: pw.FontWeight.bold,
    );

    pw.Widget header;
    if (alignment == WidgetAlignment.justified && showPrice) {
      final nameText = StringBuffer(props.name);
      if (props.vintage != null) nameText.write('  ${props.vintage}');
      if (props.dietary?.abbreviation != null) {
        nameText.write('  ${props.dietary!.abbreviation}');
      }
      header = pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              nameText.toString(),
              textAlign: pw.TextAlign.left,
              style: nameStyle,
            ),
          ),
          _pdfPriceCell(props.price, priceStyle, baseFontSize),
        ],
      );
    } else {
      final wrapAlign = switch (alignment) {
        WidgetAlignment.center => pw.WrapAlignment.center,
        WidgetAlignment.end => pw.WrapAlignment.end,
        _ => pw.WrapAlignment.start,
      };
      header = pw.Wrap(
        alignment: wrapAlign,
        crossAxisAlignment: pw.WrapCrossAlignment.end,
        children: [
          pw.Text(props.name, textAlign: textAlign, style: nameStyle),
          if (props.vintage != null)
            pw.Text(
              '  ${props.vintage}',
              textAlign: textAlign,
              style: pw.TextStyle(
                fontSize: baseFontSize - 2,
                letterSpacing: 0.4,
              ),
            ),
          pw.Text(
            props.dietary?.abbreviation != null
                ? '  ${props.dietary!.abbreviation}'
                : '',
            textAlign: textAlign,
            style: pw.TextStyle(fontSize: baseFontSize - 3, letterSpacing: 0.4),
          ),
          if (showPrice)
            pw.Text(
              '  ${formatPrice(props.price).replaceFirst('£', '')}',
              textAlign: textAlign,
              style: priceStyle,
            ),
        ],
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: _pdfCrossAxis(alignment),
        children: [
          header,
          if (props.description != null && props.description!.isNotEmpty)
            pw.Text(
              props.description!,
              textAlign: textAlign,
              style: pw.TextStyle(fontSize: baseFontSize, letterSpacing: -0.2),
            ),
          if (showAllergens && props.containsSulphites)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'SULPHITES',
                textAlign: textAlign,
                style: pw.TextStyle(
                  fontSize: baseFontSize - 3,
                  letterSpacing: 0.6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildTextWidget(WidgetInstance widget, StyleConfig? styleConfig) {
    final props = TextProps.fromJson(widget.props);

    pw.TextAlign alignment;
    switch (props.align) {
      case 'center':
        alignment = pw.TextAlign.center;
        break;
      case 'right':
        alignment = pw.TextAlign.right;
        break;
      default:
        alignment = pw.TextAlign.left;
    }

    pw.FontWeight? fontWeight;
    pw.FontStyle? fontStyle;

    if (props.bold && props.italic) {
      fontWeight = pw.FontWeight.bold;
      fontStyle = pw.FontStyle.italic;
    } else if (props.bold) {
      fontWeight = pw.FontWeight.bold;
    } else if (props.italic) {
      fontStyle = pw.FontStyle.italic;
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        props.text,
        textAlign: alignment,
        style: pw.TextStyle(
          fontSize: props.fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ),
      ),
    );
  }

  pw.Widget _buildSectionWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    pw.Font sectionFont,
    WidgetAlignment alignment,
  ) {
    final props = SectionProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

    // Section has no price line, so justified falls back to start (mirrors the
    // Flutter-side SectionWidget).
    final effective = alignment.isJustified ? WidgetAlignment.start : alignment;
    final title = props.uppercase ? props.title.toUpperCase() : props.title;

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: _pdfCrossAxis(effective),
        children: [
          pw.Text(
            title,
            textAlign: _pdfTextAlign(effective),
            style: pw.TextStyle(
              font: sectionFont,
              fontSize: baseFontSize + 2,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: props.uppercase ? 1.5 : 0,
            ),
          ),
          if (props.showDivider) ...[
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 1),
          ],
        ],
      ),
    );
  }

  @visibleForTesting
  pw.Widget debugBuildSection(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    pw.Font sectionFont,
    WidgetAlignment alignment,
  ) => _buildSectionWidget(widget, styleConfig, sectionFont, alignment);

  pw.Widget _buildImageWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    Map<String, Uint8List> imageCache,
  ) {
    final props = ImageProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

    pw.Alignment alignment;
    switch (props.align.toLowerCase()) {
      case 'left':
        alignment = pw.Alignment.centerLeft;
        break;
      case 'right':
        alignment = pw.Alignment.centerRight;
        break;
      case 'center':
      default:
        alignment = pw.Alignment.center;
        break;
    }

    final imageBytes = imageCache[props.fileId];

    if (imageBytes != null) {
      final image = pw.MemoryImage(imageBytes);

      pw.BoxFit boxFit;
      switch (props.fit.toLowerCase()) {
        case 'cover':
          boxFit = pw.BoxFit.cover;
          break;
        case 'fill':
          boxFit = pw.BoxFit.fill;
          break;
        case 'fitwidth':
          boxFit = pw.BoxFit.fitWidth;
          break;
        case 'fitheight':
          boxFit = pw.BoxFit.fitHeight;
          break;
        case 'contain':
        default:
          boxFit = pw.BoxFit.contain;
          break;
      }

      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Align(
          alignment: alignment,
          child: pw.Image(
            image,
            width: props.width,
            height: props.height,
            fit: boxFit,
          ),
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Align(
        alignment: alignment,
        child: pw.Container(
          width: props.width ?? 100,
          height: props.height ?? 100,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            color: PdfColors.grey200,
          ),
          child: pw.Center(
            child: pw.Text(
              '[Image: ${props.fileId}]',
              style: pw.TextStyle(
                fontSize: baseFontSize - 2,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildDishToShareWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    WidgetAlignment alignment,
  ) {
    final props = DishToShareProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;
    final textAlign = _pdfTextAlign(alignment);

    final nameStyle = pw.TextStyle(
      fontSize: baseFontSize,
      letterSpacing: 0.55,
      fontWeight: pw.FontWeight.bold,
    );
    final priceStyle = pw.TextStyle(
      fontSize: baseFontSize - 2,
      letterSpacing: -0.33,
      fontWeight: pw.FontWeight.bold,
    );

    pw.Widget header;
    if (alignment == WidgetAlignment.justified && showPrice) {
      final nameText = StringBuffer(props.name);
      if (props.dietary?.abbreviation != null) {
        nameText.write('  ${props.dietary!.abbreviation}');
      }
      nameText.write('  ${props.sharingText}');
      header = pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              nameText.toString(),
              textAlign: pw.TextAlign.left,
              style: nameStyle,
            ),
          ),
          _pdfPriceCell(props.price, priceStyle, baseFontSize),
        ],
      );
    } else {
      final wrapAlign = switch (alignment) {
        WidgetAlignment.center => pw.WrapAlignment.center,
        WidgetAlignment.end => pw.WrapAlignment.end,
        _ => pw.WrapAlignment.start,
      };
      header = pw.Wrap(
        alignment: wrapAlign,
        crossAxisAlignment: pw.WrapCrossAlignment.end,
        children: [
          pw.Text(props.name, textAlign: textAlign, style: nameStyle),
          pw.Text(
            props.dietary?.abbreviation != null
                ? '  ${props.dietary!.abbreviation}'
                : '',
            textAlign: textAlign,
            style: pw.TextStyle(
              fontSize: baseFontSize - 3,
              letterSpacing: 0.4,
              fontStyle: pw.FontStyle.normal,
            ),
          ),
          if (showPrice)
            pw.Text(
              '  ${formatPrice(props.price).replaceFirst('£', '')}',
              textAlign: textAlign,
              style: priceStyle,
            ),
          pw.Text(
            '  ${props.sharingText}',
            textAlign: textAlign,
            style: priceStyle,
          ),
        ],
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: _pdfCrossAxis(alignment),
        children: [
          header,
          if (props.description != null && props.description!.isNotEmpty ||
              showAllergens && props.calories != null)
            pw.RichText(
              textAlign: textAlign,
              text: pw.TextSpan(
                children: [
                  if (props.description != null &&
                      props.description!.isNotEmpty)
                    pw.TextSpan(
                      text: props.description!,
                      style: pw.TextStyle(
                        fontSize: baseFontSize,
                        letterSpacing: -0.2,
                      ),
                    ),
                  if (showAllergens && props.calories != null)
                    pw.TextSpan(
                      text: '  ${props.calories}KCAL',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 5,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          if (showAllergens) ...[
            () {
              final formattedAllergens = AllergenFormatter.formatForDisplay(
                props.allergenInfo,
              );
              if (formattedAllergens.isEmpty) {
                return pw.SizedBox.shrink();
              }
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  formattedAllergens,
                  textAlign: textAlign,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 3,
                    letterSpacing: 0.6,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSetMenuDishWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    final props = SetMenuDishProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showAllergens = displayOptions?.showAllergens ?? true;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Wrap(
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              pw.Text(
                props.name,
                style: pw.TextStyle(
                  fontSize: baseFontSize,
                  letterSpacing: 0.55,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                props.dietary?.abbreviation != null
                    ? '  ${props.dietary!.abbreviation}'
                    : '',
                style: pw.TextStyle(
                  fontSize: baseFontSize - 3,
                  letterSpacing: 0.4,
                  fontStyle: pw.FontStyle.normal,
                ),
              ),
              if (props.supplementText.isNotEmpty)
                pw.Text(
                  '  ${props.supplementText}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 3,
                    letterSpacing: 0.4,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
            ],
          ),
          if (props.description != null && props.description!.isNotEmpty ||
              showAllergens && props.calories != null)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  if (props.description != null &&
                      props.description!.isNotEmpty)
                    pw.TextSpan(
                      text: props.description!,
                      style: pw.TextStyle(
                        fontSize: baseFontSize,
                        letterSpacing: -0.2,
                      ),
                    ),
                  if (showAllergens && props.calories != null)
                    pw.TextSpan(
                      text: '  ${props.calories}KCAL',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 5,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          if (showAllergens) ...[
            () {
              final formattedAllergens = AllergenFormatter.formatForDisplay(
                props.allergenInfo,
              );
              if (formattedAllergens.isEmpty) {
                return pw.SizedBox.shrink();
              }
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  formattedAllergens,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 3,
                    letterSpacing: 0.6,
                    fontStyle: pw.FontStyle.normal,
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSetMenuTitleWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    pw.Font sectionFont,
  ) {
    final props = SetMenuTitleProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrices = displayOptions?.showPrices ?? true;

    final titleText = props.title.toUpperCase();
    final pricesText = showPrices && props.formattedPrices != null
        ? '  ${props.formattedPrices}'
        : '';

    final titleStyle = pw.TextStyle(
      font: sectionFont,
      fontSize: baseFontSize + 2,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1.5,
    );

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$titleText$pricesText', style: titleStyle),
          if (props.subtitle != null && props.subtitle!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                props.subtitle!,
                style: pw.TextStyle(
                  font: sectionFont,
                  fontSize: baseFontSize - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
