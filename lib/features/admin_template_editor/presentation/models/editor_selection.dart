import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_selection.freezed.dart';

enum EditorElementType { menu, container, column }

@freezed
abstract class EditorSelection with _$EditorSelection {
  const factory EditorSelection({
    required EditorElementType type,
    required int id,
  }) = _EditorSelection;
}
