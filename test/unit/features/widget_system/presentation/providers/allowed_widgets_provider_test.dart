import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/allowed_widgets_provider.dart';

void main() {
  const dishConfig = WidgetTypeConfig(
    type: 'dish',
    alignment: WidgetAlignment.start,
  );
  const wineConfig = WidgetTypeConfig(
    type: 'wine',
    alignment: WidgetAlignment.end,
  );
  const sectionConfig = WidgetTypeConfig(
    type: 'section',
    alignment: WidgetAlignment.center,
    enabled: false,
  );

  group('AllowedWidgetsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    AllowedWidgetsNotifier readNotifier() =>
        container.read(allowedWidgetsProvider.notifier);
    List<WidgetTypeConfig> readState() =>
        container.read(allowedWidgetsProvider);

    test('should start with an empty list', () {
      expect(readState(), isEmpty);
    });

    test('should set configs when set is called', () {
      readNotifier().set([dishConfig, wineConfig]);

      expect(readState(), [dishConfig, wineConfig]);
    });

    test('should replace previous configs when set is called twice', () {
      readNotifier().set([dishConfig]);
      readNotifier().set([wineConfig, sectionConfig]);

      expect(readState(), [wineConfig, sectionConfig]);
    });

    test('should clear configs when set is called with empty list', () {
      readNotifier().set([dishConfig, wineConfig]);
      readNotifier().set([]);

      expect(readState(), isEmpty);
    });

    group('alignmentFor', () {
      test('should return alignment for a registered widget type', () {
        readNotifier().set([dishConfig, wineConfig]);

        expect(readNotifier().alignmentFor('dish'), WidgetAlignment.start);
      });

      test('should return end alignment for wine type', () {
        readNotifier().set([dishConfig, wineConfig]);

        expect(readNotifier().alignmentFor('wine'), WidgetAlignment.end);
      });

      test('should return WidgetAlignment.start for unknown type', () {
        readNotifier().set([dishConfig]);

        expect(readNotifier().alignmentFor('unknown'), WidgetAlignment.start);
      });

      test('should return start alignment when state is empty', () {
        expect(readNotifier().alignmentFor('dish'), WidgetAlignment.start);
      });

      test('should return center alignment for center-aligned type', () {
        readNotifier().set([sectionConfig]);

        expect(readNotifier().alignmentFor('section'), WidgetAlignment.center);
      });

      test('should return start alignment for disabled widget type', () {
        // disabled type still has a configured alignment
        readNotifier().set([sectionConfig]);
        expect(readNotifier().alignmentFor('section'), WidgetAlignment.center);
      });
    });

    test('should notify listeners when configs change', () {
      final states = <List<WidgetTypeConfig>>[];
      container.listen<List<WidgetTypeConfig>>(
        allowedWidgetsProvider,
        (_, next) => states.add(next),
      );

      readNotifier().set([dishConfig]);

      expect(states, hasLength(1));
      expect(states.first, [dishConfig]);
    });
  });
}
