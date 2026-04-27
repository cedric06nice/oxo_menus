import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/state/admin_exportable_menus_screen_state.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

const _bundle = MenuBundle(id: 1, name: 'Lunch', menuIds: [10]);
const _menu = Menu(id: 10, name: 'Lunch', status: Status.draft, version: '1');

void main() {
  group('AdminExportableMenusScreenState — defaults', () {
    test('default state matches the pre-load snapshot', () {
      const state = AdminExportableMenusScreenState();

      expect(state.isAdmin, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.bundles, isEmpty);
      expect(state.availableMenus, isEmpty);
      expect(state.publishingBundleIds, isEmpty);
    });
  });

  group('AdminExportableMenusScreenState — equality', () {
    test('two equal states compare equal and share a hashCode', () {
      const a = AdminExportableMenusScreenState(
        isAdmin: true,
        isLoading: false,
        bundles: [_bundle],
        availableMenus: [_menu],
        publishingBundleIds: {1},
      );
      const b = AdminExportableMenusScreenState(
        isAdmin: true,
        isLoading: false,
        bundles: [_bundle],
        availableMenus: [_menu],
        publishingBundleIds: {1},
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('changing each scalar field breaks equality', () {
      const base = AdminExportableMenusScreenState();

      expect(base, isNot(base.copyWith(isAdmin: true)));
      expect(base, isNot(base.copyWith(isLoading: false)));
      expect(base, isNot(base.copyWith(errorMessage: 'oops')));
    });

    test('list and set equality compare element-by-element', () {
      const a = AdminExportableMenusScreenState(bundles: [_bundle]);
      const b = AdminExportableMenusScreenState(bundles: [_bundle]);
      const c = AdminExportableMenusScreenState(bundles: <MenuBundle>[]);

      expect(a, b);
      expect(a, isNot(c));

      const d = AdminExportableMenusScreenState(availableMenus: [_menu]);
      const e = AdminExportableMenusScreenState(availableMenus: [_menu]);
      const f = AdminExportableMenusScreenState(availableMenus: <Menu>[]);

      expect(d, e);
      expect(d, isNot(f));

      const g = AdminExportableMenusScreenState(publishingBundleIds: {1});
      const h = AdminExportableMenusScreenState(publishingBundleIds: {1});
      const i = AdminExportableMenusScreenState(
        publishingBundleIds: <int>{},
      );

      expect(g, h);
      expect(g, isNot(i));
    });
  });

  group('AdminExportableMenusScreenState — copyWith', () {
    test('returns identical state when no overrides are passed', () {
      const state = AdminExportableMenusScreenState(
        isAdmin: true,
        bundles: [_bundle],
        errorMessage: 'oops',
      );

      expect(state.copyWith(), state);
    });

    test('null sentinel — explicit null clears errorMessage', () {
      const base = AdminExportableMenusScreenState(errorMessage: 'oops');

      expect(base.copyWith(errorMessage: null).errorMessage, isNull);
    });

    test('omitting nullable fields preserves the previous values', () {
      const base = AdminExportableMenusScreenState(
        errorMessage: 'oops',
        bundles: [_bundle],
      );

      final copy = base.copyWith(isLoading: false);

      expect(copy.errorMessage, 'oops');
      expect(copy.bundles, [_bundle]);
      expect(copy.isLoading, isFalse);
    });

    test('replaces collections when explicit overrides are passed', () {
      const base = AdminExportableMenusScreenState(bundles: [_bundle]);

      final copy = base.copyWith(bundles: const <MenuBundle>[]);

      expect(copy.bundles, isEmpty);
    });
  });
}
