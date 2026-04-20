import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';

void main() {
  group('PriceVariant', () {
    test('should create with required fields', () {
      const variant = PriceVariant(label: 'Large', price: 18.50);

      expect(variant.label, 'Large');
      expect(variant.price, 18.50);
    });

    test('should support copyWith', () {
      const original = PriceVariant(label: 'Small', price: 10.0);

      final modified = original.copyWith(label: 'Medium', price: 14.0);

      expect(original.label, 'Small');
      expect(original.price, 10.0);
      expect(modified.label, 'Medium');
      expect(modified.price, 14.0);
    });

    test('should support value equality', () {
      const a = PriceVariant(label: 'Per 6', price: 17.0);
      const b = PriceVariant(label: 'Per 6', price: 17.0);
      const c = PriceVariant(label: 'Per 9', price: 17.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('should round-trip through JSON', () {
      const original = PriceVariant(label: 'Large', price: 18.50);

      final json = original.toJson();
      final deserialized = PriceVariant.fromJson(json);

      expect(json['label'], 'Large');
      expect(json['price'], 18.50);
      expect(deserialized, equals(original));
    });
  });
}
