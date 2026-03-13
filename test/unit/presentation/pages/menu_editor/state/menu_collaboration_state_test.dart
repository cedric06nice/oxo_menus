import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/state/menu_collaboration_state.dart';

void main() {
  group('MenuCollaborationState', () {
    test('should have correct default values', () {
      const state = MenuCollaborationState();

      expect(state.presences, isEmpty);
      expect(state.isReconnecting, false);
      expect(state.isPaused, false);
      expect(state.currentUserId, isNull);
      expect(state.wsErrorCount, 0);
      expect(state.isLoadingMenu, false);
    });

    test('should support copyWith for new fields', () {
      const state = MenuCollaborationState();

      final updated = state.copyWith(wsErrorCount: 3, isLoadingMenu: true);

      expect(updated.wsErrorCount, 3);
      expect(updated.isLoadingMenu, true);
    });

    test('should support equality', () {
      const state1 = MenuCollaborationState();
      const state2 = MenuCollaborationState();

      expect(state1, equals(state2));
    });
  });
}
