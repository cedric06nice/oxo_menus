import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';

void main() {
  group('BorderType', () {
    test('should have correct label for each type', () {
      expect(BorderType.none.label, 'No Border');
      expect(BorderType.plainThin.label, 'Plain Thin');
      expect(BorderType.plainThick.label, 'Plain Thick');
      expect(BorderType.doubleOffset.label, 'Offset Double Border');
      expect(BorderType.dropShadow.label, 'Drop Shadow');
    });

    test('should have 5 values', () {
      expect(BorderType.values.length, 5);
    });
  });

  group('BorderTypeConverter', () {
    test('should convert string to BorderType', () {
      expect(BorderTypeConverter.fromString('none'), BorderType.none);
      expect(BorderTypeConverter.fromString('plain_thin'), BorderType.plainThin);
      expect(BorderTypeConverter.fromString('plain_thick'), BorderType.plainThick);
      expect(
        BorderTypeConverter.fromString('double_offset'),
        BorderType.doubleOffset,
      );
      expect(
        BorderTypeConverter.fromString('drop_shadow'),
        BorderType.dropShadow,
      );
    });

    test('should fall back to none for unknown string', () {
      expect(BorderTypeConverter.fromString('unknown'), BorderType.none);
      expect(BorderTypeConverter.fromString(''), BorderType.none);
    });

    test('should convert BorderType to string', () {
      expect(BorderTypeConverter.toJsonString(BorderType.none), 'none');
      expect(
        BorderTypeConverter.toJsonString(BorderType.plainThin),
        'plain_thin',
      );
      expect(
        BorderTypeConverter.toJsonString(BorderType.plainThick),
        'plain_thick',
      );
      expect(
        BorderTypeConverter.toJsonString(BorderType.doubleOffset),
        'double_offset',
      );
      expect(
        BorderTypeConverter.toJsonString(BorderType.dropShadow),
        'drop_shadow',
      );
    });

    test('should round-trip all values', () {
      for (final type in BorderType.values) {
        final str = BorderTypeConverter.toJsonString(type);
        expect(BorderTypeConverter.fromString(str), type);
      }
    });
  });
}
