import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';

void main() {
  group('TextProps', () {
    group('construction', () {
      test('should store text when constructed with a required text', () {
        const props = TextProps(text: 'Hello World');

        expect(props.text, 'Hello World');
      });

      test('should default fontSize to 10.0 when none is provided', () {
        const props = TextProps(text: 'Hello');

        expect(props.fontSize, 10.0);
      });

      test('should default align to left when none is provided', () {
        const props = TextProps(text: 'Hello World');

        expect(props.align, 'left');
      });

      test('should default bold to false when none is provided', () {
        const props = TextProps(text: 'Hello World');

        expect(props.bold, isFalse);
      });

      test('should default italic to false when none is provided', () {
        const props = TextProps(text: 'Hello World');

        expect(props.italic, isFalse);
      });

      test('should store custom fontSize when provided', () {
        const props = TextProps(text: 'Hello', fontSize: 14.0);

        expect(props.fontSize, 14.0);
      });

      test('should store custom align when provided', () {
        const props = TextProps(text: 'Hello', align: 'center');

        expect(props.align, 'center');
      });

      test('should store bold true when provided', () {
        const props = TextProps(text: 'Hello', bold: true);

        expect(props.bold, isTrue);
      });

      test('should store italic true when provided', () {
        const props = TextProps(text: 'Hello', italic: true);

        expect(props.italic, isTrue);
      });

      test('should store an empty-string text when provided', () {
        const props = TextProps(text: '');

        expect(props.text, '');
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = TextProps(text: 'Same', align: 'center', bold: true);
        const b = TextProps(text: 'Same', align: 'center', bold: true);

        expect(a, equals(b));
      });

      test('should not be equal when text values differ', () {
        const a = TextProps(text: 'Same');
        const b = TextProps(text: 'Different');

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when bold values differ', () {
        const a = TextProps(text: 'Hello', bold: true);
        const b = TextProps(text: 'Hello', bold: false);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when italic values differ', () {
        const a = TextProps(text: 'Hello', italic: true);
        const b = TextProps(text: 'Hello', italic: false);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when align values differ', () {
        const a = TextProps(text: 'Hello', align: 'left');
        const b = TextProps(text: 'Hello', align: 'center');

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when fontSize values differ', () {
        const a = TextProps(text: 'Hello', fontSize: 10.0);
        const b = TextProps(text: 'Hello', fontSize: 14.0);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = TextProps(text: 'Hello', align: 'center', bold: true);
        const b = TextProps(text: 'Hello', align: 'center', bold: true);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update text when copyWith is called with a new text', () {
        const original = TextProps(text: 'Original');

        final modified = original.copyWith(text: 'Modified');

        expect(modified.text, 'Modified');
      });

      test(
        'should update fontSize when copyWith is called with a new value',
        () {
          const original = TextProps(text: 'Hello');

          final modified = original.copyWith(fontSize: 16.0);

          expect(modified.fontSize, 16.0);
        },
      );

      test('should update align when copyWith is called with a new value', () {
        const original = TextProps(text: 'Hello', align: 'left');

        final modified = original.copyWith(align: 'right');

        expect(modified.align, 'right');
      });

      test('should update bold when copyWith is called with true', () {
        const original = TextProps(text: 'Hello');

        final modified = original.copyWith(bold: true);

        expect(modified.bold, isTrue);
      });

      test('should update italic when copyWith is called with true', () {
        const original = TextProps(text: 'Hello');

        final modified = original.copyWith(italic: true);

        expect(modified.italic, isTrue);
      });

      test('should preserve unchanged fields when only text is updated', () {
        const original = TextProps(
          text: 'Original',
          align: 'center',
          bold: true,
          italic: true,
          fontSize: 14.0,
        );

        final modified = original.copyWith(text: 'Modified');

        expect(modified.align, 'center');
        expect(modified.bold, isTrue);
        expect(modified.italic, isTrue);
        expect(modified.fontSize, 14.0);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = TextProps(text: 'Original', align: 'left');

        final _ = original.copyWith(text: 'Modified', align: 'right');

        expect(original.text, 'Original');
        expect(original.align, 'left');
      });
    });

    group('JSON round-trip', () {
      test('should serialise text as a string key in the JSON map', () {
        const props = TextProps(text: 'Test Text');

        final json = props.toJson();

        expect(json['text'], 'Test Text');
      });

      test('should serialise align as a string key in the JSON map', () {
        const props = TextProps(text: 'Hello', align: 'right');

        final json = props.toJson();

        expect(json['align'], 'right');
      });

      test('should serialise bold as a bool key in the JSON map', () {
        const props = TextProps(text: 'Hello', bold: true);

        final json = props.toJson();

        expect(json['bold'], isTrue);
      });

      test('should serialise italic as a bool key in the JSON map', () {
        const props = TextProps(text: 'Hello', italic: false);

        final json = props.toJson();

        expect(json['italic'], isFalse);
      });

      test('should serialise fontSize as a numeric key in the JSON map', () {
        const props = TextProps(text: 'Hello', fontSize: 12.0);

        final json = props.toJson();

        expect(json['fontSize'], 12.0);
      });

      test('should be equal to the original after toJson then fromJson', () {
        const original = TextProps(
          text: 'Test Content',
          align: 'center',
          bold: true,
          italic: true,
          fontSize: 12.0,
        );

        final json = original.toJson();
        final restored = TextProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should use default values when only text is present in JSON', () {
        final json = {'text': 'Simple'};

        final props = TextProps.fromJson(json);

        expect(props.align, 'left');
        expect(props.bold, isFalse);
        expect(props.italic, isFalse);
        expect(props.fontSize, 10.0);
      });

      test('should round-trip the left alignment value correctly', () {
        const original = TextProps(text: 'Left', align: 'left');

        final json = original.toJson();
        final restored = TextProps.fromJson(json);

        expect(restored.align, 'left');
      });

      test('should round-trip the center alignment value correctly', () {
        const original = TextProps(text: 'Center', align: 'center');

        final json = original.toJson();
        final restored = TextProps.fromJson(json);

        expect(restored.align, 'center');
      });

      test('should round-trip the right alignment value correctly', () {
        const original = TextProps(text: 'Right', align: 'right');

        final json = original.toJson();
        final restored = TextProps.fromJson(json);

        expect(restored.align, 'right');
      });
    });
  });
}
