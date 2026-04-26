import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';

void main() {
  group('ImageProps', () {
    group('construction', () {
      test('should store fileId when constructed with a required fileId', () {
        const props = ImageProps(fileId: 'abc-123');

        expect(props.fileId, 'abc-123');
      });

      test('should default align to center when no align is provided', () {
        const props = ImageProps(fileId: 'abc-123');

        expect(props.align, 'center');
      });

      test('should default fit to contain when no fit is provided', () {
        const props = ImageProps(fileId: 'abc-123');

        expect(props.fit, 'contain');
      });

      test('should default width to null when no width is provided', () {
        const props = ImageProps(fileId: 'abc-123');

        expect(props.width, isNull);
      });

      test('should default height to null when no height is provided', () {
        const props = ImageProps(fileId: 'abc-123');

        expect(props.height, isNull);
      });

      test('should store custom align when one is provided', () {
        const props = ImageProps(fileId: 'xyz-789', align: 'left');

        expect(props.align, 'left');
      });

      test('should store custom fit when one is provided', () {
        const props = ImageProps(fileId: 'xyz-789', fit: 'cover');

        expect(props.fit, 'cover');
      });

      test('should store width when one is provided', () {
        const props = ImageProps(fileId: 'xyz-789', width: 200.0);

        expect(props.width, 200.0);
      });

      test('should store height when one is provided', () {
        const props = ImageProps(fileId: 'xyz-789', height: 150.0);

        expect(props.height, 150.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = ImageProps(
          fileId: 'abc',
          align: 'center',
          fit: 'contain',
          width: 100.0,
          height: 80.0,
        );
        const b = ImageProps(
          fileId: 'abc',
          align: 'center',
          fit: 'contain',
          width: 100.0,
          height: 80.0,
        );

        expect(a, equals(b));
      });

      test('should not be equal when fileIds differ', () {
        const a = ImageProps(fileId: 'abc');
        const b = ImageProps(fileId: 'xyz');

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when align values differ', () {
        const a = ImageProps(fileId: 'abc', align: 'left');
        const b = ImageProps(fileId: 'abc', align: 'right');

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = ImageProps(fileId: 'abc', align: 'center');
        const b = ImageProps(fileId: 'abc', align: 'center');

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test(
        'should update fileId when copyWith is called with a new fileId',
        () {
          const original = ImageProps(fileId: 'old-id');

          final modified = original.copyWith(fileId: 'new-id');

          expect(modified.fileId, 'new-id');
        },
      );

      test('should update align when copyWith is called with a new value', () {
        const original = ImageProps(fileId: 'abc', align: 'center');

        final modified = original.copyWith(align: 'left');

        expect(modified.align, 'left');
      });

      test('should update fit when copyWith is called with a new value', () {
        const original = ImageProps(fileId: 'abc');

        final modified = original.copyWith(fit: 'cover');

        expect(modified.fit, 'cover');
      });

      test('should update width when copyWith is called with a new value', () {
        const original = ImageProps(fileId: 'abc');

        final modified = original.copyWith(width: 300.0);

        expect(modified.width, 300.0);
      });

      test('should update height when copyWith is called with a new value', () {
        const original = ImageProps(fileId: 'abc');

        final modified = original.copyWith(height: 200.0);

        expect(modified.height, 200.0);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = ImageProps(fileId: 'abc', align: 'center');

        final _ = original.copyWith(align: 'left');

        expect(original.align, 'center');
      });
    });

    group('JSON round-trip', () {
      test('should serialise fileId as a string key in the JSON map', () {
        const props = ImageProps(fileId: 'serialize-test');

        final json = props.toJson();

        expect(json['fileId'], 'serialize-test');
      });

      test('should serialise align as a string key in the JSON map', () {
        const props = ImageProps(fileId: 'abc', align: 'left');

        final json = props.toJson();

        expect(json['align'], 'left');
      });

      test('should serialise fit as a string key in the JSON map', () {
        const props = ImageProps(fileId: 'abc', fit: 'cover');

        final json = props.toJson();

        expect(json['fit'], 'cover');
      });

      test('should serialise width as a numeric key in the JSON map', () {
        const props = ImageProps(fileId: 'abc', width: 100.0);

        final json = props.toJson();

        expect(json['width'], 100.0);
      });

      test('should be equal to the original after toJson then fromJson', () {
        const original = ImageProps(
          fileId: 'round-trip',
          align: 'center',
          fit: 'contain',
          width: 250.0,
          height: 180.0,
        );

        final json = original.toJson();
        final restored = ImageProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should use defaults when only fileId is present in JSON', () {
        final json = {'fileId': 'minimal-id'};

        final props = ImageProps.fromJson(json);

        expect(props.align, 'center');
        expect(props.fit, 'contain');
        expect(props.width, isNull);
        expect(props.height, isNull);
      });

      test(
        'should restore null height after round-trip when only width was set',
        () {
          const original = ImageProps(fileId: 'abc', width: 250.0);

          final json = original.toJson();
          final restored = ImageProps.fromJson(json);

          expect(restored.height, isNull);
          expect(restored.width, 250.0);
        },
      );

      test(
        'should handle all align string values centre right left after round-trip',
        () {
          const props = ImageProps(
            fileId: 'test-file-id',
            align: 'right',
            fit: 'fill',
            width: 300.0,
            height: 200.0,
          );

          final json = props.toJson();
          final restored = ImageProps.fromJson(json);

          expect(restored.align, 'right');
          expect(restored.fit, 'fill');
        },
      );
    });
  });
}
