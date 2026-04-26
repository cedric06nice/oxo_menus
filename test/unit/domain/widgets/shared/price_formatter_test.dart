import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/price_formatter.dart';

void main() {
  group('formatPriceParts', () {
    group('integer part', () {
      test('should prefix integer part with £ sign for a simple value', () {
        final parts = formatPriceParts(1.0);

        expect(parts.integer, '£1');
      });

      test('should include thousands comma separator for 1000', () {
        final parts = formatPriceParts(1000.0);

        expect(parts.integer, '£1,000');
      });

      test('should include thousands comma separator for 12345', () {
        final parts = formatPriceParts(12345.99);

        expect(parts.integer, '£12,345');
      });

      test('should return £0 integer part for zero price', () {
        final parts = formatPriceParts(0.0);

        expect(parts.integer, '£0');
      });

      test('should return £1000 integer part for 1000.5', () {
        final parts = formatPriceParts(1000.5);

        expect(parts.integer, '£1,000');
      });

      test('should truncate the integer part from the fractional value', () {
        final parts = formatPriceParts(9.99);

        expect(parts.integer, '£9');
      });
    });

    group('decimal part', () {
      test('should return empty string when price is a whole number', () {
        final parts = formatPriceParts(1.0);

        expect(parts.decimal, '');
      });

      test('should return empty string when price is zero', () {
        final parts = formatPriceParts(0.0);

        expect(parts.decimal, '');
      });

      test('should return .5 when price has half-pence (1.5)', () {
        final parts = formatPriceParts(1.5);

        expect(parts.decimal, '.5');
      });

      test('should return .25 when price has two decimal places (1.25)', () {
        final parts = formatPriceParts(1.25);

        expect(parts.decimal, '.25');
      });

      test(
        'should preserve leading zero in decimal so 1.05 gives .05 not .5',
        () {
          final parts = formatPriceParts(1.05);

          expect(parts.decimal, '.05');
        },
      );

      test('should return .99 for price 12345.99', () {
        final parts = formatPriceParts(12345.99);

        expect(parts.decimal, '.99');
      });

      test(
        'should return .5 for 1000.5 (decimal preserved with thousands)',
        () {
          final parts = formatPriceParts(1000.5);

          expect(parts.decimal, '.5');
        },
      );

      test('should return .5 for 9.50 (trailing zero stripped)', () {
        final parts = formatPriceParts(9.50);

        expect(parts.decimal, '.5');
      });

      test(
        'should strip trailing zero only from the right (9.10 becomes .1)',
        () {
          final parts = formatPriceParts(9.10);

          expect(parts.decimal, '.1');
        },
      );
    });
  });

  group('formatPrice (single string)', () {
    test('should return £1 for a whole-number GBP price', () {
      expect(formatPrice(1.0), '£1');
    });

    test('should return £0 for zero GBP price', () {
      expect(formatPrice(0.0), '£0');
    });

    test('should return £1.5 for a half-pence GBP price', () {
      expect(formatPrice(1.5), '£1.5');
    });

    test('should return £1.25 for a two-decimal GBP price', () {
      expect(formatPrice(1.25), '£1.25');
    });

    test('should return £1.05 for a price with a leading decimal zero', () {
      expect(formatPrice(1.05), '£1.05');
    });

    test('should include thousands comma separator for £1000', () {
      expect(formatPrice(1000.0), '£1,000');
    });

    test('should combine thousands separator and decimal for £1000.5', () {
      expect(formatPrice(1000.5), '£1,000.5');
    });

    test('should return £9.99 for a common menu price', () {
      expect(formatPrice(9.99), '£9.99');
    });

    test('should return £12.50 stripped as £12.5 for half-pound price', () {
      expect(formatPrice(12.50), '£12.5');
    });

    test('should return £12,345.99 for a large price', () {
      expect(formatPrice(12345.99), '£12,345.99');
    });

    test('should strip all decimal zeros so 18.00 becomes £18', () {
      expect(formatPrice(18.00), '£18');
    });
  });

  group('PriceParts record', () {
    test(
      'should combine integer and decimal to match formatPrice for same input',
      () {
        final parts = formatPriceParts(9.75);
        final combined = '${parts.integer}${parts.decimal}';

        expect(combined, formatPrice(9.75));
      },
    );

    test('should combine correctly for a whole-number price', () {
      final parts = formatPriceParts(20.0);
      final combined = '${parts.integer}${parts.decimal}';

      expect(combined, formatPrice(20.0));
    });

    test('should combine correctly for a price with leading decimal zero', () {
      final parts = formatPriceParts(5.05);
      final combined = '${parts.integer}${parts.decimal}';

      expect(combined, formatPrice(5.05));
    });
  });
}
