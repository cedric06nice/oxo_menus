import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  EditorSelectionNotifier notifier() =>
      container.read(editorSelectionProvider.notifier);

  EditorSelectionState state() => container.read(editorSelectionProvider);

  group('EditorSelectionNotifier - select/deselect', () {
    test('initial state has null selection', () {
      expect(state().selection, isNull);
    });

    test('select() sets the selection in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );

      notifier().select(selection, const StyleConfig());

      expect(state().selection, selection);
    });

    test('deselect() clears the selection in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier().select(selection, const StyleConfig());

      notifier().deselect();

      expect(state().selection, isNull);
    });

    test('select() with new element replaces previous selection', () {
      const first = EditorSelection(type: EditorElementType.container, id: 1);
      const second = EditorSelection(type: EditorElementType.column, id: 2);

      notifier().select(first, const StyleConfig());
      notifier().select(second, const StyleConfig());

      expect(state().selection, second);
    });

    test('select() stores the style as currentStyle in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      const style = StyleConfig(marginTop: 10);

      notifier().select(selection, style);

      expect(state().currentStyle, style);
    });

    test('select() stores the style as originalStyle in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      const style = StyleConfig(marginTop: 10);

      notifier().select(selection, style);

      expect(state().originalStyle, style);
    });

    test('deselect() clears currentStyle and originalStyle', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier().select(selection, const StyleConfig(marginTop: 10));

      notifier().deselect();

      expect(state().currentStyle, isNull);
      expect(state().originalStyle, isNull);
    });
  });

  group('EditorSelectionNotifier - updateStyle', () {
    test('updateStyle() updates currentStyle in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier().select(selection, const StyleConfig());

      const newStyle = StyleConfig(marginTop: 20);
      notifier().updateStyle(newStyle);

      expect(state().currentStyle, newStyle);
    });

    test('updateStyle() does not change originalStyle', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      const originalStyle = StyleConfig(marginTop: 10);
      notifier().select(selection, originalStyle);

      notifier().updateStyle(const StyleConfig(marginTop: 20));

      expect(state().originalStyle, originalStyle);
    });
  });

  group('EditorSelectionNotifier - copy/paste', () {
    test('clipboard is null initially', () {
      expect(state().clipboardStyle, isNull);
    });

    test('copyStyle() stores current style in state.clipboardStyle', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const style = StyleConfig(marginTop: 10, paddingLeft: 5);
      notifier().select(selection, style);

      notifier().copyStyle();

      expect(state().clipboardStyle, style);
    });

    test('copyStyle() when no selection does nothing', () {
      notifier().copyStyle();

      expect(state().clipboardStyle, isNull);
    });

    test('pasteStyle() returns clipboard value', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const style = StyleConfig(marginTop: 10);
      notifier().select(selection, style);
      notifier().copyStyle();

      final pasted = notifier().pasteStyle();

      expect(pasted, style);
    });

    test('clipboard persists across selection changes', () {
      const first = EditorSelection(type: EditorElementType.container, id: 1);
      const style = StyleConfig(marginTop: 10);
      notifier().select(first, style);
      notifier().copyStyle();

      const second = EditorSelection(type: EditorElementType.column, id: 2);
      notifier().select(second, const StyleConfig());

      expect(state().clipboardStyle, style);
      expect(notifier().pasteStyle(), style);
    });

    test('copyStyle() copies updated style after updateStyle()', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      notifier().select(selection, const StyleConfig());
      notifier().updateStyle(const StyleConfig(fontSize: 14));

      notifier().copyStyle();

      expect(state().clipboardStyle, const StyleConfig(fontSize: 14));
    });
  });
}
