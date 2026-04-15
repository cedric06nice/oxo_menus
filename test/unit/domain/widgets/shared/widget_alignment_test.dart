import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';

void main() {
  group('WidgetAlignment', () {
    test('crossAxis mapping', () {
      expect(WidgetAlignment.start.crossAxis, CrossAxisAlignment.start);
      expect(WidgetAlignment.center.crossAxis, CrossAxisAlignment.center);
      expect(WidgetAlignment.end.crossAxis, CrossAxisAlignment.end);
      expect(WidgetAlignment.justified.crossAxis, CrossAxisAlignment.stretch);
    });

    test('textAlign mapping', () {
      expect(WidgetAlignment.start.textAlign, TextAlign.start);
      expect(WidgetAlignment.center.textAlign, TextAlign.center);
      expect(WidgetAlignment.end.textAlign, TextAlign.end);
      expect(WidgetAlignment.justified.textAlign, TextAlign.start);
    });

    test('isJustified', () {
      expect(WidgetAlignment.justified.isJustified, isTrue);
      expect(WidgetAlignment.start.isJustified, isFalse);
      expect(WidgetAlignment.center.isJustified, isFalse);
      expect(WidgetAlignment.end.isJustified, isFalse);
    });
  });
}
