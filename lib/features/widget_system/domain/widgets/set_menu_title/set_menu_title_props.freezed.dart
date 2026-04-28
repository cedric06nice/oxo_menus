// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_menu_title_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetMenuTitleProps {

 String get title; String? get subtitle; bool get uppercase; String? get priceLabel1; double? get price1; String? get priceLabel2; double? get price2;
/// Create a copy of SetMenuTitleProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetMenuTitlePropsCopyWith<SetMenuTitleProps> get copyWith => _$SetMenuTitlePropsCopyWithImpl<SetMenuTitleProps>(this as SetMenuTitleProps, _$identity);

  /// Serializes this SetMenuTitleProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetMenuTitleProps&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.uppercase, uppercase) || other.uppercase == uppercase)&&(identical(other.priceLabel1, priceLabel1) || other.priceLabel1 == priceLabel1)&&(identical(other.price1, price1) || other.price1 == price1)&&(identical(other.priceLabel2, priceLabel2) || other.priceLabel2 == priceLabel2)&&(identical(other.price2, price2) || other.price2 == price2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,uppercase,priceLabel1,price1,priceLabel2,price2);

@override
String toString() {
  return 'SetMenuTitleProps(title: $title, subtitle: $subtitle, uppercase: $uppercase, priceLabel1: $priceLabel1, price1: $price1, priceLabel2: $priceLabel2, price2: $price2)';
}


}

/// @nodoc
abstract mixin class $SetMenuTitlePropsCopyWith<$Res>  {
  factory $SetMenuTitlePropsCopyWith(SetMenuTitleProps value, $Res Function(SetMenuTitleProps) _then) = _$SetMenuTitlePropsCopyWithImpl;
@useResult
$Res call({
 String title, String? subtitle, bool uppercase, String? priceLabel1, double? price1, String? priceLabel2, double? price2
});




}
/// @nodoc
class _$SetMenuTitlePropsCopyWithImpl<$Res>
    implements $SetMenuTitlePropsCopyWith<$Res> {
  _$SetMenuTitlePropsCopyWithImpl(this._self, this._then);

  final SetMenuTitleProps _self;
  final $Res Function(SetMenuTitleProps) _then;

/// Create a copy of SetMenuTitleProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? subtitle = freezed,Object? uppercase = null,Object? priceLabel1 = freezed,Object? price1 = freezed,Object? priceLabel2 = freezed,Object? price2 = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,uppercase: null == uppercase ? _self.uppercase : uppercase // ignore: cast_nullable_to_non_nullable
as bool,priceLabel1: freezed == priceLabel1 ? _self.priceLabel1 : priceLabel1 // ignore: cast_nullable_to_non_nullable
as String?,price1: freezed == price1 ? _self.price1 : price1 // ignore: cast_nullable_to_non_nullable
as double?,priceLabel2: freezed == priceLabel2 ? _self.priceLabel2 : priceLabel2 // ignore: cast_nullable_to_non_nullable
as String?,price2: freezed == price2 ? _self.price2 : price2 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetMenuTitleProps].
extension SetMenuTitlePropsPatterns on SetMenuTitleProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetMenuTitleProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetMenuTitleProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetMenuTitleProps value)  $default,){
final _that = this;
switch (_that) {
case _SetMenuTitleProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetMenuTitleProps value)?  $default,){
final _that = this;
switch (_that) {
case _SetMenuTitleProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? subtitle,  bool uppercase,  String? priceLabel1,  double? price1,  String? priceLabel2,  double? price2)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetMenuTitleProps() when $default != null:
return $default(_that.title,_that.subtitle,_that.uppercase,_that.priceLabel1,_that.price1,_that.priceLabel2,_that.price2);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? subtitle,  bool uppercase,  String? priceLabel1,  double? price1,  String? priceLabel2,  double? price2)  $default,) {final _that = this;
switch (_that) {
case _SetMenuTitleProps():
return $default(_that.title,_that.subtitle,_that.uppercase,_that.priceLabel1,_that.price1,_that.priceLabel2,_that.price2);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? subtitle,  bool uppercase,  String? priceLabel1,  double? price1,  String? priceLabel2,  double? price2)?  $default,) {final _that = this;
switch (_that) {
case _SetMenuTitleProps() when $default != null:
return $default(_that.title,_that.subtitle,_that.uppercase,_that.priceLabel1,_that.price1,_that.priceLabel2,_that.price2);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetMenuTitleProps extends SetMenuTitleProps {
  const _SetMenuTitleProps({required this.title, this.subtitle, this.uppercase = true, this.priceLabel1, this.price1, this.priceLabel2, this.price2}): super._();
  factory _SetMenuTitleProps.fromJson(Map<String, dynamic> json) => _$SetMenuTitlePropsFromJson(json);

@override final  String title;
@override final  String? subtitle;
@override@JsonKey() final  bool uppercase;
@override final  String? priceLabel1;
@override final  double? price1;
@override final  String? priceLabel2;
@override final  double? price2;

/// Create a copy of SetMenuTitleProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetMenuTitlePropsCopyWith<_SetMenuTitleProps> get copyWith => __$SetMenuTitlePropsCopyWithImpl<_SetMenuTitleProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetMenuTitlePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetMenuTitleProps&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.uppercase, uppercase) || other.uppercase == uppercase)&&(identical(other.priceLabel1, priceLabel1) || other.priceLabel1 == priceLabel1)&&(identical(other.price1, price1) || other.price1 == price1)&&(identical(other.priceLabel2, priceLabel2) || other.priceLabel2 == priceLabel2)&&(identical(other.price2, price2) || other.price2 == price2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,uppercase,priceLabel1,price1,priceLabel2,price2);

@override
String toString() {
  return 'SetMenuTitleProps(title: $title, subtitle: $subtitle, uppercase: $uppercase, priceLabel1: $priceLabel1, price1: $price1, priceLabel2: $priceLabel2, price2: $price2)';
}


}

/// @nodoc
abstract mixin class _$SetMenuTitlePropsCopyWith<$Res> implements $SetMenuTitlePropsCopyWith<$Res> {
  factory _$SetMenuTitlePropsCopyWith(_SetMenuTitleProps value, $Res Function(_SetMenuTitleProps) _then) = __$SetMenuTitlePropsCopyWithImpl;
@override @useResult
$Res call({
 String title, String? subtitle, bool uppercase, String? priceLabel1, double? price1, String? priceLabel2, double? price2
});




}
/// @nodoc
class __$SetMenuTitlePropsCopyWithImpl<$Res>
    implements _$SetMenuTitlePropsCopyWith<$Res> {
  __$SetMenuTitlePropsCopyWithImpl(this._self, this._then);

  final _SetMenuTitleProps _self;
  final $Res Function(_SetMenuTitleProps) _then;

/// Create a copy of SetMenuTitleProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? subtitle = freezed,Object? uppercase = null,Object? priceLabel1 = freezed,Object? price1 = freezed,Object? priceLabel2 = freezed,Object? price2 = freezed,}) {
  return _then(_SetMenuTitleProps(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,uppercase: null == uppercase ? _self.uppercase : uppercase // ignore: cast_nullable_to_non_nullable
as bool,priceLabel1: freezed == priceLabel1 ? _self.priceLabel1 : priceLabel1 // ignore: cast_nullable_to_non_nullable
as String?,price1: freezed == price1 ? _self.price1 : price1 // ignore: cast_nullable_to_non_nullable
as double?,priceLabel2: freezed == priceLabel2 ? _self.priceLabel2 : priceLabel2 // ignore: cast_nullable_to_non_nullable
as String?,price2: freezed == price2 ? _self.price2 : price2 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
