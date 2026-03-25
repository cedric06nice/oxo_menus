import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';

void main() {
  group('VerticalAlignment', () {
    test('should have correct label for each type', () {
      expect(VerticalAlignment.top.label, 'Top');
      expect(VerticalAlignment.center.label, 'Center');
      expect(VerticalAlignment.bottom.label, 'Bottom');
    });

    test('should have 3 values', () {
      expect(VerticalAlignment.values.length, 3);
    });
  });

  group('VerticalAlignmentConverter', () {
    test('should convert string to VerticalAlignment', () {
      expect(
        VerticalAlignmentConverter.fromString('top'),
        VerticalAlignment.top,
      );
      expect(
        VerticalAlignmentConverter.fromString('center'),
        VerticalAlignment.center,
      );
      expect(
        VerticalAlignmentConverter.fromString('bottom'),
        VerticalAlignment.bottom,
      );
    });

    test('should fall back to top for unknown string', () {
      expect(
        VerticalAlignmentConverter.fromString('unknown'),
        VerticalAlignment.top,
      );
      expect(VerticalAlignmentConverter.fromString(''), VerticalAlignment.top);
    });

    test('should convert VerticalAlignment to string', () {
      expect(
        VerticalAlignmentConverter.toJsonString(VerticalAlignment.top),
        'top',
      );
      expect(
        VerticalAlignmentConverter.toJsonString(VerticalAlignment.center),
        'center',
      );
      expect(
        VerticalAlignmentConverter.toJsonString(VerticalAlignment.bottom),
        'bottom',
      );
    });

    test('should round-trip all values', () {
      for (final type in VerticalAlignment.values) {
        final str = VerticalAlignmentConverter.toJsonString(type);
        expect(VerticalAlignmentConverter.fromString(str), type);
      }
    });
  });
}
