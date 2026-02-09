import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

void main() {
  group('MenuDisplayOptions', () {
    test('can be created with defaults', () {
      const options = MenuDisplayOptions();

      expect(options.showPrices, true);
      expect(options.showAllergens, true);
    });

    test('can be created with explicit false values', () {
      const options = MenuDisplayOptions(
        showPrices: false,
        showAllergens: false,
      );

      expect(options.showPrices, false);
      expect(options.showAllergens, false);
    });

    test('serializes to JSON correctly', () {
      const options = MenuDisplayOptions(
        showPrices: true,
        showAllergens: false,
      );

      final json = options.toJson();

      expect(json['showPrices'], true);
      expect(json['showAllergens'], false);
    });

    test('deserializes from JSON correctly', () {
      final json = {'showPrices': false, 'showAllergens': true};

      final options = MenuDisplayOptions.fromJson(json);

      expect(options.showPrices, false);
      expect(options.showAllergens, true);
    });

    test('round-trips through JSON', () {
      const original = MenuDisplayOptions(
        showPrices: false,
        showAllergens: true,
      );

      final json = original.toJson();
      final restored = MenuDisplayOptions.fromJson(json);

      expect(restored, original);
    });

    test('supports equality', () {
      const options1 = MenuDisplayOptions(
        showPrices: true,
        showAllergens: false,
      );
      const options2 = MenuDisplayOptions(
        showPrices: true,
        showAllergens: false,
      );
      const options3 = MenuDisplayOptions(
        showPrices: false,
        showAllergens: false,
      );

      expect(options1, options2);
      expect(options1, isNot(options3));
    });

    test('supports copyWith', () {
      const options = MenuDisplayOptions(showPrices: true, showAllergens: true);

      final updated = options.copyWith(showPrices: false);

      expect(updated.showPrices, false);
      expect(updated.showAllergens, true);
    });
  });
}
