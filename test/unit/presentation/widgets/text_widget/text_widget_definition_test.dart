import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

void main() {
  group('textWidgetDefinition', () {
    test('should have type "text"', () {
      expect(textWidgetDefinition.type, 'text');
    });

    test('should have version 1.0.0', () {
      expect(textWidgetDefinition.version, '1.0.0');
    });

    test('should have correct default props', () {
      final defaults = textWidgetDefinition.defaultProps;
      expect(defaults.text, 'New Text');
      expect(defaults.fontSize, 10.0);
      expect(defaults.align, 'left');
      expect(defaults.bold, false);
      expect(defaults.italic, false);
    });

    test('should parse props from JSON', () {
      final json = {
        'text': 'Hello World',
        'fontSize': 16.0,
        'align': 'center',
        'bold': true,
        'italic': true,
      };

      final props = textWidgetDefinition.parseProps(json);

      expect(props.text, 'Hello World');
      expect(props.fontSize, 16.0);
      expect(props.align, 'center');
      expect(props.bold, true);
      expect(props.italic, true);
    });
  });
}
