import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('Column', () {
    test('should create Column with styleConfig', () {
      const column = Column(
        id: 1,
        containerId: 1,
        index: 0,
        styleConfig: StyleConfig(
          paddingLeft: 5.0,
          borderType: BorderType.dropShadow,
        ),
      );

      expect(column.styleConfig, isNotNull);
      expect(column.styleConfig!.paddingLeft, 5.0);
      expect(column.styleConfig!.borderType, BorderType.dropShadow);
    });

    test('should default styleConfig to null', () {
      const column = Column(id: 1, containerId: 1, index: 0);

      expect(column.styleConfig, isNull);
    });

    test('should copyWith styleConfig', () {
      const column = Column(id: 1, containerId: 1, index: 0);
      final updated = column.copyWith(
        styleConfig: const StyleConfig(marginTop: 20.0),
      );

      expect(updated.styleConfig, isNotNull);
      expect(updated.styleConfig!.marginTop, 20.0);
    });

    test('isDroppable defaults to true', () {
      const column = Column(id: 1, containerId: 1, index: 0);

      expect(column.isDroppable, true);
    });

    test('can be created with isDroppable: false', () {
      const column = Column(
        id: 1,
        containerId: 1,
        index: 0,
        isDroppable: false,
      );

      expect(column.isDroppable, false);
    });

    test('copyWith(isDroppable: false) works', () {
      const column = Column(id: 1, containerId: 1, index: 0);
      final updated = column.copyWith(isDroppable: false);

      expect(updated.isDroppable, false);
    });
  });
}
