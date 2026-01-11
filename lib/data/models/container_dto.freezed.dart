// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerDto {

 String get id;@JsonKey(name: 'date_created') DateTime? get dateCreated;@JsonKey(name: 'date_updated') DateTime? get dateUpdated;@JsonKey(name: 'page_id') String get pageId; int get index; String? get name;@JsonKey(name: 'layout_json') Map<String, dynamic>? get layoutJson;
/// Create a copy of ContainerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerDtoCopyWith<ContainerDto> get copyWith => _$ContainerDtoCopyWithImpl<ContainerDto>(this as ContainerDto, _$identity);

  /// Serializes this ContainerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.layoutJson, layoutJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,pageId,index,name,const DeepCollectionEquality().hash(layoutJson));

@override
String toString() {
  return 'ContainerDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, pageId: $pageId, index: $index, name: $name, layoutJson: $layoutJson)';
}


}

/// @nodoc
abstract mixin class $ContainerDtoCopyWith<$Res>  {
  factory $ContainerDtoCopyWith(ContainerDto value, $Res Function(ContainerDto) _then) = _$ContainerDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'page_id') String pageId, int index, String? name,@JsonKey(name: 'layout_json') Map<String, dynamic>? layoutJson
});




}
/// @nodoc
class _$ContainerDtoCopyWithImpl<$Res>
    implements $ContainerDtoCopyWith<$Res> {
  _$ContainerDtoCopyWithImpl(this._self, this._then);

  final ContainerDto _self;
  final $Res Function(ContainerDto) _then;

/// Create a copy of ContainerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? pageId = null,Object? index = null,Object? name = freezed,Object? layoutJson = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,layoutJson: freezed == layoutJson ? _self.layoutJson : layoutJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContainerDto].
extension ContainerDtoPatterns on ContainerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerDto value)  $default,){
final _that = this;
switch (_that) {
case _ContainerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerDto value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'page_id')  String pageId,  int index,  String? name, @JsonKey(name: 'layout_json')  Map<String, dynamic>? layoutJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.pageId,_that.index,_that.name,_that.layoutJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'page_id')  String pageId,  int index,  String? name, @JsonKey(name: 'layout_json')  Map<String, dynamic>? layoutJson)  $default,) {final _that = this;
switch (_that) {
case _ContainerDto():
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.pageId,_that.index,_that.name,_that.layoutJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'page_id')  String pageId,  int index,  String? name, @JsonKey(name: 'layout_json')  Map<String, dynamic>? layoutJson)?  $default,) {final _that = this;
switch (_that) {
case _ContainerDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.pageId,_that.index,_that.name,_that.layoutJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerDto extends ContainerDto {
  const _ContainerDto({required this.id, @JsonKey(name: 'date_created') this.dateCreated, @JsonKey(name: 'date_updated') this.dateUpdated, @JsonKey(name: 'page_id') required this.pageId, required this.index, this.name, @JsonKey(name: 'layout_json') final  Map<String, dynamic>? layoutJson}): _layoutJson = layoutJson,super._();
  factory _ContainerDto.fromJson(Map<String, dynamic> json) => _$ContainerDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'date_created') final  DateTime? dateCreated;
@override@JsonKey(name: 'date_updated') final  DateTime? dateUpdated;
@override@JsonKey(name: 'page_id') final  String pageId;
@override final  int index;
@override final  String? name;
 final  Map<String, dynamic>? _layoutJson;
@override@JsonKey(name: 'layout_json') Map<String, dynamic>? get layoutJson {
  final value = _layoutJson;
  if (value == null) return null;
  if (_layoutJson is EqualUnmodifiableMapView) return _layoutJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ContainerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerDtoCopyWith<_ContainerDto> get copyWith => __$ContainerDtoCopyWithImpl<_ContainerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._layoutJson, _layoutJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,pageId,index,name,const DeepCollectionEquality().hash(_layoutJson));

@override
String toString() {
  return 'ContainerDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, pageId: $pageId, index: $index, name: $name, layoutJson: $layoutJson)';
}


}

/// @nodoc
abstract mixin class _$ContainerDtoCopyWith<$Res> implements $ContainerDtoCopyWith<$Res> {
  factory _$ContainerDtoCopyWith(_ContainerDto value, $Res Function(_ContainerDto) _then) = __$ContainerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'page_id') String pageId, int index, String? name,@JsonKey(name: 'layout_json') Map<String, dynamic>? layoutJson
});




}
/// @nodoc
class __$ContainerDtoCopyWithImpl<$Res>
    implements _$ContainerDtoCopyWith<$Res> {
  __$ContainerDtoCopyWithImpl(this._self, this._then);

  final _ContainerDto _self;
  final $Res Function(_ContainerDto) _then;

/// Create a copy of ContainerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? pageId = null,Object? index = null,Object? name = freezed,Object? layoutJson = freezed,}) {
  return _then(_ContainerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,layoutJson: freezed == layoutJson ? _self._layoutJson : layoutJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
