import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('Container', () {
    test('should create Container with styleConfig', () {
      const container = Container(
        id: 1,
        pageId: 1,
        index: 0,
        styleConfig: StyleConfig(
          marginTop: 10.0,
          borderType: BorderType.plainThin,
        ),
      );

      expect(container.styleConfig, isNotNull);
      expect(container.styleConfig!.marginTop, 10.0);
      expect(container.styleConfig!.borderType, BorderType.plainThin);
    });

    test('should default styleConfig to null', () {
      const container = Container(id: 1, pageId: 1, index: 0);

      expect(container.styleConfig, isNull);
    });

    test('should copyWith styleConfig', () {
      const container = Container(id: 1, pageId: 1, index: 0);
      final updated = container.copyWith(
        styleConfig: const StyleConfig(paddingLeft: 5.0),
      );

      expect(updated.styleConfig, isNotNull);
      expect(updated.styleConfig!.paddingLeft, 5.0);
    });
  });
}
