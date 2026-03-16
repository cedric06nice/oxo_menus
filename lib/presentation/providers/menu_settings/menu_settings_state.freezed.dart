// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuSettingsState {

 List<Size> get sizes; List<Area> get areas; bool get isLoadingSizes; bool get isLoadingAreas; String? get errorMessage;
/// Create a copy of MenuSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuSettingsStateCopyWith<MenuSettingsState> get copyWith => _$MenuSettingsStateCopyWithImpl<MenuSettingsState>(this as MenuSettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuSettingsState&&const DeepCollectionEquality().equals(other.sizes, sizes)&&const DeepCollectionEquality().equals(other.areas, areas)&&(identical(other.isLoadingSizes, isLoadingSizes) || other.isLoadingSizes == isLoadingSizes)&&(identical(other.isLoadingAreas, isLoadingAreas) || other.isLoadingAreas == isLoadingAreas)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sizes),const DeepCollectionEquality().hash(areas),isLoadingSizes,isLoadingAreas,errorMessage);

@override
String toString() {
  return 'MenuSettingsState(sizes: $sizes, areas: $areas, isLoadingSizes: $isLoadingSizes, isLoadingAreas: $isLoadingAreas, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MenuSettingsStateCopyWith<$Res>  {
  factory $MenuSettingsStateCopyWith(MenuSettingsState value, $Res Function(MenuSettingsState) _then) = _$MenuSettingsStateCopyWithImpl;
@useResult
$Res call({
 List<Size> sizes, List<Area> areas, bool isLoadingSizes, bool isLoadingAreas, String? errorMessage
});




}
/// @nodoc
class _$MenuSettingsStateCopyWithImpl<$Res>
    implements $MenuSettingsStateCopyWith<$Res> {
  _$MenuSettingsStateCopyWithImpl(this._self, this._then);

  final MenuSettingsState _self;
  final $Res Function(MenuSettingsState) _then;

/// Create a copy of MenuSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sizes = null,Object? areas = null,Object? isLoadingSizes = null,Object? isLoadingAreas = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
sizes: null == sizes ? _self.sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<Size>,areas: null == areas ? _self.areas : areas // ignore: cast_nullable_to_non_nullable
as List<Area>,isLoadingSizes: null == isLoadingSizes ? _self.isLoadingSizes : isLoadingSizes // ignore: cast_nullable_to_non_nullable
as bool,isLoadingAreas: null == isLoadingAreas ? _self.isLoadingAreas : isLoadingAreas // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuSettingsState].
extension MenuSettingsStatePatterns on MenuSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuSettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _MenuSettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _MenuSettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Size> sizes,  List<Area> areas,  bool isLoadingSizes,  bool isLoadingAreas,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuSettingsState() when $default != null:
return $default(_that.sizes,_that.areas,_that.isLoadingSizes,_that.isLoadingAreas,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Size> sizes,  List<Area> areas,  bool isLoadingSizes,  bool isLoadingAreas,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MenuSettingsState():
return $default(_that.sizes,_that.areas,_that.isLoadingSizes,_that.isLoadingAreas,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Size> sizes,  List<Area> areas,  bool isLoadingSizes,  bool isLoadingAreas,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MenuSettingsState() when $default != null:
return $default(_that.sizes,_that.areas,_that.isLoadingSizes,_that.isLoadingAreas,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MenuSettingsState extends MenuSettingsState {
  const _MenuSettingsState({final  List<Size> sizes = const [], final  List<Area> areas = const [], this.isLoadingSizes = false, this.isLoadingAreas = false, this.errorMessage}): _sizes = sizes,_areas = areas,super._();
  

 final  List<Size> _sizes;
@override@JsonKey() List<Size> get sizes {
  if (_sizes is EqualUnmodifiableListView) return _sizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sizes);
}

 final  List<Area> _areas;
@override@JsonKey() List<Area> get areas {
  if (_areas is EqualUnmodifiableListView) return _areas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_areas);
}

@override@JsonKey() final  bool isLoadingSizes;
@override@JsonKey() final  bool isLoadingAreas;
@override final  String? errorMessage;

/// Create a copy of MenuSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuSettingsStateCopyWith<_MenuSettingsState> get copyWith => __$MenuSettingsStateCopyWithImpl<_MenuSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuSettingsState&&const DeepCollectionEquality().equals(other._sizes, _sizes)&&const DeepCollectionEquality().equals(other._areas, _areas)&&(identical(other.isLoadingSizes, isLoadingSizes) || other.isLoadingSizes == isLoadingSizes)&&(identical(other.isLoadingAreas, isLoadingAreas) || other.isLoadingAreas == isLoadingAreas)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sizes),const DeepCollectionEquality().hash(_areas),isLoadingSizes,isLoadingAreas,errorMessage);

@override
String toString() {
  return 'MenuSettingsState(sizes: $sizes, areas: $areas, isLoadingSizes: $isLoadingSizes, isLoadingAreas: $isLoadingAreas, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MenuSettingsStateCopyWith<$Res> implements $MenuSettingsStateCopyWith<$Res> {
  factory _$MenuSettingsStateCopyWith(_MenuSettingsState value, $Res Function(_MenuSettingsState) _then) = __$MenuSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Size> sizes, List<Area> areas, bool isLoadingSizes, bool isLoadingAreas, String? errorMessage
});




}
/// @nodoc
class __$MenuSettingsStateCopyWithImpl<$Res>
    implements _$MenuSettingsStateCopyWith<$Res> {
  __$MenuSettingsStateCopyWithImpl(this._self, this._then);

  final _MenuSettingsState _self;
  final $Res Function(_MenuSettingsState) _then;

/// Create a copy of MenuSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sizes = null,Object? areas = null,Object? isLoadingSizes = null,Object? isLoadingAreas = null,Object? errorMessage = freezed,}) {
  return _then(_MenuSettingsState(
sizes: null == sizes ? _self._sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<Size>,areas: null == areas ? _self._areas : areas // ignore: cast_nullable_to_non_nullable
as List<Area>,isLoadingSizes: null == isLoadingSizes ? _self.isLoadingSizes : isLoadingSizes // ignore: cast_nullable_to_non_nullable
as bool,isLoadingAreas: null == isLoadingAreas ? _self.isLoadingAreas : isLoadingAreas // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
