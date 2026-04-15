import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';

void main() {
  group('WidgetTypeConfig', () {
    test('defaults alignment to start', () {
      const cfg = WidgetTypeConfig(type: 'dish');
      expect(cfg.alignment, WidgetAlignment.start);
    });

    test('round-trips justified through json', () {
      const cfg = WidgetTypeConfig(
        type: 'dish',
        alignment: WidgetAlignment.justified,
      );
      final json = cfg.toJson();
      expect(json['type'], 'dish');
      expect(json['alignment'], 'justified');
      final restored = WidgetTypeConfig.fromJson(json);
      expect(restored, cfg);
    });

    test('round-trips center and end', () {
      for (final a in [WidgetAlignment.center, WidgetAlignment.end]) {
        final cfg = WidgetTypeConfig(type: 'wine', alignment: a);
        expect(WidgetTypeConfig.fromJson(cfg.toJson()), cfg);
      }
    });

    test('missing alignment in json defaults to start', () {
      final cfg = WidgetTypeConfig.fromJson({'type': 'dish'});
      expect(cfg.alignment, WidgetAlignment.start);
    });

    test('defaults enabled to true', () {
      const cfg = WidgetTypeConfig(type: 'dish');
      expect(cfg.enabled, isTrue);
    });

    test('round-trips enabled=false through json', () {
      const cfg = WidgetTypeConfig(
        type: 'dish',
        alignment: WidgetAlignment.center,
        enabled: false,
      );
      final json = cfg.toJson();
      expect(json['enabled'], isFalse);
      expect(WidgetTypeConfig.fromJson(json), cfg);
    });
  });
}
