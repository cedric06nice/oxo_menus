import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  const resolver = PdfStyleResolver();

  // ---------------------------------------------------------------------------
  // resolvePageFormat
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.resolvePageFormat', () {
    test('should return A4 when pageSize is null', () {
      final result = resolver.resolvePageFormat(null);

      expect(result, PdfPageFormat.a4);
    });

    test('should return A4 when name is "a4" (lowercase)', () {
      const pageSize = PageSize(name: 'a4', width: 210, height: 297);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.a4);
    });

    test('should return A4 when name is "A4" (uppercase — case-insensitive)', () {
      const pageSize = PageSize(name: 'A4', width: 210, height: 297);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.a4);
    });

    test('should return letter when name is "letter"', () {
      const pageSize = PageSize(name: 'letter', width: 216, height: 279);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.letter);
    });

    test('should return letter when name is "LETTER" (uppercase)', () {
      const pageSize = PageSize(name: 'LETTER', width: 216, height: 279);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.letter);
    });

    test('should return legal when name is "legal"', () {
      const pageSize = PageSize(name: 'legal', width: 216, height: 356);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.legal);
    });

    test('should return A3 when name is "a3"', () {
      const pageSize = PageSize(name: 'a3', width: 297, height: 420);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.a3);
    });

    test('should return A3 when name is "A3" (uppercase)', () {
      const pageSize = PageSize(name: 'A3', width: 297, height: 420);

      final result = resolver.resolvePageFormat(pageSize);

      expect(result, PdfPageFormat.a3);
    });

    test(
      'should return custom PdfPageFormat with correct dimensions when name is unrecognised',
      () {
        const pageSize = PageSize(name: 'custom', width: 150, height: 250);

        final result = resolver.resolvePageFormat(pageSize);

        expect(result.width, closeTo(150.0 * PdfPageFormat.mm, 0.01));
        expect(result.height, closeTo(250.0 * PdfPageFormat.mm, 0.01));
      },
    );

    test(
      'should return custom PdfPageFormat for very small page (edge case)',
      () {
        const pageSize = PageSize(name: 'tiny', width: 50, height: 50);

        final result = resolver.resolvePageFormat(pageSize);

        expect(result.width, closeTo(50.0 * PdfPageFormat.mm, 0.01));
        expect(result.height, closeTo(50.0 * PdfPageFormat.mm, 0.01));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // resolveContentMargins
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.resolveContentMargins', () {
    test('should return zero on all sides when styleConfig is null', () {
      final result = resolver.resolveContentMargins(null);

      expect(result.top, 0.0);
      expect(result.bottom, 0.0);
      expect(result.left, 0.0);
      expect(result.right, 0.0);
    });

    test(
      'should return zero on all sides when StyleConfig has no margin fields set',
      () {
        final result = resolver.resolveContentMargins(const StyleConfig());

        expect(result.top, 0.0);
        expect(result.bottom, 0.0);
        expect(result.left, 0.0);
        expect(result.right, 0.0);
      },
    );

    test(
      'should use single margin field as fallback for all unset per-side values',
      () {
        final result = resolver.resolveContentMargins(
          const StyleConfig(margin: 20.0),
        );

        expect(result.top, 20.0);
        expect(result.bottom, 20.0);
        expect(result.left, 20.0);
        expect(result.right, 20.0);
      },
    );

    test('should use individual per-side margins when all four are set', () {
      final result = resolver.resolveContentMargins(
        const StyleConfig(
          marginTop: 10.0,
          marginBottom: 20.0,
          marginLeft: 15.0,
          marginRight: 5.0,
        ),
      );

      expect(result.top, 10.0);
      expect(result.bottom, 20.0);
      expect(result.left, 15.0);
      expect(result.right, 5.0);
    });

    test(
      'should use per-side margin for set side and zero for unset side when no fallback',
      () {
        final result = resolver.resolveContentMargins(
          const StyleConfig(marginTop: 8.0),
        );

        expect(result.top, 8.0);
        expect(result.bottom, 0.0);
        expect(result.left, 0.0);
        expect(result.right, 0.0);
      },
    );

    test(
      'should prefer per-side margin over single margin fallback when both provided',
      () {
        final result = resolver.resolveContentMargins(
          const StyleConfig(margin: 10.0, marginTop: 30.0),
        );

        expect(result.top, 30.0);
        expect(result.bottom, 10.0);
        expect(result.left, 10.0);
        expect(result.right, 10.0);
      },
    );

    test('should handle zero margin explicitly set', () {
      final result = resolver.resolveContentMargins(
        const StyleConfig(marginTop: 0.0, marginBottom: 0.0),
      );

      expect(result.top, 0.0);
      expect(result.bottom, 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // resolveContentPadding
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.resolveContentPadding', () {
    test('should return zero on all sides when styleConfig is null', () {
      final result = resolver.resolveContentPadding(null);

      expect(result.top, 0.0);
      expect(result.bottom, 0.0);
      expect(result.left, 0.0);
      expect(result.right, 0.0);
    });

    test(
      'should return zero on all sides when StyleConfig has no padding fields set',
      () {
        final result = resolver.resolveContentPadding(const StyleConfig());

        expect(result.top, 0.0);
        expect(result.bottom, 0.0);
        expect(result.left, 0.0);
        expect(result.right, 0.0);
      },
    );

    test(
      'should use single padding field as uniform fallback for all sides',
      () {
        final result = resolver.resolveContentPadding(
          const StyleConfig(padding: 24.0),
        );

        expect(result.top, 24.0);
        expect(result.bottom, 24.0);
        expect(result.left, 24.0);
        expect(result.right, 24.0);
      },
    );

    test('should use individual per-side paddings when all four are set', () {
      final result = resolver.resolveContentPadding(
        const StyleConfig(
          paddingTop: 10.0,
          paddingBottom: 20.0,
          paddingLeft: 5.0,
          paddingRight: 8.0,
        ),
      );

      expect(result.top, 10.0);
      expect(result.bottom, 20.0);
      expect(result.left, 5.0);
      expect(result.right, 8.0);
    });

    test(
      'should prefer per-side padding over single padding fallback when both provided',
      () {
        final result = resolver.resolveContentPadding(
          const StyleConfig(padding: 12.0, paddingTop: 20.0),
        );

        expect(result.top, 20.0);
        expect(result.bottom, 12.0);
        expect(result.left, 12.0);
        expect(result.right, 12.0);
      },
    );

    test(
      'should fall through to zero for unset per-side padding when no fallback',
      () {
        final result = resolver.resolveContentPadding(
          const StyleConfig(paddingBottom: 6.0),
        );

        expect(result.top, 0.0);
        expect(result.bottom, 6.0);
        expect(result.left, 0.0);
        expect(result.right, 0.0);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // resolveBaseFontSize
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.resolveBaseFontSize', () {
    test('should return 11.0 when styleConfig is null', () {
      expect(resolver.resolveBaseFontSize(null), 11.0);
    });

    test('should return 11.0 when fontSize field is null', () {
      expect(resolver.resolveBaseFontSize(const StyleConfig()), 11.0);
    });

    test('should return the configured fontSize when set', () {
      expect(
        resolver.resolveBaseFontSize(const StyleConfig(fontSize: 18.0)),
        18.0,
      );
    });

    test('should return small fontSize correctly (edge: 6.0)', () {
      expect(
        resolver.resolveBaseFontSize(const StyleConfig(fontSize: 6.0)),
        6.0,
      );
    });

    test('should return large fontSize correctly (edge: 72.0)', () {
      expect(
        resolver.resolveBaseFontSize(const StyleConfig(fontSize: 72.0)),
        72.0,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // resolveBorderHorizontalInset
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.resolveBorderHorizontalInset', () {
    test('should return 0.0 when styleConfig is null', () {
      expect(resolver.resolveBorderHorizontalInset(null), 0.0);
    });

    test('should return 0.0 when borderType is null', () {
      expect(
        resolver.resolveBorderHorizontalInset(const StyleConfig()),
        0.0,
      );
    });

    test('should return 0.0 for BorderType.none', () {
      expect(
        resolver.resolveBorderHorizontalInset(
          const StyleConfig(borderType: BorderType.none),
        ),
        0.0,
      );
    });

    test('should return 1.0 for BorderType.plainThin', () {
      expect(
        resolver.resolveBorderHorizontalInset(
          const StyleConfig(borderType: BorderType.plainThin),
        ),
        1.0,
      );
    });

    test('should return 4.0 for BorderType.plainThick', () {
      expect(
        resolver.resolveBorderHorizontalInset(
          const StyleConfig(borderType: BorderType.plainThick),
        ),
        4.0,
      );
    });

    test('should return 8.0 for BorderType.doubleOffset', () {
      expect(
        resolver.resolveBorderHorizontalInset(
          const StyleConfig(borderType: BorderType.doubleOffset),
        ),
        8.0,
      );
    });

    test('should return 1.0 for BorderType.dropShadow', () {
      expect(
        resolver.resolveBorderHorizontalInset(
          const StyleConfig(borderType: BorderType.dropShadow),
        ),
        1.0,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // wrapWithBorder
  // ---------------------------------------------------------------------------

  group('PdfStyleResolver.wrapWithBorder', () {
    final child = pw.SizedBox(width: 100, height: 100);

    test('should return the child unchanged when styleConfig is null', () {
      final result = resolver.wrapWithBorder(child, null);

      expect(identical(result, child), isTrue);
    });

    test('should return the child unchanged when borderType is null', () {
      final result = resolver.wrapWithBorder(child, const StyleConfig());

      expect(identical(result, child), isTrue);
    });

    test('should return the child unchanged for BorderType.none', () {
      final result = resolver.wrapWithBorder(
        child,
        const StyleConfig(borderType: BorderType.none),
      );

      expect(identical(result, child), isTrue);
    });

    test('should wrap child in a pw.Container for BorderType.plainThin', () {
      final result = resolver.wrapWithBorder(
        child,
        const StyleConfig(borderType: BorderType.plainThin),
      );

      expect(result, isA<pw.Container>());
    });

    test(
      'should set a non-null decoration on the container for BorderType.plainThin',
      () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.plainThin),
        ) as pw.Container;

        expect(result.decoration, isNotNull);
        expect((result.decoration as pw.BoxDecoration).border, isNotNull);
      },
    );

    test('should wrap child in a pw.Container for BorderType.plainThick', () {
      final result = resolver.wrapWithBorder(
        child,
        const StyleConfig(borderType: BorderType.plainThick),
      );

      expect(result, isA<pw.Container>());
      expect((result as pw.Container).decoration, isNotNull);
    });

    test(
      'should produce outer container with border and nested padding for BorderType.doubleOffset',
      () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.doubleOffset),
        );

        expect(result, isA<pw.Container>());
        final outer = result as pw.Container;
        expect(outer.decoration, isNotNull);
        expect(outer.child, isA<pw.Padding>());
        final innerPadding = outer.child as pw.Padding;
        expect(innerPadding.child, isA<pw.Container>());
        expect((innerPadding.child as pw.Container).decoration, isNotNull);
      },
    );

    test(
      'should add a boxShadow to the decoration for BorderType.dropShadow',
      () {
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(borderType: BorderType.dropShadow),
        );

        expect(result, isA<pw.Container>());
        final container = result as pw.Container;
        expect(container.decoration, isNotNull);
        final decoration = container.decoration as pw.BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.isNotEmpty, isTrue);
      },
    );

    test(
      'should not alter verticalAlignment field in StyleConfig when resolving border',
      () {
        // StyleConfig carrying a verticalAlignment should not crash wrapWithBorder
        final result = resolver.wrapWithBorder(
          child,
          const StyleConfig(
            borderType: BorderType.plainThin,
            verticalAlignment: VerticalAlignment.center,
          ),
        );

        expect(result, isA<pw.Container>());
      },
    );
  });
}
