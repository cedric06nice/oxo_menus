import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

part 'menu_collaboration_state.freezed.dart';

@freezed
abstract class MenuCollaborationState with _$MenuCollaborationState {
  const factory MenuCollaborationState({
    @Default([]) List<MenuPresence> presences,
    @Default(false) bool isReconnecting,
    @Default(false) bool isPaused,
    String? currentUserId,
  }) = _MenuCollaborationState;
}
