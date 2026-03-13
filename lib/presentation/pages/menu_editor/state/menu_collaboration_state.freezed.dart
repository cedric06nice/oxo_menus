// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_collaboration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuCollaborationState {

 List<MenuPresence> get presences; bool get isReconnecting; bool get isPaused; String? get currentUserId;
/// Create a copy of MenuCollaborationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuCollaborationStateCopyWith<MenuCollaborationState> get copyWith => _$MenuCollaborationStateCopyWithImpl<MenuCollaborationState>(this as MenuCollaborationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuCollaborationState&&const DeepCollectionEquality().equals(other.presences, presences)&&(identical(other.isReconnecting, isReconnecting) || other.isReconnecting == isReconnecting)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(presences),isReconnecting,isPaused,currentUserId);

@override
String toString() {
  return 'MenuCollaborationState(presences: $presences, isReconnecting: $isReconnecting, isPaused: $isPaused, currentUserId: $currentUserId)';
}


}

/// @nodoc
abstract mixin class $MenuCollaborationStateCopyWith<$Res>  {
  factory $MenuCollaborationStateCopyWith(MenuCollaborationState value, $Res Function(MenuCollaborationState) _then) = _$MenuCollaborationStateCopyWithImpl;
@useResult
$Res call({
 List<MenuPresence> presences, bool isReconnecting, bool isPaused, String? currentUserId
});




}
/// @nodoc
class _$MenuCollaborationStateCopyWithImpl<$Res>
    implements $MenuCollaborationStateCopyWith<$Res> {
  _$MenuCollaborationStateCopyWithImpl(this._self, this._then);

  final MenuCollaborationState _self;
  final $Res Function(MenuCollaborationState) _then;

/// Create a copy of MenuCollaborationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? presences = null,Object? isReconnecting = null,Object? isPaused = null,Object? currentUserId = freezed,}) {
  return _then(_self.copyWith(
presences: null == presences ? _self.presences : presences // ignore: cast_nullable_to_non_nullable
as List<MenuPresence>,isReconnecting: null == isReconnecting ? _self.isReconnecting : isReconnecting // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentUserId: freezed == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuCollaborationState].
extension MenuCollaborationStatePatterns on MenuCollaborationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuCollaborationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuCollaborationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuCollaborationState value)  $default,){
final _that = this;
switch (_that) {
case _MenuCollaborationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuCollaborationState value)?  $default,){
final _that = this;
switch (_that) {
case _MenuCollaborationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MenuPresence> presences,  bool isReconnecting,  bool isPaused,  String? currentUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuCollaborationState() when $default != null:
return $default(_that.presences,_that.isReconnecting,_that.isPaused,_that.currentUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MenuPresence> presences,  bool isReconnecting,  bool isPaused,  String? currentUserId)  $default,) {final _that = this;
switch (_that) {
case _MenuCollaborationState():
return $default(_that.presences,_that.isReconnecting,_that.isPaused,_that.currentUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MenuPresence> presences,  bool isReconnecting,  bool isPaused,  String? currentUserId)?  $default,) {final _that = this;
switch (_that) {
case _MenuCollaborationState() when $default != null:
return $default(_that.presences,_that.isReconnecting,_that.isPaused,_that.currentUserId);case _:
  return null;

}
}

}

/// @nodoc


class _MenuCollaborationState implements MenuCollaborationState {
  const _MenuCollaborationState({final  List<MenuPresence> presences = const [], this.isReconnecting = false, this.isPaused = false, this.currentUserId}): _presences = presences;
  

 final  List<MenuPresence> _presences;
@override@JsonKey() List<MenuPresence> get presences {
  if (_presences is EqualUnmodifiableListView) return _presences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presences);
}

@override@JsonKey() final  bool isReconnecting;
@override@JsonKey() final  bool isPaused;
@override final  String? currentUserId;

/// Create a copy of MenuCollaborationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuCollaborationStateCopyWith<_MenuCollaborationState> get copyWith => __$MenuCollaborationStateCopyWithImpl<_MenuCollaborationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuCollaborationState&&const DeepCollectionEquality().equals(other._presences, _presences)&&(identical(other.isReconnecting, isReconnecting) || other.isReconnecting == isReconnecting)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_presences),isReconnecting,isPaused,currentUserId);

@override
String toString() {
  return 'MenuCollaborationState(presences: $presences, isReconnecting: $isReconnecting, isPaused: $isPaused, currentUserId: $currentUserId)';
}


}

/// @nodoc
abstract mixin class _$MenuCollaborationStateCopyWith<$Res> implements $MenuCollaborationStateCopyWith<$Res> {
  factory _$MenuCollaborationStateCopyWith(_MenuCollaborationState value, $Res Function(_MenuCollaborationState) _then) = __$MenuCollaborationStateCopyWithImpl;
@override @useResult
$Res call({
 List<MenuPresence> presences, bool isReconnecting, bool isPaused, String? currentUserId
});




}
/// @nodoc
class __$MenuCollaborationStateCopyWithImpl<$Res>
    implements _$MenuCollaborationStateCopyWith<$Res> {
  __$MenuCollaborationStateCopyWithImpl(this._self, this._then);

  final _MenuCollaborationState _self;
  final $Res Function(_MenuCollaborationState) _then;

/// Create a copy of MenuCollaborationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? presences = null,Object? isReconnecting = null,Object? isPaused = null,Object? currentUserId = freezed,}) {
  return _then(_MenuCollaborationState(
presences: null == presences ? _self._presences : presences // ignore: cast_nullable_to_non_nullable
as List<MenuPresence>,isReconnecting: null == isReconnecting ? _self.isReconnecting : isReconnecting // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,currentUserId: freezed == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
