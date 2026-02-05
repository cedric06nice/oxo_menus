// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateContainerInput {

 int get pageId; int get index; String get direction; String? get name; LayoutConfig? get layout;
/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateContainerInputCopyWith<CreateContainerInput> get copyWith => _$CreateContainerInputCopyWithImpl<CreateContainerInput>(this as CreateContainerInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateContainerInput&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.name, name) || other.name == name)&&(identical(other.layout, layout) || other.layout == layout));
}


@override
int get hashCode => Object.hash(runtimeType,pageId,index,direction,name,layout);

@override
String toString() {
  return 'CreateContainerInput(pageId: $pageId, index: $index, direction: $direction, name: $name, layout: $layout)';
}


}

/// @nodoc
abstract mixin class $CreateContainerInputCopyWith<$Res>  {
  factory $CreateContainerInputCopyWith(CreateContainerInput value, $Res Function(CreateContainerInput) _then) = _$CreateContainerInputCopyWithImpl;
@useResult
$Res call({
 int pageId, int index, String direction, String? name, LayoutConfig? layout
});


$LayoutConfigCopyWith<$Res>? get layout;

}
/// @nodoc
class _$CreateContainerInputCopyWithImpl<$Res>
    implements $CreateContainerInputCopyWith<$Res> {
  _$CreateContainerInputCopyWithImpl(this._self, this._then);

  final CreateContainerInput _self;
  final $Res Function(CreateContainerInput) _then;

/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageId = null,Object? index = null,Object? direction = null,Object? name = freezed,Object? layout = freezed,}) {
  return _then(_self.copyWith(
pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,
  ));
}
/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateContainerInput].
extension CreateContainerInputPatterns on CreateContainerInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateContainerInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateContainerInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateContainerInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateContainerInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateContainerInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateContainerInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageId,  int index,  String direction,  String? name,  LayoutConfig? layout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateContainerInput() when $default != null:
return $default(_that.pageId,_that.index,_that.direction,_that.name,_that.layout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageId,  int index,  String direction,  String? name,  LayoutConfig? layout)  $default,) {final _that = this;
switch (_that) {
case _CreateContainerInput():
return $default(_that.pageId,_that.index,_that.direction,_that.name,_that.layout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageId,  int index,  String direction,  String? name,  LayoutConfig? layout)?  $default,) {final _that = this;
switch (_that) {
case _CreateContainerInput() when $default != null:
return $default(_that.pageId,_that.index,_that.direction,_that.name,_that.layout);case _:
  return null;

}
}

}

/// @nodoc


class _CreateContainerInput extends CreateContainerInput {
  const _CreateContainerInput({required this.pageId, required this.index, required this.direction, this.name, this.layout}): super._();
  

@override final  int pageId;
@override final  int index;
@override final  String direction;
@override final  String? name;
@override final  LayoutConfig? layout;

/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateContainerInputCopyWith<_CreateContainerInput> get copyWith => __$CreateContainerInputCopyWithImpl<_CreateContainerInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateContainerInput&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.name, name) || other.name == name)&&(identical(other.layout, layout) || other.layout == layout));
}


@override
int get hashCode => Object.hash(runtimeType,pageId,index,direction,name,layout);

@override
String toString() {
  return 'CreateContainerInput(pageId: $pageId, index: $index, direction: $direction, name: $name, layout: $layout)';
}


}

/// @nodoc
abstract mixin class _$CreateContainerInputCopyWith<$Res> implements $CreateContainerInputCopyWith<$Res> {
  factory _$CreateContainerInputCopyWith(_CreateContainerInput value, $Res Function(_CreateContainerInput) _then) = __$CreateContainerInputCopyWithImpl;
@override @useResult
$Res call({
 int pageId, int index, String direction, String? name, LayoutConfig? layout
});


@override $LayoutConfigCopyWith<$Res>? get layout;

}
/// @nodoc
class __$CreateContainerInputCopyWithImpl<$Res>
    implements _$CreateContainerInputCopyWith<$Res> {
  __$CreateContainerInputCopyWithImpl(this._self, this._then);

  final _CreateContainerInput _self;
  final $Res Function(_CreateContainerInput) _then;

/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageId = null,Object? index = null,Object? direction = null,Object? name = freezed,Object? layout = freezed,}) {
  return _then(_CreateContainerInput(
pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,
  ));
}

