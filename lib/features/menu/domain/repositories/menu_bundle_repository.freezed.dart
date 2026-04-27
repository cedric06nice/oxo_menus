// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_bundle_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateMenuBundleInput {

 String get name; List<int> get menuIds;
/// Create a copy of CreateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMenuBundleInputCopyWith<CreateMenuBundleInput> get copyWith => _$CreateMenuBundleInputCopyWithImpl<CreateMenuBundleInput>(this as CreateMenuBundleInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMenuBundleInput&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.menuIds, menuIds));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(menuIds));

@override
String toString() {
  return 'CreateMenuBundleInput(name: $name, menuIds: $menuIds)';
}


}

/// @nodoc
abstract mixin class $CreateMenuBundleInputCopyWith<$Res>  {
  factory $CreateMenuBundleInputCopyWith(CreateMenuBundleInput value, $Res Function(CreateMenuBundleInput) _then) = _$CreateMenuBundleInputCopyWithImpl;
@useResult
$Res call({
 String name, List<int> menuIds
});




}
/// @nodoc
class _$CreateMenuBundleInputCopyWithImpl<$Res>
    implements $CreateMenuBundleInputCopyWith<$Res> {
  _$CreateMenuBundleInputCopyWithImpl(this._self, this._then);

  final CreateMenuBundleInput _self;
  final $Res Function(CreateMenuBundleInput) _then;

/// Create a copy of CreateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? menuIds = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,menuIds: null == menuIds ? _self.menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateMenuBundleInput].
extension CreateMenuBundleInputPatterns on CreateMenuBundleInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMenuBundleInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMenuBundleInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMenuBundleInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateMenuBundleInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMenuBundleInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMenuBundleInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<int> menuIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMenuBundleInput() when $default != null:
return $default(_that.name,_that.menuIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<int> menuIds)  $default,) {final _that = this;
switch (_that) {
case _CreateMenuBundleInput():
return $default(_that.name,_that.menuIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<int> menuIds)?  $default,) {final _that = this;
switch (_that) {
case _CreateMenuBundleInput() when $default != null:
return $default(_that.name,_that.menuIds);case _:
  return null;

}
}

}

/// @nodoc


class _CreateMenuBundleInput extends CreateMenuBundleInput {
  const _CreateMenuBundleInput({required this.name, final  List<int> menuIds = const []}): _menuIds = menuIds,super._();
  

@override final  String name;
 final  List<int> _menuIds;
@override@JsonKey() List<int> get menuIds {
  if (_menuIds is EqualUnmodifiableListView) return _menuIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_menuIds);
}


/// Create a copy of CreateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMenuBundleInputCopyWith<_CreateMenuBundleInput> get copyWith => __$CreateMenuBundleInputCopyWithImpl<_CreateMenuBundleInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMenuBundleInput&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._menuIds, _menuIds));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_menuIds));

@override
String toString() {
  return 'CreateMenuBundleInput(name: $name, menuIds: $menuIds)';
}


}

