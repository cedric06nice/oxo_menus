import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/pdf_preview_screen_state.dart';

void main() {
  group('PdfPreviewScreenState — defaults', () {
    test('default state matches the pre-load snapshot', () {
      const state = PdfPreviewScreenState();

      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.pdfBytes, isNull);
      expect(state.filename, isNull);
    });
  });

  group('PdfPreviewScreenState — equality', () {
    test('two equal states compare equal and share a hashCode', () {
      const a = PdfPreviewScreenState(
        isLoading: false,
        errorMessage: 'oops',
        filename: 'x.pdf',
      );
      const b = PdfPreviewScreenState(
        isLoading: false,
        errorMessage: 'oops',
        filename: 'x.pdf',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('changing each scalar field breaks equality', () {
      const base = PdfPreviewScreenState();

      expect(base, isNot(base.copyWith(isLoading: false)));
      expect(base, isNot(base.copyWith(errorMessage: 'oops')));
      expect(base, isNot(base.copyWith(filename: 'menu.pdf')));
    });

    test('two states with the same Uint8List instance compare equal', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final a = PdfPreviewScreenState(pdfBytes: bytes);
      final b = PdfPreviewScreenState(pdfBytes: bytes);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('two states with different Uint8List instances are not equal', () {
      final a = PdfPreviewScreenState(pdfBytes: Uint8List.fromList(const [1]));
      final b = PdfPreviewScreenState(pdfBytes: Uint8List.fromList(const [1]));

      expect(a, isNot(b));
    });
  });

  group('PdfPreviewScreenState — copyWith', () {
    test('returns identical state when no overrides are passed', () {
      final bytes = Uint8List.fromList(const [9, 8, 7]);
      final state = PdfPreviewScreenState(
        isLoading: false,
        errorMessage: 'oops',
        pdfBytes: bytes,
        filename: 'menu.pdf',
      );

      expect(state.copyWith(), state);
    });

    test('null sentinel — explicit null clears errorMessage', () {
      const base = PdfPreviewScreenState(errorMessage: 'oops');

      expect(base.copyWith(errorMessage: null).errorMessage, isNull);
    });

    test('null sentinel — explicit null clears pdfBytes', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final base = PdfPreviewScreenState(pdfBytes: bytes);

      expect(base.copyWith(pdfBytes: null).pdfBytes, isNull);
    });

    test('null sentinel — explicit null clears filename', () {
      const base = PdfPreviewScreenState(filename: 'menu.pdf');

      expect(base.copyWith(filename: null).filename, isNull);
    });

    test('omitting nullable fields preserves the previous values', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final base = PdfPreviewScreenState(
        isLoading: true,
        errorMessage: 'oops',
        pdfBytes: bytes,
        filename: 'menu.pdf',
      );

      final copy = base.copyWith(isLoading: false);

      expect(copy.errorMessage, 'oops');
      expect(copy.pdfBytes, same(bytes));
      expect(copy.filename, 'menu.pdf');
      expect(copy.isLoading, isFalse);
    });
  });
}
