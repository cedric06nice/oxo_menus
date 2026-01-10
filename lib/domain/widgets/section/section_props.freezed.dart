// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SectionProps _$SectionPropsFromJson(Map<String, dynamic> json) {
  return _SectionProps.fromJson(json);
}

/// @nodoc
mixin _$SectionProps {
  /// The title of the section
  String get title => throw _privateConstructorUsedError;

  /// Whether to display the title in uppercase
  bool get uppercase => throw _privateConstructorUsedError;

  /// Whether to show a divider line below the title
  bool get showDivider => throw _privateConstructorUsedError;

  /// Serializes this SectionProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SectionPropsCopyWith<SectionProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectionPropsCopyWith<$Res> {
  factory $SectionPropsCopyWith(
          SectionProps value, $Res Function(SectionProps) then) =
      _$SectionPropsCopyWithImpl<$Res, SectionProps>;
  @useResult
  $Res call({String title, bool uppercase, bool showDivider});
}

/// @nodoc
class _$SectionPropsCopyWithImpl<$Res, $Val extends SectionProps>
    implements $SectionPropsCopyWith<$Res> {
  _$SectionPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? uppercase = null,
    Object? showDivider = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uppercase: null == uppercase
          ? _value.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      showDivider: null == showDivider
          ? _value.showDivider
          : showDivider // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SectionPropsImplCopyWith<$Res>
    implements $SectionPropsCopyWith<$Res> {
  factory _$$SectionPropsImplCopyWith(
          _$SectionPropsImpl value, $Res Function(_$SectionPropsImpl) then) =
      __$$SectionPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, bool uppercase, bool showDivider});
}

/// @nodoc
class __$$SectionPropsImplCopyWithImpl<$Res>
    extends _$SectionPropsCopyWithImpl<$Res, _$SectionPropsImpl>
    implements _$$SectionPropsImplCopyWith<$Res> {
  __$$SectionPropsImplCopyWithImpl(
      _$SectionPropsImpl _value, $Res Function(_$SectionPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? uppercase = null,
    Object? showDivider = null,
  }) {
    return _then(_$SectionPropsImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uppercase: null == uppercase
          ? _value.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      showDivider: null == showDivider
          ? _value.showDivider
          : showDivider // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SectionPropsImpl implements _SectionProps {
  const _$SectionPropsImpl(
      {required this.title, this.uppercase = false, this.showDivider = true});

  factory _$SectionPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SectionPropsImplFromJson(json);

  /// The title of the section
  @override
  final String title;

  /// Whether to display the title in uppercase
  @override
  @JsonKey()
  final bool uppercase;

  /// Whether to show a divider line below the title
  @override
  @JsonKey()
  final bool showDivider;

  @override
  String toString() {
    return 'SectionProps(title: $title, uppercase: $uppercase, showDivider: $showDivider)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectionPropsImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.uppercase, uppercase) ||
                other.uppercase == uppercase) &&
            (identical(other.showDivider, showDivider) ||
                other.showDivider == showDivider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, uppercase, showDivider);

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SectionPropsImplCopyWith<_$SectionPropsImpl> get copyWith =>
      __$$SectionPropsImplCopyWithImpl<_$SectionPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SectionPropsImplToJson(
      this,
    );
  }
}

abstract class _SectionProps implements SectionProps {
  const factory _SectionProps(
      {required final String title,
      final bool uppercase,
      final bool showDivider}) = _$SectionPropsImpl;

  factory _SectionProps.fromJson(Map<String, dynamic> json) =
      _$SectionPropsImpl.fromJson;

  /// The title of the section
  @override
  String get title;

  /// Whether to display the title in uppercase
  @override
  bool get uppercase;

  /// Whether to show a divider line below the title
  @override
  bool get showDivider;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SectionPropsImplCopyWith<_$SectionPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
