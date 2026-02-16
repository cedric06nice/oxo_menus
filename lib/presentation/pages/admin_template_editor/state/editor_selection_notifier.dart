import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_state.dart';

typedef SaveMenuStyleCallback = Future<void> Function(StyleConfig style);
typedef SaveElementStyleCallback =
    Future<void> Function(int id, StyleConfig style);
typedef ResolveStyleCallback = StyleConfig? Function(EditorSelection selection);

class EditorSelectionNotifier extends StateNotifier<EditorSelectionState> {
  final SaveMenuStyleCallback saveMenuStyle;
  final SaveElementStyleCallback saveContainerStyle;
  final SaveElementStyleCallback saveColumnStyle;
  final ResolveStyleCallback resolveStyle;

  StyleConfig? _originalStyle;
  StyleConfig? _currentStyle;

  EditorSelectionNotifier({
    required this.saveMenuStyle,
    required this.saveContainerStyle,
    required this.saveColumnStyle,
    required this.resolveStyle,
  }) : super(const EditorSelectionState());

  void select(EditorSelection selection, StyleConfig? style) {
    _autoSaveCurrent();
    _originalStyle = style;
    _currentStyle = style;
    state = state.copyWith(selection: selection);
  }

  void deselect() {
    _autoSaveCurrent();
    _originalStyle = null;
    _currentStyle = null;
    state = state.copyWith(selection: null);
  }

  void updateStyle(StyleConfig style) {
    _currentStyle = style;
  }

  void copyStyle() {
    if (state.selection == null) return;
    state = state.copyWith(clipboardStyle: _currentStyle);
  }

  StyleConfig? pasteStyle() {
    return state.clipboardStyle;
  }

  /// Public read access to clipboard for the side panel.
  StyleConfig? get clipboardStyle => state.clipboardStyle;

  /// Public read access to current selection.
  EditorSelection? get selection => state.selection;

  void _autoSaveCurrent() {
    final selection = state.selection;
    if (selection == null) return;
    if (_currentStyle == _originalStyle) return;
    if (_currentStyle == null) return;

    final styleToSave = _currentStyle!;
    switch (selection.type) {
      case EditorElementType.menu:
        saveMenuStyle(styleToSave);
      case EditorElementType.container:
        saveContainerStyle(selection.id, styleToSave);
      case EditorElementType.column:
        saveColumnStyle(selection.id, styleToSave);
    }
  }
}
