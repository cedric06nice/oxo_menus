import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';

void main() {
  group('ImageProps', () {
    test('should create with required fileId and default values', () {
      const props = ImageProps(fileId: 'abc-123');

      expect(props.fileId, 'abc-123');
      expect(props.align, 'center');
      expect(props.fit, 'contain');
      expect(props.width, isNull);
      expect(props.height, isNull);
    });

    test('should create with custom values', () {
      const props = ImageProps(
        fileId: 'xyz-789',
        align: 'left',
        fit: 'cover',
        width: 200.0,
        height: 150.0,
      );

      expect(props.fileId, 'xyz-789');
      expect(props.align, 'left');
      expect(props.fit, 'cover');
      expect(props.width, 200.0);
      expect(props.height, 150.0);
    });

    test('should parse from JSON with all fields', () {
      final json = {
        'fileId': 'test-file-id',
        'align': 'right',
        'fit': 'fill',
        'width': 300.0,
        'height': 200.0,
      };

      final props = ImageProps.fromJson(json);

      expect(props.fileId, 'test-file-id');
      expect(props.align, 'right');
      expect(props.fit, 'fill');
      expect(props.width, 300.0);
      expect(props.height, 200.0);
    });

    test('should parse from JSON with minimal fields', () {
      final json = {'fileId': 'minimal-id'};

      final props = ImageProps.fromJson(json);

      expect(props.fileId, 'minimal-id');
      expect(props.align, 'center');
      expect(props.fit, 'contain');
      expect(props.width, isNull);
      expect(props.height, isNull);
    });

    test('should serialize to JSON', () {
      const props = ImageProps(
        fileId: 'serialize-test',
        align: 'left',
        fit: 'cover',
        width: 100.0,
        height: 100.0,
      );

      final json = props.toJson();

      expect(json['fileId'], 'serialize-test');
      expect(json['align'], 'left');
      expect(json['fit'], 'cover');
      expect(json['width'], 100.0);
      expect(json['height'], 100.0);
    });

    test('should round-trip through JSON', () {
      const original = ImageProps(
        fileId: 'round-trip',
        align: 'center',
        fit: 'contain',
        width: 250.0,
      );

      final json = original.toJson();
      final restored = ImageProps.fromJson(json);

      expect(restored.fileId, original.fileId);
      expect(restored.align, original.align);
      expect(restored.fit, original.fit);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
    });
  });
}
