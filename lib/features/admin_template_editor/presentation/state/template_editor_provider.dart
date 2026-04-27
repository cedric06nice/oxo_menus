import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/template_editor_notifier.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/template_editor_state.dart';

final templateEditorProvider =
    NotifierProvider.family<TemplateEditorNotifier, TemplateEditorState, int>(
      TemplateEditorNotifier.new,
    );
