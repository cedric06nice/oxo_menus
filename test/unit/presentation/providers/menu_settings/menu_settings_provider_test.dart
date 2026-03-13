import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_notifier.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

void main() {
  group('menuSettingsProvider', () {
    test('should create MenuSettingsNotifier with repositories', () {
      final container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(MockMenuRepository()),
          sizeRepositoryProvider.overrideWithValue(MockSizeRepository()),
          areaRepositoryProvider.overrideWithValue(MockAreaRepository()),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(menuSettingsProvider.notifier);
      final state = container.read(menuSettingsProvider);

      expect(notifier, isA<MenuSettingsNotifier>());
      expect(state, const MenuSettingsState());
    });

    test('build() returns default MenuSettingsState', () {
      final container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(MockMenuRepository()),
          sizeRepositoryProvider.overrideWithValue(MockSizeRepository()),
          areaRepositoryProvider.overrideWithValue(MockAreaRepository()),
        ],
      );

      addTearDown(container.dispose);

      final state = container.read(menuSettingsProvider);

      expect(state.sizes, isEmpty);
      expect(state.areas, isEmpty);
      expect(state.isLoadingSizes, false);
      expect(state.isLoadingAreas, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });
  });
}
