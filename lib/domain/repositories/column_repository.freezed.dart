// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateColumnInput {

 int get containerId; int get index; int? get flex; double? get width; StyleConfig? get styleConfig;
/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateColumnInputCopyWith<CreateColumnInput> get copyWith => _$CreateColumnInputCopyWithImpl<CreateColumnInput>(this as CreateColumnInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateColumnInput&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig));
}


@override
int get hashCode => Object.hash(runtimeType,containerId,index,flex,width,styleConfig);

@override
String toString() {
  return 'CreateColumnInput(containerId: $containerId, index: $index, flex: $flex, width: $width, styleConfig: $styleConfig)';
}


}

/// @nodoc
abstract mixin class $CreateColumnInputCopyWith<$Res>  {
  factory $CreateColumnInputCopyWith(CreateColumnInput value, $Res Function(CreateColumnInput) _then) = _$CreateColumnInputCopyWithImpl;
@useResult
$Res call({
 int containerId, int index, int? flex, double? width, StyleConfig? styleConfig
});


$StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class _$CreateColumnInputCopyWithImpl<$Res>
    implements $CreateColumnInputCopyWith<$Res> {
  _$CreateColumnInputCopyWithImpl(this._self, this._then);

  final CreateColumnInput _self;
  final $Res Function(CreateColumnInput) _then;

/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,Object? styleConfig = freezed,}) {
  return _then(_self.copyWith(
containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,
  ));
}
/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateColumnInput].
extension CreateColumnInputPatterns on CreateColumnInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateColumnInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateColumnInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateColumnInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateColumnInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateColumnInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateColumnInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int containerId,  int index,  int? flex,  double? width,  StyleConfig? styleConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateColumnInput() when $default != null:
return $default(_that.containerId,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int containerId,  int index,  int? flex,  double? width,  StyleConfig? styleConfig)  $default,) {final _that = this;
switch (_that) {
case _CreateColumnInput():
return $default(_that.containerId,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int containerId,  int index,  int? flex,  double? width,  StyleConfig? styleConfig)?  $default,) {final _that = this;
switch (_that) {
case _CreateColumnInput() when $default != null:
return $default(_that.containerId,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
  return null;

}
}

}

/// @nodoc


class _CreateColumnInput extends CreateColumnInput {
  const _CreateColumnInput({required this.containerId, required this.index, this.flex, this.width, this.styleConfig}): super._();
  

@override final  int containerId;
@override final  int index;
@override final  int? flex;
@override final  double? width;
@override final  StyleConfig? styleConfig;

/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateColumnInputCopyWith<_CreateColumnInput> get copyWith => __$CreateColumnInputCopyWithImpl<_CreateColumnInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateColumnInput&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig));
}


@override
int get hashCode => Object.hash(runtimeType,containerId,index,flex,width,styleConfig);

@override
String toString() {
  return 'CreateColumnInput(containerId: $containerId, index: $index, flex: $flex, width: $width, styleConfig: $styleConfig)';
}


}

/// @nodoc
abstract mixin class _$CreateColumnInputCopyWith<$Res> implements $CreateColumnInputCopyWith<$Res> {
  factory _$CreateColumnInputCopyWith(_CreateColumnInput value, $Res Function(_CreateColumnInput) _then) = __$CreateColumnInputCopyWithImpl;
@override @useResult
$Res call({
 int containerId, int index, int? flex, double? width, StyleConfig? styleConfig
});


@override $StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class __$CreateColumnInputCopyWithImpl<$Res>
    implements _$CreateColumnInputCopyWith<$Res> {
  __$CreateColumnInputCopyWithImpl(this._self, this._then);

  final _CreateColumnInput _self;
  final $Res Function(_CreateColumnInput) _then;

/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,Object? styleConfig = freezed,}) {
  return _then(_CreateColumnInput(
containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,
  ));
}

/// Create a copy of CreateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}

