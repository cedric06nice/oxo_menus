// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_sizes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminSizesState {

 List<Size> get sizes; bool get isLoading; String? get errorMessage; String get statusFilter;
/// Create a copy of AdminSizesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminSizesStateCopyWith<AdminSizesState> get copyWith => _$AdminSizesStateCopyWithImpl<AdminSizesState>(this as AdminSizesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminSizesState&&const DeepCollectionEquality().equals(other.sizes, sizes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sizes),isLoading,errorMessage,statusFilter);

@override
String toString() {
  return 'AdminSizesState(sizes: $sizes, isLoading: $isLoading, errorMessage: $errorMessage, statusFilter: $statusFilter)';
}


}

/// @nodoc
abstract mixin class $AdminSizesStateCopyWith<$Res>  {
  factory $AdminSizesStateCopyWith(AdminSizesState value, $Res Function(AdminSizesState) _then) = _$AdminSizesStateCopyWithImpl;
@useResult
$Res call({
 List<Size> sizes, bool isLoading, String? errorMessage, String statusFilter
});




}
/// @nodoc
class _$AdminSizesStateCopyWithImpl<$Res>
    implements $AdminSizesStateCopyWith<$Res> {
  _$AdminSizesStateCopyWithImpl(this._self, this._then);

  final AdminSizesState _self;
  final $Res Function(AdminSizesState) _then;

/// Create a copy of AdminSizesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sizes = null,Object? isLoading = null,Object? errorMessage = freezed,Object? statusFilter = null,}) {
  return _then(_self.copyWith(
sizes: null == sizes ? _self.sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<Size>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminSizesState].
extension AdminSizesStatePatterns on AdminSizesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminSizesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminSizesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminSizesState value)  $default,){
final _that = this;
switch (_that) {
case _AdminSizesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminSizesState value)?  $default,){
final _that = this;
switch (_that) {
case _AdminSizesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Size> sizes,  bool isLoading,  String? errorMessage,  String statusFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminSizesState() when $default != null:
return $default(_that.sizes,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Size> sizes,  bool isLoading,  String? errorMessage,  String statusFilter)  $default,) {final _that = this;
switch (_that) {
case _AdminSizesState():
return $default(_that.sizes,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Size> sizes,  bool isLoading,  String? errorMessage,  String statusFilter)?  $default,) {final _that = this;
switch (_that) {
case _AdminSizesState() when $default != null:
return $default(_that.sizes,_that.isLoading,_that.errorMessage,_that.statusFilter);case _:
  return null;

}
}

}

/// @nodoc


class _AdminSizesState implements AdminSizesState {
  const _AdminSizesState({final  List<Size> sizes = const [], this.isLoading = false, this.errorMessage, this.statusFilter = 'all'}): _sizes = sizes;
  

 final  List<Size> _sizes;
@override@JsonKey() List<Size> get sizes {
  if (_sizes is EqualUnmodifiableListView) return _sizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sizes);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override@JsonKey() final  String statusFilter;

/// Create a copy of AdminSizesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminSizesStateCopyWith<_AdminSizesState> get copyWith => __$AdminSizesStateCopyWithImpl<_AdminSizesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminSizesState&&const DeepCollectionEquality().equals(other._sizes, _sizes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sizes),isLoading,errorMessage,statusFilter);

@override
String toString() {
  return 'AdminSizesState(sizes: $sizes, isLoading: $isLoading, errorMessage: $errorMessage, statusFilter: $statusFilter)';
}


}

/// @nodoc
abstract mixin class _$AdminSizesStateCopyWith<$Res> implements $AdminSizesStateCopyWith<$Res> {
  factory _$AdminSizesStateCopyWith(_AdminSizesState value, $Res Function(_AdminSizesState) _then) = __$AdminSizesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Size> sizes, bool isLoading, String? errorMessage, String statusFilter
});




}
/// @nodoc
class __$AdminSizesStateCopyWithImpl<$Res>
    implements _$AdminSizesStateCopyWith<$Res> {
  __$AdminSizesStateCopyWithImpl(this._self, this._then);

  final _AdminSizesState _self;
  final $Res Function(_AdminSizesState) _then;

/// Create a copy of AdminSizesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sizes = null,Object? isLoading = null,Object? errorMessage = freezed,Object? statusFilter = null,}) {
  return _then(_AdminSizesState(
sizes: null == sizes ? _self._sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<Size>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
