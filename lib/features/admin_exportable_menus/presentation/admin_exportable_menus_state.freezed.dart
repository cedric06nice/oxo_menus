// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_exportable_menus_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminExportableMenusState {

 List<MenuBundle> get bundles; List<Menu> get availableMenus; bool get isLoading; String? get errorMessage;
/// Create a copy of AdminExportableMenusState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminExportableMenusStateCopyWith<AdminExportableMenusState> get copyWith => _$AdminExportableMenusStateCopyWithImpl<AdminExportableMenusState>(this as AdminExportableMenusState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminExportableMenusState&&const DeepCollectionEquality().equals(other.bundles, bundles)&&const DeepCollectionEquality().equals(other.availableMenus, availableMenus)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bundles),const DeepCollectionEquality().hash(availableMenus),isLoading,errorMessage);

@override
String toString() {
  return 'AdminExportableMenusState(bundles: $bundles, availableMenus: $availableMenus, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AdminExportableMenusStateCopyWith<$Res>  {
  factory $AdminExportableMenusStateCopyWith(AdminExportableMenusState value, $Res Function(AdminExportableMenusState) _then) = _$AdminExportableMenusStateCopyWithImpl;
@useResult
$Res call({
 List<MenuBundle> bundles, List<Menu> availableMenus, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$AdminExportableMenusStateCopyWithImpl<$Res>
    implements $AdminExportableMenusStateCopyWith<$Res> {
  _$AdminExportableMenusStateCopyWithImpl(this._self, this._then);

  final AdminExportableMenusState _self;
  final $Res Function(AdminExportableMenusState) _then;

/// Create a copy of AdminExportableMenusState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bundles = null,Object? availableMenus = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
bundles: null == bundles ? _self.bundles : bundles // ignore: cast_nullable_to_non_nullable
as List<MenuBundle>,availableMenus: null == availableMenus ? _self.availableMenus : availableMenus // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminExportableMenusState].
extension AdminExportableMenusStatePatterns on AdminExportableMenusState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminExportableMenusState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminExportableMenusState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminExportableMenusState value)  $default,){
final _that = this;
switch (_that) {
case _AdminExportableMenusState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminExportableMenusState value)?  $default,){
final _that = this;
switch (_that) {
case _AdminExportableMenusState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MenuBundle> bundles,  List<Menu> availableMenus,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminExportableMenusState() when $default != null:
return $default(_that.bundles,_that.availableMenus,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MenuBundle> bundles,  List<Menu> availableMenus,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AdminExportableMenusState():
return $default(_that.bundles,_that.availableMenus,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MenuBundle> bundles,  List<Menu> availableMenus,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AdminExportableMenusState() when $default != null:
return $default(_that.bundles,_that.availableMenus,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AdminExportableMenusState implements AdminExportableMenusState {
  const _AdminExportableMenusState({final  List<MenuBundle> bundles = const [], final  List<Menu> availableMenus = const [], this.isLoading = false, this.errorMessage}): _bundles = bundles,_availableMenus = availableMenus;
  

 final  List<MenuBundle> _bundles;
@override@JsonKey() List<MenuBundle> get bundles {
  if (_bundles is EqualUnmodifiableListView) return _bundles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bundles);
}

 final  List<Menu> _availableMenus;
@override@JsonKey() List<Menu> get availableMenus {
  if (_availableMenus is EqualUnmodifiableListView) return _availableMenus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableMenus);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of AdminExportableMenusState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminExportableMenusStateCopyWith<_AdminExportableMenusState> get copyWith => __$AdminExportableMenusStateCopyWithImpl<_AdminExportableMenusState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminExportableMenusState&&const DeepCollectionEquality().equals(other._bundles, _bundles)&&const DeepCollectionEquality().equals(other._availableMenus, _availableMenus)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bundles),const DeepCollectionEquality().hash(_availableMenus),isLoading,errorMessage);

@override
String toString() {
  return 'AdminExportableMenusState(bundles: $bundles, availableMenus: $availableMenus, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AdminExportableMenusStateCopyWith<$Res> implements $AdminExportableMenusStateCopyWith<$Res> {
  factory _$AdminExportableMenusStateCopyWith(_AdminExportableMenusState value, $Res Function(_AdminExportableMenusState) _then) = __$AdminExportableMenusStateCopyWithImpl;
@override @useResult
$Res call({
 List<MenuBundle> bundles, List<Menu> availableMenus, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$AdminExportableMenusStateCopyWithImpl<$Res>
    implements _$AdminExportableMenusStateCopyWith<$Res> {
  __$AdminExportableMenusStateCopyWithImpl(this._self, this._then);

  final _AdminExportableMenusState _self;
  final $Res Function(_AdminExportableMenusState) _then;

/// Create a copy of AdminExportableMenusState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bundles = null,Object? availableMenus = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_AdminExportableMenusState(
bundles: null == bundles ? _self._bundles : bundles // ignore: cast_nullable_to_non_nullable
as List<MenuBundle>,availableMenus: null == availableMenus ? _self._availableMenus : availableMenus // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
