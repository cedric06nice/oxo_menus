import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';

void main() {
  group('sectionWidgetDefinition', () {
    test('should have type "section"', () {
      expect(sectionWidgetDefinition.type, 'section');
    });

    test('should have version 1.0.0', () {
      expect(sectionWidgetDefinition.version, '1.0.0');
    });

    test('should have correct default props', () {
      final defaults = sectionWidgetDefinition.defaultProps;
      expect(defaults.title, 'New Section');
      expect(defaults.uppercase, true);
      expect(defaults.showDivider, false);
    });

    test('should parse props from JSON', () {
      final json = {
        'title': 'Starters',
        'uppercase': true,
        'showDivider': false,
      };

      final props = sectionWidgetDefinition.parseProps(json);

      expect(props.title, 'Starters');
      expect(props.uppercase, true);
      expect(props.showDivider, false);
    });
  });
}
