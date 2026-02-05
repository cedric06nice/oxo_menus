import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generate PDF UseCase
///
/// Generates a PDF document from a MenuTree matching the exact visual layout.
/// Uses the pdf package for client-side PDF generation.
class GeneratePdfUseCase {
  const GeneratePdfUseCase();

  /// Execute PDF generation for a menu tree
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    try {
      final pdf = pw.Document();

      // Apply page size from menu config
      final pageFormat = _getPageFormat(menuTree.menu.pageSize);

      // Generate pages
      for (final pageData in menuTree.pages) {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (context) => _buildPage(pageData, menuTree.menu.styleConfig),
          ),
        );
      }

      final bytes = await pdf.save();
      return Success(bytes);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  /// Get PDF page format from menu page size configuration
  PdfPageFormat _getPageFormat(dynamic pageSize) {
    if (pageSize == null) return PdfPageFormat.a4;

    // pageSize is a Map<String, dynamic> from JSON
    if (pageSize is Map<String, dynamic>) {
      final name = pageSize['name'] as String?;
      final width = pageSize['width'] as num?;
      final height = pageSize['height'] as num?;

      // Use predefined formats if name matches
      if (name != null) {
        switch (name.toLowerCase()) {
          case 'a4':
            return PdfPageFormat.a4;
          case 'letter':
            return PdfPageFormat.letter;
          case 'legal':
            return PdfPageFormat.legal;
          case 'a3':
            return PdfPageFormat.a3;
        }
      }

      // Custom size if width and height provided
      if (width != null && height != null) {
        return PdfPageFormat(
          width.toDouble() * PdfPageFormat.mm,
          height.toDouble() * PdfPageFormat.mm,
        );
      }
    }

    return PdfPageFormat.a4;
  }

  /// Build a single page with containers
  pw.Widget _buildPage(
    PageWithContainers pageData,
    dynamic styleConfig,
  ) {
    final padding = _getDoubleValue(styleConfig, 'padding') ?? 16.0;

    return pw.Container(
      padding: pw.EdgeInsets.all(padding),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: pageData.containers.map((containerData) {
          return _buildContainer(containerData, styleConfig);
        }).toList(),
      ),
    );
  }

  /// Build a container with columns in a row
  pw.Widget _buildContainer(
    ContainerWithColumns containerData,
    dynamic styleConfig,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Container name (if present)
          if (containerData.container.name != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                containerData.container.name!,
                style: pw.TextStyle(
                  fontSize: (_getDoubleValue(styleConfig, 'fontSize') ?? 14.0) + 2,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          // Columns in row
          if (containerData.columns.isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: containerData.columns.map((columnData) {
                return pw.Expanded(
                  flex: columnData.column.flex ?? 1,
                  child: _buildColumn(columnData, styleConfig),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Build a column with widgets
  pw.Widget _buildColumn(
    ColumnWithWidgets columnData,
    dynamic styleConfig,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: columnData.widgets.map((widget) {
          return _buildWidget(widget, styleConfig);
        }).toList(),
      ),
    );
  }

  /// Build a widget based on its type
  pw.Widget _buildWidget(
    dynamic widget,
    dynamic styleConfig,
  ) {
    // widget is a WidgetInstance with type and props
    final type = widget.type as String;

    switch (type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig);
      default:
        return pw.SizedBox();
    }
  }

  /// Build dish widget in PDF
  pw.Widget _buildDishWidget(
    dynamic widget,
    dynamic styleConfig,
  ) {
    final props = DishProps.fromJson(widget.props as Map<String, dynamic>);
    final baseFontSize = _getDoubleValue(styleConfig, 'fontSize') ?? 14.0;

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
                  props.name,
                  style: pw.TextStyle(
                    fontSize: baseFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (props.showPrice)
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
              style: pw.TextStyle(
                fontSize: baseFontSize - 2,
              ),
            ),
          ],
          // Allergens
          if (props.showAllergens) ...[
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
          // Dietary
          if (props.dietary.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 4,
              runSpacing: 4,
              children: props.dietary
                  .map((diet) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.all(
                            pw.Radius.circular(12),
                          ),
                        ),
                        child: pw.Text(
                          diet,
                          style: pw.TextStyle(
                            fontSize: baseFontSize - 3,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Build text widget in PDF
  pw.Widget _buildTextWidget(
    dynamic widget,
    dynamic styleConfig,
  ) {
    final props = TextProps.fromJson(widget.props as Map<String, dynamic>);
    final baseFontSize = _getDoubleValue(styleConfig, 'fontSize') ?? 14.0;

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
    dynamic widget,
    dynamic styleConfig,
  ) {
    final props = SectionProps.fromJson(widget.props as Map<String, dynamic>);
    final baseFontSize = _getDoubleValue(styleConfig, 'fontSize') ?? 14.0;

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

  /// Helper to safely get double value from styleConfig
  double? _getDoubleValue(dynamic styleConfig, String key) {
    if (styleConfig == null) return null;
    if (styleConfig is! Map<String, dynamic>) return null;
    final value = styleConfig[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
