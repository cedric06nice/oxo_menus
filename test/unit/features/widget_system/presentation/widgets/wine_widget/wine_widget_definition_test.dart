import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/wine_widget/wine_widget_definition.dart';

void main() {
  group('wineWidgetDefinition', () {
    test('should have type wine', () {
      expect(wineWidgetDefinition.type, 'wine');
    });

    test('should have version 1.0.0', () {
      expect(wineWidgetDefinition.version, '1.0.0');
    });

    test('should have defaultProps with name New Wine', () {
      expect(wineWidgetDefinition.defaultProps.name, 'New Wine');
    });

    test('should have 0.0 price in defaultProps', () {
      expect(wineWidgetDefinition.defaultProps.price, 0.0);
    });

    test('should have null dietary in defaultProps', () {
      expect(wineWidgetDefinition.defaultProps.dietary, isNull);
    });

    test('should have false containsSulphites in defaultProps', () {
      expect(wineWidgetDefinition.defaultProps.containsSulphites, false);
    });

    test('should parse props from JSON', () {
      final json = {
        'name': 'Merlot',
        'price': 10.0,
        'vintage': 2020,
        'containsSulphites': true,
      };

      final props = wineWidgetDefinition.parseProps(json);

      expect(props, isA<WineProps>());
      expect(props.name, 'Merlot');
      expect(props.price, 10.0);
      expect(props.vintage, 2020);
      expect(props.containsSulphites, true);
    });
  });
}
