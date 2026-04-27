import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection_notifier.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection_state.dart';

final editorSelectionProvider =
    NotifierProvider<EditorSelectionNotifier, EditorSelectionState>(
      EditorSelectionNotifier.new,
    );
