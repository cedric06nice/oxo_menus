import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';

void main() {
  group('DishProps', () {
    test('should create DishProps with required fields', () {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, isNull);
      expect(props.allergens, isEmpty);
      expect(props.dietary, isEmpty);
    });

    test('should create DishProps with all fields', () {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: 'Classic Italian pasta',
        allergens: ['Dairy', 'Gluten'],
        dietary: ['Vegetarian'],
      );

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, 'Classic Italian pasta');
      expect(props.allergens, ['Dairy', 'Gluten']);
      expect(props.dietary, ['Vegetarian']);
    });

    test('should serialize to JSON', () {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: 'Classic Italian pasta',
        allergens: ['Dairy'],
        dietary: ['Vegetarian'],
      );

      final json = props.toJson();

      expect(json['name'], 'Pasta Carbonara');
      expect(json['price'], 12.50);
      expect(json['description'], 'Classic Italian pasta');
      expect(json['allergens'], ['Dairy']);
      expect(json['dietary'], ['Vegetarian']);
    });

    test('should deserialize from JSON', () {
      final json = {
        'name': 'Pasta Carbonara',
        'price': 12.50,
        'description': 'Classic Italian pasta',
        'allergens': ['Dairy', 'Gluten'],
        'dietary': ['Vegetarian'],
      };

      final props = DishProps.fromJson(json);

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, 'Classic Italian pasta');
      expect(props.allergens, ['Dairy', 'Gluten']);
      expect(props.dietary, ['Vegetarian']);
    });

    test('should deserialize from JSON with defaults', () {
      final json = {'name': 'Simple Dish', 'price': 10.0};

      final props = DishProps.fromJson(json);

      expect(props.name, 'Simple Dish');
      expect(props.price, 10.0);
      expect(props.description, isNull);
      expect(props.allergens, isEmpty);
      expect(props.dietary, isEmpty);
    });

    test(
      'should deserialize from legacy JSON with showPrice/showAllergens (backward compatibility)',
      () {
        final json = {
          'name': 'Pasta Carbonara',
          'price': 12.50,
          'showPrice': false,
          'showAllergens': false,
        };

        // Should parse successfully, ignoring unknown fields
        final props = DishProps.fromJson(json);

        expect(props.name, 'Pasta Carbonara');
        expect(props.price, 12.50);
      },
    );

    test('should support copyWith', () {
      const original = DishProps(name: 'Original', price: 10.0);

      final modified = original.copyWith(name: 'Modified', price: 15.0);

      expect(original.name, 'Original');
      expect(original.price, 10.0);
      expect(modified.name, 'Modified');
      expect(modified.price, 15.0);
    });

    test('should support equality', () {
      const props1 = DishProps(
        name: 'Pasta',
        price: 12.50,
        allergens: ['Dairy'],
      );

      const props2 = DishProps(
        name: 'Pasta',
        price: 12.50,
        allergens: ['Dairy'],
      );

      const props3 = DishProps(name: 'Pizza', price: 12.50);

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('should handle empty lists in JSON', () {
      final json = {
        'name': 'Dish',
        'price': 10.0,
        'allergens': <String>[],
        'dietary': <String>[],
      };

      final props = DishProps.fromJson(json);

      expect(props.allergens, isEmpty);
      expect(props.dietary, isEmpty);
    });

    test('should handle null description in JSON', () {
      final json = {'name': 'Dish', 'price': 10.0, 'description': null};

      final props = DishProps.fromJson(json);

      expect(props.description, isNull);
    });

    test('should round-trip through JSON', () {
      const original = DishProps(
        name: 'Test Dish',
        price: 19.99,
        description: 'A test description',
        allergens: ['Nuts', 'Soy'],
        dietary: ['Vegan', 'Gluten-Free'],
      );

      final json = original.toJson();
      final deserialized = DishProps.fromJson(json);

      expect(deserialized, equals(original));
    });
  });
}
