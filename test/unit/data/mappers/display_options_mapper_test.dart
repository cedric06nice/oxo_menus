import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/display_options_mapper.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

void main() {
  group('DisplayOptionsMapper', () {
    group('fromJson', () {
      test('parses full JSON correctly', () {
        final json = {'showPrices': true, 'showAllergens': false};

        final options = DisplayOptionsMapper.fromJson(json);

        expect(options.showPrices, true);
        expect(options.showAllergens, false);
      });

      test('parses empty JSON using defaults', () {
        final json = <String, dynamic>{};

        final options = DisplayOptionsMapper.fromJson(json);

        expect(options.showPrices, true);
        expect(options.showAllergens, true);
      });

      test('handles missing keys with defaults', () {
        final json = {'showPrices': false};

        final options = DisplayOptionsMapper.fromJson(json);

        expect(options.showPrices, false);
        expect(options.showAllergens, true); // Default
      });

      test('handles null values with defaults', () {
        final json = {'showPrices': null, 'showAllergens': null};

        final options = DisplayOptionsMapper.fromJson(json);

        expect(options.showPrices, true);
        expect(options.showAllergens, true);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: false,
        );

        final json = DisplayOptionsMapper.toJson(options);

        expect(json['showPrices'], true);
        expect(json['showAllergens'], false);
      });

      test('includes all fields even with defaults', () {
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: true,
        );

        final json = DisplayOptionsMapper.toJson(options);

        expect(json, containsPair('showPrices', true));
        expect(json, containsPair('showAllergens', true));
      });
    });

    group('round-trip', () {
      test('preserves data through fromJson/toJson cycle', () {
        const original = MenuDisplayOptions(
          showPrices: false,
          showAllergens: true,
        );

        final json = DisplayOptionsMapper.toJson(original);
        final restored = DisplayOptionsMapper.fromJson(json);

        expect(restored, original);
      });
    });
  });
}
