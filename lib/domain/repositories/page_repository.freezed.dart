// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreatePageInput {

 int get menuId; String get name; int get index;
/// Create a copy of CreatePageInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePageInputCopyWith<CreatePageInput> get copyWith => _$CreatePageInputCopyWithImpl<CreatePageInput>(this as CreatePageInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePageInput&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,menuId,name,index);

@override
String toString() {
  return 'CreatePageInput(menuId: $menuId, name: $name, index: $index)';
}


}

/// @nodoc
abstract mixin class $CreatePageInputCopyWith<$Res>  {
  factory $CreatePageInputCopyWith(CreatePageInput value, $Res Function(CreatePageInput) _then) = _$CreatePageInputCopyWithImpl;
@useResult
$Res call({
 int menuId, String name, int index
});




}
/// @nodoc
class _$CreatePageInputCopyWithImpl<$Res>
    implements $CreatePageInputCopyWith<$Res> {
  _$CreatePageInputCopyWithImpl(this._self, this._then);

  final CreatePageInput _self;
  final $Res Function(CreatePageInput) _then;

/// Create a copy of CreatePageInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuId = null,Object? name = null,Object? index = null,}) {
  return _then(_self.copyWith(
menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePageInput].
extension CreatePageInputPatterns on CreatePageInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePageInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePageInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePageInput value)  $default,){
final _that = this;
switch (_that) {
case _CreatePageInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePageInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePageInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int menuId,  String name,  int index)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePageInput() when $default != null:
return $default(_that.menuId,_that.name,_that.index);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int menuId,  String name,  int index)  $default,) {final _that = this;
switch (_that) {
case _CreatePageInput():
return $default(_that.menuId,_that.name,_that.index);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int menuId,  String name,  int index)?  $default,) {final _that = this;
switch (_that) {
case _CreatePageInput() when $default != null:
return $default(_that.menuId,_that.name,_that.index);case _:
  return null;

}
}

}

/// @nodoc


class _CreatePageInput extends CreatePageInput {
  const _CreatePageInput({required this.menuId, required this.name, required this.index}): super._();
  

@override final  int menuId;
@override final  String name;
@override final  int index;

/// Create a copy of CreatePageInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePageInputCopyWith<_CreatePageInput> get copyWith => __$CreatePageInputCopyWithImpl<_CreatePageInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePageInput&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,menuId,name,index);

@override
String toString() {
  return 'CreatePageInput(menuId: $menuId, name: $name, index: $index)';
}


}

/// @nodoc
abstract mixin class _$CreatePageInputCopyWith<$Res> implements $CreatePageInputCopyWith<$Res> {
  factory _$CreatePageInputCopyWith(_CreatePageInput value, $Res Function(_CreatePageInput) _then) = __$CreatePageInputCopyWithImpl;
@override @useResult
$Res call({
 int menuId, String name, int index
});




}
/// @nodoc
class __$CreatePageInputCopyWithImpl<$Res>
    implements _$CreatePageInputCopyWith<$Res> {
  __$CreatePageInputCopyWithImpl(this._self, this._then);

  final _CreatePageInput _self;
  final $Res Function(_CreatePageInput) _then;

/// Create a copy of CreatePageInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuId = null,Object? name = null,Object? index = null,}) {
  return _then(_CreatePageInput(
menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$UpdatePageInput {

 int get id; String? get name; int? get index;
/// Create a copy of UpdatePageInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePageInputCopyWith<UpdatePageInput> get copyWith => _$UpdatePageInputCopyWithImpl<UpdatePageInput>(this as UpdatePageInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePageInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,index);

@override
String toString() {
  return 'UpdatePageInput(id: $id, name: $name, index: $index)';
}


}

/// @nodoc
abstract mixin class $UpdatePageInputCopyWith<$Res>  {
  factory $UpdatePageInputCopyWith(UpdatePageInput value, $Res Function(UpdatePageInput) _then) = _$UpdatePageInputCopyWithImpl;
@useResult
$Res call({
 int id, String? name, int? index
});




}
/// @nodoc
class _$UpdatePageInputCopyWithImpl<$Res>
    implements $UpdatePageInputCopyWith<$Res> {
  _$UpdatePageInputCopyWithImpl(this._self, this._then);

  final UpdatePageInput _self;
  final $Res Function(UpdatePageInput) _then;

/// Create a copy of UpdatePageInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? index = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePageInput].
extension UpdatePageInputPatterns on UpdatePageInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePageInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePageInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePageInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePageInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePageInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePageInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  int? index)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePageInput() when $default != null:
return $default(_that.id,_that.name,_that.index);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  int? index)  $default,) {final _that = this;
switch (_that) {
case _UpdatePageInput():
return $default(_that.id,_that.name,_that.index);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  int? index)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePageInput() when $default != null:
return $default(_that.id,_that.name,_that.index);case _:
  return null;

}
}

}

/// @nodoc


class _UpdatePageInput extends UpdatePageInput {
  const _UpdatePageInput({required this.id, this.name, this.index}): super._();
  

@override final  int id;
@override final  String? name;
@override final  int? index;

/// Create a copy of UpdatePageInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePageInputCopyWith<_UpdatePageInput> get copyWith => __$UpdatePageInputCopyWithImpl<_UpdatePageInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePageInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,index);

@override
String toString() {
  return 'UpdatePageInput(id: $id, name: $name, index: $index)';
}


}

/// @nodoc
abstract mixin class _$UpdatePageInputCopyWith<$Res> implements $UpdatePageInputCopyWith<$Res> {
  factory _$UpdatePageInputCopyWith(_UpdatePageInput value, $Res Function(_UpdatePageInput) _then) = __$UpdatePageInputCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, int? index
});




}
/// @nodoc
class __$UpdatePageInputCopyWithImpl<$Res>
    implements _$UpdatePageInputCopyWith<$Res> {
  __$UpdatePageInputCopyWithImpl(this._self, this._then);

  final _UpdatePageInput _self;
  final $Res Function(_UpdatePageInput) _then;

/// Create a copy of UpdatePageInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? index = freezed,}) {
  return _then(_UpdatePageInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
