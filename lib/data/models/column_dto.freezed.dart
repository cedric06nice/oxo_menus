// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ColumnDto {

 String get id;@JsonKey(name: 'date_created') DateTime? get dateCreated;@JsonKey(name: 'date_updated') DateTime? get dateUpdated;@JsonKey(name: 'container_id') String get containerId; int get index; int? get flex; double? get width;
/// Create a copy of ColumnDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColumnDtoCopyWith<ColumnDto> get copyWith => _$ColumnDtoCopyWithImpl<ColumnDto>(this as ColumnDto, _$identity);

  /// Serializes this ColumnDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColumnDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,containerId,index,flex,width);

@override
String toString() {
  return 'ColumnDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, containerId: $containerId, index: $index, flex: $flex, width: $width)';
}


}

/// @nodoc
abstract mixin class $ColumnDtoCopyWith<$Res>  {
  factory $ColumnDtoCopyWith(ColumnDto value, $Res Function(ColumnDto) _then) = _$ColumnDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'container_id') String containerId, int index, int? flex, double? width
});




}
/// @nodoc
class _$ColumnDtoCopyWithImpl<$Res>
    implements $ColumnDtoCopyWith<$Res> {
  _$ColumnDtoCopyWithImpl(this._self, this._then);

  final ColumnDto _self;
  final $Res Function(ColumnDto) _then;

/// Create a copy of ColumnDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColumnDto].
extension ColumnDtoPatterns on ColumnDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColumnDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColumnDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColumnDto value)  $default,){
final _that = this;
switch (_that) {
case _ColumnDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColumnDto value)?  $default,){
final _that = this;
switch (_that) {
case _ColumnDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'container_id')  String containerId,  int index,  int? flex,  double? width)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColumnDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.containerId,_that.index,_that.flex,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'container_id')  String containerId,  int index,  int? flex,  double? width)  $default,) {final _that = this;
switch (_that) {
case _ColumnDto():
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.containerId,_that.index,_that.flex,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'date_created')  DateTime? dateCreated, @JsonKey(name: 'date_updated')  DateTime? dateUpdated, @JsonKey(name: 'container_id')  String containerId,  int index,  int? flex,  double? width)?  $default,) {final _that = this;
switch (_that) {
case _ColumnDto() when $default != null:
return $default(_that.id,_that.dateCreated,_that.dateUpdated,_that.containerId,_that.index,_that.flex,_that.width);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ColumnDto extends ColumnDto {
  const _ColumnDto({required this.id, @JsonKey(name: 'date_created') this.dateCreated, @JsonKey(name: 'date_updated') this.dateUpdated, @JsonKey(name: 'container_id') required this.containerId, required this.index, this.flex, this.width}): super._();
  factory _ColumnDto.fromJson(Map<String, dynamic> json) => _$ColumnDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'date_created') final  DateTime? dateCreated;
@override@JsonKey(name: 'date_updated') final  DateTime? dateUpdated;
@override@JsonKey(name: 'container_id') final  String containerId;
@override final  int index;
@override final  int? flex;
@override final  double? width;

/// Create a copy of ColumnDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColumnDtoCopyWith<_ColumnDto> get copyWith => __$ColumnDtoCopyWithImpl<_ColumnDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColumnDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColumnDto&&(identical(other.id, id) || other.id == id)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateCreated,dateUpdated,containerId,index,flex,width);

@override
String toString() {
  return 'ColumnDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, containerId: $containerId, index: $index, flex: $flex, width: $width)';
}


}

/// @nodoc
abstract mixin class _$ColumnDtoCopyWith<$Res> implements $ColumnDtoCopyWith<$Res> {
  factory _$ColumnDtoCopyWith(_ColumnDto value, $Res Function(_ColumnDto) _then) = __$ColumnDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'date_created') DateTime? dateCreated,@JsonKey(name: 'date_updated') DateTime? dateUpdated,@JsonKey(name: 'container_id') String containerId, int index, int? flex, double? width
});




}
/// @nodoc
class __$ColumnDtoCopyWithImpl<$Res>
    implements _$ColumnDtoCopyWith<$Res> {
  __$ColumnDtoCopyWithImpl(this._self, this._then);

  final _ColumnDto _self;
  final $Res Function(_ColumnDto) _then;

/// Create a copy of ColumnDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,}) {
  return _then(_ColumnDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
