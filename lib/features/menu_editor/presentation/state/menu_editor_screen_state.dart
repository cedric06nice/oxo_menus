import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';

/// Saving / publishing state of the menu editor's top-level actions.
///
/// `idle` outside an explicit Save / Publish-bundles action; `saving` while
/// the header Save button is in flight; `publishingBundles` while the
/// background "Show PDF" bundle publish loop is running. Drives the disabled
/// state of those two buttons.
enum MenuSavingState { idle, saving, publishingBundles }

/// Immutable state of the migrated menu editor screen.
///
/// Combines what the legacy `editor_tree_state` + `menu_collaboration_state`
/// + `menu_settings_state` Riverpod stack covered into a single
/// sentinel-guarded `copyWith` value object the [MenuEditorViewModel] owns.
class MenuEditorScreenState {
  const MenuEditorScreenState({
    this.isLoading = true,
    this.errorMessage,
    this.tree,
    this.presences = const <MenuPresence>[],
    this.currentUserId,
    this.isReconnecting = false,
    this.isPaused = false,
    this.wsErrorCount = 0,
    this.isReloadingMenu = false,
    this.savingState = MenuSavingState.idle,
  });

  /// True while the initial load (or a connectivity-driven reload) is in
  /// flight. Subsequent CRUD calls keep this `false` so the screen doesn't
  /// flash a spinner on every save.
  final bool isLoading;

  /// Last error message surfaced by a load or CRUD failure; `null` when there
  /// is no current error.
  final String? errorMessage;

  /// Loaded menu tree. `null` until the first successful load completes.
  final EditorTreeData? tree;

  /// Active collaborators (excluding self) currently editing the same menu.
  final List<MenuPresence> presences;

  /// Auth-snapshot userId taken at construction. Used to decorate the presence
  /// bar and to decide whether a widget edit-lock applies to the current user.
  final String? currentUserId;

  /// `true` after the WebSocket subscription dropped — the banner shows a
  /// "Reconnecting..." indicator until the next event arrives.
  final bool isReconnecting;

  /// `true` after the screen / app went off-foreground or off-network — the
  /// VM cancels the WebSocket and presence timers until lifecycle restores.
  final bool isPaused;

  /// Consecutive WebSocket error count. After three consecutive errors the
  /// VM falls back to a 30s polling reload of the tree until a real change
  /// event arrives.
  final int wsErrorCount;

  /// `true` while the WS-driven reload is in flight. Used to gate concurrent
  /// reloads so two events back-to-back don't double-fetch.
  final bool isReloadingMenu;

  /// `idle` outside an explicit Save / Publish-bundles action; `saving` while
  /// the header Save button is in flight; `publishingBundles` while the
  /// background "Show PDF" bundle publish loop is running.
  final MenuSavingState savingState;

  MenuEditorScreenState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? tree = _sentinel,
    List<MenuPresence>? presences,
    Object? currentUserId = _sentinel,
    bool? isReconnecting,
    bool? isPaused,
    int? wsErrorCount,
    bool? isReloadingMenu,
    MenuSavingState? savingState,
  }) {
    return MenuEditorScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      tree: identical(tree, _sentinel) ? this.tree : tree as EditorTreeData?,
      presences: presences ?? this.presences,
      currentUserId: identical(currentUserId, _sentinel)
          ? this.currentUserId
          : currentUserId as String?,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isPaused: isPaused ?? this.isPaused,
      wsErrorCount: wsErrorCount ?? this.wsErrorCount,
      isReloadingMenu: isReloadingMenu ?? this.isReloadingMenu,
      savingState: savingState ?? this.savingState,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is MenuEditorScreenState &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      identical(other.tree, tree) &&
      _listEquals(other.presences, presences) &&
      other.currentUserId == currentUserId &&
      other.isReconnecting == isReconnecting &&
      other.isPaused == isPaused &&
      other.wsErrorCount == wsErrorCount &&
      other.isReloadingMenu == isReloadingMenu &&
      other.savingState == savingState;

  @override
  int get hashCode => Object.hash(
    isLoading,
    errorMessage,
    identityHashCode(tree),
    Object.hashAll(presences),
    currentUserId,
    isReconnecting,
    isPaused,
    wsErrorCount,
    isReloadingMenu,
    savingState,
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
