import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';

void main() {
  group('allWidgetDefinitions', () {
    test('contains exactly 7 widget definitions', () {
      expect(allWidgetDefinitions, hasLength(7));
    });

    test('contains all expected widget types', () {
      final types = allWidgetDefinitions.map((d) => d.type).toSet();
      expect(
        types,
        containsAll([
          'dish',
          'dish_to_share',
          'image',
          'section',
          'set_menu_dish',
          'text',
          'wine',
        ]),
      );
    });
  });
}
