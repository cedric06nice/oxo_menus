// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_selection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorSelectionState {

 EditorSelection? get selection; StyleConfig? get clipboardStyle; StyleConfig? get currentStyle; StyleConfig? get originalStyle; bool get isSaving;
/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSelectionStateCopyWith<EditorSelectionState> get copyWith => _$EditorSelectionStateCopyWithImpl<EditorSelectionState>(this as EditorSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSelectionState&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.clipboardStyle, clipboardStyle) || other.clipboardStyle == clipboardStyle)&&(identical(other.currentStyle, currentStyle) || other.currentStyle == currentStyle)&&(identical(other.originalStyle, originalStyle) || other.originalStyle == originalStyle)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode => Object.hash(runtimeType,selection,clipboardStyle,currentStyle,originalStyle,isSaving);

@override
String toString() {
  return 'EditorSelectionState(selection: $selection, clipboardStyle: $clipboardStyle, currentStyle: $currentStyle, originalStyle: $originalStyle, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class $EditorSelectionStateCopyWith<$Res>  {
  factory $EditorSelectionStateCopyWith(EditorSelectionState value, $Res Function(EditorSelectionState) _then) = _$EditorSelectionStateCopyWithImpl;
@useResult
$Res call({
 EditorSelection? selection, StyleConfig? clipboardStyle, StyleConfig? currentStyle, StyleConfig? originalStyle, bool isSaving
});


$EditorSelectionCopyWith<$Res>? get selection;$StyleConfigCopyWith<$Res>? get clipboardStyle;$StyleConfigCopyWith<$Res>? get currentStyle;$StyleConfigCopyWith<$Res>? get originalStyle;

}
/// @nodoc
class _$EditorSelectionStateCopyWithImpl<$Res>
    implements $EditorSelectionStateCopyWith<$Res> {
  _$EditorSelectionStateCopyWithImpl(this._self, this._then);

  final EditorSelectionState _self;
  final $Res Function(EditorSelectionState) _then;

/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selection = freezed,Object? clipboardStyle = freezed,Object? currentStyle = freezed,Object? originalStyle = freezed,Object? isSaving = null,}) {
  return _then(_self.copyWith(
selection: freezed == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as EditorSelection?,clipboardStyle: freezed == clipboardStyle ? _self.clipboardStyle : clipboardStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,currentStyle: freezed == currentStyle ? _self.currentStyle : currentStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,originalStyle: freezed == originalStyle ? _self.originalStyle : originalStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSelectionCopyWith<$Res>? get selection {
    if (_self.selection == null) {
    return null;
  }

  return $EditorSelectionCopyWith<$Res>(_self.selection!, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get clipboardStyle {
    if (_self.clipboardStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.clipboardStyle!, (value) {
    return _then(_self.copyWith(clipboardStyle: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get currentStyle {
    if (_self.currentStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.currentStyle!, (value) {
    return _then(_self.copyWith(currentStyle: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get originalStyle {
    if (_self.originalStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.originalStyle!, (value) {
    return _then(_self.copyWith(originalStyle: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorSelectionState].
extension EditorSelectionStatePatterns on EditorSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSelectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSelectionState value)  $default,){
final _that = this;
switch (_that) {
case _EditorSelectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSelectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EditorSelection? selection,  StyleConfig? clipboardStyle,  StyleConfig? currentStyle,  StyleConfig? originalStyle,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSelectionState() when $default != null:
return $default(_that.selection,_that.clipboardStyle,_that.currentStyle,_that.originalStyle,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EditorSelection? selection,  StyleConfig? clipboardStyle,  StyleConfig? currentStyle,  StyleConfig? originalStyle,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _EditorSelectionState():
return $default(_that.selection,_that.clipboardStyle,_that.currentStyle,_that.originalStyle,_that.isSaving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EditorSelection? selection,  StyleConfig? clipboardStyle,  StyleConfig? currentStyle,  StyleConfig? originalStyle,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _EditorSelectionState() when $default != null:
return $default(_that.selection,_that.clipboardStyle,_that.currentStyle,_that.originalStyle,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _EditorSelectionState implements EditorSelectionState {
  const _EditorSelectionState({this.selection, this.clipboardStyle, this.currentStyle, this.originalStyle, this.isSaving = false});
  

@override final  EditorSelection? selection;
@override final  StyleConfig? clipboardStyle;
@override final  StyleConfig? currentStyle;
@override final  StyleConfig? originalStyle;
@override@JsonKey() final  bool isSaving;

/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSelectionStateCopyWith<_EditorSelectionState> get copyWith => __$EditorSelectionStateCopyWithImpl<_EditorSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSelectionState&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.clipboardStyle, clipboardStyle) || other.clipboardStyle == clipboardStyle)&&(identical(other.currentStyle, currentStyle) || other.currentStyle == currentStyle)&&(identical(other.originalStyle, originalStyle) || other.originalStyle == originalStyle)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode => Object.hash(runtimeType,selection,clipboardStyle,currentStyle,originalStyle,isSaving);

@override
String toString() {
  return 'EditorSelectionState(selection: $selection, clipboardStyle: $clipboardStyle, currentStyle: $currentStyle, originalStyle: $originalStyle, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$EditorSelectionStateCopyWith<$Res> implements $EditorSelectionStateCopyWith<$Res> {
  factory _$EditorSelectionStateCopyWith(_EditorSelectionState value, $Res Function(_EditorSelectionState) _then) = __$EditorSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 EditorSelection? selection, StyleConfig? clipboardStyle, StyleConfig? currentStyle, StyleConfig? originalStyle, bool isSaving
});


@override $EditorSelectionCopyWith<$Res>? get selection;@override $StyleConfigCopyWith<$Res>? get clipboardStyle;@override $StyleConfigCopyWith<$Res>? get currentStyle;@override $StyleConfigCopyWith<$Res>? get originalStyle;

}
/// @nodoc
class __$EditorSelectionStateCopyWithImpl<$Res>
    implements _$EditorSelectionStateCopyWith<$Res> {
  __$EditorSelectionStateCopyWithImpl(this._self, this._then);

  final _EditorSelectionState _self;
  final $Res Function(_EditorSelectionState) _then;

/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selection = freezed,Object? clipboardStyle = freezed,Object? currentStyle = freezed,Object? originalStyle = freezed,Object? isSaving = null,}) {
  return _then(_EditorSelectionState(
selection: freezed == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as EditorSelection?,clipboardStyle: freezed == clipboardStyle ? _self.clipboardStyle : clipboardStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,currentStyle: freezed == currentStyle ? _self.currentStyle : currentStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,originalStyle: freezed == originalStyle ? _self.originalStyle : originalStyle // ignore: cast_nullable_to_non_nullable
as StyleConfig?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSelectionCopyWith<$Res>? get selection {
    if (_self.selection == null) {
    return null;
  }

  return $EditorSelectionCopyWith<$Res>(_self.selection!, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get clipboardStyle {
    if (_self.clipboardStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.clipboardStyle!, (value) {
    return _then(_self.copyWith(clipboardStyle: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get currentStyle {
    if (_self.currentStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.currentStyle!, (value) {
    return _then(_self.copyWith(currentStyle: value));
  });
}/// Create a copy of EditorSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get originalStyle {
    if (_self.originalStyle == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.originalStyle!, (value) {
    return _then(_self.copyWith(originalStyle: value));
  });
}
}

// dart format on
