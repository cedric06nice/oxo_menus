// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DishProps _$DishPropsFromJson(Map<String, dynamic> json) {
  return _DishProps.fromJson(json);
}

/// @nodoc
mixin _$DishProps {
  /// The name of the dish
  String get name => throw _privateConstructorUsedError;

  /// The price of the dish
  double get price => throw _privateConstructorUsedError;

  /// Optional description of the dish
  String? get description => throw _privateConstructorUsedError;

  /// List of allergens (e.g., 'Dairy', 'Gluten', 'Nuts')
  List<String> get allergens => throw _privateConstructorUsedError;

  /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
  List<String> get dietary => throw _privateConstructorUsedError;

  /// Whether to display the price
  bool get showPrice => throw _privateConstructorUsedError;

  /// Whether to display allergen information
  bool get showAllergens => throw _privateConstructorUsedError;

  /// Serializes this DishProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DishProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DishPropsCopyWith<DishProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DishPropsCopyWith<$Res> {
  factory $DishPropsCopyWith(DishProps value, $Res Function(DishProps) then) =
      _$DishPropsCopyWithImpl<$Res, DishProps>;
  @useResult
  $Res call(
      {String name,
      double price,
      String? description,
      List<String> allergens,
      List<String> dietary,
      bool showPrice,
      bool showAllergens});
}

/// @nodoc
class _$DishPropsCopyWithImpl<$Res, $Val extends DishProps>
    implements $DishPropsCopyWith<$Res> {
  _$DishPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DishProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? description = freezed,
    Object? allergens = null,
    Object? dietary = null,
    Object? showPrice = null,
    Object? showAllergens = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      allergens: null == allergens
          ? _value.allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dietary: null == dietary
          ? _value.dietary
          : dietary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showPrice: null == showPrice
          ? _value.showPrice
          : showPrice // ignore: cast_nullable_to_non_nullable
              as bool,
      showAllergens: null == showAllergens
          ? _value.showAllergens
          : showAllergens // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DishPropsImplCopyWith<$Res>
    implements $DishPropsCopyWith<$Res> {
  factory _$$DishPropsImplCopyWith(
          _$DishPropsImpl value, $Res Function(_$DishPropsImpl) then) =
      __$$DishPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double price,
      String? description,
      List<String> allergens,
      List<String> dietary,
      bool showPrice,
      bool showAllergens});
}

/// @nodoc
class __$$DishPropsImplCopyWithImpl<$Res>
    extends _$DishPropsCopyWithImpl<$Res, _$DishPropsImpl>
    implements _$$DishPropsImplCopyWith<$Res> {
  __$$DishPropsImplCopyWithImpl(
      _$DishPropsImpl _value, $Res Function(_$DishPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DishProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? description = freezed,
    Object? allergens = null,
    Object? dietary = null,
    Object? showPrice = null,
    Object? showAllergens = null,
  }) {
    return _then(_$DishPropsImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      allergens: null == allergens
          ? _value._allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dietary: null == dietary
          ? _value._dietary
          : dietary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showPrice: null == showPrice
          ? _value.showPrice
          : showPrice // ignore: cast_nullable_to_non_nullable
              as bool,
      showAllergens: null == showAllergens
          ? _value.showAllergens
          : showAllergens // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DishPropsImpl implements _DishProps {
  const _$DishPropsImpl(
      {required this.name,
      required this.price,
      this.description,
      final List<String> allergens = const [],
      final List<String> dietary = const [],
      this.showPrice = true,
      this.showAllergens = true})
      : _allergens = allergens,
        _dietary = dietary;

  factory _$DishPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DishPropsImplFromJson(json);

  /// The name of the dish
  @override
  final String name;

  /// The price of the dish
  @override
  final double price;

  /// Optional description of the dish
  @override
  final String? description;

  /// List of allergens (e.g., 'Dairy', 'Gluten', 'Nuts')
  final List<String> _allergens;

  /// List of allergens (e.g., 'Dairy', 'Gluten', 'Nuts')
  @override
  @JsonKey()
  List<String> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
  final List<String> _dietary;

  /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
  @override
  @JsonKey()
  List<String> get dietary {
    if (_dietary is EqualUnmodifiableListView) return _dietary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dietary);
  }

  /// Whether to display the price
  @override
  @JsonKey()
  final bool showPrice;

  /// Whether to display allergen information
  @override
  @JsonKey()
  final bool showAllergens;

  @override
  String toString() {
    return 'DishProps(name: $name, price: $price, description: $description, allergens: $allergens, dietary: $dietary, showPrice: $showPrice, showAllergens: $showAllergens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DishPropsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._allergens, _allergens) &&
            const DeepCollectionEquality().equals(other._dietary, _dietary) &&
            (identical(other.showPrice, showPrice) ||
                other.showPrice == showPrice) &&
            (identical(other.showAllergens, showAllergens) ||
                other.showAllergens == showAllergens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      price,
      description,
      const DeepCollectionEquality().hash(_allergens),
      const DeepCollectionEquality().hash(_dietary),
      showPrice,
      showAllergens);

  /// Create a copy of DishProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DishPropsImplCopyWith<_$DishPropsImpl> get copyWith =>
      __$$DishPropsImplCopyWithImpl<_$DishPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DishPropsImplToJson(
      this,
    );
  }
}

abstract class _DishProps implements DishProps {
  const factory _DishProps(
      {required final String name,
      required final double price,
      final String? description,
      final List<String> allergens,
      final List<String> dietary,
      final bool showPrice,
      final bool showAllergens}) = _$DishPropsImpl;

  factory _DishProps.fromJson(Map<String, dynamic> json) =
      _$DishPropsImpl.fromJson;

  /// The name of the dish
  @override
  String get name;

  /// The price of the dish
  @override
  double get price;

  /// Optional description of the dish
  @override
  String? get description;

  /// List of allergens (e.g., 'Dairy', 'Gluten', 'Nuts')
  @override
  List<String> get allergens;

  /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
  @override
  List<String> get dietary;

  /// Whether to display the price
  @override
  bool get showPrice;

  /// Whether to display allergen information
  @override
  bool get showAllergens;

  /// Create a copy of DishProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DishPropsImplCopyWith<_$DishPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
