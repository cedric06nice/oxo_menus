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

    test('should create Container with parentContainerId', () {
      const container = Container(
        id: 2,
        pageId: 1,
        index: 0,
        parentContainerId: 1,
      );

      expect(container.parentContainerId, 1);
    });

    test('should default parentContainerId to null', () {
      const container = Container(id: 1, pageId: 1, index: 0);

      expect(container.parentContainerId, isNull);
    });

    test('should copyWith parentContainerId', () {
      const container = Container(id: 1, pageId: 1, index: 0);
      final updated = container.copyWith(parentContainerId: 5);

      expect(updated.parentContainerId, 5);
    });
  });

  group('LayoutConfig', () {
    test('should create LayoutConfig with mainAxisAlignment', () {
      const layout = LayoutConfig(
        direction: 'row',
        mainAxisAlignment: 'center',
      );

      expect(layout.mainAxisAlignment, 'center');
    });

    test('should default mainAxisAlignment to null', () {
      const layout = LayoutConfig(direction: 'row');

      expect(layout.mainAxisAlignment, isNull);
    });

    test('should serialize mainAxisAlignment to JSON', () {
      const layout = LayoutConfig(
        direction: 'column',
        mainAxisAlignment: 'spaceBetween',
        spacing: 8.0,
      );

      final json = layout.toJson();

      expect(json['mainAxisAlignment'], 'spaceBetween');
      expect(json['direction'], 'column');
      expect(json['spacing'], 8.0);
    });

    test('should deserialize mainAxisAlignment from JSON', () {
      final layout = LayoutConfig.fromJson({
        'direction': 'row',
        'mainAxisAlignment': 'spaceEvenly',
      });

      expect(layout.mainAxisAlignment, 'spaceEvenly');
      expect(layout.direction, 'row');
    });
  });
}
