// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
  avatar: json['avatar'] as String?,
  areas:
      (json['areas'] as List<dynamic>?)
          ?.map((e) => Area.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'role': _$UserRoleEnumMap[instance.role],
  'avatar': instance.avatar,
  'areas': instance.areas,
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.user: 'user'};
