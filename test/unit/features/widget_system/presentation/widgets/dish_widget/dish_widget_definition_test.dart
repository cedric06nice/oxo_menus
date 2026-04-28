import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';

void main() {
  group('dishWidgetDefinition', () {
    test('has version 1.0.0', () {
      expect(dishWidgetDefinition.version, '1.0.0');
    });

    test('has type dish', () {
      expect(dishWidgetDefinition.type, 'dish');
    });

    test('has no migration function', () {
      expect(dishWidgetDefinition.migrate, isNull);
    });

    test('defaultProps has null dietary', () {
      expect(dishWidgetDefinition.defaultProps.dietary, isNull);
    });
  });
}
