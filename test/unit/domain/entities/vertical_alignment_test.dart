import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';

void main() {
  group('VerticalAlignment enum', () {
    group('values', () {
      test('should have exactly three cases', () {
        expect(VerticalAlignment.values.length, 3);
      });

      test('should include top case', () {
        expect(VerticalAlignment.values, contains(VerticalAlignment.top));
      });

      test('should include center case', () {
        expect(VerticalAlignment.values, contains(VerticalAlignment.center));
      });

      test('should include bottom case', () {
        expect(VerticalAlignment.values, contains(VerticalAlignment.bottom));
      });
    });

    group('label getter', () {
      test('should return "Top" for top case', () {
        expect(VerticalAlignment.top.label, 'Top');
      });

      test('should return "Center" for center case', () {
        expect(VerticalAlignment.center.label, 'Center');
      });

      test('should return "Bottom" for bottom case', () {
        expect(VerticalAlignment.bottom.label, 'Bottom');
      });
    });

    group('name', () {
      test('should have name "top" for top case', () {
        expect(VerticalAlignment.top.name, 'top');
      });

      test('should have name "center" for center case', () {
        expect(VerticalAlignment.center.name, 'center');
      });

      test('should have name "bottom" for bottom case', () {
        expect(VerticalAlignment.bottom.name, 'bottom');
      });
    });

    group('equality', () {
      test('should be equal to itself for each case', () {
        for (final alignment in VerticalAlignment.values) {
          expect(alignment, equals(alignment));
        }
      });

      test('should not be equal to a different case', () {
        expect(VerticalAlignment.top, isNot(equals(VerticalAlignment.center)));
        expect(VerticalAlignment.center, isNot(equals(VerticalAlignment.bottom)));
      });
    });

    group('toString', () {
      test('should produce a non-empty string for each case', () {
        for (final alignment in VerticalAlignment.values) {
          expect(alignment.toString(), isNotEmpty);
        }
      });
    });
  });

  group('VerticalAlignmentConverter', () {
    group('fromString', () {
      test('should return VerticalAlignment.top when value is "top"', () {
        expect(VerticalAlignmentConverter.fromString('top'), VerticalAlignment.top);
      });

      test('should return VerticalAlignment.center when value is "center"', () {
        expect(VerticalAlignmentConverter.fromString('center'), VerticalAlignment.center);
      });

      test('should return VerticalAlignment.bottom when value is "bottom"', () {
        expect(VerticalAlignmentConverter.fromString('bottom'), VerticalAlignment.bottom);
      });

      test('should return VerticalAlignment.top when value is an unknown string', () {
        expect(VerticalAlignmentConverter.fromString('unknown'), VerticalAlignment.top);
      });

      test('should return VerticalAlignment.top when value is an empty string', () {
        expect(VerticalAlignmentConverter.fromString(''), VerticalAlignment.top);
      });
    });

    group('toJsonString', () {
      test('should return "top" for VerticalAlignment.top', () {
        expect(VerticalAlignmentConverter.toJsonString(VerticalAlignment.top), 'top');
      });

      test('should return "center" for VerticalAlignment.center', () {
        expect(VerticalAlignmentConverter.toJsonString(VerticalAlignment.center), 'center');
      });

      test('should return "bottom" for VerticalAlignment.bottom', () {
        expect(VerticalAlignmentConverter.toJsonString(VerticalAlignment.bottom), 'bottom');
      });
    });

    group('round-trip', () {
      test('should round-trip every case through toJsonString then fromString', () {
        for (final alignment in VerticalAlignment.values) {
          final serialized = VerticalAlignmentConverter.toJsonString(alignment);
          final restored = VerticalAlignmentConverter.fromString(serialized);
          expect(restored, alignment);
        }
      });
    });
  });
}
