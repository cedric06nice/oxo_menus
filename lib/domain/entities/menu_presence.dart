import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_presence.freezed.dart';
part 'menu_presence.g.dart';

/// Represents an active user's presence on a menu editing session.
@freezed
abstract class MenuPresence with _$MenuPresence {
  const MenuPresence._();

  const factory MenuPresence({
    required int id,
    required String userId,
    required int menuId,
    required DateTime lastSeen,
    String? userName,
    String? userAvatar,
  }) = _MenuPresence;

  factory MenuPresence.fromJson(Map<String, dynamic> json) =>
      _$MenuPresenceFromJson(json);
}
