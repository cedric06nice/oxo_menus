import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';

void main() {
  group('BorderType enum', () {
    group('values', () {
      test('should have exactly five cases', () {
        expect(BorderType.values.length, 5);
      });

      test('should include none case', () {
        expect(BorderType.values, contains(BorderType.none));
      });

      test('should include plainThin case', () {
        expect(BorderType.values, contains(BorderType.plainThin));
      });

      test('should include plainThick case', () {
        expect(BorderType.values, contains(BorderType.plainThick));
      });

      test('should include doubleOffset case', () {
        expect(BorderType.values, contains(BorderType.doubleOffset));
      });

      test('should include dropShadow case', () {
        expect(BorderType.values, contains(BorderType.dropShadow));
      });
    });

    group('label getter', () {
      test('should return "No Border" for none', () {
        expect(BorderType.none.label, 'No Border');
      });

      test('should return "Plain Thin" for plainThin', () {
        expect(BorderType.plainThin.label, 'Plain Thin');
      });

      test('should return "Plain Thick" for plainThick', () {
        expect(BorderType.plainThick.label, 'Plain Thick');
      });

      test('should return "Offset Double Border" for doubleOffset', () {
        expect(BorderType.doubleOffset.label, 'Offset Double Border');
      });

      test('should return "Drop Shadow" for dropShadow', () {
        expect(BorderType.dropShadow.label, 'Drop Shadow');
      });
    });

    group('equality', () {
      test('should be equal to itself for each case', () {
        for (final type in BorderType.values) {
          expect(type, equals(type));
        }
      });

      test('should not be equal to a different case', () {
        expect(BorderType.none, isNot(equals(BorderType.plainThin)));
        expect(BorderType.plainThick, isNot(equals(BorderType.dropShadow)));
      });
    });

    group('toString', () {
      test('should produce a non-empty string for each case', () {
        for (final type in BorderType.values) {
          expect(type.toString(), isNotEmpty);
        }
      });
    });
  });

  group('BorderTypeConverter', () {
    group('fromString', () {
      test('should return none when value is "none"', () {
        expect(BorderTypeConverter.fromString('none'), BorderType.none);
      });

      test('should return plainThin when value is "plain_thin"', () {
        expect(BorderTypeConverter.fromString('plain_thin'), BorderType.plainThin);
      });

      test('should return plainThick when value is "plain_thick"', () {
        expect(BorderTypeConverter.fromString('plain_thick'), BorderType.plainThick);
      });

      test('should return doubleOffset when value is "double_offset"', () {
        expect(BorderTypeConverter.fromString('double_offset'), BorderType.doubleOffset);
      });

      test('should return dropShadow when value is "drop_shadow"', () {
        expect(BorderTypeConverter.fromString('drop_shadow'), BorderType.dropShadow);
      });

      test('should return none when value is an unknown string', () {
        expect(BorderTypeConverter.fromString('unknown_value'), BorderType.none);
      });

      test('should return none when value is an empty string', () {
        expect(BorderTypeConverter.fromString(''), BorderType.none);
      });
    });

    group('toJsonString', () {
      test('should return "none" for none', () {
        expect(BorderTypeConverter.toJsonString(BorderType.none), 'none');
      });

      test('should return "plain_thin" for plainThin', () {
        expect(BorderTypeConverter.toJsonString(BorderType.plainThin), 'plain_thin');
      });

      test('should return "plain_thick" for plainThick', () {
        expect(BorderTypeConverter.toJsonString(BorderType.plainThick), 'plain_thick');
      });

      test('should return "double_offset" for doubleOffset', () {
        expect(BorderTypeConverter.toJsonString(BorderType.doubleOffset), 'double_offset');
      });

      test('should return "drop_shadow" for dropShadow', () {
        expect(BorderTypeConverter.toJsonString(BorderType.dropShadow), 'drop_shadow');
      });
    });

    group('round-trip', () {
      test('should round-trip every case through toJsonString then fromString', () {
        for (final type in BorderType.values) {
          final serialized = BorderTypeConverter.toJsonString(type);
          final restored = BorderTypeConverter.fromString(serialized);
          expect(restored, type);
        }
      });
    });
  });
}
