import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_notifier.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_state.dart';

final editorTreeProvider =
    NotifierProvider.family<EditorTreeNotifier, EditorTreeState, int>(
      EditorTreeNotifier.new,
    );
