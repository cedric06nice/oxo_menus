// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WidgetDto {

 String get id;@JsonKey(name: 'date_created') DateTime? get dateCreated;@JsonKey(name: 'date_updated') DateTime? get dateUpdated;@JsonKey(name: 'column_id') String get columnId; String get type; String get version; int get index; Map<String, dynamic> get props;@JsonKey(name: 'style_json') Map<String, dynamic>? get styleJson;
/// Create a copy of WidgetDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetDtoCopyWith<WidgetDto> get copyWith => _$WidgetDtoCopyWithImpl<WidgetDto>(this as WidgetDto, _$identity);

  /// Serializes this WidgetDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.props, props)&&const DeepCollectionEquality().equals(other.styleJson, styleJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,columnId,type,version,index,const DeepCollectionEquality().hash(props),const DeepCollectionEquality().hash(styleJson));

@override
String toString() {
  return 'WidgetDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, columnId: $columnId, type: $type, version: $version, index: $index, props: $props, styleJson: $styleJson)';
}


}

/// @nodoc
abstract mixin class $WidgetDtoCopyWith<$Res>  {
  factory $WidgetDtoCopyWith(WidgetDto value, $Res Function(WidgetDto) _then) = _$WidgetDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'column_id') String columnId, String type, String version, int index, Map<String, dynamic> props,@JsonKey(name: 'style_json') Map<String, dynamic>? styleJson
});




}
/// @nodoc
class _$WidgetDtoCopyWithImpl<$Res>
    implements $WidgetDtoCopyWith<$Res> {
  _$WidgetDtoCopyWithImpl(this._self, this._then);

  final WidgetDto _self;
  final $Res Function(WidgetDto) _then;

/// Create a copy of WidgetDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? columnId = null,Object? type = null,Object? version = null,Object? index = null,Object? props = null,Object? styleJson = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,styleJson: freezed == styleJson ? _self.styleJson : styleJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetDto].
extension WidgetDtoPatterns on WidgetDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetDto value)  $default,){
final _that = this;
switch (_that) {
case _WidgetDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetDto value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'column_id')  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props, @JsonKey(name: 'style_json')  Map<String, dynamic>? styleJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.styleJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'column_id')  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props, @JsonKey(name: 'style_json')  Map<String, dynamic>? styleJson)  $default,) {final _that = this;
switch (_that) {
case _WidgetDto():
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.styleJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'column_id')  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props, @JsonKey(name: 'style_json')  Map<String, dynamic>? styleJson)?  $default,) {final _that = this;
switch (_that) {
case _WidgetDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.styleJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetDto extends WidgetDto {
  const _WidgetDto({required this.id, @JsonKey(name: 'date_created') this.dateCreated, @JsonKey(name: 'date_updated') this.dateUpdated, @JsonKey(name: 'column_id') required this.columnId, required this.type, required this.version, required this.index, required final  Map<String, dynamic> props, @JsonKey(name: 'style_json') final  Map<String, dynamic>? styleJson}): _props = props,_styleJson = styleJson,super._();
  factory _WidgetDto.fromJson(Map<String, dynamic> json) => _$WidgetDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'date_created') final  DateTime? dateCreated;
@override@JsonKey(name: 'date_updated') final  DateTime? dateUpdated;
@override@JsonKey(name: 'column_id') final  String columnId;
@override final  String type;
@override final  String version;
@override final  int index;
 final  Map<String, dynamic> _props;
@override Map<String, dynamic> get props {
  if (_props is EqualUnmodifiableMapView) return _props;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_props);
}

 final  Map<String, dynamic>? _styleJson;
@override@JsonKey(name: 'style_json') Map<String, dynamic>? get styleJson {
  final value = _styleJson;
  if (value == null) return null;
  if (_styleJson is EqualUnmodifiableMapView) return _styleJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WidgetDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetDtoCopyWith<_WidgetDto> get copyWith => __$WidgetDtoCopyWithImpl<_WidgetDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other._props, _props)&&const DeepCollectionEquality().equals(other._styleJson, _styleJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,columnId,type,version,index,const DeepCollectionEquality().hash(_props),const DeepCollectionEquality().hash(_styleJson));

@override
String toString() {
  return 'WidgetDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, columnId: $columnId, type: $type, version: $version, index: $index, props: $props, styleJson: $styleJson)';
}


}

/// @nodoc
abstract mixin class _$WidgetDtoCopyWith<$Res> implements $WidgetDtoCopyWith<$Res> {
  factory _$WidgetDtoCopyWith(_WidgetDto value, $Res Function(_WidgetDto) _then) = __$WidgetDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'column_id') String columnId, String type, String version, int index, Map<String, dynamic> props,@JsonKey(name: 'style_json') Map<String, dynamic>? styleJson
});




}
/// @nodoc
class __$WidgetDtoCopyWithImpl<$Res>
    implements _$WidgetDtoCopyWith<$Res> {
  __$WidgetDtoCopyWithImpl(this._self, this._then);

  final _WidgetDto _self;
  final $Res Function(_WidgetDto) _then;

/// Create a copy of WidgetDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? columnId = null,Object? type = null,Object? version = null,Object? index = null,Object? props = null,Object? styleJson = freezed,}) {
  return _then(_WidgetDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,props: null == props ? _self._props : props // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,styleJson: freezed == styleJson ? _self._styleJson : styleJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
