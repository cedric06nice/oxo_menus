// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AllergenInfo {

/// The UK allergen type
 UkAllergen get allergen;/// Whether this is a "may contain" vs definite contains
 bool get mayContain;/// Optional details (for gluten: specific cereals; for nuts: specific nuts)
 String? get details;
/// Create a copy of AllergenInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllergenInfoCopyWith<AllergenInfo> get copyWith => _$AllergenInfoCopyWithImpl<AllergenInfo>(this as AllergenInfo, _$identity);

  /// Serializes this AllergenInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllergenInfo&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.mayContain, mayContain) || other.mayContain == mayContain)&&(identical(other.details, details) || other.details == details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allergen,mayContain,details);

@override
String toString() {
  return 'AllergenInfo(allergen: $allergen, mayContain: $mayContain, details: $details)';
}


}

/// @nodoc
abstract mixin class $AllergenInfoCopyWith<$Res>  {
  factory $AllergenInfoCopyWith(AllergenInfo value, $Res Function(AllergenInfo) _then) = _$AllergenInfoCopyWithImpl;
@useResult
$Res call({
 UkAllergen allergen, bool mayContain, String? details
});




}
/// @nodoc
class _$AllergenInfoCopyWithImpl<$Res>
    implements $AllergenInfoCopyWith<$Res> {
  _$AllergenInfoCopyWithImpl(this._self, this._then);

  final AllergenInfo _self;
  final $Res Function(AllergenInfo) _then;

/// Create a copy of AllergenInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allergen = null,Object? mayContain = null,Object? details = freezed,}) {
  return _then(_self.copyWith(
allergen: null == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as UkAllergen,mayContain: null == mayContain ? _self.mayContain : mayContain // ignore: cast_nullable_to_non_nullable
as bool,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AllergenInfo].
extension AllergenInfoPatterns on AllergenInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllergenInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllergenInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllergenInfo value)  $default,){
final _that = this;
switch (_that) {
case _AllergenInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllergenInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AllergenInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UkAllergen allergen,  bool mayContain,  String? details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllergenInfo() when $default != null:
return $default(_that.allergen,_that.mayContain,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UkAllergen allergen,  bool mayContain,  String? details)  $default,) {final _that = this;
switch (_that) {
case _AllergenInfo():
return $default(_that.allergen,_that.mayContain,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UkAllergen allergen,  bool mayContain,  String? details)?  $default,) {final _that = this;
switch (_that) {
case _AllergenInfo() when $default != null:
return $default(_that.allergen,_that.mayContain,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AllergenInfo extends AllergenInfo {
  const _AllergenInfo({required this.allergen, this.mayContain = false, this.details}): super._();
  factory _AllergenInfo.fromJson(Map<String, dynamic> json) => _$AllergenInfoFromJson(json);

/// The UK allergen type
@override final  UkAllergen allergen;
/// Whether this is a "may contain" vs definite contains
@override@JsonKey() final  bool mayContain;
/// Optional details (for gluten: specific cereals; for nuts: specific nuts)
@override final  String? details;

/// Create a copy of AllergenInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllergenInfoCopyWith<_AllergenInfo> get copyWith => __$AllergenInfoCopyWithImpl<_AllergenInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AllergenInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllergenInfo&&(identical(other.allergen, allergen) || other.allergen == allergen)&&(identical(other.mayContain, mayContain) || other.mayContain == mayContain)&&(identical(other.details, details) || other.details == details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allergen,mayContain,details);

@override
String toString() {
  return 'AllergenInfo(allergen: $allergen, mayContain: $mayContain, details: $details)';
}


}

/// @nodoc
abstract mixin class _$AllergenInfoCopyWith<$Res> implements $AllergenInfoCopyWith<$Res> {
  factory _$AllergenInfoCopyWith(_AllergenInfo value, $Res Function(_AllergenInfo) _then) = __$AllergenInfoCopyWithImpl;
@override @useResult
$Res call({
 UkAllergen allergen, bool mayContain, String? details
});




}
/// @nodoc
class __$AllergenInfoCopyWithImpl<$Res>
    implements _$AllergenInfoCopyWith<$Res> {
  __$AllergenInfoCopyWithImpl(this._self, this._then);

  final _AllergenInfo _self;
  final $Res Function(_AllergenInfo) _then;

/// Create a copy of AllergenInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allergen = null,Object? mayContain = null,Object? details = freezed,}) {
  return _then(_AllergenInfo(
allergen: null == allergen ? _self.allergen : allergen // ignore: cast_nullable_to_non_nullable
as UkAllergen,mayContain: null == mayContain ? _self.mayContain : mayContain // ignore: cast_nullable_to_non_nullable
as bool,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