/// @nodoc
mixin _$UpdateColumnInput {

 int get id; int? get index; int? get flex; double? get width; StyleConfig? get styleConfig;
/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateColumnInputCopyWith<UpdateColumnInput> get copyWith => _$UpdateColumnInputCopyWithImpl<UpdateColumnInput>(this as UpdateColumnInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateColumnInput&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig));
}


@override
int get hashCode => Object.hash(runtimeType,id,index,flex,width,styleConfig);

@override
String toString() {
  return 'UpdateColumnInput(id: $id, index: $index, flex: $flex, width: $width, styleConfig: $styleConfig)';
}


}

/// @nodoc
abstract mixin class $UpdateColumnInputCopyWith<$Res>  {
  factory $UpdateColumnInputCopyWith(UpdateColumnInput value, $Res Function(UpdateColumnInput) _then) = _$UpdateColumnInputCopyWithImpl;
@useResult
$Res call({
 int id, int? index, int? flex, double? width, StyleConfig? styleConfig
});


$StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class _$UpdateColumnInputCopyWithImpl<$Res>
    implements $UpdateColumnInputCopyWith<$Res> {
  _$UpdateColumnInputCopyWithImpl(this._self, this._then);

  final UpdateColumnInput _self;
  final $Res Function(UpdateColumnInput) _then;

/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? index = freezed,Object? flex = freezed,Object? width = freezed,Object? styleConfig = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,
  ));
}
/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateColumnInput].
extension UpdateColumnInputPatterns on UpdateColumnInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateColumnInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateColumnInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateColumnInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateColumnInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateColumnInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateColumnInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? index,  int? flex,  double? width,  StyleConfig? styleConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateColumnInput() when $default != null:
return $default(_that.id,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? index,  int? flex,  double? width,  StyleConfig? styleConfig)  $default,) {final _that = this;
switch (_that) {
case _UpdateColumnInput():
return $default(_that.id,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? index,  int? flex,  double? width,  StyleConfig? styleConfig)?  $default,) {final _that = this;
switch (_that) {
case _UpdateColumnInput() when $default != null:
return $default(_that.id,_that.index,_that.flex,_that.width,_that.styleConfig);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateColumnInput extends UpdateColumnInput {
  const _UpdateColumnInput({required this.id, this.index, this.flex, this.width, this.styleConfig}): super._();
  

@override final  int id;
@override final  int? index;
@override final  int? flex;
@override final  double? width;
@override final  StyleConfig? styleConfig;

/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateColumnInputCopyWith<_UpdateColumnInput> get copyWith => __$UpdateColumnInputCopyWithImpl<_UpdateColumnInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateColumnInput&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig));
}


@override
int get hashCode => Object.hash(runtimeType,id,index,flex,width,styleConfig);

@override
String toString() {
  return 'UpdateColumnInput(id: $id, index: $index, flex: $flex, width: $width, styleConfig: $styleConfig)';
}


}

/// @nodoc
abstract mixin class _$UpdateColumnInputCopyWith<$Res> implements $UpdateColumnInputCopyWith<$Res> {
  factory _$UpdateColumnInputCopyWith(_UpdateColumnInput value, $Res Function(_UpdateColumnInput) _then) = __$UpdateColumnInputCopyWithImpl;
@override @useResult
$Res call({
 int id, int? index, int? flex, double? width, StyleConfig? styleConfig
});


@override $StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class __$UpdateColumnInputCopyWithImpl<$Res>
    implements _$UpdateColumnInputCopyWith<$Res> {
  __$UpdateColumnInputCopyWithImpl(this._self, this._then);

  final _UpdateColumnInput _self;
  final $Res Function(_UpdateColumnInput) _then;

/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = freezed,Object? flex = freezed,Object? width = freezed,Object? styleConfig = freezed,}) {
  return _then(_UpdateColumnInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,
  ));
}

/// Create a copy of UpdateColumnInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}

// dart format on