/// Create a copy of CreateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}
}

/// @nodoc
mixin _$UpdateContainerInput {

 int get id; String? get name; int? get index; LayoutConfig? get layout;
/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateContainerInputCopyWith<UpdateContainerInput> get copyWith => _$UpdateContainerInputCopyWithImpl<UpdateContainerInput>(this as UpdateContainerInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateContainerInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index)&&(identical(other.layout, layout) || other.layout == layout));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,index,layout);

@override
String toString() {
  return 'UpdateContainerInput(id: $id, name: $name, index: $index, layout: $layout)';
}


}

/// @nodoc
abstract mixin class $UpdateContainerInputCopyWith<$Res>  {
  factory $UpdateContainerInputCopyWith(UpdateContainerInput value, $Res Function(UpdateContainerInput) _then) = _$UpdateContainerInputCopyWithImpl;
@useResult
$Res call({
 int id, String? name, int? index, LayoutConfig? layout
});


$LayoutConfigCopyWith<$Res>? get layout;

}
/// @nodoc
class _$UpdateContainerInputCopyWithImpl<$Res>
    implements $UpdateContainerInputCopyWith<$Res> {
  _$UpdateContainerInputCopyWithImpl(this._self, this._then);

  final UpdateContainerInput _self;
  final $Res Function(UpdateContainerInput) _then;

/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? index = freezed,Object? layout = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,
  ));
}
/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateContainerInput].
extension UpdateContainerInputPatterns on UpdateContainerInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateContainerInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateContainerInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateContainerInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateContainerInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateContainerInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateContainerInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  int? index,  LayoutConfig? layout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateContainerInput() when $default != null:
return $default(_that.id,_that.name,_that.index,_that.layout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  int? index,  LayoutConfig? layout)  $default,) {final _that = this;
switch (_that) {
case _UpdateContainerInput():
return $default(_that.id,_that.name,_that.index,_that.layout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  int? index,  LayoutConfig? layout)?  $default,) {final _that = this;
switch (_that) {
case _UpdateContainerInput() when $default != null:
return $default(_that.id,_that.name,_that.index,_that.layout);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateContainerInput extends UpdateContainerInput {
  const _UpdateContainerInput({required this.id, this.name, this.index, this.layout}): super._();
  

@override final  int id;
@override final  String? name;
@override final  int? index;
@override final  LayoutConfig? layout;

/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateContainerInputCopyWith<_UpdateContainerInput> get copyWith => __$UpdateContainerInputCopyWithImpl<_UpdateContainerInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateContainerInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index)&&(identical(other.layout, layout) || other.layout == layout));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,index,layout);

@override
String toString() {
  return 'UpdateContainerInput(id: $id, name: $name, index: $index, layout: $layout)';
}


}

/// @nodoc
abstract mixin class _$UpdateContainerInputCopyWith<$Res> implements $UpdateContainerInputCopyWith<$Res> {
  factory _$UpdateContainerInputCopyWith(_UpdateContainerInput value, $Res Function(_UpdateContainerInput) _then) = __$UpdateContainerInputCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, int? index, LayoutConfig? layout
});


@override $LayoutConfigCopyWith<$Res>? get layout;

}
/// @nodoc
class __$UpdateContainerInputCopyWithImpl<$Res>
    implements _$UpdateContainerInputCopyWith<$Res> {
  __$UpdateContainerInputCopyWithImpl(this._self, this._then);

  final _UpdateContainerInput _self;
  final $Res Function(_UpdateContainerInput) _then;

/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? index = freezed,Object? layout = freezed,}) {
  return _then(_UpdateContainerInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,
  ));
}

/// Create a copy of UpdateContainerInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}
}

// dart format on
