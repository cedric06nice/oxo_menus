import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_state.dart';

class EditorSelectionNotifier extends Notifier<EditorSelectionState> {
  @override
  EditorSelectionState build() => const EditorSelectionState();

  void select(EditorSelection selection, StyleConfig? style) {
    state = state.copyWith(
      selection: selection,
      currentStyle: style,
      originalStyle: style,
    );
  }

  void deselect() {
    state = state.copyWith(
      selection: null,
      currentStyle: null,
      originalStyle: null,
    );
  }

  void updateStyle(StyleConfig style) {
    state = state.copyWith(currentStyle: style);
  }

  void copyStyle() {
    if (state.selection == null) return;
    state = state.copyWith(clipboardStyle: state.currentStyle);
  }

  StyleConfig? pasteStyle() {
    return state.clipboardStyle;
  }
}
