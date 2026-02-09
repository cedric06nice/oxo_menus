// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DishProps {

/// The name of the dish
 String get name;/// The price of the dish
 double get price;/// Optional description of the dish
 String? get description;/// Legacy allergens field (for backward compatibility)
/// @deprecated Use allergenInfo instead
 List<String> get allergens;/// Structured allergen information with UK allergen types
 List<AllergenInfo> get allergenInfo;/// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
 List<String> get dietary;
/// Create a copy of DishProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishPropsCopyWith<DishProps> get copyWith => _$DishPropsCopyWithImpl<DishProps>(this as DishProps, _$identity);

  /// Serializes this DishProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DishProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.allergens, allergens)&&const DeepCollectionEquality().equals(other.allergenInfo, allergenInfo)&&const DeepCollectionEquality().equals(other.dietary, dietary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,const DeepCollectionEquality().hash(allergens),const DeepCollectionEquality().hash(allergenInfo),const DeepCollectionEquality().hash(dietary));

@override
String toString() {
  return 'DishProps(name: $name, price: $price, description: $description, allergens: $allergens, allergenInfo: $allergenInfo, dietary: $dietary)';
}


}

/// @nodoc
abstract mixin class $DishPropsCopyWith<$Res>  {
  factory $DishPropsCopyWith(DishProps value, $Res Function(DishProps) _then) = _$DishPropsCopyWithImpl;
@useResult
$Res call({
 String name, double price, String? description, List<String> allergens, List<AllergenInfo> allergenInfo, List<String> dietary
});




}
/// @nodoc
class _$DishPropsCopyWithImpl<$Res>
    implements $DishPropsCopyWith<$Res> {
  _$DishPropsCopyWithImpl(this._self, this._then);

  final DishProps _self;
  final $Res Function(DishProps) _then;

/// Create a copy of DishProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? allergens = null,Object? allergenInfo = null,Object? dietary = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,allergens: null == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<String>,allergenInfo: null == allergenInfo ? _self.allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: null == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DishProps].
extension DishPropsPatterns on DishProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DishProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DishProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DishProps value)  $default,){
final _that = this;
switch (_that) {
case _DishProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DishProps value)?  $default,){
final _that = this;
switch (_that) {
case _DishProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  List<String> allergens,  List<AllergenInfo> allergenInfo,  List<String> dietary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DishProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.allergens,_that.allergenInfo,_that.dietary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  List<String> allergens,  List<AllergenInfo> allergenInfo,  List<String> dietary)  $default,) {final _that = this;
switch (_that) {
case _DishProps():
return $default(_that.name,_that.price,_that.description,_that.allergens,_that.allergenInfo,_that.dietary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  String? description,  List<String> allergens,  List<AllergenInfo> allergenInfo,  List<String> dietary)?  $default,) {final _that = this;
switch (_that) {
case _DishProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.allergens,_that.allergenInfo,_that.dietary);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DishProps extends DishProps {
  const _DishProps({required this.name, required this.price, this.description, final  List<String> allergens = const [], final  List<AllergenInfo> allergenInfo = const [], final  List<String> dietary = const []}): _allergens = allergens,_allergenInfo = allergenInfo,_dietary = dietary,super._();
  factory _DishProps.fromJson(Map<String, dynamic> json) => _$DishPropsFromJson(json);

/// The name of the dish
@override final  String name;
/// The price of the dish
@override final  double price;
/// Optional description of the dish
@override final  String? description;
/// Legacy allergens field (for backward compatibility)
/// @deprecated Use allergenInfo instead
 final  List<String> _allergens;
/// Legacy allergens field (for backward compatibility)
/// @deprecated Use allergenInfo instead
@override@JsonKey() List<String> get allergens {
  if (_allergens is EqualUnmodifiableListView) return _allergens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergens);
}

/// Structured allergen information with UK allergen types
 final  List<AllergenInfo> _allergenInfo;
/// Structured allergen information with UK allergen types
@override@JsonKey() List<AllergenInfo> get allergenInfo {
  if (_allergenInfo is EqualUnmodifiableListView) return _allergenInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergenInfo);
}

/// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
 final  List<String> _dietary;
/// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
@override@JsonKey() List<String> get dietary {
  if (_dietary is EqualUnmodifiableListView) return _dietary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietary);
}


/// Create a copy of DishProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishPropsCopyWith<_DishProps> get copyWith => __$DishPropsCopyWithImpl<_DishProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DishPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DishProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._allergens, _allergens)&&const DeepCollectionEquality().equals(other._allergenInfo, _allergenInfo)&&const DeepCollectionEquality().equals(other._dietary, _dietary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,const DeepCollectionEquality().hash(_allergens),const DeepCollectionEquality().hash(_allergenInfo),const DeepCollectionEquality().hash(_dietary));

@override
String toString() {
  return 'DishProps(name: $name, price: $price, description: $description, allergens: $allergens, allergenInfo: $allergenInfo, dietary: $dietary)';
}


}

/// @nodoc
abstract mixin class _$DishPropsCopyWith<$Res> implements $DishPropsCopyWith<$Res> {
  factory _$DishPropsCopyWith(_DishProps value, $Res Function(_DishProps) _then) = __$DishPropsCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, String? description, List<String> allergens, List<AllergenInfo> allergenInfo, List<String> dietary
});




}
/// @nodoc
class __$DishPropsCopyWithImpl<$Res>
    implements _$DishPropsCopyWith<$Res> {
  __$DishPropsCopyWithImpl(this._self, this._then);

  final _DishProps _self;
  final $Res Function(_DishProps) _then;

/// Create a copy of DishProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? allergens = null,Object? allergenInfo = null,Object? dietary = null,}) {
  return _then(_DishProps(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,allergens: null == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<String>,allergenInfo: null == allergenInfo ? _self._allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: null == dietary ? _self._dietary : dietary // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
