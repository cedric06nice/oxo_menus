// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_variant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceVariant {

 String get label; double get price;
/// Create a copy of PriceVariant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceVariantCopyWith<PriceVariant> get copyWith => _$PriceVariantCopyWithImpl<PriceVariant>(this as PriceVariant, _$identity);

  /// Serializes this PriceVariant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceVariant&&(identical(other.label, label) || other.label == label)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,price);

@override
String toString() {
  return 'PriceVariant(label: $label, price: $price)';
}


}

/// @nodoc
abstract mixin class $PriceVariantCopyWith<$Res>  {
  factory $PriceVariantCopyWith(PriceVariant value, $Res Function(PriceVariant) _then) = _$PriceVariantCopyWithImpl;
@useResult
$Res call({
 String label, double price
});




}
/// @nodoc
class _$PriceVariantCopyWithImpl<$Res>
    implements $PriceVariantCopyWith<$Res> {
  _$PriceVariantCopyWithImpl(this._self, this._then);

  final PriceVariant _self;
  final $Res Function(PriceVariant) _then;

/// Create a copy of PriceVariant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? price = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceVariant].
extension PriceVariantPatterns on PriceVariant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceVariant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceVariant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceVariant value)  $default,){
final _that = this;
switch (_that) {
case _PriceVariant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceVariant value)?  $default,){
final _that = this;
switch (_that) {
case _PriceVariant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceVariant() when $default != null:
return $default(_that.label,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double price)  $default,) {final _that = this;
switch (_that) {
case _PriceVariant():
return $default(_that.label,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double price)?  $default,) {final _that = this;
switch (_that) {
case _PriceVariant() when $default != null:
return $default(_that.label,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceVariant extends PriceVariant {
  const _PriceVariant({required this.label, required this.price}): super._();
  factory _PriceVariant.fromJson(Map<String, dynamic> json) => _$PriceVariantFromJson(json);

@override final  String label;
@override final  double price;

/// Create a copy of PriceVariant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceVariantCopyWith<_PriceVariant> get copyWith => __$PriceVariantCopyWithImpl<_PriceVariant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceVariantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceVariant&&(identical(other.label, label) || other.label == label)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,price);

@override
String toString() {
  return 'PriceVariant(label: $label, price: $price)';
}


}

/// @nodoc
abstract mixin class _$PriceVariantCopyWith<$Res> implements $PriceVariantCopyWith<$Res> {
  factory _$PriceVariantCopyWith(_PriceVariant value, $Res Function(_PriceVariant) _then) = __$PriceVariantCopyWithImpl;
@override @useResult
$Res call({
 String label, double price
});




}
/// @nodoc
class __$PriceVariantCopyWithImpl<$Res>
    implements _$PriceVariantCopyWith<$Res> {
  __$PriceVariantCopyWithImpl(this._self, this._then);

  final _PriceVariant _self;
  final $Res Function(_PriceVariant) _then;

/// Create a copy of PriceVariant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? price = null,}) {
  return _then(_PriceVariant(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
