import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget_definition.dart';

void main() {
  group('imageWidgetDefinition', () {
    test('should have type image', () {
      expect(imageWidgetDefinition.type, 'image');
    });

    test('should have version 1.0.0', () {
      expect(imageWidgetDefinition.version, '1.0.0');
    });

    test('should parse props from JSON', () {
      final json = {
        'fileId': 'test-file-id',
        'align': 'left',
        'fit': 'cover',
        'width': 200.0,
        'height': 150.0,
      };

      final props = imageWidgetDefinition.parseProps(json);

      expect(props, isA<ImageProps>());
      expect(props.fileId, 'test-file-id');
      expect(props.align, 'left');
      expect(props.fit, 'cover');
      expect(props.width, 200.0);
      expect(props.height, 150.0);
    });

    test('should have default props with placeholder fileId', () {
      final defaultProps = imageWidgetDefinition.defaultProps;

      expect(defaultProps.fileId, isNotEmpty);
      expect(defaultProps.align, 'center');
      expect(defaultProps.fit, 'contain');
      expect(defaultProps.width, isNull);
      expect(defaultProps.height, isNull);
    });
  });
}
