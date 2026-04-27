import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/admin_template_editor_screen_state.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

void main() {
  group('AdminTemplateEditorScreenState defaults', () {
    test('has sensible defaults', () {
      const state = AdminTemplateEditorScreenState();

      expect(state.isAdmin, false);
      expect(state.isLoading, true);
      expect(state.errorMessage, isNull);
      expect(state.tree, isNull);
      expect(state.selection, isNull);
      expect(state.currentStyle, isNull);
      expect(state.originalStyle, isNull);
      expect(state.clipboardStyle, isNull);
      expect(state.savingState, TemplateSavingState.idle);
    });
  });

  group('AdminTemplateEditorScreenState copyWith', () {
    test('overrides individual fields', () {
      const initial = AdminTemplateEditorScreenState();

      final next = initial.copyWith(
        isAdmin: true,
        isLoading: false,
        errorMessage: 'boom',
        savingState: TemplateSavingState.saving,
      );

      expect(next.isAdmin, true);
      expect(next.isLoading, false);
      expect(next.errorMessage, 'boom');
      expect(next.savingState, TemplateSavingState.saving);
    });

    test('clears nullable fields when explicit null is passed', () {
      const initial = AdminTemplateEditorScreenState(
        errorMessage: 'oops',
        currentStyle: StyleConfig(marginTop: 4),
        originalStyle: StyleConfig(marginTop: 0),
        clipboardStyle: StyleConfig(marginTop: 1),
        selection: EditorSelection.menu(),
      );

      final cleared = initial.copyWith(
        errorMessage: null,
        currentStyle: null,
        originalStyle: null,
        clipboardStyle: null,
        selection: null,
      );

      expect(cleared.errorMessage, isNull);
      expect(cleared.currentStyle, isNull);
      expect(cleared.originalStyle, isNull);
      expect(cleared.clipboardStyle, isNull);
      expect(cleared.selection, isNull);
    });

    test('preserves nullable fields when not passed (sentinel)', () {
      const initial = AdminTemplateEditorScreenState(
        errorMessage: 'oops',
        currentStyle: StyleConfig(marginTop: 4),
      );

      final next = initial.copyWith(isAdmin: true);

      expect(next.errorMessage, 'oops');
      expect(next.currentStyle, const StyleConfig(marginTop: 4));
    });
  });

  group('AdminTemplateEditorScreenState equality', () {
    test('equal when all fields match', () {
      const a = AdminTemplateEditorScreenState(
        isAdmin: true,
        errorMessage: 'x',
      );
      const b = AdminTemplateEditorScreenState(
        isAdmin: true,
        errorMessage: 'x',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different when isAdmin differs', () {
      const a = AdminTemplateEditorScreenState(isAdmin: true);
      const b = AdminTemplateEditorScreenState();
      expect(a == b, false);
    });

    test('different when errorMessage differs', () {
      const a = AdminTemplateEditorScreenState(errorMessage: 'x');
      const b = AdminTemplateEditorScreenState(errorMessage: 'y');
      expect(a == b, false);
    });

    test('different when savingState differs', () {
      const a = AdminTemplateEditorScreenState(
        savingState: TemplateSavingState.saving,
      );
      const b = AdminTemplateEditorScreenState();
      expect(a == b, false);
    });
  });

  group('EditorSelection', () {
    test('menu shorthand produces type=menu, id=0', () {
      const selection = EditorSelection.menu();
      expect(selection.type, EditorElementType.menu);
      expect(selection.id, 0);
    });

    test('container shorthand carries the id', () {
      const selection = EditorSelection.container(5);
      expect(selection.type, EditorElementType.container);
      expect(selection.id, 5);
    });

    test('column shorthand carries the id', () {
      const selection = EditorSelection.column(7);
      expect(selection.type, EditorElementType.column);
      expect(selection.id, 7);
    });

    test('equality compares type + id', () {
      expect(
        const EditorSelection.container(5),
        const EditorSelection(type: EditorElementType.container, id: 5),
      );
      expect(
        const EditorSelection.container(5) ==
            const EditorSelection.container(6),
        false,
      );
      expect(
        const EditorSelection.container(5) == const EditorSelection.column(5),
        false,
      );
    });
  });
}
