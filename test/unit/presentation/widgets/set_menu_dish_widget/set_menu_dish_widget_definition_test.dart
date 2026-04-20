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

    test('has no migration function', () {
      expect(setMenuDishWidgetDefinition.migrate, isNull);
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
  });
}
