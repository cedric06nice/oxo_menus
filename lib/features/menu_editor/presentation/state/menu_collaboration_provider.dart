import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_collaboration_notifier.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_collaboration_state.dart';

final menuCollaborationProvider =
    NotifierProvider.family<
      MenuCollaborationNotifier,
      MenuCollaborationState,
      int
    >(MenuCollaborationNotifier.new);
