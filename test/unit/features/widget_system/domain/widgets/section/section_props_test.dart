import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/section/section_props.dart';

void main() {
  group('SectionProps', () {
    group('construction', () {
      test('should store title when constructed with a required title', () {
        const props = SectionProps(title: 'Appetizers');

        expect(props.title, 'Appetizers');
      });

      test('should default uppercase to false when none is provided', () {
        const props = SectionProps(title: 'Appetizers');

        expect(props.uppercase, isFalse);
      });

      test('should default showDivider to true when none is provided', () {
        const props = SectionProps(title: 'Appetizers');

        expect(props.showDivider, isTrue);
      });

      test('should store uppercase true when explicitly set', () {
        const props = SectionProps(title: 'Main Courses', uppercase: true);

        expect(props.uppercase, isTrue);
      });

      test('should store showDivider false when explicitly set', () {
        const props = SectionProps(title: 'Desserts', showDivider: false);

        expect(props.showDivider, isFalse);
      });

      test('should store an empty-string title when provided', () {
        const props = SectionProps(title: '');

        expect(props.title, '');
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = SectionProps(
          title: 'Section',
          uppercase: true,
          showDivider: false,
        );
        const b = SectionProps(
          title: 'Section',
          uppercase: true,
          showDivider: false,
        );

        expect(a, equals(b));
      });

      test('should not be equal when titles differ', () {
        const a = SectionProps(title: 'Starters');
        const b = SectionProps(title: 'Mains');

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when uppercase differs', () {
        const a = SectionProps(title: 'Section', uppercase: true);
        const b = SectionProps(title: 'Section', uppercase: false);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when showDivider differs', () {
        const a = SectionProps(title: 'Section', showDivider: true);
        const b = SectionProps(title: 'Section', showDivider: false);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = SectionProps(title: 'Section', uppercase: true);
        const b = SectionProps(title: 'Section', uppercase: true);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update title when copyWith is called with a new title', () {
        const original = SectionProps(title: 'Original');

        final modified = original.copyWith(title: 'Modified');

        expect(modified.title, 'Modified');
      });

      test('should update uppercase when copyWith is called with true', () {
        const original = SectionProps(title: 'Section', uppercase: false);

        final modified = original.copyWith(uppercase: true);

        expect(modified.uppercase, isTrue);
      });

      test('should update showDivider when copyWith is called with false', () {
        const original = SectionProps(title: 'Section');

        final modified = original.copyWith(showDivider: false);

        expect(modified.showDivider, isFalse);
      });

      test('should preserve unchanged fields when only title is updated', () {
        const original = SectionProps(
          title: 'Original',
          uppercase: true,
          showDivider: false,
        );

        final modified = original.copyWith(title: 'Modified');

        expect(modified.uppercase, isTrue);
        expect(modified.showDivider, isFalse);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = SectionProps(title: 'Original', uppercase: false);

        final _ = original.copyWith(title: 'Modified', uppercase: true);

        expect(original.title, 'Original');
        expect(original.uppercase, isFalse);
      });
    });

    group('JSON round-trip', () {
      test('should serialise title as a string key in the JSON map', () {
        const props = SectionProps(title: 'Desserts');

        final json = props.toJson();

        expect(json['title'], 'Desserts');
      });

      test('should serialise uppercase as a bool key in the JSON map', () {
        const props = SectionProps(title: 'Desserts', uppercase: true);

        final json = props.toJson();

        expect(json['uppercase'], isTrue);
      });

      test('should serialise showDivider as a bool key in the JSON map', () {
        const props = SectionProps(title: 'Desserts', showDivider: false);

        final json = props.toJson();

        expect(json['showDivider'], isFalse);
      });

      test('should be equal to the original after toJson then fromJson', () {
        const original = SectionProps(
          title: 'Test Section',
          uppercase: true,
          showDivider: false,
        );

        final json = original.toJson();
        final restored = SectionProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should use default values when only title is present in JSON', () {
        final json = {'title': 'Sides'};

        final props = SectionProps.fromJson(json);

        expect(props.uppercase, isFalse);
        expect(props.showDivider, isTrue);
      });

      test('should round-trip all fields when fully populated', () {
        const original = SectionProps(
          title: 'Beverages',
          uppercase: false,
          showDivider: true,
        );

        final json = original.toJson();
        final restored = SectionProps.fromJson(json);

        expect(restored, equals(original));
      });
    });
  });
}
