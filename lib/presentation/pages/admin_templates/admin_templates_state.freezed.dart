// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_templates_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminTemplatesState {

 List<Menu> get templates; bool get isLoading; String? get errorMessage; String get statusFilter;
/// Create a copy of AdminTemplatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminTemplatesStateCopyWith<AdminTemplatesState> get copyWith => _$AdminTemplatesStateCopyWithImpl<AdminTemplatesState>(this as AdminTemplatesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminTemplatesState&&const DeepCollectionEquality().equals(other.templates, templates)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(templates),isLoading,errorMessage,statusFilter);

@override
String toString() {
  return 'AdminTemplatesState(templates: $templates, isLoading: $isLoading, errorMessage: $errorMessage, statusFilter: $statusFilter)';
}


}

/// @nodoc
abstract mixin class $AdminTemplatesStateCopyWith<$Res>  {
  factory $AdminTemplatesStateCopyWith(AdminTemplatesState value, $Res Function(AdminTemplatesState) _then) = _$AdminTemplatesStateCopyWithImpl;
@useResult
$Res call({
 List<Menu> templates, bool isLoading, String? errorMessage, String statusFilter
});




}
/// @nodoc
class _$AdminTemplatesStateCopyWithImpl<$Res>
    implements $AdminTemplatesStateCopyWith<$Res> {
  _$AdminTemplatesStateCopyWithImpl(this._self, this._then);

  final AdminTemplatesState _self;
  final $Res Function(AdminTemplatesState) _then;

/// Create a copy of AdminTemplatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templates = null,Object? isLoading = null,Object? errorMessage = freezed,Object? statusFilter = null,}) {
  return _then(_self.copyWith(
templates: null == templates ? _self.templates : templates // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminTemplatesState].
extension AdminTemplatesStatePatterns on AdminTemplatesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminTemplatesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminTemplatesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminTemplatesState value)  $default,){
final _that = this;
switch (_that) {
case _AdminTemplatesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminTemplatesState value)?  $default,){
final _that = this;
switch (_that) {
case _AdminTemplatesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Menu> templates,  bool isLoading,  String? errorMessage,  String statusFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminTemplatesState() when $default != null:
return $default(_that.templates,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Menu> templates,  bool isLoading,  String? errorMessage,  String statusFilter)  $default,) {final _that = this;
switch (_that) {
case _AdminTemplatesState():
return $default(_that.templates,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Menu> templates,  bool isLoading,  String? errorMessage,  String statusFilter)?  $default,) {final _that = this;
switch (_that) {
case _AdminTemplatesState() when $default != null:
return $default(_that.templates,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
  return null;

}
}

}

/// @nodoc


class _AdminTemplatesState implements AdminTemplatesState {
  const _AdminTemplatesState({final  List<Menu> templates = const [], this.isLoading = false, this.errorMessage, this.statusFilter = 'all'}): _templates = templates;
  

 final  List<Menu> _templates;
@override@JsonKey() List<Menu> get templates {
  if (_templates is EqualUnmodifiableListView) return _templates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_templates);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override@JsonKey() final  String statusFilter;

/// Create a copy of AdminTemplatesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminTemplatesStateCopyWith<_AdminTemplatesState> get copyWith => __$AdminTemplatesStateCopyWithImpl<_AdminTemplatesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminTemplatesState&&const DeepCollectionEquality().equals(other._templates, _templates)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_templates),isLoading,errorMessage,statusFilter);

@override
String toString() {
  return 'AdminTemplatesState(templates: $templates, isLoading: $isLoading, errorMessage: $errorMessage, statusFilter: $statusFilter)';
}


}

/// @nodoc
abstract mixin class _$AdminTemplatesStateCopyWith<$Res> implements $AdminTemplatesStateCopyWith<$Res> {
  factory _$AdminTemplatesStateCopyWith(_AdminTemplatesState value, $Res Function(_AdminTemplatesState) _then) = __$AdminTemplatesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Menu> templates, bool isLoading, String? errorMessage, String statusFilter
});




}
/// @nodoc
class __$AdminTemplatesStateCopyWithImpl<$Res>
    implements _$AdminTemplatesStateCopyWith<$Res> {
  __$AdminTemplatesStateCopyWithImpl(this._self, this._then);

  final _AdminTemplatesState _self;
  final $Res Function(_AdminTemplatesState) _then;

/// Create a copy of AdminTemplatesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templates = null,Object? isLoading = null,Object? errorMessage = freezed,Object? statusFilter = null,}) {
  return _then(_AdminTemplatesState(
templates: null == templates ? _self._templates : templates // ignore: cast_nullable_to_non_nullable
as List<Menu>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