/// @nodoc
abstract mixin class _$CreateMenuBundleInputCopyWith<$Res> implements $CreateMenuBundleInputCopyWith<$Res> {
  factory _$CreateMenuBundleInputCopyWith(_CreateMenuBundleInput value, $Res Function(_CreateMenuBundleInput) _then) = __$CreateMenuBundleInputCopyWithImpl;
@override @useResult
$Res call({
 String name, List<int> menuIds
});




}
/// @nodoc
class __$CreateMenuBundleInputCopyWithImpl<$Res>
    implements _$CreateMenuBundleInputCopyWith<$Res> {
  __$CreateMenuBundleInputCopyWithImpl(this._self, this._then);

  final _CreateMenuBundleInput _self;
  final $Res Function(_CreateMenuBundleInput) _then;

/// Create a copy of CreateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? menuIds = null,}) {
  return _then(_CreateMenuBundleInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,menuIds: null == menuIds ? _self._menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc
mixin _$UpdateMenuBundleInput {

 int get id; String? get name; List<int>? get menuIds; String? get pdfFileId;
/// Create a copy of UpdateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMenuBundleInputCopyWith<UpdateMenuBundleInput> get copyWith => _$UpdateMenuBundleInputCopyWithImpl<UpdateMenuBundleInput>(this as UpdateMenuBundleInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMenuBundleInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.menuIds, menuIds)&&(identical(other.pdfFileId, pdfFileId) || other.pdfFileId == pdfFileId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(menuIds),pdfFileId);

@override
String toString() {
  return 'UpdateMenuBundleInput(id: $id, name: $name, menuIds: $menuIds, pdfFileId: $pdfFileId)';
}


}

/// @nodoc
abstract mixin class $UpdateMenuBundleInputCopyWith<$Res>  {
  factory $UpdateMenuBundleInputCopyWith(UpdateMenuBundleInput value, $Res Function(UpdateMenuBundleInput) _then) = _$UpdateMenuBundleInputCopyWithImpl;
@useResult
$Res call({
 int id, String? name, List<int>? menuIds, String? pdfFileId
});




}
/// @nodoc
class _$UpdateMenuBundleInputCopyWithImpl<$Res>
    implements $UpdateMenuBundleInputCopyWith<$Res> {
  _$UpdateMenuBundleInputCopyWithImpl(this._self, this._then);

  final UpdateMenuBundleInput _self;
  final $Res Function(UpdateMenuBundleInput) _then;

/// Create a copy of UpdateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? menuIds = freezed,Object? pdfFileId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,menuIds: freezed == menuIds ? _self.menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>?,pdfFileId: freezed == pdfFileId ? _self.pdfFileId : pdfFileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMenuBundleInput].
extension UpdateMenuBundleInputPatterns on UpdateMenuBundleInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMenuBundleInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMenuBundleInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMenuBundleInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuBundleInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMenuBundleInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMenuBundleInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  List<int>? menuIds,  String? pdfFileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMenuBundleInput() when $default != null:
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  List<int>? menuIds,  String? pdfFileId)  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuBundleInput():
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  List<int>? menuIds,  String? pdfFileId)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMenuBundleInput() when $default != null:
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateMenuBundleInput extends UpdateMenuBundleInput {
  const _UpdateMenuBundleInput({required this.id, this.name, final  List<int>? menuIds, this.pdfFileId}): _menuIds = menuIds,super._();
  

@override final  int id;
@override final  String? name;
 final  List<int>? _menuIds;
@override List<int>? get menuIds {
  final value = _menuIds;
  if (value == null) return null;
  if (_menuIds is EqualUnmodifiableListView) return _menuIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? pdfFileId;

/// Create a copy of UpdateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMenuBundleInputCopyWith<_UpdateMenuBundleInput> get copyWith => __$UpdateMenuBundleInputCopyWithImpl<_UpdateMenuBundleInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMenuBundleInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._menuIds, _menuIds)&&(identical(other.pdfFileId, pdfFileId) || other.pdfFileId == pdfFileId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_menuIds),pdfFileId);

@override
String toString() {
  return 'UpdateMenuBundleInput(id: $id, name: $name, menuIds: $menuIds, pdfFileId: $pdfFileId)';
}


}

/// @nodoc
abstract mixin class _$UpdateMenuBundleInputCopyWith<$Res> implements $UpdateMenuBundleInputCopyWith<$Res> {
  factory _$UpdateMenuBundleInputCopyWith(_UpdateMenuBundleInput value, $Res Function(_UpdateMenuBundleInput) _then) = __$UpdateMenuBundleInputCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, List<int>? menuIds, String? pdfFileId
});




}
/// @nodoc
class __$UpdateMenuBundleInputCopyWithImpl<$Res>
    implements _$UpdateMenuBundleInputCopyWith<$Res> {
  __$UpdateMenuBundleInputCopyWithImpl(this._self, this._then);

  final _UpdateMenuBundleInput _self;
  final $Res Function(_UpdateMenuBundleInput) _then;

/// Create a copy of UpdateMenuBundleInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? menuIds = freezed,Object? pdfFileId = freezed,}) {
  return _then(_UpdateMenuBundleInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,menuIds: freezed == menuIds ? _self._menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>?,pdfFileId: freezed == pdfFileId ? _self.pdfFileId : pdfFileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
