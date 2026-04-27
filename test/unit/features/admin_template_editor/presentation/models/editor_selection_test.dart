import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/models/editor_selection.dart';

void main() {
  group('EditorElementType', () {
    test('has 3 values: menu, container, column', () {
      expect(EditorElementType.values, hasLength(3));
      expect(EditorElementType.values, contains(EditorElementType.menu));
      expect(EditorElementType.values, contains(EditorElementType.container));
      expect(EditorElementType.values, contains(EditorElementType.column));
    });
  });

  group('EditorSelection', () {
    test('can be constructed with type and id', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 42,
      );

      expect(selection.type, EditorElementType.container);
      expect(selection.id, 42);
    });

    test('two selections with same type and id are equal', () {
      const a = EditorSelection(type: EditorElementType.column, id: 7);
      const b = EditorSelection(type: EditorElementType.column, id: 7);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two selections with different type are not equal', () {
      const a = EditorSelection(type: EditorElementType.container, id: 7);
      const b = EditorSelection(type: EditorElementType.column, id: 7);

      expect(a, isNot(equals(b)));
    });

    test('two selections with different id are not equal', () {
      const a = EditorSelection(type: EditorElementType.container, id: 1);
      const b = EditorSelection(type: EditorElementType.container, id: 2);

      expect(a, isNot(equals(b)));
    });
  });
}
