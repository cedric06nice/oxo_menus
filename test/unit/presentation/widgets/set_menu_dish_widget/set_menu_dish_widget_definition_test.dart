import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/set_menu_dish_widget/set_menu_dish_widget_definition.dart';

void main() {
  group('SetMenuDishWidgetDefinition', () {
    test('has type "set_menu_dish"', () {
      expect(setMenuDishWidgetDefinition.type, 'set_menu_dish');
    });

    test('has version 1.0.0', () {
      expect(setMenuDishWidgetDefinition.version, '1.0.0');
    });

    test('has display name "Set Menu Dish"', () {
      expect(setMenuDishWidgetDefinition.displayName, 'Set Menu Dish');
    });

    test('has default props with no supplement', () {
      final props = setMenuDishWidgetDefinition.defaultProps;
      expect(props.name, 'New Set Menu Dish');
      expect(props.hasSupplement, false);
      expect(props.supplementPrice, 0.0);
    });

    test('parseProps correctly parses JSON', () {
      final json = {
        'name': 'Lobster Thermidor',
        'hasSupplement': true,
        'supplementPrice': 7.5,
      };

      final props = setMenuDishWidgetDefinition.parseProps(json);
      expect(props.name, 'Lobster Thermidor');
      expect(props.hasSupplement, true);
      expect(props.supplementPrice, 7.5);
    });

    group('migration', () {
      test('migrates legacy allergens to allergenInfo', () {
        final json = {
          'name': 'Dish',
          'allergens': ['gluten', 'milk'],
        };

        final props = setMenuDishWidgetDefinition.migrate!(json);
        expect(props.allergenInfo, hasLength(2));
        expect(props.allergens, isEmpty);
      });

      test('migrates legacy dietary list to enum', () {
        final json = {
          'name': 'Dish',
          'dietary': ['vegetarian'],
        };

        final props = setMenuDishWidgetDefinition.migrate!(json);
        expect(props.dietary, isNotNull);
      });

      test('migrates empty dietary list to null', () {
        final json = {'name': 'Dish', 'dietary': <String>[]};

        final props = setMenuDishWidgetDefinition.migrate!(json);
        expect(props.dietary, isNull);
      });

      test('prefers vegan over vegetarian in dietary migration', () {
        final json = {
          'name': 'Dish',
          'dietary': ['vegetarian', 'vegan'],
        };

        final props = setMenuDishWidgetDefinition.migrate!(json);
        expect(props.dietary!.name, 'vegan');
      });
    });
  });
}
