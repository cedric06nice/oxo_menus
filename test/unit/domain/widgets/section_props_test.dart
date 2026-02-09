import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';

void main() {
  group('SectionProps', () {
    test('should create SectionProps with required fields', () {
      const props = SectionProps(title: 'Appetizers');

      expect(props.title, 'Appetizers');
      expect(props.uppercase, false);
      expect(props.showDivider, true);
    });

    test('should create SectionProps with all fields', () {
      const props = SectionProps(
        title: 'Main Courses',
        uppercase: true,
        showDivider: false,
      );

      expect(props.title, 'Main Courses');
      expect(props.uppercase, true);
      expect(props.showDivider, false);
    });

    test('should serialize to JSON', () {
      const props = SectionProps(
        title: 'Desserts',
        uppercase: true,
        showDivider: false,
      );

      final json = props.toJson();

      expect(json['title'], 'Desserts');
      expect(json['uppercase'], true);
      expect(json['showDivider'], false);
    });

    test('should deserialize from JSON', () {
      final json = {
        'title': 'Beverages',
        'uppercase': false,
        'showDivider': true,
      };

      final props = SectionProps.fromJson(json);

      expect(props.title, 'Beverages');
      expect(props.uppercase, false);
      expect(props.showDivider, true);
    });

    test('should deserialize from JSON with defaults', () {
      final json = {'title': 'Sides'};

      final props = SectionProps.fromJson(json);

      expect(props.title, 'Sides');
      expect(props.uppercase, false);
      expect(props.showDivider, true);
    });

    test('should support copyWith', () {
      const original = SectionProps(title: 'Original', uppercase: false);

      final modified = original.copyWith(title: 'Modified', uppercase: true);

      expect(original.title, 'Original');
      expect(original.uppercase, false);
      expect(modified.title, 'Modified');
      expect(modified.uppercase, true);
    });

    test('should support equality', () {
      const props1 = SectionProps(
        title: 'Section',
        uppercase: true,
        showDivider: false,
      );

      const props2 = SectionProps(
        title: 'Section',
        uppercase: true,
        showDivider: false,
      );

      const props3 = SectionProps(title: 'Different');

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('should round-trip through JSON', () {
      const original = SectionProps(
        title: 'Test Section',
        uppercase: true,
        showDivider: false,
      );

      final json = original.toJson();
      final deserialized = SectionProps.fromJson(json);

      expect(deserialized, equals(original));
    });
  });
}
