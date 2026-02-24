// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_presence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuPresence {

 int get id; String get userId; int get menuId; DateTime get lastSeen; String? get userName;
/// Create a copy of MenuPresence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPresenceCopyWith<MenuPresence> get copyWith => _$MenuPresenceCopyWithImpl<MenuPresence>(this as MenuPresence, _$identity);

  /// Serializes this MenuPresence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPresence&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,menuId,lastSeen,userName);

@override
String toString() {
  return 'MenuPresence(id: $id, userId: $userId, menuId: $menuId, lastSeen: $lastSeen, userName: $userName)';
}


}

/// @nodoc
abstract mixin class $MenuPresenceCopyWith<$Res>  {
  factory $MenuPresenceCopyWith(MenuPresence value, $Res Function(MenuPresence) _then) = _$MenuPresenceCopyWithImpl;
@useResult
$Res call({
 int id, String userId, int menuId, DateTime lastSeen, String? userName
});




}
/// @nodoc
class _$MenuPresenceCopyWithImpl<$Res>
    implements $MenuPresenceCopyWith<$Res> {
  _$MenuPresenceCopyWithImpl(this._self, this._then);

  final MenuPresence _self;
  final $Res Function(MenuPresence) _then;

/// Create a copy of MenuPresence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? menuId = null,Object? lastSeen = null,Object? userName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as int,lastSeen: null == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPresence].
extension MenuPresencePatterns on MenuPresence {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPresence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPresence() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPresence value)  $default,){
final _that = this;
switch (_that) {
case _MenuPresence():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPresence value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPresence() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String userId,  int menuId,  DateTime lastSeen,  String? userName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPresence() when $default != null:
return $default(_that.id,_that.userId,_that.menuId,_that.lastSeen,_that.userName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String userId,  int menuId,  DateTime lastSeen,  String? userName)  $default,) {final _that = this;
switch (_that) {
case _MenuPresence():
return $default(_that.id,_that.userId,_that.menuId,_that.lastSeen,_that.userName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String userId,  int menuId,  DateTime lastSeen,  String? userName)?  $default,) {final _that = this;
switch (_that) {
case _MenuPresence() when $default != null:
return $default(_that.id,_that.userId,_that.menuId,_that.lastSeen,_that.userName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuPresence extends MenuPresence {
  const _MenuPresence({required this.id, required this.userId, required this.menuId, required this.lastSeen, this.userName}): super._();
  factory _MenuPresence.fromJson(Map<String, dynamic> json) => _$MenuPresenceFromJson(json);

@override final  int id;
@override final  String userId;
@override final  int menuId;
@override final  DateTime lastSeen;
@override final  String? userName;

/// Create a copy of MenuPresence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPresenceCopyWith<_MenuPresence> get copyWith => __$MenuPresenceCopyWithImpl<_MenuPresence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuPresenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPresence&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.userName, userName) || other.userName == userName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,menuId,lastSeen,userName);

@override
String toString() {
  return 'MenuPresence(id: $id, userId: $userId, menuId: $menuId, lastSeen: $lastSeen, userName: $userName)';
}


}

/// @nodoc
abstract mixin class _$MenuPresenceCopyWith<$Res> implements $MenuPresenceCopyWith<$Res> {
  factory _$MenuPresenceCopyWith(_MenuPresence value, $Res Function(_MenuPresence) _then) = __$MenuPresenceCopyWithImpl;
@override @useResult
$Res call({
 int id, String userId, int menuId, DateTime lastSeen, String? userName
});




}
/// @nodoc
class __$MenuPresenceCopyWithImpl<$Res>
    implements _$MenuPresenceCopyWith<$Res> {
  __$MenuPresenceCopyWithImpl(this._self, this._then);

  final _MenuPresence _self;
  final $Res Function(_MenuPresence) _then;

/// Create a copy of MenuPresence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? menuId = null,Object? lastSeen = null,Object? userName = freezed,}) {
  return _then(_MenuPresence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as int,lastSeen: null == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
