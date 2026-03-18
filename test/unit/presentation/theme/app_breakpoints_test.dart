import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/theme/app_spacing.dart';

void main() {
  group('AppBreakpoints', () {
    test('mobile breakpoint is 600.0', () {
      expect(AppBreakpoints.mobile, 600.0);
    });

    test('desktop breakpoint is 1200.0', () {
      expect(AppBreakpoints.desktop, 1200.0);
    });
  });
}
