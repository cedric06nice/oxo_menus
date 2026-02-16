import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';

void main() {
  group('menuDisplayOptionsProvider', () {
    test('should have null as initial value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final options = container.read(menuDisplayOptionsProvider);

      expect(options, isNull);
    });

    test('should allow updating to a valid value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const displayOptions = MenuDisplayOptions(
        showAllergens: true,
        showPrices: false,
      );

      container.read(menuDisplayOptionsProvider.notifier).state =
          displayOptions;

      final options = container.read(menuDisplayOptionsProvider);
      expect(options, isNotNull);
      expect(options!.showAllergens, true);
      expect(options.showPrices, false);
    });

    test('should allow resetting to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(menuDisplayOptionsProvider.notifier).state =
          const MenuDisplayOptions(
        showAllergens: true,
        showPrices: true,
      );

      container.read(menuDisplayOptionsProvider.notifier).state = null;

      expect(container.read(menuDisplayOptionsProvider), isNull);
    });
  });
}
