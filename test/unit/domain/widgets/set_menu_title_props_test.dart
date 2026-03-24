import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';

void main() {
  group('SetMenuTitleProps', () {
    group('creation', () {
      test('creates with required fields and defaults', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');

        expect(props.title, 'Set Lunch Menu');
        expect(props.subtitle, isNull);
        expect(props.uppercase, true);
        expect(props.priceLabel1, isNull);
        expect(props.price1, isNull);
        expect(props.priceLabel2, isNull);
        expect(props.price2, isNull);
      });

      test('creates with all fields', () {
        const props = SetMenuTitleProps(
          title: 'Set Dinner Menu',
          subtitle: 'Seasonal dishes',
          uppercase: false,
          priceLabel1: '3 Courses',
          price1: 45.0,
          priceLabel2: '4 Courses',
          price2: 55.0,
        );

        expect(props.title, 'Set Dinner Menu');
        expect(props.subtitle, 'Seasonal dishes');
        expect(props.uppercase, false);
        expect(props.priceLabel1, '3 Courses');
        expect(props.price1, 45.0);
        expect(props.priceLabel2, '4 Courses');
        expect(props.price2, 55.0);
      });
    });

    group('JSON serialization', () {
      test('round-trips with all fields', () {
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

        expect(restored, original);
      });

      test('round-trips with minimal fields', () {
        const original = SetMenuTitleProps(title: 'Set Menu');

        final json = original.toJson();
        final restored = SetMenuTitleProps.fromJson(json);

        expect(restored, original);
      });

      test('fromJson handles missing optional keys', () {
        final json = {'title': 'Menu'};
        final props = SetMenuTitleProps.fromJson(json);

        expect(props.title, 'Menu');
        expect(props.subtitle, isNull);
        expect(props.uppercase, true);
        expect(props.priceLabel1, isNull);
        expect(props.price1, isNull);
        expect(props.priceLabel2, isNull);
        expect(props.price2, isNull);
      });
    });

    group('displayTitle', () {
      test('returns uppercased title when uppercase is true', () {
        const props = SetMenuTitleProps(title: 'Set Lunch Menu');
        expect(props.displayTitle, 'SET LUNCH MENU');
      });

      test('returns original title when uppercase is false', () {
        const props = SetMenuTitleProps(
          title: 'Set Lunch Menu',
          uppercase: false,
        );
        expect(props.displayTitle, 'Set Lunch Menu');
      });
    });

    group('formattedPrice1', () {
      test('returns null when priceLabel1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price1: 45.0);
        expect(props.formattedPrice1, isNull);
      });

      test('returns null when price1 is null', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
        );
        expect(props.formattedPrice1, isNull);
      });

      test('returns formatted string for whole number', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );
        expect(props.formattedPrice1, '3 Courses  45');
      });

      test('returns formatted string for decimal', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '2 Courses',
          price1: 29.5,
        );
        expect(props.formattedPrice1, '2 Courses  29.5');
      });
    });

    group('formattedPrice2', () {
      test('returns null when priceLabel2 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price2: 55.0);
        expect(props.formattedPrice2, isNull);
      });

      test('returns null when price2 is null', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel2: '4 Courses',
        );
        expect(props.formattedPrice2, isNull);
      });

      test('returns formatted string for whole number', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel2: '4 Courses',
          price2: 55.0,
        );
        expect(props.formattedPrice2, '4 Courses  55');
      });
    });

    group('formattedPrices', () {
      test('returns null when price1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu');
        expect(props.formattedPrices, isNull);
      });

      test('returns price1 only when no label and no price2', () {
        const props = SetMenuTitleProps(title: 'Menu', price1: 45.0);
        expect(props.formattedPrices, '45');
      });

      test('returns price1 / price2 when no labels', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          price1: 45.0,
          price2: 55.0,
        );
        expect(props.formattedPrices, '45 / 55');
      });

      test('returns label1 price1 when label1 and price1 set', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );
        expect(props.formattedPrices, '3 Courses 45');
      });

      test('returns label1 price1 / label2 price2 when all set', () {
        const props = SetMenuTitleProps(
          title: 'Menu',
          priceLabel1: '3 Courses',
          price1: 45.0,
          priceLabel2: '4 Courses',
          price2: 55.0,
        );
        expect(props.formattedPrices, '3 Courses 45 / 4 Courses 55');
      });

      test('strips trailing zeros from decimal prices', () {
        const props = SetMenuTitleProps(title: 'Menu', price1: 29.5);
        expect(props.formattedPrices, '29.5');
      });

      test('ignores price2 when price1 is null', () {
        const props = SetMenuTitleProps(title: 'Menu', price2: 55.0);
        expect(props.formattedPrices, isNull);
      });
    });

    group('equality', () {
      test('two props with same values are equal', () {
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
        expect(a, b);
      });

      test('two props with different values are not equal', () {
        const a = SetMenuTitleProps(title: 'Menu A');
        const b = SetMenuTitleProps(title: 'Menu B');
        expect(a, isNot(b));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = SetMenuTitleProps(title: 'Old');
        final copy = original.copyWith(
          title: 'New',
          priceLabel1: '3 Courses',
          price1: 45.0,
        );

        expect(copy.title, 'New');
        expect(copy.priceLabel1, '3 Courses');
        expect(copy.price1, 45.0);
      });
    });
  });
}
