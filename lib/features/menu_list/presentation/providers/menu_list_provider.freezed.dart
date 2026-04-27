// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_list_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuListState {

 List<Menu> get menus; bool get isLoading; String? get errorMessage;
/// Create a copy of MenuListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuListStateCopyWith<MenuListState> get copyWith => _$MenuListStateCopyWithImpl<MenuListState>(this as MenuListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuListState&&const DeepCollectionEquality().equals(other.menus, menus)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(menus),isLoading,errorMessage);

@override
String toString() {
  return 'MenuListState(menus: $menus, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MenuListStateCopyWith<$Res>  {
  factory $MenuListStateCopyWith(MenuListState value, $Res Function(MenuListState) _then) = _$MenuListStateCopyWithImpl;
@useResult
$Res call({
 List<Menu> menus, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$MenuListStateCopyWithImpl<$Res>
    implements $MenuListStateCopyWith<$Res> {
  _$MenuListStateCopyWithImpl(this._self, this._then);

  final MenuListState _self;
  final $Res Function(MenuListState) _then;

/// Create a copy of MenuListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menus = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
menus: null == menus ? _self.menus : menus // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuListState].
extension MenuListStatePatterns on MenuListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuListState value)  $default,){
final _that = this;
switch (_that) {
case _MenuListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuListState value)?  $default,){
final _that = this;
switch (_that) {
case _MenuListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Menu> menus,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuListState() when $default != null:
return $default(_that.menus,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Menu> menus,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MenuListState():
return $default(_that.menus,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Menu> menus,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MenuListState() when $default != null:
return $default(_that.menus,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MenuListState implements MenuListState {
  const _MenuListState({final  List<Menu> menus = const [], this.isLoading = false, this.errorMessage}): _menus = menus;
  

 final  List<Menu> _menus;
@override@JsonKey() List<Menu> get menus {
  if (_menus is EqualUnmodifiableListView) return _menus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_menus);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of MenuListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuListStateCopyWith<_MenuListState> get copyWith => __$MenuListStateCopyWithImpl<_MenuListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuListState&&const DeepCollectionEquality().equals(other._menus, _menus)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_menus),isLoading,errorMessage);

@override
String toString() {
  return 'MenuListState(menus: $menus, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MenuListStateCopyWith<$Res> implements $MenuListStateCopyWith<$Res> {
  factory _$MenuListStateCopyWith(_MenuListState value, $Res Function(_MenuListState) _then) = __$MenuListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Menu> menus, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$MenuListStateCopyWithImpl<$Res>
    implements _$MenuListStateCopyWith<$Res> {
  __$MenuListStateCopyWithImpl(this._self, this._then);

  final _MenuListState _self;
  final $Res Function(_MenuListState) _then;

/// Create a copy of MenuListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menus = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_MenuListState(
menus: null == menus ? _self._menus : menus // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
