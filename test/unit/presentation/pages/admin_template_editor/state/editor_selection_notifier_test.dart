import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_notifier.dart';

void main() {
  group('EditorSelectionNotifier - select/deselect', () {
    late EditorSelectionNotifier notifier;

    setUp(() {
      notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {},
        saveContainerStyle: (_, _) async {},
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );
    });

    test('initial state has null selection', () {
      expect(notifier.state.selection, isNull);
    });

    test('select() sets the selection in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );

      notifier.select(selection, const StyleConfig());

      expect(notifier.state.selection, selection);
    });

    test('deselect() clears the selection in state', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier.select(selection, const StyleConfig());

      notifier.deselect();

      expect(notifier.state.selection, isNull);
    });

    test('select() with new element replaces previous selection', () {
      const first = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const second = EditorSelection(
        type: EditorElementType.column,
        id: 2,
      );

      notifier.select(first, const StyleConfig());
      notifier.select(second, const StyleConfig());

      expect(notifier.state.selection, second);
    });
  });

  group('EditorSelectionNotifier - auto-save', () {
    test('select() when previous element has modified style calls save', () {
      StyleConfig? savedStyle;
      int? savedId;

      final notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {},
        saveContainerStyle: (id, style) async {
          savedId = id;
          savedStyle = style;
        },
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );

      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier.select(selection, const StyleConfig());

      // Modify the style
      const newStyle = StyleConfig(marginTop: 20);
      notifier.updateStyle(newStyle);

      // Select a different element — triggers auto-save of previous
      const next = EditorSelection(
        type: EditorElementType.column,
        id: 10,
      );
      notifier.select(next, const StyleConfig());

      expect(savedId, 5);
      expect(savedStyle, newStyle);
    });

    test('select() when previous element has unchanged style does NOT save', () {
      bool saveCalled = false;

      final notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {},
        saveContainerStyle: (_, _) async {
          saveCalled = true;
        },
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );

      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 5,
      );
      notifier.select(selection, const StyleConfig());

      // Select a different element without modifying style
      const next = EditorSelection(
        type: EditorElementType.column,
        id: 10,
      );
      notifier.select(next, const StyleConfig());

      expect(saveCalled, isFalse);
    });

    test('deselect() saves current dirty element', () {
      StyleConfig? savedStyle;

      final notifier = EditorSelectionNotifier(
        saveMenuStyle: (style) async {
          savedStyle = style;
        },
        saveContainerStyle: (_, _) async {},
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );

      const selection = EditorSelection(
        type: EditorElementType.menu,
        id: 0,
      );
      notifier.select(selection, const StyleConfig());
      notifier.updateStyle(const StyleConfig(paddingTop: 15));
      notifier.deselect();

      expect(savedStyle, const StyleConfig(paddingTop: 15));
    });

    test('save callback receives correct id and StyleConfig for column', () {
      int? savedId;
      StyleConfig? savedStyle;

      final notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {},
        saveContainerStyle: (_, _) async {},
        saveColumnStyle: (id, style) async {
          savedId = id;
          savedStyle = style;
        },
        resolveStyle: (_) => null,
      );

      const selection = EditorSelection(
        type: EditorElementType.column,
        id: 42,
      );
      notifier.select(selection, const StyleConfig());
      notifier.updateStyle(const StyleConfig(marginLeft: 8));
      notifier.deselect();

      expect(savedId, 42);
      expect(savedStyle, const StyleConfig(marginLeft: 8));
    });

    test('updateStyle() marks the element as dirty', () {
      bool saveCalled = false;

      final notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {
          saveCalled = true;
        },
        saveContainerStyle: (_, _) async {},
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );

      const selection = EditorSelection(
        type: EditorElementType.menu,
        id: 0,
      );
      notifier.select(selection, const StyleConfig());

      // Without updateStyle, save should not be called
      notifier.deselect();
      expect(saveCalled, isFalse);

      // With updateStyle, save should be called
      notifier.select(selection, const StyleConfig());
      notifier.updateStyle(const StyleConfig(fontSize: 14));
      notifier.deselect();
      expect(saveCalled, isTrue);
    });
  });

  group('EditorSelectionNotifier - copy/paste', () {
    late EditorSelectionNotifier notifier;

    setUp(() {
      notifier = EditorSelectionNotifier(
        saveMenuStyle: (_) async {},
        saveContainerStyle: (_, _) async {},
        saveColumnStyle: (_, _) async {},
        resolveStyle: (_) => null,
      );
    });

    test('clipboard is null initially', () {
      expect(notifier.state.clipboardStyle, isNull);
    });

    test('copyStyle() stores current style in state.clipboardStyle', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const style = StyleConfig(marginTop: 10, paddingLeft: 5);
      notifier.select(selection, style);

      notifier.copyStyle();

      expect(notifier.state.clipboardStyle, style);
    });

    test('copyStyle() when no selection does nothing', () {
      notifier.copyStyle();

      expect(notifier.state.clipboardStyle, isNull);
    });

    test('pasteStyle() returns clipboard value', () {
      const selection = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const style = StyleConfig(marginTop: 10);
      notifier.select(selection, style);
      notifier.copyStyle();

      final pasted = notifier.pasteStyle();

      expect(pasted, style);
    });

    test('clipboard persists across selection changes', () {
      const first = EditorSelection(
        type: EditorElementType.container,
        id: 1,
      );
      const style = StyleConfig(marginTop: 10);
      notifier.select(first, style);
      notifier.copyStyle();

      const second = EditorSelection(
        type: EditorElementType.column,
        id: 2,
      );
      notifier.select(second, const StyleConfig());

      expect(notifier.state.clipboardStyle, style);
      expect(notifier.pasteStyle(), style);
    });
  });
}
