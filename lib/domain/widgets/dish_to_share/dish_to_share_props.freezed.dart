// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish_to_share_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DishToShareProps {

 String get name; double get price; String? get description; int? get calories; List<String> get allergens; List<AllergenInfo> get allergenInfo; DietaryType? get dietary; int? get servings;
/// Create a copy of DishToShareProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishToSharePropsCopyWith<DishToShareProps> get copyWith => _$DishToSharePropsCopyWithImpl<DishToShareProps>(this as DishToShareProps, _$identity);

  /// Serializes this DishToShareProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DishToShareProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&const DeepCollectionEquality().equals(other.allergens, allergens)&&const DeepCollectionEquality().equals(other.allergenInfo, allergenInfo)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.servings, servings) || other.servings == servings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,calories,const DeepCollectionEquality().hash(allergens),const DeepCollectionEquality().hash(allergenInfo),dietary,servings);

@override
String toString() {
  return 'DishToShareProps(name: $name, price: $price, description: $description, calories: $calories, allergens: $allergens, allergenInfo: $allergenInfo, dietary: $dietary, servings: $servings)';
}


}

/// @nodoc
abstract mixin class $DishToSharePropsCopyWith<$Res>  {
  factory $DishToSharePropsCopyWith(DishToShareProps value, $Res Function(DishToShareProps) _then) = _$DishToSharePropsCopyWithImpl;
@useResult
$Res call({
 String name, double price, String? description, int? calories, List<String> allergens, List<AllergenInfo> allergenInfo, DietaryType? dietary, int? servings
});




}
/// @nodoc
class _$DishToSharePropsCopyWithImpl<$Res>
    implements $DishToSharePropsCopyWith<$Res> {
  _$DishToSharePropsCopyWithImpl(this._self, this._then);

  final DishToShareProps _self;
  final $Res Function(DishToShareProps) _then;

/// Create a copy of DishToShareProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? calories = freezed,Object? allergens = null,Object? allergenInfo = null,Object? dietary = freezed,Object? servings = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,allergens: null == allergens ? _self.allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<String>,allergenInfo: null == allergenInfo ? _self.allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,servings: freezed == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DishToShareProps].
extension DishToSharePropsPatterns on DishToShareProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DishToShareProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DishToShareProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DishToShareProps value)  $default,){
final _that = this;
switch (_that) {
case _DishToShareProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DishToShareProps value)?  $default,){
final _that = this;
switch (_that) {
case _DishToShareProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  int? calories,  List<String> allergens,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  int? servings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DishToShareProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.calories,_that.allergens,_that.allergenInfo,_that.dietary,_that.servings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  String? description,  int? calories,  List<String> allergens,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  int? servings)  $default,) {final _that = this;
switch (_that) {
case _DishToShareProps():
return $default(_that.name,_that.price,_that.description,_that.calories,_that.allergens,_that.allergenInfo,_that.dietary,_that.servings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  String? description,  int? calories,  List<String> allergens,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  int? servings)?  $default,) {final _that = this;
switch (_that) {
case _DishToShareProps() when $default != null:
return $default(_that.name,_that.price,_that.description,_that.calories,_that.allergens,_that.allergenInfo,_that.dietary,_that.servings);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DishToShareProps extends DishToShareProps {
  const _DishToShareProps({required this.name, required this.price, this.description, this.calories, final  List<String> allergens = const [], final  List<AllergenInfo> allergenInfo = const [], this.dietary, this.servings}): _allergens = allergens,_allergenInfo = allergenInfo,super._();
  factory _DishToShareProps.fromJson(Map<String, dynamic> json) => _$DishToSharePropsFromJson(json);

@override final  String name;
@override final  double price;
@override final  String? description;
@override final  int? calories;
 final  List<String> _allergens;
@override@JsonKey() List<String> get allergens {
  if (_allergens is EqualUnmodifiableListView) return _allergens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergens);
}

 final  List<AllergenInfo> _allergenInfo;
@override@JsonKey() List<AllergenInfo> get allergenInfo {
  if (_allergenInfo is EqualUnmodifiableListView) return _allergenInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergenInfo);
}

@override final  DietaryType? dietary;
@override final  int? servings;

/// Create a copy of DishToShareProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishToSharePropsCopyWith<_DishToShareProps> get copyWith => __$DishToSharePropsCopyWithImpl<_DishToShareProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DishToSharePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DishToShareProps&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&const DeepCollectionEquality().equals(other._allergens, _allergens)&&const DeepCollectionEquality().equals(other._allergenInfo, _allergenInfo)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.servings, servings) || other.servings == servings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,description,calories,const DeepCollectionEquality().hash(_allergens),const DeepCollectionEquality().hash(_allergenInfo),dietary,servings);

@override
String toString() {
  return 'DishToShareProps(name: $name, price: $price, description: $description, calories: $calories, allergens: $allergens, allergenInfo: $allergenInfo, dietary: $dietary, servings: $servings)';
}


}

/// @nodoc
abstract mixin class _$DishToSharePropsCopyWith<$Res> implements $DishToSharePropsCopyWith<$Res> {
  factory _$DishToSharePropsCopyWith(_DishToShareProps value, $Res Function(_DishToShareProps) _then) = __$DishToSharePropsCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, String? description, int? calories, List<String> allergens, List<AllergenInfo> allergenInfo, DietaryType? dietary, int? servings
});




}
/// @nodoc
class __$DishToSharePropsCopyWithImpl<$Res>
    implements _$DishToSharePropsCopyWith<$Res> {
  __$DishToSharePropsCopyWithImpl(this._self, this._then);

  final _DishToShareProps _self;
  final $Res Function(_DishToShareProps) _then;

/// Create a copy of DishToShareProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? description = freezed,Object? calories = freezed,Object? allergens = null,Object? allergenInfo = null,Object? dietary = freezed,Object? servings = freezed,}) {
  return _then(_DishToShareProps(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,allergens: null == allergens ? _self._allergens : allergens // ignore: cast_nullable_to_non_nullable
as List<String>,allergenInfo: null == allergenInfo ? _self._allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,servings: freezed == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
