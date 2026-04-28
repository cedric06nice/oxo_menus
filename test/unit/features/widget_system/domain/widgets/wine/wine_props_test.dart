import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/wine/wine_props.dart';

void main() {
  group('WineProps', () {
    group('construction', () {
      test('should store name when constructed with a required name', () {
        const props = WineProps(name: 'Chateau Margaux', price: 12.50);

        expect(props.name, 'Chateau Margaux');
      });

      test('should store price when constructed with a required price', () {
        const props = WineProps(name: 'Chateau Margaux', price: 12.50);

        expect(props.price, 12.50);
      });

      test('should default description to null when none is provided', () {
        const props = WineProps(name: 'House Red', price: 8.0);

        expect(props.description, isNull);
      });

      test('should default vintage to null when none is provided', () {
        const props = WineProps(name: 'House Red', price: 8.0);

        expect(props.vintage, isNull);
      });

      test('should default dietary to null when none is provided', () {
        const props = WineProps(name: 'House Red', price: 8.0);

        expect(props.dietary, isNull);
      });

      test(
        'should default containsSulphites to false when none is provided',
        () {
          const props = WineProps(name: 'House Red', price: 8.0);

          expect(props.containsSulphites, isFalse);
        },
      );

      test('should store zero price when price is 0.0', () {
        const props = WineProps(name: 'Chateau Margaux', price: 0.0);

        expect(props.price, 0.0);
      });

      test('should store all optional fields when provided', () {
        const props = WineProps(
          name: 'Chateau Margaux',
          price: 12.50,
          description: 'Full-bodied Bordeaux',
          vintage: 2019,
          dietary: DietaryType.vegan,
          containsSulphites: true,
        );

        expect(props.description, 'Full-bodied Bordeaux');
        expect(props.vintage, 2019);
        expect(props.dietary, DietaryType.vegan);
        expect(props.containsSulphites, isTrue);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = WineProps(name: 'Wine A', price: 12.50);
        const b = WineProps(name: 'Wine A', price: 12.50);

        expect(a, equals(b));
      });

      test('should not be equal when names differ', () {
        const a = WineProps(name: 'Wine A', price: 12.50);
        const b = WineProps(name: 'Wine B', price: 12.50);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when prices differ', () {
        const a = WineProps(name: 'Wine', price: 10.0);
        const b = WineProps(name: 'Wine', price: 12.0);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when vintage values differ', () {
        const a = WineProps(name: 'Wine', price: 10.0, vintage: 2019);
        const b = WineProps(name: 'Wine', price: 10.0, vintage: 2021);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when containsSulphites differs', () {
        const a = WineProps(name: 'Wine', price: 10.0, containsSulphites: true);
        const b = WineProps(
          name: 'Wine',
          price: 10.0,
          containsSulphites: false,
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = WineProps(name: 'Wine A', price: 12.50);
        const b = WineProps(name: 'Wine A', price: 12.50);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        const original = WineProps(name: 'Original Wine', price: 10.0);

        final modified = original.copyWith(name: 'Modified Wine');

        expect(modified.name, 'Modified Wine');
      });

      test('should update price when copyWith is called with a new price', () {
        const original = WineProps(name: 'Wine', price: 10.0);

        final modified = original.copyWith(price: 15.0);

        expect(modified.price, 15.0);
      });

      test(
        'should update vintage when copyWith is called with a new value',
        () {
          const original = WineProps(name: 'Wine', price: 10.0);

          final modified = original.copyWith(vintage: 2020);

          expect(modified.vintage, 2020);
        },
      );

      test(
        'should update containsSulphites when copyWith is called with true',
        () {
          const original = WineProps(name: 'Wine', price: 10.0);

          final modified = original.copyWith(containsSulphites: true);

          expect(modified.containsSulphites, isTrue);
        },
      );

      test('should preserve unchanged fields when only name is updated', () {
        const original = WineProps(
          name: 'Wine',
          price: 10.0,
          vintage: 2019,
          containsSulphites: true,
        );

        final modified = original.copyWith(name: 'New Wine');

        expect(modified.price, 10.0);
        expect(modified.vintage, 2019);
        expect(modified.containsSulphites, isTrue);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = WineProps(name: 'Original Wine', price: 10.0);

        final _ = original.copyWith(name: 'Modified Wine', price: 15.0);

        expect(original.name, 'Original Wine');
        expect(original.price, 10.0);
      });
    });

    group('displayName', () {
      test('should return uppercased name when no dietary is set', () {
        const props = WineProps(name: 'Chateau Margaux', price: 12.50);

        expect(props.displayName, 'CHATEAU MARGAUX');
      });

      test('should append (V) abbreviation when dietary is vegetarian', () {
        const props = WineProps(
          name: 'Pinot Noir',
          price: 9.50,
          dietary: DietaryType.vegetarian,
        );

        expect(props.displayName, 'PINOT NOIR (V)');
      });

      test('should append (Ve) abbreviation when dietary is vegan', () {
        const props = WineProps(
          name: 'Sauvignon Blanc',
          price: 8.50,
          dietary: DietaryType.vegan,
        );

        expect(props.displayName, 'SAUVIGNON BLANC (Ve)');
      });

      test(
        'should return empty string when name is empty and no dietary set',
        () {
          const props = WineProps(name: '', price: 0.0);

          expect(props.displayName, '');
        },
      );

      test(
        'should return space-prefixed abbreviation when name is empty and dietary is set',
        () {
          const props = WineProps(
            name: '',
            price: 0.0,
            dietary: DietaryType.vegan,
          );

          expect(props.displayName, ' (Ve)');
        },
      );
    });

    group('JSON round-trip', () {
      test('should serialise name as a string key in the JSON map', () {
        const props = WineProps(name: 'Chateau Margaux', price: 12.50);

        final json = props.toJson();

        expect(json['name'], 'Chateau Margaux');
      });

      test('should serialise price as a numeric key in the JSON map', () {
        const props = WineProps(name: 'Wine', price: 12.50);

        final json = props.toJson();

        expect(json['price'], 12.50);
      });

      test('should serialise dietary as lowercase string in JSON', () {
        const props = WineProps(
          name: 'Wine',
          price: 10.0,
          dietary: DietaryType.vegetarian,
        );

        final json = props.toJson();

        expect(json['dietary'], 'vegetarian');
      });

      test('should serialise vintage as integer in JSON', () {
        const props = WineProps(name: 'Wine', price: 10.0, vintage: 2019);

        final json = props.toJson();

        expect(json['vintage'], 2019);
      });

      test('should serialise containsSulphites as bool in JSON', () {
        const props = WineProps(
          name: 'Wine',
          price: 10.0,
          containsSulphites: true,
        );

        final json = props.toJson();

        expect(json['containsSulphites'], isTrue);
      });

      test(
        'should be equal to the original after toJson then fromJson with all fields',
        () {
          const original = WineProps(
            name: 'Pinot Noir',
            price: 9.50,
            description: 'Light and fruity',
            vintage: 2021,
            dietary: DietaryType.vegan,
            containsSulphites: true,
          );

          final json = original.toJson();
          final restored = WineProps.fromJson(json);

          expect(restored, equals(original));
        },
      );

      test(
        'should be equal to the original after toJson then fromJson with minimal fields',
        () {
          const original = WineProps(name: 'House Red', price: 8.0);

          final json = original.toJson();
          final restored = WineProps.fromJson(json);

          expect(restored, equals(original));
        },
      );

      test(
        'should use defaults when only name and price are present in JSON',
        () {
          final json = {'name': 'Simple Wine', 'price': 10.0};

          final props = WineProps.fromJson(json);

          expect(props.description, isNull);
          expect(props.vintage, isNull);
          expect(props.dietary, isNull);
          expect(props.containsSulphites, isFalse);
        },
      );

      test('should round-trip a fractional GBP price correctly', () {
        const original = WineProps(name: 'House White', price: 7.50);

        final json = original.toJson();
        final restored = WineProps.fromJson(json);

        expect(restored.price, 7.50);
      });

      test('should round-trip zero GBP price correctly', () {
        const original = WineProps(name: 'Test Wine', price: 0.0);

        final json = original.toJson();
        final restored = WineProps.fromJson(json);

        expect(restored.price, 0.0);
      });
    });
  });
}
