import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/dish_to_share_widget/dish_to_share_widget_definition.dart';

void main() {
  group('DishToShareWidgetDefinition', () {
    test('has type "dish_to_share"', () {
      expect(dishToShareWidgetDefinition.type, 'dish_to_share');
    });

    test('has version 1.0.0', () {
      expect(dishToShareWidgetDefinition.version, '1.0.0');
    });

    test('has display name "Dish To Share"', () {
      expect(dishToShareWidgetDefinition.displayName, 'Dish To Share');
    });

    test('has default props with null servings', () {
      final props = dishToShareWidgetDefinition.defaultProps;
      expect(props.name, 'New Dish To Share');
      expect(props.price, 0.0);
      expect(props.servings, isNull);
    });

    test('parseProps correctly parses JSON', () {
      final json = {'name': 'Mezze Platter', 'price': 18.50, 'servings': 4};

      final props = dishToShareWidgetDefinition.parseProps(json);
      expect(props.name, 'Mezze Platter');
      expect(props.price, 18.50);
      expect(props.servings, 4);
    });

    group('migration', () {
      test('handles missing servings by defaulting to null', () {
        final json = {'name': 'Board', 'price': 20.0};

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.servings, isNull);
      });

      test('preserves existing servings', () {
        final json = {'name': 'Board', 'price': 20.0, 'servings': 6};

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.servings, 6);
      });

      test('migrates legacy allergens to allergenInfo', () {
        final json = {
          'name': 'Board',
          'price': 20.0,
          'allergens': ['gluten', 'milk'],
        };

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.allergenInfo, hasLength(2));
        expect(props.allergens, isEmpty);
      });

      test('migrates legacy dietary list to enum', () {
        final json = {
          'name': 'Board',
          'price': 20.0,
          'dietary': ['vegetarian'],
        };

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.dietary, isNotNull);
      });

      test('migrates empty dietary list to null', () {
        final json = {'name': 'Board', 'price': 20.0, 'dietary': <String>[]};

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.dietary, isNull);
      });

      test('prefers vegan over vegetarian in dietary migration', () {
        final json = {
          'name': 'Board',
          'price': 20.0,
          'dietary': ['vegetarian', 'vegan'],
        };

        final props = dishToShareWidgetDefinition.migrate!(json);
        expect(props.dietary!.name, 'vegan');
      });
    });
  });
}
