import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';

void main() {
  group('WidgetAlignment', () {
    group('values', () {
      test('should contain exactly four values', () {
        expect(WidgetAlignment.values.length, 4);
      });

      test('should include start', () {
        expect(WidgetAlignment.values, contains(WidgetAlignment.start));
      });

      test('should include center', () {
        expect(WidgetAlignment.values, contains(WidgetAlignment.center));
      });

      test('should include end', () {
        expect(WidgetAlignment.values, contains(WidgetAlignment.end));
      });

      test('should include justified', () {
        expect(WidgetAlignment.values, contains(WidgetAlignment.justified));
      });
    });

    group('crossAxis', () {
      test(
        'should return CrossAxisAlignment.start when alignment is start',
        () {
          expect(WidgetAlignment.start.crossAxis, CrossAxisAlignment.start);
        },
      );

      test(
        'should return CrossAxisAlignment.center when alignment is center',
        () {
          expect(WidgetAlignment.center.crossAxis, CrossAxisAlignment.center);
        },
      );

      test('should return CrossAxisAlignment.end when alignment is end', () {
        expect(WidgetAlignment.end.crossAxis, CrossAxisAlignment.end);
      });

      test(
        'should return CrossAxisAlignment.stretch when alignment is justified',
        () {
          expect(
            WidgetAlignment.justified.crossAxis,
            CrossAxisAlignment.stretch,
          );
        },
      );
    });

    group('textAlign', () {
      test('should return TextAlign.start when alignment is start', () {
        expect(WidgetAlignment.start.textAlign, TextAlign.start);
      });

      test('should return TextAlign.center when alignment is center', () {
        expect(WidgetAlignment.center.textAlign, TextAlign.center);
      });

      test('should return TextAlign.end when alignment is end', () {
        expect(WidgetAlignment.end.textAlign, TextAlign.end);
      });

      test('should return TextAlign.start when alignment is justified', () {
        expect(WidgetAlignment.justified.textAlign, TextAlign.start);
      });
    });

    group('isJustified', () {
      test('should return true when alignment is justified', () {
        expect(WidgetAlignment.justified.isJustified, isTrue);
      });

      test('should return false when alignment is start', () {
        expect(WidgetAlignment.start.isJustified, isFalse);
      });

      test('should return false when alignment is center', () {
        expect(WidgetAlignment.center.isJustified, isFalse);
      });

      test('should return false when alignment is end', () {
        expect(WidgetAlignment.end.isJustified, isFalse);
      });
    });
  });
}
