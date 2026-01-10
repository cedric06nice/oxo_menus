import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';

void main() {
  group('TextProps', () {
    test('should create TextProps with required fields', () {
      const props = TextProps(
        text: 'Hello World',
      );

      expect(props.text, 'Hello World');
      expect(props.align, 'left');
      expect(props.bold, false);
      expect(props.italic, false);
    });

    test('should create TextProps with all fields', () {
      const props = TextProps(
        text: 'Styled Text',
        align: 'center',
        bold: true,
        italic: true,
      );

      expect(props.text, 'Styled Text');
      expect(props.align, 'center');
      expect(props.bold, true);
      expect(props.italic, true);
    });

    test('should serialize to JSON', () {
      const props = TextProps(
        text: 'Test Text',
        align: 'right',
        bold: true,
        italic: false,
      );

      final json = props.toJson();

      expect(json['text'], 'Test Text');
      expect(json['align'], 'right');
      expect(json['bold'], true);
      expect(json['italic'], false);
    });

    test('should deserialize from JSON', () {
      final json = {
        'text': 'Deserialized',
        'align': 'center',
        'bold': false,
        'italic': true,
      };

      final props = TextProps.fromJson(json);

      expect(props.text, 'Deserialized');
      expect(props.align, 'center');
      expect(props.bold, false);
      expect(props.italic, true);
    });

    test('should deserialize from JSON with defaults', () {
      final json = {
        'text': 'Simple',
      };

      final props = TextProps.fromJson(json);

      expect(props.text, 'Simple');
      expect(props.align, 'left');
      expect(props.bold, false);
      expect(props.italic, false);
    });

    test('should support copyWith', () {
      const original = TextProps(
        text: 'Original',
        align: 'left',
      );

      final modified = original.copyWith(
        text: 'Modified',
        align: 'right',
        bold: true,
      );

      expect(original.text, 'Original');
      expect(original.align, 'left');
      expect(original.bold, false);
      expect(modified.text, 'Modified');
      expect(modified.align, 'right');
      expect(modified.bold, true);
    });

    test('should support equality', () {
      const props1 = TextProps(
        text: 'Same',
        align: 'center',
        bold: true,
      );

      const props2 = TextProps(
        text: 'Same',
        align: 'center',
        bold: true,
      );

      const props3 = TextProps(
        text: 'Different',
      );

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('should handle different alignment values', () {
      const leftAlign = TextProps(text: 'Left', align: 'left');
      const centerAlign = TextProps(text: 'Center', align: 'center');
      const rightAlign = TextProps(text: 'Right', align: 'right');

      expect(leftAlign.align, 'left');
      expect(centerAlign.align, 'center');
      expect(rightAlign.align, 'right');
    });

    test('should round-trip through JSON', () {
      const original = TextProps(
        text: 'Test Content',
        align: 'center',
        bold: true,
        italic: true,
      );

      final json = original.toJson();
      final deserialized = TextProps.fromJson(json);

      expect(deserialized, equals(original));
    });
  });
}
