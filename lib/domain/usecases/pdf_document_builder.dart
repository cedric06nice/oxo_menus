import 'dart:math' as math;
import 'dart:typed_data';

import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a PDF document from a MenuTree.
///
/// This class is isolate-safe: it holds only a const [PdfStyleResolver]
/// and accepts all data (fonts, images, menu tree) as parameters.
class PdfDocumentBuilder {
  static final _trailingZeros = RegExp(r'\.?0+$');

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
  }) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(baseFontData),
      bold: pw.Font.ttf(boldFontData),
    );
    final sectionFont = pw.Font.ttf(sectionFontData);
    final pdf = pw.Document(theme: theme, version: PdfVersion.pdf_1_5);

    final styleConfig = menuTree.menu.styleConfig;
    final displayOptions = menuTree.menu.displayOptions;
    final pageFormat = _resolver.resolvePageFormat(menuTree.menu.pageSize);
    final pageMargins = _resolver.resolveContentMargins(styleConfig);
    final availableWidth = pageFormat.width - pageMargins.horizontal;

    for (final pageData in menuTree.pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pageMargins,
          build: (context) => _buildPageWithHeaderFooter(
            pageData,
            menuTree.headerPage,
            menuTree.footerPage,
            styleConfig,
            displayOptions,
            imageCache,
            availableWidth,
            sectionFont,
          ),
        ),
      );
    }

    return await pdf.save();
  }

  pw.Widget _buildPageWithHeaderFooter(
    PageWithContainers pageData,
    PageWithContainers? headerPage,
    PageWithContainers? footerPage,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    double availableWidth,
    pw.Font sectionFont,
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
    final borderInset = _resolver.resolveBorderHorizontalInset(styleConfig);

    final innerWidth = math.max(
      0.0,
      availableWidth - margin.horizontal - borderInset - padding.horizontal,
    );

    pw.Widget scalableContent;
    if (contentChildren.isNotEmpty) {
      scalableContent = pw.FittedBox(
        fit: pw.BoxFit.scaleDown,
        alignment: pw.Alignment.topLeft,
        child: pw.ConstrainedBox(
          constraints: pw.BoxConstraints(
            minWidth: innerWidth,
            maxWidth: innerWidth,
            minHeight: 0.1,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: contentChildren,
          ),
        ),
      );
    } else {
      scalableContent = pw.SizedBox();
    }

    pw.Widget innerLayout;
    if (footerChildren.isNotEmpty) {
      innerLayout = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.max,
        children: [
          pw.Expanded(child: scalableContent),
          ...footerChildren,
        ],
      );
    } else {
      innerLayout = scalableContent;
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
  ) {
    final containerStyle = containerData.container.styleConfig;

    final margin = containerStyle != null
        ? _resolver.resolveContentMargins(containerStyle)
        : pw.EdgeInsets.zero;

    final padding = containerStyle != null
        ? _resolver.resolveContentPadding(containerStyle)
        : pw.EdgeInsets.zero;

    pw.Widget content;

    if (containerData.columns.length <= 1) {
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
        ),
      );
    }

    final borderedContent = _resolver.wrapWithBorder(content, containerStyle);

    return pw.Container(margin: margin, child: borderedContent);
  }

  pw.Widget _buildColumnsAsGrid(
    List<ColumnWithWidgets> columns,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
    pw.Font sectionFont,
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
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
    );
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
  ) {
    switch (widget.type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig, displayOptions);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig, sectionFont);
      case 'image':
        return _buildImageWidget(widget, styleConfig, imageCache);
      case 'wine':
        return _buildWineWidget(widget, styleConfig, displayOptions);
      case 'dish_to_share':
        return _buildDishToShareWidget(widget, styleConfig, displayOptions);
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
  ) {
    final props = DishProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
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
              if (showPrice)
                pw.Text(
                  '  ${props.price.toStringAsFixed(2).replaceAll(_trailingZeros, '')}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    letterSpacing: -0.33,
                    fontWeight: pw.FontWeight.bold,
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
                props.effectiveAllergenInfo,
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

  pw.Widget _buildWineWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    final props = WineProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                props.name,
                style: pw.TextStyle(
                  fontSize: baseFontSize,
                  letterSpacing: 0.55,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (props.vintage != null)
                pw.Text(
                  '  ${props.vintage.toString()}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    letterSpacing: 0.4,
                  ),
                ),
              pw.Text(
                props.dietary?.abbreviation != null
                    ? '  ${props.dietary!.abbreviation}'
                    : '',
                style: pw.TextStyle(
                  fontSize: baseFontSize - 3,
                  letterSpacing: 0.4,
                ),
              ),
              if (showPrice)
                pw.Text(
                  '  ${props.price.toStringAsFixed(2).replaceAll(_trailingZeros, '')}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    letterSpacing: -0.33,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (props.description != null && props.description!.isNotEmpty)
            pw.Text(
              props.description!,
              style: pw.TextStyle(fontSize: baseFontSize, letterSpacing: -0.2),
            ),
          if (showAllergens && props.containsSulphites)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'SULPHITES',
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
  ) {
    final props = SectionProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

    final title = props.uppercase ? props.title.toUpperCase() : props.title;

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
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
  ) {
    final props = DishToShareProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);
    final showPrice = displayOptions?.showPrices ?? true;
    final showAllergens = displayOptions?.showAllergens ?? true;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
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
              if (showPrice)
                pw.Text(
                  '  ${props.price.toStringAsFixed(2).replaceAll(_trailingZeros, '')}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    letterSpacing: -0.33,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.Text(
                '  ${props.sharingText}',
                style: pw.TextStyle(
                  fontSize: baseFontSize - 2,
                  letterSpacing: -0.33,
                  fontWeight: pw.FontWeight.bold,
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
                props.effectiveAllergenInfo,
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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
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
                props.effectiveAllergenInfo,
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
