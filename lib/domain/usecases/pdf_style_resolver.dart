import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Pure helper that resolves StyleConfig and PageSize to PDF values.
/// Extracted from GeneratePdfUseCase for testability.
class PdfStyleResolver {
  const PdfStyleResolver();

  /// Resolve PageSize entity to PdfPageFormat.
  PdfPageFormat resolvePageFormat(PageSize? pageSize) {
    if (pageSize == null) return PdfPageFormat.a4;

    switch (pageSize.name.toLowerCase()) {
      case 'a4':
        return PdfPageFormat.a4;
      case 'letter':
        return PdfPageFormat.letter;
      case 'legal':
        return PdfPageFormat.legal;
      case 'a3':
        return PdfPageFormat.a3;
    }

    return PdfPageFormat(
      pageSize.width * PdfPageFormat.mm,
      pageSize.height * PdfPageFormat.mm,
    );
  }

  /// Resolve page margins from StyleConfig.
  pw.EdgeInsets resolvePageMargins(StyleConfig? style) {
    if (style == null) return pw.EdgeInsets.zero;
    return pw.EdgeInsets.only(
      top: style.marginTop ?? 0,
      bottom: style.marginBottom ?? 0,
      left: style.marginLeft ?? 0,
      right: style.marginRight ?? 0,
    );
  }

  /// Resolve content padding from StyleConfig.
  /// Per-side values take priority, then single padding, then default 16.0.
  pw.EdgeInsets resolveContentPadding(StyleConfig? style) {
    const defaultPadding = 16.0;
    if (style == null) return const pw.EdgeInsets.all(defaultPadding);

    final fallback = style.padding ?? defaultPadding;
    return pw.EdgeInsets.only(
      top: style.paddingTop ?? fallback,
      bottom: style.paddingBottom ?? fallback,
      left: style.paddingLeft ?? fallback,
      right: style.paddingRight ?? fallback,
    );
  }

  /// Resolve base font size from StyleConfig.
  double resolveBaseFontSize(StyleConfig? style) {
    return style?.fontSize ?? 14.0;
  }

  /// Wrap a child widget with the appropriate border decoration.
  /// Returns the child unchanged when no border is configured.
  pw.Widget wrapWithBorder(pw.Widget child, StyleConfig? style) {
    final borderType = style?.borderType;
    if (borderType == null || borderType == BorderType.none) {
      return child;
    }

    switch (borderType) {
      case BorderType.none:
        return child;
      case BorderType.plainThin:
        return pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
          child: child,
        );
      case BorderType.plainThick:
        return pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 2.0)),
          child: child,
        );
      case BorderType.doubleOffset:
        return pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
              child: child,
            ),
          ),
        );
      case BorderType.dropShadow:
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
            boxShadow: const [
              pw.BoxShadow(
                color: PdfColors.grey400,
                offset: PdfPoint(2, -2),
                blurRadius: 3,
              ),
            ],
          ),
          child: child,
        );
    }
  }
}
