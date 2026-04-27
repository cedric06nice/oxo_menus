// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_display_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuDisplayOptions {

/// Whether to display prices across all widgets
 bool get showPrices;/// Whether to display allergen information across all widgets
 bool get showAllergens;
/// Create a copy of MenuDisplayOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuDisplayOptionsCopyWith<MenuDisplayOptions> get copyWith => _$MenuDisplayOptionsCopyWithImpl<MenuDisplayOptions>(this as MenuDisplayOptions, _$identity);

  /// Serializes this MenuDisplayOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuDisplayOptions&&(identical(other.showPrices, showPrices) || other.showPrices == showPrices)&&(identical(other.showAllergens, showAllergens) || other.showAllergens == showAllergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showPrices,showAllergens);

@override
String toString() {
  return 'MenuDisplayOptions(showPrices: $showPrices, showAllergens: $showAllergens)';
}


}

/// @nodoc
abstract mixin class $MenuDisplayOptionsCopyWith<$Res>  {
  factory $MenuDisplayOptionsCopyWith(MenuDisplayOptions value, $Res Function(MenuDisplayOptions) _then) = _$MenuDisplayOptionsCopyWithImpl;
@useResult
$Res call({
 bool showPrices, bool showAllergens
});




}
/// @nodoc
class _$MenuDisplayOptionsCopyWithImpl<$Res>
    implements $MenuDisplayOptionsCopyWith<$Res> {
  _$MenuDisplayOptionsCopyWithImpl(this._self, this._then);

  final MenuDisplayOptions _self;
  final $Res Function(MenuDisplayOptions) _then;

/// Create a copy of MenuDisplayOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showPrices = null,Object? showAllergens = null,}) {
  return _then(_self.copyWith(
showPrices: null == showPrices ? _self.showPrices : showPrices // ignore: cast_nullable_to_non_nullable
as bool,showAllergens: null == showAllergens ? _self.showAllergens : showAllergens // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuDisplayOptions].
extension MenuDisplayOptionsPatterns on MenuDisplayOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuDisplayOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuDisplayOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuDisplayOptions value)  $default,){
final _that = this;
switch (_that) {
case _MenuDisplayOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuDisplayOptions value)?  $default,){
final _that = this;
switch (_that) {
case _MenuDisplayOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showPrices,  bool showAllergens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuDisplayOptions() when $default != null:
return $default(_that.showPrices,_that.showAllergens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showPrices,  bool showAllergens)  $default,) {final _that = this;
switch (_that) {
case _MenuDisplayOptions():
return $default(_that.showPrices,_that.showAllergens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showPrices,  bool showAllergens)?  $default,) {final _that = this;
switch (_that) {
case _MenuDisplayOptions() when $default != null:
return $default(_that.showPrices,_that.showAllergens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuDisplayOptions extends MenuDisplayOptions {
  const _MenuDisplayOptions({this.showPrices = true, this.showAllergens = true}): super._();
  factory _MenuDisplayOptions.fromJson(Map<String, dynamic> json) => _$MenuDisplayOptionsFromJson(json);

/// Whether to display prices across all widgets
@override@JsonKey() final  bool showPrices;
/// Whether to display allergen information across all widgets
@override@JsonKey() final  bool showAllergens;

/// Create a copy of MenuDisplayOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuDisplayOptionsCopyWith<_MenuDisplayOptions> get copyWith => __$MenuDisplayOptionsCopyWithImpl<_MenuDisplayOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuDisplayOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuDisplayOptions&&(identical(other.showPrices, showPrices) || other.showPrices == showPrices)&&(identical(other.showAllergens, showAllergens) || other.showAllergens == showAllergens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showPrices,showAllergens);

@override
String toString() {
  return 'MenuDisplayOptions(showPrices: $showPrices, showAllergens: $showAllergens)';
}


}

/// @nodoc
abstract mixin class _$MenuDisplayOptionsCopyWith<$Res> implements $MenuDisplayOptionsCopyWith<$Res> {
  factory _$MenuDisplayOptionsCopyWith(_MenuDisplayOptions value, $Res Function(_MenuDisplayOptions) _then) = __$MenuDisplayOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool showPrices, bool showAllergens
});




}
/// @nodoc
class __$MenuDisplayOptionsCopyWithImpl<$Res>
    implements _$MenuDisplayOptionsCopyWith<$Res> {
  __$MenuDisplayOptionsCopyWithImpl(this._self, this._then);

  final _MenuDisplayOptions _self;
  final $Res Function(_MenuDisplayOptions) _then;

/// Create a copy of MenuDisplayOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showPrices = null,Object? showAllergens = null,}) {
  return _then(_MenuDisplayOptions(
showPrices: null == showPrices ? _self.showPrices : showPrices // ignore: cast_nullable_to_non_nullable
as bool,showAllergens: null == showAllergens ? _self.showAllergens : showAllergens // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
