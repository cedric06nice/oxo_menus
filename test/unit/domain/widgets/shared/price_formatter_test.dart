import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/price_formatter.dart';

void main() {
  group('formatPriceParts', () {
    test('integer-only price omits dot and zeros', () {
      final p = formatPriceParts(1.0);
      expect(p.integer, '£1');
      expect(p.decimal, '');
    });

    test('half value shows single decimal digit (1.5 -> .5)', () {
      final p = formatPriceParts(1.5);
      expect(p.integer, '£1');
      expect(p.decimal, '.5');
    });

    test('two-digit decimal preserved (1.25 -> .25)', () {
      final p = formatPriceParts(1.25);
      expect(p.integer, '£1');
      expect(p.decimal, '.25');
    });

    test('leading-zero decimal preserved (1.05 -> .05, not .5)', () {
      final p = formatPriceParts(1.05);
      expect(p.integer, '£1');
      expect(p.decimal, '.05');
    });

    test('1000 uses thousands comma', () {
      final p = formatPriceParts(1000.0);
      expect(p.integer, '£1,000');
      expect(p.decimal, '');
    });

    test('1000.5 uses thousands comma and .5 decimal', () {
      final p = formatPriceParts(1000.5);
      expect(p.integer, '£1,000');
      expect(p.decimal, '.5');
    });

    test('12345.99', () {
      final p = formatPriceParts(12345.99);
      expect(p.integer, '£12,345');
      expect(p.decimal, '.99');
    });

    test('zero price', () {
      final p = formatPriceParts(0.0);
      expect(p.integer, '£0');
      expect(p.decimal, '');
    });
  });

  group('formatPrice (single string)', () {
    test('integer-only price omits dot', () {
      expect(formatPrice(1.0), '£1');
    });
    test('half price', () {
      expect(formatPrice(1.5), '£1.5');
    });
    test('two-decimal price', () {
      expect(formatPrice(1.25), '£1.25');
    });
    test('leading-zero decimal', () {
      expect(formatPrice(1.05), '£1.05');
    });
    test('thousands separator', () {
      expect(formatPrice(1000.0), '£1,000');
    });
    test('thousands and decimal', () {
      expect(formatPrice(1000.5), '£1,000.5');
    });
  });
}
