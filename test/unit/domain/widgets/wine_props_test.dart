import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';

void main() {
  group('WineProps', () {
    test('should create WineProps with required fields only', () {
      const props = WineProps(name: 'Chateau Margaux', price: 0.0);

      expect(props.name, 'Chateau Margaux');
      expect(props.price, 0.0);
      expect(props.description, isNull);
      expect(props.vintage, isNull);
      expect(props.dietary, isNull);
      expect(props.containsSulphites, false);
    });

    test('should create WineProps with all fields', () {
      const props = WineProps(
        name: 'Chateau Margaux',
        price: 12.50,
        description: 'Full-bodied Bordeaux',
        vintage: 2019,
        dietary: DietaryType.vegan,
        containsSulphites: true,
      );

      expect(props.name, 'Chateau Margaux');
      expect(props.price, 12.50);
      expect(props.description, 'Full-bodied Bordeaux');
      expect(props.vintage, 2019);
      expect(props.dietary, DietaryType.vegan);
      expect(props.containsSulphites, true);
    });

    test('should serialize to JSON', () {
      const props = WineProps(
        name: 'Chateau Margaux',
        price: 12.50,
        description: 'Full-bodied Bordeaux',
        vintage: 2019,
        dietary: DietaryType.vegetarian,
        containsSulphites: true,
      );

      final json = props.toJson();

      expect(json['name'], 'Chateau Margaux');
      expect(json['price'], 12.50);
      expect(json['description'], 'Full-bodied Bordeaux');
      expect(json['vintage'], 2019);
      expect(json['dietary'], 'vegetarian');
      expect(json['containsSulphites'], true);
    });

    test('should deserialize from JSON', () {
      final json = {
        'name': 'Chateau Margaux',
        'price': 12.50,
        'description': 'Full-bodied Bordeaux',
        'vintage': 2019,
        'dietary': 'vegetarian',
        'containsSulphites': true,
      };

      final props = WineProps.fromJson(json);

      expect(props.name, 'Chateau Margaux');
      expect(props.price, 12.50);
      expect(props.description, 'Full-bodied Bordeaux');
      expect(props.vintage, 2019);
      expect(props.dietary, DietaryType.vegetarian);
      expect(props.containsSulphites, true);
    });

    test('should deserialize from JSON with defaults', () {
      final json = {'name': 'Simple Wine', 'price': 10.0};

      final props = WineProps.fromJson(json);

      expect(props.name, 'Simple Wine');
      expect(props.price, 10.0);
      expect(props.description, isNull);
      expect(props.vintage, isNull);
      expect(props.dietary, isNull);
      expect(props.containsSulphites, false);
    });

    test('should round-trip through JSON with all fields', () {
      const original = WineProps(
        name: 'Pinot Noir',
        price: 9.50,
        description: 'Light and fruity',
        vintage: 2021,
        dietary: DietaryType.vegan,
        containsSulphites: true,
      );

      final json = original.toJson();
      final deserialized = WineProps.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('should round-trip through JSON with minimal fields', () {
      const original = WineProps(name: 'House Red', price: 8.0);

      final json = original.toJson();
      final deserialized = WineProps.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('should support copyWith', () {
      const original = WineProps(name: 'Original Wine', price: 10.0);

      final modified = original.copyWith(
        name: 'Modified Wine',
        price: 15.0,
        vintage: 2020,
      );

      expect(original.name, 'Original Wine');
      expect(original.price, 10.0);
      expect(modified.name, 'Modified Wine');
      expect(modified.price, 15.0);
      expect(modified.vintage, 2020);
    });

    test('should support equality', () {
      const props1 = WineProps(name: 'Wine A', price: 12.50);
      const props2 = WineProps(name: 'Wine A', price: 12.50);
      const props3 = WineProps(name: 'Wine B', price: 12.50);

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    group('displayName', () {
      test('should return uppercased name when no dietary', () {
        const props = WineProps(name: 'Chateau Margaux', price: 12.50);
        expect(props.displayName, 'CHATEAU MARGAUX');
      });

      test('should append (V) for vegetarian', () {
        const props = WineProps(
          name: 'Pinot Noir',
          price: 9.50,
          dietary: DietaryType.vegetarian,
        );
        expect(props.displayName, 'PINOT NOIR (V)');
      });

      test('should append (Ve) for vegan', () {
        const props = WineProps(
          name: 'Sauvignon Blanc',
          price: 8.50,
          dietary: DietaryType.vegan,
        );
        expect(props.displayName, 'SAUVIGNON BLANC (Ve)');
      });

      test('should handle empty name', () {
        const props = WineProps(name: '', price: 0.0);
        expect(props.displayName, '');
      });

      test('should handle empty name with dietary', () {
        const props = WineProps(
          name: '',
          price: 0.0,
          dietary: DietaryType.vegan,
        );
        expect(props.displayName, ' (Ve)');
      });
    });
  });
}
