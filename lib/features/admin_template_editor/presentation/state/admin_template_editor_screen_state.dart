import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection.dart';
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

/// Saving / publishing state of the editor's top-level actions.
enum TemplateSavingState { idle, saving, publishing }

/// Immutable state of the migrated admin template editor screen.
///
/// Mirrors the legacy `editor_tree_state` + `template_editor_state` +
/// `editor_selection_state` Riverpod stack as a single sentinel-guarded
/// `copyWith` value object. The view model owns it and replays it through the
/// `ChangeNotifier` mechanism inherited from `ViewModel`.
class AdminTemplateEditorScreenState {
  const AdminTemplateEditorScreenState({
    this.isAdmin = false,
    this.isLoading = true,
    this.errorMessage,
    this.tree,
    this.selection,
    this.currentStyle,
    this.originalStyle,
    this.clipboardStyle,
    this.savingState = TemplateSavingState.idle,
  });

  /// `true` when the viewer is an admin. Mirrors the auth gateway snapshot at
  /// VM construction time.
  final bool isAdmin;

  /// True while the initial load (or a connectivity-driven reload) is in
  /// flight. Subsequent CRUD calls keep this `false` so the screen doesn't
  /// flash a spinner on every save.
  final bool isLoading;

  /// Last error message surfaced by a load or CRUD failure; `null` when there
  /// is no current error.
  final String? errorMessage;

  /// Loaded editor tree. `null` until the first successful load completes.
  final EditorTreeData? tree;

  /// Currently selected element for the side-panel style editor.
  final EditorSelection? selection;

  /// Live style being edited in the side panel — updates between debounce
  /// flushes use this value, persisted writes consume it.
  final StyleConfig? currentStyle;

  /// Style snapshot at the moment the selection was made. Used by the dirty
  /// check that decides whether a debounce flush should issue a persistence
  /// call.
  final StyleConfig? originalStyle;

  /// Last copied style. Survives selection changes so the user can paste from
  /// one element to the next.
  final StyleConfig? clipboardStyle;

  /// `idle` outside an explicit Save / Publish action; `saving` while the
  /// header Save button is in flight; `publishing` while Publish is in flight.
  /// Drives the disabled state of those two buttons.
  final TemplateSavingState savingState;

  AdminTemplateEditorScreenState copyWith({
    bool? isAdmin,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? tree = _sentinel,
    Object? selection = _sentinel,
    Object? currentStyle = _sentinel,
    Object? originalStyle = _sentinel,
    Object? clipboardStyle = _sentinel,
    TemplateSavingState? savingState,
  }) {
    return AdminTemplateEditorScreenState(
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      tree: identical(tree, _sentinel) ? this.tree : tree as EditorTreeData?,
      selection: identical(selection, _sentinel)
          ? this.selection
          : selection as EditorSelection?,
      currentStyle: identical(currentStyle, _sentinel)
          ? this.currentStyle
          : currentStyle as StyleConfig?,
      originalStyle: identical(originalStyle, _sentinel)
          ? this.originalStyle
          : originalStyle as StyleConfig?,
      clipboardStyle: identical(clipboardStyle, _sentinel)
          ? this.clipboardStyle
          : clipboardStyle as StyleConfig?,
      savingState: savingState ?? this.savingState,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is AdminTemplateEditorScreenState &&
      other.isAdmin == isAdmin &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      identical(other.tree, tree) &&
      other.selection == selection &&
      other.currentStyle == currentStyle &&
      other.originalStyle == originalStyle &&
      other.clipboardStyle == clipboardStyle &&
      other.savingState == savingState;

  @override
  int get hashCode => Object.hash(
    isAdmin,
    isLoading,
    errorMessage,
    identityHashCode(tree),
    selection,
    currentStyle,
    originalStyle,
    clipboardStyle,
    savingState,
  );
}
