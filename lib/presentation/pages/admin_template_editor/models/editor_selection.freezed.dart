// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorSelection {

 EditorElementType get type; int get id;
/// Create a copy of EditorSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSelectionCopyWith<EditorSelection> get copyWith => _$EditorSelectionCopyWithImpl<EditorSelection>(this as EditorSelection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSelection&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,type,id);

@override
String toString() {
  return 'EditorSelection(type: $type, id: $id)';
}


}

/// @nodoc
abstract mixin class $EditorSelectionCopyWith<$Res>  {
  factory $EditorSelectionCopyWith(EditorSelection value, $Res Function(EditorSelection) _then) = _$EditorSelectionCopyWithImpl;
@useResult
$Res call({
 EditorElementType type, int id
});




}
/// @nodoc
class _$EditorSelectionCopyWithImpl<$Res>
    implements $EditorSelectionCopyWith<$Res> {
  _$EditorSelectionCopyWithImpl(this._self, this._then);

  final EditorSelection _self;
  final $Res Function(EditorSelection) _then;

/// Create a copy of EditorSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EditorElementType,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorSelection].
extension EditorSelectionPatterns on EditorSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSelection value)  $default,){
final _that = this;
switch (_that) {
case _EditorSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSelection value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EditorElementType type,  int id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSelection() when $default != null:
return $default(_that.type,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EditorElementType type,  int id)  $default,) {final _that = this;
switch (_that) {
case _EditorSelection():
return $default(_that.type,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EditorElementType type,  int id)?  $default,) {final _that = this;
switch (_that) {
case _EditorSelection() when $default != null:
return $default(_that.type,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _EditorSelection implements EditorSelection {
  const _EditorSelection({required this.type, required this.id});
  

@override final  EditorElementType type;
@override final  int id;

/// Create a copy of EditorSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSelectionCopyWith<_EditorSelection> get copyWith => __$EditorSelectionCopyWithImpl<_EditorSelection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSelection&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,type,id);

@override
String toString() {
  return 'EditorSelection(type: $type, id: $id)';
}


}

/// @nodoc
abstract mixin class _$EditorSelectionCopyWith<$Res> implements $EditorSelectionCopyWith<$Res> {
  factory _$EditorSelectionCopyWith(_EditorSelection value, $Res Function(_EditorSelection) _then) = __$EditorSelectionCopyWithImpl;
@override @useResult
$Res call({
 EditorElementType type, int id
});




}
/// @nodoc
class __$EditorSelectionCopyWithImpl<$Res>
    implements _$EditorSelectionCopyWith<$Res> {
  __$EditorSelectionCopyWithImpl(this._self, this._then);

  final _EditorSelection _self;
  final $Res Function(_EditorSelection) _then;

/// Create a copy of EditorSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,}) {
  return _then(_EditorSelection(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EditorElementType,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
