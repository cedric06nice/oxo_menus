import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_state.dart';

void main() {
  group('EditorSelectionState', () {
    test('default state has null selection, null clipboardStyle, isSaving false',
        () {
      const state = EditorSelectionState();

      expect(state.selection, isNull);
      expect(state.clipboardStyle, isNull);
      expect(state.isSaving, isFalse);
    });

    test('copyWith works for selection', () {
      const state = EditorSelectionState();
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );

      final updated = state.copyWith(selection: selection);

      expect(updated.selection, selection);
      expect(updated.clipboardStyle, isNull);
      expect(updated.isSaving, isFalse);
    });

    test('copyWith works for clipboardStyle', () {
      const state = EditorSelectionState();
      const style = StyleConfig(marginTop: 10);

      final updated = state.copyWith(clipboardStyle: style);

      expect(updated.clipboardStyle, style);
      expect(updated.selection, isNull);
    });

    test('copyWith works for isSaving', () {
      const state = EditorSelectionState();

      final updated = state.copyWith(isSaving: true);

      expect(updated.isSaving, isTrue);
    });
  });
}
