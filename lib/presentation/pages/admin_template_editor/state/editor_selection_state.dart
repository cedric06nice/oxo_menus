import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';

part 'editor_selection_state.freezed.dart';

@freezed
abstract class EditorSelectionState with _$EditorSelectionState {
  const factory EditorSelectionState({
    EditorSelection? selection,
    StyleConfig? clipboardStyle,
    StyleConfig? currentStyle,
    StyleConfig? originalStyle,
    @Default(false) bool isSaving,
  }) = _EditorSelectionState;
}
