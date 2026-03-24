import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/presentation/utils/pdf_filename.dart';

void main() {
  final fixedDate = DateTime(2026, 3, 24);

  group('generatePdfFilename', () {
    test(
      'returns name with Allergy suffix when allergens shown and prices shown',
      () {
        const options = MenuDisplayOptions(
          showAllergens: true,
          showPrices: true,
        );

        final result = generatePdfFilename(
          'Restaurant A La Carte',
          options,
          now: fixedDate,
        );

        expect(result, 'Restaurant A La Carte - Allergy (2026-03-24).pdf');
      },
    );

    test(
      'returns name without suffix when allergens hidden and prices shown',
      () {
        const options = MenuDisplayOptions(
          showAllergens: false,
          showPrices: true,
        );

        final result = generatePdfFilename(
          'Restaurant A La Carte',
          options,
          now: fixedDate,
        );

        expect(result, 'Restaurant A La Carte (2026-03-24).pdf');
      },
    );

    test(
      'returns name with No Prices suffix when prices hidden and allergens hidden',
      () {
        const options = MenuDisplayOptions(
          showAllergens: false,
          showPrices: false,
        );

        final result = generatePdfFilename(
          'Restaurant A La Carte',
          options,
          now: fixedDate,
        );

        expect(result, 'Restaurant A La Carte - No Prices (2026-03-24).pdf');
      },
    );

    test(
      'returns name with both suffixes when allergens shown and prices hidden',
      () {
        const options = MenuDisplayOptions(
          showAllergens: true,
          showPrices: false,
        );

        final result = generatePdfFilename(
          'Restaurant A La Carte',
          options,
          now: fixedDate,
        );

        expect(
          result,
          'Restaurant A La Carte - Allergy - No Prices (2026-03-24).pdf',
        );
      },
    );

    test('pads single-digit month and day with leading zeros', () {
      const options = MenuDisplayOptions(
        showAllergens: false,
        showPrices: true,
      );
      final date = DateTime(2026, 1, 5);

      final result = generatePdfFilename('Test Menu', options, now: date);

      expect(result, 'Test Menu (2026-01-05).pdf');
    });

    test('uses current date when now is not provided', () {
      const options = MenuDisplayOptions(
        showAllergens: false,
        showPrices: true,
      );
      final now = DateTime.now();
      final expectedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final result = generatePdfFilename('Menu', options);

      expect(result, 'Menu ($expectedDate).pdf');
    });
  });
}
