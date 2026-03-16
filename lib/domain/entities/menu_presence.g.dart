// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_presence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuPresence _$MenuPresenceFromJson(Map<String, dynamic> json) =>
    _MenuPresence(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      menuId: (json['menuId'] as num).toInt(),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
    );

Map<String, dynamic> _$MenuPresenceToJson(_MenuPresence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'menuId': instance.menuId,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
    };
