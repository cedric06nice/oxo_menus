// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wine_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WineProps {

 String get name; double get price; String? get description; int? get vintage; DietaryType? get dietary; bool get containsSulphites;
/// Create a copy of WineProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WinePropsCopyWith<WineProps> get copyWith => _$WinePropsCopyWithImpl<WineProps>(this as WineProps, _$identity);

  /// Serializes this WineProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WineProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.vintage, vintage) || other.vintage == vintage)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.containsSulphites, containsSulphites) || other.containsSulphites == containsSulphites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,vintage,dietary,containsSulphites);

@override
String toString() {
  return 'WineProps(name: $name, price: $price, description: $description, vintage: $vintage, dietary: $dietary, containsSulphites: $containsSulphites)';
}


}

/// @nodoc
abstract mixin class $WinePropsCopyWith<$Res>  {
  factory $WinePropsCopyWith(WineProps value, $Res Function(WineProps) _then) = _$WinePropsCopyWithImpl;
@useResult
$Res call({
 String name, double price, String? description, int? vintage, DietaryType? dietary, bool containsSulphites
});




}
/// @nodoc
class _$WinePropsCopyWithImpl<$Res>
    implements $WinePropsCopyWith<$Res> {
  _$WinePropsCopyWithImpl(this._self, this._then);

  final WineProps _self;
  final $Res Function(WineProps) _then;

/// Create a copy of WineProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? vintage = freezed,Object? dietary = freezed,Object? containsSulphites = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,vintage: freezed == vintage ? _self.vintage : vintage // ignore: cast_nullable_to_non_nullable
as int?,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,containsSulphites: null == containsSulphites ? _self.containsSulphites : containsSulphites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WineProps].
extension WinePropsPatterns on WineProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WineProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WineProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WineProps value)  $default,){
final _that = this;
switch (_that) {
case _WineProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WineProps value)?  $default,){
final _that = this;
switch (_that) {
case _WineProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  int? vintage,  DietaryType? dietary,  bool containsSulphites)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WineProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.vintage,_that.dietary,_that.containsSulphites);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  int? vintage,  DietaryType? dietary,  bool containsSulphites)  $default,) {final _that = this;
switch (_that) {
case _WineProps():
return $default(_that.name,_that.price,_that.description,_that.vintage,_that.dietary,_that.containsSulphites);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  String? description,  int? vintage,  DietaryType? dietary,  bool containsSulphites)?  $default,) {final _that = this;
switch (_that) {
case _WineProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.vintage,_that.dietary,_that.containsSulphites);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WineProps extends WineProps {
  const _WineProps({required this.name, required this.price, this.description, this.vintage, this.dietary, this.containsSulphites = false}): super._();
  factory _WineProps.fromJson(Map<String, dynamic> json) => _$WinePropsFromJson(json);

@override final  String name;
@override final  double price;
@override final  String? description;
@override final  int? vintage;
@override final  DietaryType? dietary;
@override@JsonKey() final  bool containsSulphites;

/// Create a copy of WineProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WinePropsCopyWith<_WineProps> get copyWith => __$WinePropsCopyWithImpl<_WineProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WinePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WineProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.vintage, vintage) || other.vintage == vintage)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.containsSulphites, containsSulphites) || other.containsSulphites == containsSulphites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,vintage,dietary,containsSulphites);

@override
String toString() {
  return 'WineProps(name: $name, price: $price, description: $description, vintage: $vintage, dietary: $dietary, containsSulphites: $containsSulphites)';
}


}

/// @nodoc
abstract mixin class _$WinePropsCopyWith<$Res> implements $WinePropsCopyWith<$Res> {
  factory _$WinePropsCopyWith(_WineProps value, $Res Function(_WineProps) _then) = __$WinePropsCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, String? description, int? vintage, DietaryType? dietary, bool containsSulphites
});




}
/// @nodoc
class __$WinePropsCopyWithImpl<$Res>
    implements _$WinePropsCopyWith<$Res> {
  __$WinePropsCopyWithImpl(this._self, this._then);

  final _WineProps _self;
  final $Res Function(_WineProps) _then;

/// Create a copy of WineProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? vintage = freezed,Object? dietary = freezed,Object? containsSulphites = null,}) {
  return _then(_WineProps(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,vintage: freezed == vintage ? _self.vintage : vintage // ignore: cast_nullable_to_non_nullable
as int?,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,containsSulphites: null == containsSulphites ? _self.containsSulphites : containsSulphites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
