// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Column {

 String get id; String get containerId; int get index; int? get flex; double? get width; DateTime? get dateCreated; DateTime? get dateUpdated;
/// Create a copy of Column
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColumnCopyWith<Column> get copyWith => _$ColumnCopyWithImpl<Column>(this as Column, _$identity);

  /// Serializes this Column to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Column&&(identical(other.id, id) || other.id == id)&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,containerId,index,flex,width,dateCreated,dateUpdated);

@override
String toString() {
  return 'Column(id: $id, containerId: $containerId, index: $index, flex: $flex, width: $width, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class $ColumnCopyWith<$Res>  {
  factory $ColumnCopyWith(Column value, $Res Function(Column) _then) = _$ColumnCopyWithImpl;
@useResult
$Res call({
 String id, String containerId, int index, int? flex, double? width, DateTime? dateCreated, DateTime? dateUpdated
});




}
/// @nodoc
class _$ColumnCopyWithImpl<$Res>
    implements $ColumnCopyWith<$Res> {
  _$ColumnCopyWithImpl(this._self, this._then);

  final Column _self;
  final $Res Function(Column) _then;

/// Create a copy of Column
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Column].
extension ColumnPatterns on Column {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Column value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Column() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Column value)  $default,){
final _that = this;
switch (_that) {
case _Column():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Column value)?  $default,){
final _that = this;
switch (_that) {
case _Column() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String containerId,  int index,  int? flex,  double? width,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Column() when $default != null:
return $default(_that.id,_that.containerId,_that.index,_that.flex,_that.width,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String containerId,  int index,  int? flex,  double? width,  DateTime? dateCreated,  DateTime? dateUpdated)  $default,) {final _that = this;
switch (_that) {
case _Column():
return $default(_that.id,_that.containerId,_that.index,_that.flex,_that.width,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String containerId,  int index,  int? flex,  double? width,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,) {final _that = this;
switch (_that) {
case _Column() when $default != null:
return $default(_that.id,_that.containerId,_that.index,_that.flex,_that.width,_that.dateCreated,_that.dateUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Column extends Column {
  const _Column({required this.id, required this.containerId, required this.index, this.flex, this.width, this.dateCreated, this.dateUpdated}): super._();
  factory _Column.fromJson(Map<String, dynamic> json) => _$ColumnFromJson(json);

@override final  String id;
@override final  String containerId;
@override final  int index;
@override final  int? flex;
@override final  double? width;
@override final  DateTime? dateCreated;
@override final  DateTime? dateUpdated;

/// Create a copy of Column
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColumnCopyWith<_Column> get copyWith => __$ColumnCopyWithImpl<_Column>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColumnToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Column&&(identical(other.id, id) || other.id == id)&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.flex, flex) || other.flex == flex)&&(identical(other.width, width) || other.width == width)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,containerId,index,flex,width,dateCreated,dateUpdated);

@override
String toString() {
  return 'Column(id: $id, containerId: $containerId, index: $index, flex: $flex, width: $width, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class _$ColumnCopyWith<$Res> implements $ColumnCopyWith<$Res> {
  factory _$ColumnCopyWith(_Column value, $Res Function(_Column) _then) = __$ColumnCopyWithImpl;
@override @useResult
$Res call({
 String id, String containerId, int index, int? flex, double? width, DateTime? dateCreated, DateTime? dateUpdated
});




}
/// @nodoc
class __$ColumnCopyWithImpl<$Res>
    implements _$ColumnCopyWith<$Res> {
  __$ColumnCopyWithImpl(this._self, this._then);

  final _Column _self;
  final $Res Function(_Column) _then;

/// Create a copy of Column
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? containerId = null,Object? index = null,Object? flex = freezed,Object? width = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_Column(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,containerId: null == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,flex: freezed == flex ? _self.flex : flex // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
