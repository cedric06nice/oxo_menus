/// Element types selectable in the template editor's side panel.
enum EditorElementType { menu, container, column }

/// Describes the editor element currently selected for style editing.
///
/// `EditorSelection` is a tiny value object owned by
/// [AdminTemplateEditorScreenState]. The `id` field is `0` for the special
/// menu-level selection (since the editor only ever has one menu loaded) and
/// the actual entity id for container / column selections.
class EditorSelection {
  const EditorSelection({required this.type, required this.id});

  const EditorSelection.menu() : type = EditorElementType.menu, id = 0;
  const EditorSelection.container(this.id) : type = EditorElementType.container;
  const EditorSelection.column(this.id) : type = EditorElementType.column;

  final EditorElementType type;
  final int id;

  @override
  bool operator ==(Object other) =>
      other is EditorSelection && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'EditorSelection(type: $type, id: $id)';
}
