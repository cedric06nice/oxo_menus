import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_notifier.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_area_repository.dart';
import '../../../../fakes/fake_menu_repository.dart';
import '../../../../fakes/fake_size_repository.dart';

void main() {
  group('menuSettingsProvider', () {
    test('should provide a MenuSettingsNotifier', () {
      final container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
          sizeRepositoryProvider.overrideWithValue(FakeSizeRepository()),
          areaRepositoryProvider.overrideWithValue(FakeAreaRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(menuSettingsProvider.notifier),
        isA<MenuSettingsNotifier>(),
      );
    });

    test('should start with default MenuSettingsState', () {
      final container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
          sizeRepositoryProvider.overrideWithValue(FakeSizeRepository()),
          areaRepositoryProvider.overrideWithValue(FakeAreaRepository()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(menuSettingsProvider);

      expect(state, const MenuSettingsState());
      expect(state.sizes, isEmpty);
      expect(state.areas, isEmpty);
      expect(state.isLoadingSizes, isFalse);
      expect(state.isLoadingAreas, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('should return same notifier instance on multiple reads', () {
      final container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
          sizeRepositoryProvider.overrideWithValue(FakeSizeRepository()),
          areaRepositoryProvider.overrideWithValue(FakeAreaRepository()),
        ],
      );
      addTearDown(container.dispose);

      final n1 = container.read(menuSettingsProvider.notifier);
      final n2 = container.read(menuSettingsProvider.notifier);

      expect(identical(n1, n2), isTrue);
    });
  });
}
