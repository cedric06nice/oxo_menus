import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_editor_screen_state.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

const _menu = Menu(id: 1, name: 'Menu', version: '1', status: Status.draft);
final _tree = EditorTreeData(
  menu: _menu,
  pages: const [],
  headerPage: null,
  footerPage: null,
  containers: const {},
  childContainers: const {},
  columns: const {},
  widgets: const {},
);

final _presence = MenuPresence(
  id: 1,
  menuId: 1,
  userId: 'u-1',
  lastSeen: DateTime.utc(2026, 4, 27),
);

void main() {
  group('MenuEditorScreenState — defaults', () {
    test('default constructor returns sensible idle values', () {
      const state = MenuEditorScreenState();

      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.tree, isNull);
      expect(state.presences, isEmpty);
      expect(state.currentUserId, isNull);
      expect(state.isReconnecting, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.wsErrorCount, 0);
      expect(state.isReloadingMenu, isFalse);
      expect(state.savingState, MenuSavingState.idle);
    });
  });

  group('MenuEditorScreenState — equality', () {
    test('two identically-built states are equal and share a hashCode', () {
      const a = MenuEditorScreenState(currentUserId: 'u-1');
      const b = MenuEditorScreenState(currentUserId: 'u-1');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('changing each scalar breaks equality', () {
      const base = MenuEditorScreenState();

      expect(base, isNot(equals(base.copyWith(isLoading: false))));
      expect(base, isNot(equals(base.copyWith(errorMessage: 'oops'))));
      expect(base, isNot(equals(base.copyWith(currentUserId: 'u-1'))));
      expect(base, isNot(equals(base.copyWith(isReconnecting: true))));
      expect(base, isNot(equals(base.copyWith(isPaused: true))));
      expect(base, isNot(equals(base.copyWith(wsErrorCount: 1))));
      expect(base, isNot(equals(base.copyWith(isReloadingMenu: true))));
      expect(
        base,
        isNot(equals(base.copyWith(savingState: MenuSavingState.saving))),
      );
    });
  });

  group('MenuEditorScreenState — copyWith null sentinel', () {
    test('explicit null clears errorMessage', () {
      const start = MenuEditorScreenState(errorMessage: 'oops');

      final cleared = start.copyWith(errorMessage: null);

      expect(cleared.errorMessage, isNull);
    });

    test('explicit null clears currentUserId', () {
      const start = MenuEditorScreenState(currentUserId: 'u-1');

      final cleared = start.copyWith(currentUserId: null);

      expect(cleared.currentUserId, isNull);
    });

    test('explicit null clears tree', () {
      final start = const MenuEditorScreenState().copyWith(tree: _tree);

      final cleared = start.copyWith(tree: null);

      expect(cleared.tree, isNull);
    });

    test('omitting fields preserves the previous values', () {
      const start = MenuEditorScreenState(
        errorMessage: 'oops',
        currentUserId: 'u-1',
      );

      final next = start.copyWith();

      expect(next.errorMessage, 'oops');
      expect(next.currentUserId, 'u-1');
    });
  });

  group('MenuEditorScreenState — presences equality', () {
    test('list-equality breaks when contents differ', () {
      const empty = MenuEditorScreenState();
      final populated = empty.copyWith(presences: [_presence]);

      expect(empty, isNot(equals(populated)));
    });
  });
}
