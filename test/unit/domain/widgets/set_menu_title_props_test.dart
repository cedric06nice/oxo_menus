import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';

void main() {
  group('SetMenuTitleProps', () {
    group('construction', () {
      test('should store title when constructed with a required title', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.title, 'Set Lunch Menu');
      });

      test('should default subtitle to null when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.subtitle, isNull);
      });

      test('should default uppercase to true when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.uppercase, isTrue);
      });

      test('should default priceLabel1 to null when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.priceLabel1, isNull);
      });

      test('should default price1 to null when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.price1, isNull);
      });

      test('should default priceLabel2 to null when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.priceLabel2, isNull);
      });

      test('should default price2 to null when none is provided', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.price2, isNull);
      });

      test('should store all optional fields when provided', () {
        const props = SetMenuTitleProps(
          title: 'Set Dinner Menu',
          subtitle: 'Seasonal dishes',
          uppercase: false,
          priceLabel1: '3 Courses',
          price1: 45.0,
          priceLabel2: '4 Courses',
          price2: 55.0,
        );

        expect(props.subtitle, 'Seasonal dishes');
        expect(props.uppercase, isFalse);
        expect(props.priceLabel1, '3 Courses');
        expect(props.price1, 45.0);
        expect(props.priceLabel2, '4 Courses');
        expect(props.price2, 55.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );
        const b = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );

        expect(a, equals(b));
      });

      test('should not be equal when titles differ', () {
        const a = SetMenuTitleProps(title: 'Menu A');
        const b = SetMenuTitleProps(title: 'Menu B');

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when price1 differs', () {
        const a = SetMenuTitleProps(title: 'Menu', price1: 40.0);
        const b = SetMenuTitleProps(title: 'Menu', price1: 45.0);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = SetMenuTitleProps(title: 'Menu', price1: 45.0);
        const b = SetMenuTitleProps(title: 'Menu', price1: 45.0);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update title when copyWith is called with a new title', () {
        const original = SetMenuTitleProps(title: 'Old');

        final copy = original.copyWith(title: 'New');

        expect(copy.title, 'New');
      });

      test('should update priceLabel1 when copyWith provides a new label', () {
        const original = SetMenuTitleProps(title: 'Menu');

        final copy = original.copyWith(priceLabel1: '3 Courses');

        expect(copy.priceLabel1, '3 Courses');
      });

      test('should update price1 when copyWith provides a new price', () {
        const original = SetMenuTitleProps(title: 'Menu');

        final copy = original.copyWith(price1: 45.0);

        expect(copy.price1, 45.0);
      });

      test('should preserve unchanged fields when only title is updated', () {
        const original = SetMenuTitleProps(
          title: 'Old',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );

        final copy = original.copyWith(title: 'New');

        expect(copy.priceLabel1, '3 Courses');
        expect(copy.price1, 45.0);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = SetMenuTitleProps(title: 'Old');

        final _ = original.copyWith(title: 'New');

        expect(original.title, 'Old');
      });
    });

    group('displayTitle', () {
      test('should return uppercased title when uppercase default is true', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.displayTitle, 'SET LUNCH MENU');
      });

      test('should return original casing when uppercase is set to false', () {
        const props = SetMenuTitleProps(
          title: 'Set Lunch Menu',
          uppercase: false,
        );

        expect(props.displayTitle, 'Set Lunch Menu');
      });

      test(
        'should return empty string when title is empty and uppercase true',
        () {
          const props = SetMenuTitleProps(title: '');

          expect(props.displayTitle, '');
        },
      );
    });

    group('formattedPrice1', () {
      test('should return null when priceLabel1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price1: 45.0);

        expect(props.formattedPrice1, isNull);
      });

      test('should return null when price1 is null', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
        );

        expect(props.formattedPrice1, isNull);
      });

      test(
        'should return label with whole-number GBP price when both are set',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel1: '3 Courses',
            price1: 45.0,
          );

          expect(props.formattedPrice1, '3 Courses  45');
        },
      );

      test(
        'should return label with fractional GBP price when price has decimal',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel1: '2 Courses',
            price1: 29.5,
          );

          expect(props.formattedPrice1, '2 Courses  29.5');
        },
      );

      test(
        'should strip trailing zeros from GBP price value in formattedPrice1',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel1: '3 Courses',
            price1: 45.00,
          );

          expect(props.formattedPrice1, '3 Courses  45');
        },
      );
    });

    group('formattedPrice2', () {
      test('should return null when priceLabel2 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price2: 55.0);

        expect(props.formattedPrice2, isNull);
      });

      test('should return null when price2 is null', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel2: '4 Courses',
        );

        expect(props.formattedPrice2, isNull);
      });

      test(
        'should return label with whole-number GBP price when both are set',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel2: '4 Courses',
            price2: 55.0,
          );

          expect(props.formattedPrice2, '4 Courses  55');
        },
      );

      test(
        'should return label with fractional GBP price when price2 has decimal',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel2: '4 Courses',
            price2: 55.50,
          );

          expect(props.formattedPrice2, '4 Courses  55.5');
        },
      );
    });

    group('formattedPrices', () {
      test('should return null when price1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu');

        expect(props.formattedPrices, isNull);
      });

      test('should return null when only price2 is set and price1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price2: 55.0);

        expect(props.formattedPrices, isNull);
      });

      test(
        'should return price1 string alone when no label and no price2 set',
        () {
          const props = SetMenuTitleProps(title: 'Menu', price1: 45.0);

          expect(props.formattedPrices, '45');
        },
      );

      test(
        'should return price1 slash price2 when both prices set with no labels',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            price1: 45.0,
            price2: 55.0,
          );

          expect(props.formattedPrices, '45 / 55');
        },
      );

      test(
        'should return label plus price1 when only label1 and price1 are set',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel1: '3 Courses',
            price1: 45.0,
          );

          expect(props.formattedPrices, '3 Courses 45');
        },
      );

      test(
        'should return both labelled lines when all four fields are set',
        () {
          const props = SetMenuTitleProps(
            title: 'Menu',
            priceLabel1: '3 Courses',
            price1: 45.0,
            priceLabel2: '4 Courses',
            price2: 55.0,
          );

          expect(props.formattedPrices, '3 Courses 45 / 4 Courses 55');
        },
      );

      test('should strip trailing zeros from GBP price in formattedPrices', () {
        const props = SetMenuTitleProps(title: 'Menu', price1: 29.5);

        expect(props.formattedPrices, '29.5');
      });

      test(
        'should preserve two-decimal GBP values like 29.75 in formattedPrices',
        () {
          const props = SetMenuTitleProps(title: 'Menu', price1: 29.75);

          expect(props.formattedPrices, '29.75');
        },
      );

      test(
        'should return price1 only when price1 is set and price2 is null with no labels',
        () {
          const props = SetMenuTitleProps(title: 'Menu', price1: 40.0);

          expect(props.formattedPrices, '40');
        },
      );
    });

    group('JSON round-trip', () {
      test(
        'should be equal to the original after toJson then fromJson with all fields',
        () {
          const original = SetMenuTitleProps(
            title: 'Set Menu',
            subtitle: 'Light bites',
            priceLabel1: '2 Courses',
            price1: 30.0,
            priceLabel2: '3 Courses',
            price2: 40.0,
          );

          final json = original.toJson();
          final restored = SetMenuTitleProps.fromJson(json);

          expect(restored, equals(original));
        },
      );

      test(
        'should be equal to the original after toJson then fromJson with only title',
        () {
          const original = SetMenuTitleProps(title: 'Set Menu');

          final json = original.toJson();
          final restored = SetMenuTitleProps.fromJson(json);

          expect(restored, equals(original));
        },
      );

      test(
        'should use default uppercase true when key is absent from JSON',
        () {
          final json = {'title': 'Menu'};

          final props = SetMenuTitleProps.fromJson(json);

          expect(props.uppercase, isTrue);
        },
      );

      test(
        'should use null defaults for all optional keys absent from JSON',
        () {
          final json = {'title': 'Menu'};

          final props = SetMenuTitleProps.fromJson(json);

          expect(props.subtitle, isNull);
          expect(props.priceLabel1, isNull);
          expect(props.price1, isNull);
          expect(props.priceLabel2, isNull);
          expect(props.price2, isNull);
        },
      );

      test('should round-trip a fractional GBP price1 correctly', () {
        const original = SetMenuTitleProps(title: 'Menu', price1: 29.99);

        final json = original.toJson();
        final restored = SetMenuTitleProps.fromJson(json);

        expect(restored.price1, 29.99);
      });
    });
  });
}
