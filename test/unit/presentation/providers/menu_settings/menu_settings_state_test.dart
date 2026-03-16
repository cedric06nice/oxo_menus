import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';

void main() {
  group('MenuSettingsState', () {
    test('should have correct default values', () {
      const state = MenuSettingsState();

      expect(state.sizes, isEmpty);
      expect(state.areas, isEmpty);
      expect(state.isLoadingSizes, false);
      expect(state.isLoadingAreas, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('should support copyWith', () {
      const state = MenuSettingsState();
      const size = Size(
        id: 1,
        name: 'A4',
        width: 210,
        height: 297,
        status: Status.published,
        direction: 'portrait',
      );
      const area = Area(id: 1, name: 'Main Dining');

      final updated = state.copyWith(
        sizes: [size],
        areas: [area],
        isLoadingSizes: true,
        errorMessage: 'Something went wrong',
      );

      expect(updated.sizes, hasLength(1));
      expect(updated.sizes.first.name, 'A4');
      expect(updated.areas, hasLength(1));
      expect(updated.areas.first.name, 'Main Dining');
      expect(updated.isLoadingSizes, true);
      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'Something went wrong');
    });

    test('should support equality', () {
      const state1 = MenuSettingsState();
      const state2 = MenuSettingsState();

      expect(state1, equals(state2));
    });
  });
}
