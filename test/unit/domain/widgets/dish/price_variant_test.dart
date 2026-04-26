import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';

void main() {
  group('PriceVariant', () {
    group('construction', () {
      test('should store label when constructed with a string label', () {
        const variant = PriceVariant(label: 'Large', price: 18.50);

        expect(variant.label, 'Large');
      });

      test('should store price when constructed with a double price', () {
        const variant = PriceVariant(label: 'Large', price: 18.50);

        expect(variant.price, 18.50);
      });

      test(
        'should store whole-number price exactly when price has no decimal',
        () {
          const variant = PriceVariant(label: 'Small', price: 10.0);

          expect(variant.price, 10.0);
        },
      );

      test('should store empty-string label when label is empty', () {
        const variant = PriceVariant(label: '', price: 5.0);

        expect(variant.label, '');
      });

      test('should store zero price when price is zero', () {
        const variant = PriceVariant(label: 'Free', price: 0.0);

        expect(variant.price, 0.0);
      });
    });

    group('equality', () {
      test('should be equal when label and price are identical', () {
        const a = PriceVariant(label: 'Per 6', price: 17.0);
        const b = PriceVariant(label: 'Per 6', price: 17.0);

        expect(a, equals(b));
      });

      test('should not be equal when labels differ', () {
        const a = PriceVariant(label: 'Per 6', price: 17.0);
        const b = PriceVariant(label: 'Per 9', price: 17.0);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when prices differ', () {
        const a = PriceVariant(label: 'Large', price: 17.0);
        const b = PriceVariant(label: 'Large', price: 20.0);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should have the same hashCode when values are identical', () {
        const a = PriceVariant(label: 'Large', price: 18.0);
        const b = PriceVariant(label: 'Large', price: 18.0);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update label when copyWith is called with a new label', () {
        const original = PriceVariant(label: 'Small', price: 10.0);

        final modified = original.copyWith(label: 'Medium');

        expect(modified.label, 'Medium');
      });

      test('should preserve price when copyWith only changes label', () {
        const original = PriceVariant(label: 'Small', price: 10.0);

        final modified = original.copyWith(label: 'Medium');

        expect(modified.price, 10.0);
      });

      test('should update price when copyWith is called with a new price', () {
        const original = PriceVariant(label: 'Small', price: 10.0);

        final modified = original.copyWith(price: 14.0);

        expect(modified.price, 14.0);
      });

      test('should preserve label when copyWith only changes price', () {
        const original = PriceVariant(label: 'Small', price: 10.0);

        final modified = original.copyWith(price: 14.0);

        expect(modified.label, 'Small');
      });

      test('should not mutate the original when copyWith is called', () {
        const original = PriceVariant(label: 'Small', price: 10.0);

        final _ = original.copyWith(label: 'Medium', price: 14.0);

        expect(original.label, 'Small');
        expect(original.price, 10.0);
      });
    });

    group('JSON round-trip', () {
      test('should preserve label after toJson then fromJson', () {
        const original = PriceVariant(label: 'Large', price: 18.50);

        final json = original.toJson();
        final restored = PriceVariant.fromJson(json);

        expect(restored.label, 'Large');
      });

      test('should preserve price after toJson then fromJson', () {
        const original = PriceVariant(label: 'Large', price: 18.50);

        final json = original.toJson();
        final restored = PriceVariant.fromJson(json);

        expect(restored.price, 18.50);
      });

      test('should be equal to the original after toJson then fromJson', () {
        const original = PriceVariant(label: 'Large', price: 18.50);

        final json = original.toJson();
        final restored = PriceVariant.fromJson(json);

        expect(restored, equals(original));
      });

      test('should serialise label as a string key in the JSON map', () {
        const original = PriceVariant(label: 'Per 3', price: 9.0);

        final json = original.toJson();

        expect(json['label'], 'Per 3');
      });

      test('should serialise price as a numeric key in the JSON map', () {
        const original = PriceVariant(label: 'Per 3', price: 9.0);

        final json = original.toJson();

        expect(json['price'], 9.0);
      });

      test('should round-trip a zero price correctly', () {
        const original = PriceVariant(label: 'Free', price: 0.0);

        final json = original.toJson();
        final restored = PriceVariant.fromJson(json);

        expect(restored, equals(original));
      });

      test('should round-trip a fractional GBP price correctly', () {
        const original = PriceVariant(label: 'Half', price: 4.50);

        final json = original.toJson();
        final restored = PriceVariant.fromJson(json);

        expect(restored, equals(original));
      });
    });

    group('toString', () {
      test('should include the type name when converted to string', () {
        const variant = PriceVariant(label: 'Large', price: 18.50);

        expect(variant.toString(), contains('PriceVariant'));
      });
    });
  });
}
