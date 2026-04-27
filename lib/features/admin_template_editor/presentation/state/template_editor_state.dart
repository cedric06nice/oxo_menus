import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_editor_state.freezed.dart';

@freezed
abstract class TemplateEditorState with _$TemplateEditorState {
  const factory TemplateEditorState({@Default(false) bool isSaving}) =
      _TemplateEditorState;
}
