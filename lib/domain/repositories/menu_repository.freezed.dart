// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateMenuInput {

 String get name; String get version; Status? get status; StyleConfig? get styleConfig; int? get sizeId; String? get area;
/// Create a copy of CreateMenuInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMenuInputCopyWith<CreateMenuInput> get copyWith => _$CreateMenuInputCopyWithImpl<CreateMenuInput>(this as CreateMenuInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMenuInput&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.sizeId, sizeId) || other.sizeId == sizeId)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,name,version,status,styleConfig,sizeId,area);

@override
String toString() {
  return 'CreateMenuInput(name: $name, version: $version, status: $status, styleConfig: $styleConfig, sizeId: $sizeId, area: $area)';
}


}

/// @nodoc
abstract mixin class $CreateMenuInputCopyWith<$Res>  {
  factory $CreateMenuInputCopyWith(CreateMenuInput value, $Res Function(CreateMenuInput) _then) = _$CreateMenuInputCopyWithImpl;
@useResult
$Res call({
 String name, String version, Status? status, StyleConfig? styleConfig, int? sizeId, String? area
});


$StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class _$CreateMenuInputCopyWithImpl<$Res>
    implements $CreateMenuInputCopyWith<$Res> {
  _$CreateMenuInputCopyWithImpl(this._self, this._then);

  final CreateMenuInput _self;
  final $Res Function(CreateMenuInput) _then;

/// Create a copy of CreateMenuInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? version = null,Object? status = freezed,Object? styleConfig = freezed,Object? sizeId = freezed,Object? area = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,sizeId: freezed == sizeId ? _self.sizeId : sizeId // ignore: cast_nullable_to_non_nullable
as int?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CreateMenuInput
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


/// Adds pattern-matching-related methods to [CreateMenuInput].
extension CreateMenuInputPatterns on CreateMenuInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMenuInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMenuInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMenuInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateMenuInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMenuInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMenuInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String version,  Status? status,  StyleConfig? styleConfig,  int? sizeId,  String? area)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMenuInput() when $default != null:
return $default(_that.name,_that.version,_that.status,_that.styleConfig,_that.sizeId,_that.area);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String version,  Status? status,  StyleConfig? styleConfig,  int? sizeId,  String? area)  $default,) {final _that = this;
switch (_that) {
case _CreateMenuInput():
return $default(_that.name,_that.version,_that.status,_that.styleConfig,_that.sizeId,_that.area);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String version,  Status? status,  StyleConfig? styleConfig,  int? sizeId,  String? area)?  $default,) {final _that = this;
switch (_that) {
case _CreateMenuInput() when $default != null:
return $default(_that.name,_that.version,_that.status,_that.styleConfig,_that.sizeId,_that.area);case _:
  return null;

}
}

}

/// @nodoc


class _CreateMenuInput extends CreateMenuInput {
  const _CreateMenuInput({required this.name, required this.version, this.status, this.styleConfig, this.sizeId, this.area}): super._();
  

@override final  String name;
@override final  String version;
@override final  Status? status;
@override final  StyleConfig? styleConfig;
@override final  int? sizeId;
@override final  String? area;

/// Create a copy of CreateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMenuInputCopyWith<_CreateMenuInput> get copyWith => __$CreateMenuInputCopyWithImpl<_CreateMenuInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMenuInput&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.sizeId, sizeId) || other.sizeId == sizeId)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,name,version,status,styleConfig,sizeId,area);

@override
String toString() {
  return 'CreateMenuInput(name: $name, version: $version, status: $status, styleConfig: $styleConfig, sizeId: $sizeId, area: $area)';
}


}

