import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/set_menu_title_widget/set_menu_title_widget_definition.dart';

void main() {
  group('SetMenuTitleWidgetDefinition', () {
    test('has type "set_menu_title"', () {
      expect(setMenuTitleWidgetDefinition.type, 'set_menu_title');
    });

    test('has version 1.0.0', () {
      expect(setMenuTitleWidgetDefinition.version, '1.0.0');
    });

    test('has display name "Set Menu Title"', () {
      expect(setMenuTitleWidgetDefinition.displayName, 'Set Menu Title');
    });

    test('has default props', () {
      final props = setMenuTitleWidgetDefinition.defaultProps;
      expect(props.title, 'New Set Menu');
      expect(props.uppercase, true);
      expect(props.subtitle, isNull);
      expect(props.priceLabel1, isNull);
      expect(props.price1, isNull);
    });

    test('parseProps correctly parses JSON', () {
      final json = {
        'title': 'Set Lunch',
        'subtitle': 'Seasonal dishes',
        'priceLabel1': '3 Courses',
        'price1': 45.0,
      };

      final props = setMenuTitleWidgetDefinition.parseProps(json);
      expect(props.title, 'Set Lunch');
      expect(props.subtitle, 'Seasonal dishes');
      expect(props.priceLabel1, '3 Courses');
      expect(props.price1, 45.0);
    });
  });
}
