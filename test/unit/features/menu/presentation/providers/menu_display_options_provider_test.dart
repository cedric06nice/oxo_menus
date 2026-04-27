import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_display_options_provider.dart';

void main() {
  group('menuDisplayOptionsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should have null as initial value', () {
      expect(container.read(menuDisplayOptionsProvider), isNull);
    });

    test(
      'should set display options when set is called with a non-null value',
      () {
        const options = MenuDisplayOptions(
          showAllergens: true,
          showPrices: false,
        );

        container.read(menuDisplayOptionsProvider.notifier).set(options);

        expect(container.read(menuDisplayOptionsProvider), options);
      },
    );

    test('should show prices when showPrices is true', () {
      const options = MenuDisplayOptions(
        showPrices: true,
        showAllergens: false,
      );

      container.read(menuDisplayOptionsProvider.notifier).set(options);

      expect(container.read(menuDisplayOptionsProvider)!.showPrices, isTrue);
    });

    test('should show allergens when showAllergens is true', () {
      const options = MenuDisplayOptions(
        showPrices: false,
        showAllergens: true,
      );

      container.read(menuDisplayOptionsProvider.notifier).set(options);

      expect(container.read(menuDisplayOptionsProvider)!.showAllergens, isTrue);
    });

    test('should reset to null when set is called with null', () {
      const options = MenuDisplayOptions(showAllergens: true, showPrices: true);
      container.read(menuDisplayOptionsProvider.notifier).set(options);
      expect(container.read(menuDisplayOptionsProvider), isNotNull);

      container.read(menuDisplayOptionsProvider.notifier).set(null);

      expect(container.read(menuDisplayOptionsProvider), isNull);
    });

    test('should replace previous options when set is called twice', () {
      const options1 = MenuDisplayOptions(
        showAllergens: true,
        showPrices: true,
      );
      const options2 = MenuDisplayOptions(
        showAllergens: false,
        showPrices: false,
      );

      container.read(menuDisplayOptionsProvider.notifier).set(options1);
      container.read(menuDisplayOptionsProvider.notifier).set(options2);

      expect(container.read(menuDisplayOptionsProvider), options2);
    });

    test('should notify listeners on state change', () {
      final states = <MenuDisplayOptions?>[];
      container.listen<MenuDisplayOptions?>(
        menuDisplayOptionsProvider,
        (_, next) => states.add(next),
      );

      const options = MenuDisplayOptions(
        showAllergens: true,
        showPrices: false,
      );
      container.read(menuDisplayOptionsProvider.notifier).set(options);

      expect(states, hasLength(1));
      expect(states.first, options);
    });
  });
}
