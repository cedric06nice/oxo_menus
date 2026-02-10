import 'package:flutter/services.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generate PDF UseCase
///
/// Generates a PDF document from a MenuTree matching the exact visual layout.
/// Uses the pdf package for client-side PDF generation.
class GeneratePdfUseCase {
  final PdfStyleResolver _resolver;

  const GeneratePdfUseCase({
    PdfStyleResolver resolver = const PdfStyleResolver(),
  }) : _resolver = resolver;

  /// Execute PDF generation for a menu tree
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    var oxoTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
        await rootBundle.load('assets/fonts/FuturaStd-Light.ttf'),
      ),
      bold: pw.Font.ttf(
        await rootBundle.load('assets/fonts/FuturaStd-Book.ttf'),
      ),
    );
    try {
      final pdf = pw.Document(theme: oxoTheme, version: PdfVersion.pdf_1_5);

      final styleConfig = menuTree.menu.styleConfig;
      final displayOptions = menuTree.menu.displayOptions;
      final pageFormat = _resolver.resolvePageFormat(menuTree.menu.pageSize);
      final pageMargins = _resolver.resolvePageMargins(styleConfig);

      // Generate pages with header/footer
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
            ),
          ),
        );
      }

      final bytes = await pdf.save();
      return Success(bytes);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  /// Build a page with header, content, and footer
  pw.Widget _buildPageWithHeaderFooter(
    PageWithContainers pageData,
    PageWithContainers? headerPage,
    PageWithContainers? footerPage,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    final children = <pw.Widget>[];

    // Add header if present
    if (headerPage != null) {
      children.addAll(
        headerPage.containers.map((containerData) {
          return _buildContainer(containerData, styleConfig, displayOptions);
        }),
      );
    }

    // Add main content
    children.addAll(
      pageData.containers.map((containerData) {
        return _buildContainer(containerData, styleConfig, displayOptions);
      }),
    );

    // Add spacer to push footer to bottom
    if (footerPage != null && children.isNotEmpty) {
      children.add(pw.Spacer());
    }

    // Add footer if present
    if (footerPage != null) {
      children.addAll(
        footerPage.containers.map((containerData) {
          return _buildContainer(containerData, styleConfig, displayOptions);
        }),
      );
    }

    final padding = _resolver.resolveContentPadding(styleConfig);

    final content = pw.Container(
      padding: padding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
    return _resolver.wrapWithBorder(content, styleConfig);
  }

  /// Build a container with columns in a row
  pw.Widget _buildContainer(
    ContainerWithColumns containerData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    final containerStyle = containerData.container.styleConfig;
    final margin = containerStyle != null
        ? _resolver.resolvePageMargins(containerStyle)
        : const pw.EdgeInsets.only(bottom: 16);
    final padding = containerStyle != null
        ? _resolver.resolveContentPadding(containerStyle)
        : pw.EdgeInsets.zero;

    pw.Widget content = pw.Container(
      margin: margin,
      padding: padding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Columns in row
          if (containerData.columns.isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: containerData.columns.map((columnData) {
                return pw.Expanded(
                  flex: columnData.column.flex ?? 1,
                  child: _buildColumn(columnData, styleConfig, displayOptions),
                );
              }).toList(),
            ),
        ],
      ),
    );
    return _resolver.wrapWithBorder(content, containerStyle);
  }

  /// Build a column with widgets
  pw.Widget _buildColumn(
    ColumnWithWidgets columnData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    final columnStyle = columnData.column.styleConfig;
    final padding = columnStyle != null
        ? _resolver.resolveContentPadding(columnStyle)
        : const pw.EdgeInsets.symmetric(horizontal: 4);

    pw.Widget content = pw.Padding(
      padding: padding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: columnData.widgets.map((widget) {
          return _buildWidget(widget, styleConfig, displayOptions);
        }).toList(),
      ),
    );
    return _resolver.wrapWithBorder(content, columnStyle);
  }

  /// Build a widget based on its type
  pw.Widget _buildWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
  ) {
    switch (widget.type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig, displayOptions);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig);
      case 'image':
        return _buildImageWidget(widget, styleConfig);
      default:
        return pw.SizedBox();
    }
  }

  /// Build dish widget in PDF
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
          // Name and price row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  props.displayName,
                  style: pw.TextStyle(
                    fontSize: baseFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (showPrice)
                pw.Text(
                  '£${props.price.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          // Description
          if (props.description != null && props.description!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              props.description!,
              style: pw.TextStyle(fontSize: baseFontSize - 2),
            ),
          ],
          // Allergens
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
                    fontSize: baseFontSize - 2,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }

  /// Build text widget in PDF
  pw.Widget _buildTextWidget(WidgetInstance widget, StyleConfig? styleConfig) {
    final props = TextProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

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
          fontSize: baseFontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ),
      ),
    );
  }

  /// Build section widget in PDF
  pw.Widget _buildSectionWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    final props = SectionProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

    final title = props.uppercase ? props.title.toUpperCase() : props.title;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12, top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
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

  /// Build image widget in PDF
  ///
  /// Note: Currently renders a placeholder. Full image rendering would require
  /// fetching image bytes from Directus server, which needs HTTP client injection.
  pw.Widget _buildImageWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    final props = ImageProps.fromJson(widget.props);
    final baseFontSize = _resolver.resolveBaseFontSize(styleConfig);

    // Determine alignment
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

    // Render placeholder for now
    // TODO: Implement actual image fetching and rendering
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
}