/// @nodoc
abstract mixin class _$CreateMenuInputCopyWith<$Res> implements $CreateMenuInputCopyWith<$Res> {
  factory _$CreateMenuInputCopyWith(_CreateMenuInput value, $Res Function(_CreateMenuInput) _then) = __$CreateMenuInputCopyWithImpl;
@override @useResult
$Res call({
 String name, String version, Status? status, StyleConfig? styleConfig, int? sizeId, String? area
});


@override $StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class __$CreateMenuInputCopyWithImpl<$Res>
    implements _$CreateMenuInputCopyWith<$Res> {
  __$CreateMenuInputCopyWithImpl(this._self, this._then);

  final _CreateMenuInput _self;
  final $Res Function(_CreateMenuInput) _then;

/// Create a copy of CreateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? version = null,Object? status = freezed,Object? styleConfig = freezed,Object? sizeId = freezed,Object? area = freezed,}) {
  return _then(_CreateMenuInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,sizeId: freezed == sizeId ? _self.sizeId : sizeId // ignore: cast_nullable_to_non_nullable
as int?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateMenuInput
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
mixin _$UpdateMenuInput {

 int get id; String? get name; String? get version; Status? get status; StyleConfig? get styleConfig; PageSize? get pageSize; String? get area;
/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMenuInputCopyWith<UpdateMenuInput> get copyWith => _$UpdateMenuInputCopyWithImpl<UpdateMenuInput>(this as UpdateMenuInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMenuInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,version,status,styleConfig,pageSize,area);

@override
String toString() {
  return 'UpdateMenuInput(id: $id, name: $name, version: $version, status: $status, styleConfig: $styleConfig, pageSize: $pageSize, area: $area)';
}


}

/// @nodoc
abstract mixin class $UpdateMenuInputCopyWith<$Res>  {
  factory $UpdateMenuInputCopyWith(UpdateMenuInput value, $Res Function(UpdateMenuInput) _then) = _$UpdateMenuInputCopyWithImpl;
@useResult
$Res call({
 int id, String? name, String? version, Status? status, StyleConfig? styleConfig, PageSize? pageSize, String? area
});


$StyleConfigCopyWith<$Res>? get styleConfig;$PageSizeCopyWith<$Res>? get pageSize;

}
/// @nodoc
class _$UpdateMenuInputCopyWithImpl<$Res>
    implements $UpdateMenuInputCopyWith<$Res> {
  _$UpdateMenuInputCopyWithImpl(this._self, this._then);

  final UpdateMenuInput _self;
  final $Res Function(UpdateMenuInput) _then;

/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? version = freezed,Object? status = freezed,Object? styleConfig = freezed,Object? pageSize = freezed,Object? area = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as PageSize?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpdateMenuInput
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
}/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageSizeCopyWith<$Res>? get pageSize {
    if (_self.pageSize == null) {
    return null;
  }

  return $PageSizeCopyWith<$Res>(_self.pageSize!, (value) {
    return _then(_self.copyWith(pageSize: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateMenuInput].
extension UpdateMenuInputPatterns on UpdateMenuInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMenuInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMenuInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMenuInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMenuInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  String? version,  Status? status,  StyleConfig? styleConfig,  PageSize? pageSize,  String? area)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMenuInput() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.status,_that.styleConfig,_that.pageSize,_that.area);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  String? version,  Status? status,  StyleConfig? styleConfig,  PageSize? pageSize,  String? area)  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuInput():
return $default(_that.id,_that.name,_that.version,_that.status,_that.styleConfig,_that.pageSize,_that.area);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  String? version,  Status? status,  StyleConfig? styleConfig,  PageSize? pageSize,  String? area)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuInput() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.status,_that.styleConfig,_that.pageSize,_that.area);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateMenuInput extends UpdateMenuInput {
  const _UpdateMenuInput({required this.id, this.name, this.version, this.status, this.styleConfig, this.pageSize, this.area}): super._();
  

@override final  int id;
@override final  String? name;
@override final  String? version;
@override final  Status? status;
@override final  StyleConfig? styleConfig;
@override final  PageSize? pageSize;
@override final  String? area;

/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMenuInputCopyWith<_UpdateMenuInput> get copyWith => __$UpdateMenuInputCopyWithImpl<_UpdateMenuInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMenuInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.area, area) || other.area == area));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,version,status,styleConfig,pageSize,area);

@override
String toString() {
  return 'UpdateMenuInput(id: $id, name: $name, version: $version, status: $status, styleConfig: $styleConfig, pageSize: $pageSize, area: $area)';
}


}

/// @nodoc
abstract mixin class _$UpdateMenuInputCopyWith<$Res> implements $UpdateMenuInputCopyWith<$Res> {
  factory _$UpdateMenuInputCopyWith(_UpdateMenuInput value, $Res Function(_UpdateMenuInput) _then) = __$UpdateMenuInputCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, String? version, Status? status, StyleConfig? styleConfig, PageSize? pageSize, String? area
});


@override $StyleConfigCopyWith<$Res>? get styleConfig;@override $PageSizeCopyWith<$Res>? get pageSize;

}
/// @nodoc
class __$UpdateMenuInputCopyWithImpl<$Res>
    implements _$UpdateMenuInputCopyWith<$Res> {
  __$UpdateMenuInputCopyWithImpl(this._self, this._then);

  final _UpdateMenuInput _self;
  final $Res Function(_UpdateMenuInput) _then;

/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? version = freezed,Object? status = freezed,Object? styleConfig = freezed,Object? pageSize = freezed,Object? area = freezed,}) {
  return _then(_UpdateMenuInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as PageSize?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpdateMenuInput
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
}/// Create a copy of UpdateMenuInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageSizeCopyWith<$Res>? get pageSize {
    if (_self.pageSize == null) {
    return null;
  }

  return $PageSizeCopyWith<$Res>(_self.pageSize!, (value) {
    return _then(_self.copyWith(pageSize: value));
  });
}
}

// dart format on
