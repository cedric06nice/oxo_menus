import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_to_share_widget/dish_to_share_widget_definition.dart';

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

    test('has no migration function', () {
      expect(dishToShareWidgetDefinition.migrate, isNull);
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
  });
}
