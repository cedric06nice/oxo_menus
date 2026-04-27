import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_state.dart';

void main() {
  const size1 = Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  );
  const size2 = Size(
    id: 2,
    name: 'Letter',
    width: 215.9,
    height: 279.4,
    status: Status.published,
    direction: 'landscape',
  );
  const area1 = Area(id: 1, name: 'Main Dining');
  const area2 = Area(id: 2, name: 'Bar');

  group('MenuSettingsState', () {
    test('should have correct default values', () {
      const state = MenuSettingsState();

      expect(state.sizes, isEmpty);
      expect(state.areas, isEmpty);
      expect(state.isLoadingSizes, isFalse);
      expect(state.isLoadingAreas, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('should support copyWith for sizes', () {
      const state = MenuSettingsState();
      final updated = state.copyWith(sizes: [size1, size2]);

      expect(updated.sizes, [size1, size2]);
    });

    test('should support copyWith for areas', () {
      const state = MenuSettingsState();
      final updated = state.copyWith(areas: [area1, area2]);

      expect(updated.areas, [area1, area2]);
    });

    test('should support copyWith for isLoadingSizes', () {
      const state = MenuSettingsState();
      final updated = state.copyWith(isLoadingSizes: true);

      expect(updated.isLoadingSizes, isTrue);
      expect(updated.isLoading, isTrue);
    });

    test('should support copyWith for isLoadingAreas', () {
      const state = MenuSettingsState();
      final updated = state.copyWith(isLoadingAreas: true);

      expect(updated.isLoadingAreas, isTrue);
      expect(updated.isLoading, isTrue);
    });

    test('should support copyWith for errorMessage', () {
      const state = MenuSettingsState();
      final updated = state.copyWith(errorMessage: 'Something went wrong');

      expect(updated.errorMessage, 'Something went wrong');
    });

    test('isLoading should be true when only isLoadingSizes is true', () {
      const state = MenuSettingsState(isLoadingSizes: true);
      expect(state.isLoading, isTrue);
    });

    test('isLoading should be true when only isLoadingAreas is true', () {
      const state = MenuSettingsState(isLoadingAreas: true);
      expect(state.isLoading, isTrue);
    });

    test('isLoading should be true when both flags are true', () {
      const state = MenuSettingsState(
        isLoadingSizes: true,
        isLoadingAreas: true,
      );
      expect(state.isLoading, isTrue);
    });

    test('isLoading should be false when both flags are false', () {
      const state = MenuSettingsState(
        isLoadingSizes: false,
        isLoadingAreas: false,
      );
      expect(state.isLoading, isFalse);
    });

    test('should support equality for identical states', () {
      const state1 = MenuSettingsState();
      const state2 = MenuSettingsState();

      expect(state1, equals(state2));
    });

    test('should not equal state with different isLoadingSizes', () {
      const state1 = MenuSettingsState(isLoadingSizes: false);
      const state2 = MenuSettingsState(isLoadingSizes: true);

      expect(state1, isNot(equals(state2)));
    });

    test('should not equal state with different sizes list', () {
      final state1 = MenuSettingsState(sizes: [size1]);
      final state2 = MenuSettingsState(sizes: [size1, size2]);

      expect(state1, isNot(equals(state2)));
    });

    test('should preserve unchanged fields on copyWith', () {
      final original = MenuSettingsState(sizes: [size1], areas: [area1]);
      final updated = original.copyWith(isLoadingSizes: true);

      expect(updated.sizes, [size1]);
      expect(updated.areas, [area1]);
    });
  });
}
