import 'package:flutter/services.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
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
  final FileRepository? _fileRepository;

  const GeneratePdfUseCase({
    PdfStyleResolver resolver = const PdfStyleResolver(),
    FileRepository? fileRepository,
  }) : _resolver = resolver,
       _fileRepository = fileRepository;

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
      // Pre-fetch images if repository is available
      final imageCache = await _prefetchImages(menuTree);

      final pdf = pw.Document(theme: oxoTheme, version: PdfVersion.pdf_1_5);

      final styleConfig = menuTree.menu.styleConfig;
      final displayOptions = menuTree.menu.displayOptions;
      final pageFormat = _resolver.resolvePageFormat(menuTree.menu.pageSize);
      final pageMargins = _resolver.resolveContentMargins(styleConfig);

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
              imageCache,
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

  /// Collect all image fileIds from a MenuTree and fetch their bytes
  Future<Map<String, Uint8List>> _prefetchImages(MenuTree menuTree) async {
    if (_fileRepository == null) return {};

    final fileIds = <String>{};

    // Collect from all pages (content, header, footer)
    void collectFromPages(List<PageWithContainers> pages) {
      for (final page in pages) {
        for (final container in page.containers) {
          for (final column in container.columns) {
            for (final widget in column.widgets) {
              if (widget.type == 'image') {
                final props = ImageProps.fromJson(widget.props);
                fileIds.add(props.fileId);
              }
            }
          }
        }
      }
    }

    collectFromPages(menuTree.pages);
    if (menuTree.headerPage != null) collectFromPages([menuTree.headerPage!]);
    if (menuTree.footerPage != null) collectFromPages([menuTree.footerPage!]);

    // Fetch all images (parallel for performance)
    final cache = <String, Uint8List>{};
    final futures = fileIds.map((fileId) async {
      final result = await _fileRepository.downloadFile(fileId);
      if (result.isSuccess) {
        cache[fileId] = result.valueOrNull!;
      }
      // On failure, simply skip -- placeholder will be rendered
    });
    await Future.wait(futures);

    return cache;
  }

  /// Build a page with header, content, and footer
  pw.Widget _buildPageWithHeaderFooter(
    PageWithContainers pageData,
    PageWithContainers? headerPage,
    PageWithContainers? footerPage,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
  ) {
    final children = <pw.Widget>[];

    // Add header if present
    if (headerPage != null) {
      children.addAll(
        headerPage.containers.map((containerData) {
          return _buildContainer(
            containerData,
            styleConfig,
            displayOptions,
            imageCache,
          );
        }),
      );
    }

    // Add main content
    children.addAll(
      pageData.containers.map((containerData) {
        return _buildContainer(
          containerData,
          styleConfig,
          displayOptions,
          imageCache,
        );
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
          return _buildContainer(
            containerData,
            styleConfig,
            displayOptions,
            imageCache,
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

    final content = pw.Container(
      padding: padding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );

    final borderedContent = _resolver.wrapWithBorder(content, styleConfig);

    return pw.Container(margin: margin, child: borderedContent);
  }

  /// Build a container with columns in a row
  pw.Widget _buildContainer(
    ContainerWithColumns containerData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
  ) {
    final containerStyle = containerData.container.styleConfig;

    final margin = containerStyle != null
        ? _resolver.resolveContentMargins(containerStyle)
        : pw.EdgeInsets.zero;

    final padding = containerStyle != null
        ? _resolver.resolveContentPadding(containerStyle)
        : pw.EdgeInsets.zero;

    pw.Widget content = pw.Container(
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
                  child: _buildColumn(
                    columnData,
                    styleConfig,
                    displayOptions,
                    imageCache,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );

    final borderedContent = _resolver.wrapWithBorder(content, containerStyle);

    return pw.Container(margin: margin, child: borderedContent);
  }

  /// Build a column with widgets
  pw.Widget _buildColumn(
    ColumnWithWidgets columnData,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
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
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: columnData.widgets.map((widget) {
          return _buildWidget(widget, styleConfig, displayOptions, imageCache);
        }).toList(),
      ),
    );

    final borderedContent = _resolver.wrapWithBorder(content, columnStyle);

    return pw.Container(margin: margin, child: borderedContent);
  }

  /// Build a widget based on its type
  pw.Widget _buildWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    MenuDisplayOptions? displayOptions,
    Map<String, Uint8List> imageCache,
  ) {
    switch (widget.type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig, displayOptions);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig);
      case 'image':
        return _buildImageWidget(widget, styleConfig, imageCache);
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
            mainAxisAlignment: pw.MainAxisAlignment.start,
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
                  '  ${props.price.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2,
                    letterSpacing: -0.33,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          // Description
          if (props.description != null && props.description!.isNotEmpty) ...[
            pw.Text(
              props.description!,
              style: pw.TextStyle(fontSize: baseFontSize, letterSpacing: -0.15),
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

  /// Build text widget in PDF
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

  /// Build section widget in PDF
  pw.Widget _buildSectionWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
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
  pw.Widget _buildImageWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
    Map<String, Uint8List> imageCache,
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

    // Check if we have fetched image bytes
    final imageBytes = imageCache[props.fileId];

    if (imageBytes != null) {
      // Render real image
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

    // Fallback: render placeholder
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
