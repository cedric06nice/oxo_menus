// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_menu_dish_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetMenuDishProps {

 String get name; String? get description; int? get calories; List<AllergenInfo> get allergenInfo; DietaryType? get dietary; bool get hasSupplement; double get supplementPrice;
/// Create a copy of SetMenuDishProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetMenuDishPropsCopyWith<SetMenuDishProps> get copyWith => _$SetMenuDishPropsCopyWithImpl<SetMenuDishProps>(this as SetMenuDishProps, _$identity);

  /// Serializes this SetMenuDishProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetMenuDishProps&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&const DeepCollectionEquality().equals(other.allergenInfo, allergenInfo)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.hasSupplement, hasSupplement) || other.hasSupplement == hasSupplement)&&(identical(other.supplementPrice, supplementPrice) || other.supplementPrice == supplementPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,calories,const DeepCollectionEquality().hash(allergenInfo),dietary,hasSupplement,supplementPrice);

@override
String toString() {
  return 'SetMenuDishProps(name: $name, description: $description, calories: $calories, allergenInfo: $allergenInfo, dietary: $dietary, hasSupplement: $hasSupplement, supplementPrice: $supplementPrice)';
}


}

/// @nodoc
abstract mixin class $SetMenuDishPropsCopyWith<$Res>  {
  factory $SetMenuDishPropsCopyWith(SetMenuDishProps value, $Res Function(SetMenuDishProps) _then) = _$SetMenuDishPropsCopyWithImpl;
@useResult
$Res call({
 String name, String? description, int? calories, List<AllergenInfo> allergenInfo, DietaryType? dietary, bool hasSupplement, double supplementPrice
});




}
/// @nodoc
class _$SetMenuDishPropsCopyWithImpl<$Res>
    implements $SetMenuDishPropsCopyWith<$Res> {
  _$SetMenuDishPropsCopyWithImpl(this._self, this._then);

  final SetMenuDishProps _self;
  final $Res Function(SetMenuDishProps) _then;

/// Create a copy of SetMenuDishProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? calories = freezed,Object? allergenInfo = null,Object? dietary = freezed,Object? hasSupplement = null,Object? supplementPrice = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,allergenInfo: null == allergenInfo ? _self.allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,hasSupplement: null == hasSupplement ? _self.hasSupplement : hasSupplement // ignore: cast_nullable_to_non_nullable
as bool,supplementPrice: null == supplementPrice ? _self.supplementPrice : supplementPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SetMenuDishProps].
extension SetMenuDishPropsPatterns on SetMenuDishProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetMenuDishProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetMenuDishProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetMenuDishProps value)  $default,){
final _that = this;
switch (_that) {
case _SetMenuDishProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetMenuDishProps value)?  $default,){
final _that = this;
switch (_that) {
case _SetMenuDishProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  int? calories,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  bool hasSupplement,  double supplementPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetMenuDishProps() when $default != null:
return $default(_that.name,_that.description,_that.calories,_that.allergenInfo,_that.dietary,_that.hasSupplement,_that.supplementPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  int? calories,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  bool hasSupplement,  double supplementPrice)  $default,) {final _that = this;
switch (_that) {
case _SetMenuDishProps():
return $default(_that.name,_that.description,_that.calories,_that.allergenInfo,_that.dietary,_that.hasSupplement,_that.supplementPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  int? calories,  List<AllergenInfo> allergenInfo,  DietaryType? dietary,  bool hasSupplement,  double supplementPrice)?  $default,) {final _that = this;
switch (_that) {
case _SetMenuDishProps() when $default != null:
return $default(_that.name,_that.description,_that.calories,_that.allergenInfo,_that.dietary,_that.hasSupplement,_that.supplementPrice);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SetMenuDishProps extends SetMenuDishProps {
  const _SetMenuDishProps({required this.name, this.description, this.calories, final  List<AllergenInfo> allergenInfo = const [], this.dietary, this.hasSupplement = false, this.supplementPrice = 0.0}): _allergenInfo = allergenInfo,super._();
  factory _SetMenuDishProps.fromJson(Map<String, dynamic> json) => _$SetMenuDishPropsFromJson(json);

@override final  String name;
@override final  String? description;
@override final  int? calories;
 final  List<AllergenInfo> _allergenInfo;
@override@JsonKey() List<AllergenInfo> get allergenInfo {
  if (_allergenInfo is EqualUnmodifiableListView) return _allergenInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergenInfo);
}

@override final  DietaryType? dietary;
@override@JsonKey() final  bool hasSupplement;
@override@JsonKey() final  double supplementPrice;

/// Create a copy of SetMenuDishProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetMenuDishPropsCopyWith<_SetMenuDishProps> get copyWith => __$SetMenuDishPropsCopyWithImpl<_SetMenuDishProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetMenuDishPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetMenuDishProps&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&const DeepCollectionEquality().equals(other._allergenInfo, _allergenInfo)&&(identical(other.dietary, dietary) || other.dietary == dietary)&&(identical(other.hasSupplement, hasSupplement) || other.hasSupplement == hasSupplement)&&(identical(other.supplementPrice, supplementPrice) || other.supplementPrice == supplementPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,calories,const DeepCollectionEquality().hash(_allergenInfo),dietary,hasSupplement,supplementPrice);

@override
String toString() {
  return 'SetMenuDishProps(name: $name, description: $description, calories: $calories, allergenInfo: $allergenInfo, dietary: $dietary, hasSupplement: $hasSupplement, supplementPrice: $supplementPrice)';
}


}

/// @nodoc
abstract mixin class _$SetMenuDishPropsCopyWith<$Res> implements $SetMenuDishPropsCopyWith<$Res> {
  factory _$SetMenuDishPropsCopyWith(_SetMenuDishProps value, $Res Function(_SetMenuDishProps) _then) = __$SetMenuDishPropsCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, int? calories, List<AllergenInfo> allergenInfo, DietaryType? dietary, bool hasSupplement, double supplementPrice
});




}
/// @nodoc
class __$SetMenuDishPropsCopyWithImpl<$Res>
    implements _$SetMenuDishPropsCopyWith<$Res> {
  __$SetMenuDishPropsCopyWithImpl(this._self, this._then);

  final _SetMenuDishProps _self;
  final $Res Function(_SetMenuDishProps) _then;

/// Create a copy of SetMenuDishProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? calories = freezed,Object? allergenInfo = null,Object? dietary = freezed,Object? hasSupplement = null,Object? supplementPrice = null,}) {
  return _then(_SetMenuDishProps(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,allergenInfo: null == allergenInfo ? _self._allergenInfo : allergenInfo // ignore: cast_nullable_to_non_nullable
as List<AllergenInfo>,dietary: freezed == dietary ? _self.dietary : dietary // ignore: cast_nullable_to_non_nullable
as DietaryType?,hasSupplement: null == hasSupplement ? _self.hasSupplement : hasSupplement // ignore: cast_nullable_to_non_nullable
as bool,supplementPrice: null == supplementPrice ? _self.supplementPrice : supplementPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
