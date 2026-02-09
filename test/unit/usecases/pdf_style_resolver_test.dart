import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  const resolver = PdfStyleResolver();

  group('PdfStyleResolver', () {
    group('resolvePageFormat', () {
      test('should return A4 for null pageSize', () {
        final format = resolver.resolvePageFormat(null);
        expect(format, PdfPageFormat.a4);
      });

      test('should return A4 for name "a4"', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'a4', width: 210, height: 297),
        );
        expect(format, PdfPageFormat.a4);
      });

      test('should return A4 for name "A4" (case-insensitive)', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'A4', width: 210, height: 297),
        );
        expect(format, PdfPageFormat.a4);
      });

      test('should return letter for name "letter"', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'letter', width: 216, height: 279),
        );
        expect(format, PdfPageFormat.letter);
      });

      test('should return legal for name "legal"', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'legal', width: 216, height: 356),
        );
        expect(format, PdfPageFormat.legal);
      });

      test('should return A3 for name "a3"', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'a3', width: 297, height: 420),
        );
        expect(format, PdfPageFormat.a3);
      });

      test('should return custom size for unrecognized name', () {
        final format = resolver.resolvePageFormat(
          const PageSize(name: 'custom', width: 150, height: 250),
        );
        expect(format.width, closeTo(150.0 * PdfPageFormat.mm, 0.01));
        expect(format.height, closeTo(250.0 * PdfPageFormat.mm, 0.01));
      });
    });

    group('resolvePageMargins', () {
      test('should return zero margins for null styleConfig', () {
        final margins = resolver.resolvePageMargins(null);
        expect(margins.top, 0.0);
        expect(margins.bottom, 0.0);
        expect(margins.left, 0.0);
        expect(margins.right, 0.0);
      });

      test('should return zero margins for StyleConfig with no margin values', () {
        final margins = resolver.resolvePageMargins(const StyleConfig());
        expect(margins.top, 0.0);
        expect(margins.bottom, 0.0);
        expect(margins.left, 0.0);
        expect(margins.right, 0.0);
      });

      test('should read margin values from StyleConfig', () {
        final margins = resolver.resolvePageMargins(
          const StyleConfig(
            marginTop: 20.0,
            marginBottom: 30.0,
            marginLeft: 15.0,
            marginRight: 15.0,
          ),
        );
        expect(margins.top, 20.0);
        expect(margins.bottom, 30.0);
        expect(margins.left, 15.0);
        expect(margins.right, 15.0);
      });

      test('should default individual null margins to zero', () {
        final margins = resolver.resolvePageMargins(
          const StyleConfig(marginTop: 10.0),
        );
        expect(margins.top, 10.0);
        expect(margins.bottom, 0.0);
        expect(margins.left, 0.0);
        expect(margins.right, 0.0);
      });
    });

    group('resolveContentPadding', () {
      test('should return default 16.0 all for null styleConfig', () {
        final padding = resolver.resolveContentPadding(null);
        expect(padding.top, 16.0);
        expect(padding.bottom, 16.0);
        expect(padding.left, 16.0);
        expect(padding.right, 16.0);
      });

      test('should return default 16.0 all when all padding fields null', () {
        final padding = resolver.resolveContentPadding(const StyleConfig());
        expect(padding.top, 16.0);
        expect(padding.bottom, 16.0);
        expect(padding.left, 16.0);
        expect(padding.right, 16.0);
      });

      test('should use single padding as uniform fallback', () {
        final padding = resolver.resolveContentPadding(
          const StyleConfig(padding: 24.0),
        );
        expect(padding.top, 24.0);
        expect(padding.bottom, 24.0);
        expect(padding.left, 24.0);
        expect(padding.right, 24.0);
      });

      test('should use per-side values when set', () {
        final padding = resolver.resolveContentPadding(
          const StyleConfig(
            paddingTop: 10.0,
            paddingBottom: 20.0,
            paddingLeft: 5.0,
            paddingRight: 5.0,
          ),
        );
        expect(padding.top, 10.0);
        expect(padding.bottom, 20.0);
        expect(padding.left, 5.0);
        expect(padding.right, 5.0);
      });

      test('should fall back to single padding for unset sides', () {
        final padding = resolver.resolveContentPadding(
          const StyleConfig(
            padding: 12.0,
            paddingTop: 20.0,
          ),
        );
        expect(padding.top, 20.0);
        expect(padding.bottom, 12.0);
        expect(padding.left, 12.0);
        expect(padding.right, 12.0);
      });
    });

    group('resolveBaseFontSize', () {
      test('should return 14.0 for null styleConfig', () {
        expect(resolver.resolveBaseFontSize(null), 14.0);
      });

      test('should return 14.0 when fontSize is null', () {
        expect(resolver.resolveBaseFontSize(const StyleConfig()), 14.0);
      });

      test('should return custom fontSize from StyleConfig', () {
        expect(
          resolver.resolveBaseFontSize(const StyleConfig(fontSize: 18.0)),
          18.0,
        );
      });
    });

    group('wrapWithBorder', () {
      final child = pw.SizedBox(width: 100, height: 100);

      test('should return child unchanged for null styleConfig', () {
        final result = resolver.wrapWithBorder(child, null);
        expect(identical(result, child), isTrue);
      });

      test('should return child unchanged for BorderType.none', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.none),
        );
        expect(identical(result, child), isTrue);
      });

      test('should return child unchanged when borderType is null', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(),
        );
        expect(identical(result, child), isTrue);
      });

      test('should wrap with thin border for plainThin', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.plainThin),
        );
        expect(result, isA<pw.Container>());
        final container = result as pw.Container;
        expect(container.decoration, isNotNull);
        final decoration = container.decoration as pw.BoxDecoration;
        expect(decoration.border, isNotNull);
      });

      test('should wrap with thick border for plainThick', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.plainThick),
        );
        expect(result, isA<pw.Container>());
        final container = result as pw.Container;
        expect(container.decoration, isNotNull);
      });

      test('should wrap with nested containers for doubleOffset', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.doubleOffset),
        );
        // Outer container with border
        expect(result, isA<pw.Container>());
        final outer = result as pw.Container;
        expect(outer.decoration, isNotNull);
        // Inner container should also have a border (nested inside)
        expect(outer.child, isA<pw.Padding>());
        final padding = outer.child as pw.Padding;
        expect(padding.child, isA<pw.Container>());
        final inner = padding.child as pw.Container;
        expect(inner.decoration, isNotNull);
      });

      test('should wrap with shadow for dropShadow', () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.dropShadow),
        );
        expect(result, isA<pw.Container>());
        final container = result as pw.Container;
        expect(container.decoration, isNotNull);
        final decoration = container.decoration as pw.BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow, isNotEmpty);
      });
    });
  });
}
