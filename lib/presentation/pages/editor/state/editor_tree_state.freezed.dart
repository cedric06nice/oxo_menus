// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_tree_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorTreeState {

 Menu? get menu; List<entity.Page> get pages; entity.Page? get headerPage; entity.Page? get footerPage; Map<int, List<entity.Container>> get containers; Map<int, List<entity.Column>> get columns; Map<int, List<WidgetInstance>> get widgets; bool get isLoading; String? get errorMessage; Map<int, int> get hoverIndex;
/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorTreeStateCopyWith<EditorTreeState> get copyWith => _$EditorTreeStateCopyWithImpl<EditorTreeState>(this as EditorTreeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorTreeState&&(identical(other.menu, menu) || other.menu == menu)&&const DeepCollectionEquality().equals(other.pages, pages)&&(identical(other.headerPage, headerPage) || other.headerPage == headerPage)&&(identical(other.footerPage, footerPage) || other.footerPage == footerPage)&&const DeepCollectionEquality().equals(other.containers, containers)&&const DeepCollectionEquality().equals(other.columns, columns)&&const DeepCollectionEquality().equals(other.widgets, widgets)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.hoverIndex, hoverIndex));
}


@override
int get hashCode => Object.hash(runtimeType,menu,const DeepCollectionEquality().hash(pages),headerPage,footerPage,const DeepCollectionEquality().hash(containers),const DeepCollectionEquality().hash(columns),const DeepCollectionEquality().hash(widgets),isLoading,errorMessage,const DeepCollectionEquality().hash(hoverIndex));

@override
String toString() {
  return 'EditorTreeState(menu: $menu, pages: $pages, headerPage: $headerPage, footerPage: $footerPage, containers: $containers, columns: $columns, widgets: $widgets, isLoading: $isLoading, errorMessage: $errorMessage, hoverIndex: $hoverIndex)';
}


}

/// @nodoc
abstract mixin class $EditorTreeStateCopyWith<$Res>  {
  factory $EditorTreeStateCopyWith(EditorTreeState value, $Res Function(EditorTreeState) _then) = _$EditorTreeStateCopyWithImpl;
@useResult
$Res call({
 Menu? menu, List<entity.Page> pages, entity.Page? headerPage, entity.Page? footerPage, Map<int, List<entity.Container>> containers, Map<int, List<entity.Column>> columns, Map<int, List<WidgetInstance>> widgets, bool isLoading, String? errorMessage, Map<int, int> hoverIndex
});


$MenuCopyWith<$Res>? get menu;$PageCopyWith<$Res>? get headerPage;$PageCopyWith<$Res>? get footerPage;

}
/// @nodoc
class _$EditorTreeStateCopyWithImpl<$Res>
    implements $EditorTreeStateCopyWith<$Res> {
  _$EditorTreeStateCopyWithImpl(this._self, this._then);

  final EditorTreeState _self;
  final $Res Function(EditorTreeState) _then;

/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menu = freezed,Object? pages = null,Object? headerPage = freezed,Object? footerPage = freezed,Object? containers = null,Object? columns = null,Object? widgets = null,Object? isLoading = null,Object? errorMessage = freezed,Object? hoverIndex = null,}) {
  return _then(_self.copyWith(
menu: freezed == menu ? _self.menu : menu // ignore: cast_nullable_to_non_nullable
as Menu?,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<entity.Page>,headerPage: freezed == headerPage ? _self.headerPage : headerPage // ignore: cast_nullable_to_non_nullable
as entity.Page?,footerPage: freezed == footerPage ? _self.footerPage : footerPage // ignore: cast_nullable_to_non_nullable
as entity.Page?,containers: null == containers ? _self.containers : containers // ignore: cast_nullable_to_non_nullable
as Map<int, List<entity.Container>>,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as Map<int, List<entity.Column>>,widgets: null == widgets ? _self.widgets : widgets // ignore: cast_nullable_to_non_nullable
as Map<int, List<WidgetInstance>>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hoverIndex: null == hoverIndex ? _self.hoverIndex : hoverIndex // ignore: cast_nullable_to_non_nullable
as Map<int, int>,
  ));
}
/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuCopyWith<$Res>? get menu {
    if (_self.menu == null) {
    return null;
  }

  return $MenuCopyWith<$Res>(_self.menu!, (value) {
    return _then(_self.copyWith(menu: value));
  });
}/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res>? get headerPage {
    if (_self.headerPage == null) {
    return null;
  }

  return $PageCopyWith<$Res>(_self.headerPage!, (value) {
    return _then(_self.copyWith(headerPage: value));
  });
}/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res>? get footerPage {
    if (_self.footerPage == null) {
    return null;
  }

  return $PageCopyWith<$Res>(_self.footerPage!, (value) {
    return _then(_self.copyWith(footerPage: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorTreeState].
extension EditorTreeStatePatterns on EditorTreeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorTreeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorTreeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorTreeState value)  $default,){
final _that = this;
switch (_that) {
case _EditorTreeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorTreeState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorTreeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Menu? menu,  List<entity.Page> pages,  entity.Page? headerPage,  entity.Page? footerPage,  Map<int, List<entity.Container>> containers,  Map<int, List<entity.Column>> columns,  Map<int, List<WidgetInstance>> widgets,  bool isLoading,  String? errorMessage,  Map<int, int> hoverIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorTreeState() when $default != null:
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage,_that.containers,_that.columns,_that.widgets,_that.isLoading,_that.errorMessage,_that.hoverIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Menu? menu,  List<entity.Page> pages,  entity.Page? headerPage,  entity.Page? footerPage,  Map<int, List<entity.Container>> containers,  Map<int, List<entity.Column>> columns,  Map<int, List<WidgetInstance>> widgets,  bool isLoading,  String? errorMessage,  Map<int, int> hoverIndex)  $default,) {final _that = this;
switch (_that) {
case _EditorTreeState():
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage,_that.containers,_that.columns,_that.widgets,_that.isLoading,_that.errorMessage,_that.hoverIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Menu? menu,  List<entity.Page> pages,  entity.Page? headerPage,  entity.Page? footerPage,  Map<int, List<entity.Container>> containers,  Map<int, List<entity.Column>> columns,  Map<int, List<WidgetInstance>> widgets,  bool isLoading,  String? errorMessage,  Map<int, int> hoverIndex)?  $default,) {final _that = this;
switch (_that) {
case _EditorTreeState() when $default != null:
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage,_that.containers,_that.columns,_that.widgets,_that.isLoading,_that.errorMessage,_that.hoverIndex);case _:
  return null;

}
}

}

/// @nodoc


class _EditorTreeState implements EditorTreeState {
  const _EditorTreeState({this.menu, final  List<entity.Page> pages = const [], this.headerPage, this.footerPage, final  Map<int, List<entity.Container>> containers = const {}, final  Map<int, List<entity.Column>> columns = const {}, final  Map<int, List<WidgetInstance>> widgets = const {}, this.isLoading = true, this.errorMessage, final  Map<int, int> hoverIndex = const {}}): _pages = pages,_containers = containers,_columns = columns,_widgets = widgets,_hoverIndex = hoverIndex;
  

@override final  Menu? menu;
 final  List<entity.Page> _pages;
@override@JsonKey() List<entity.Page> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

@override final  entity.Page? headerPage;
@override final  entity.Page? footerPage;
 final  Map<int, List<entity.Container>> _containers;
@override@JsonKey() Map<int, List<entity.Container>> get containers {
  if (_containers is EqualUnmodifiableMapView) return _containers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_containers);
}

 final  Map<int, List<entity.Column>> _columns;
@override@JsonKey() Map<int, List<entity.Column>> get columns {
  if (_columns is EqualUnmodifiableMapView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_columns);
}

 final  Map<int, List<WidgetInstance>> _widgets;
@override@JsonKey() Map<int, List<WidgetInstance>> get widgets {
  if (_widgets is EqualUnmodifiableMapView) return _widgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_widgets);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
 final  Map<int, int> _hoverIndex;
@override@JsonKey() Map<int, int> get hoverIndex {
  if (_hoverIndex is EqualUnmodifiableMapView) return _hoverIndex;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hoverIndex);
}


/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorTreeStateCopyWith<_EditorTreeState> get copyWith => __$EditorTreeStateCopyWithImpl<_EditorTreeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorTreeState&&(identical(other.menu, menu) || other.menu == menu)&&const DeepCollectionEquality().equals(other._pages, _pages)&&(identical(other.headerPage, headerPage) || other.headerPage == headerPage)&&(identical(other.footerPage, footerPage) || other.footerPage == footerPage)&&const DeepCollectionEquality().equals(other._containers, _containers)&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._widgets, _widgets)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._hoverIndex, _hoverIndex));
}


@override
int get hashCode => Object.hash(runtimeType,menu,const DeepCollectionEquality().hash(_pages),headerPage,footerPage,const DeepCollectionEquality().hash(_containers),const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_widgets),isLoading,errorMessage,const DeepCollectionEquality().hash(_hoverIndex));

@override
String toString() {
  return 'EditorTreeState(menu: $menu, pages: $pages, headerPage: $headerPage, footerPage: $footerPage, containers: $containers, columns: $columns, widgets: $widgets, isLoading: $isLoading, errorMessage: $errorMessage, hoverIndex: $hoverIndex)';
}


}

/// @nodoc
abstract mixin class _$EditorTreeStateCopyWith<$Res> implements $EditorTreeStateCopyWith<$Res> {
  factory _$EditorTreeStateCopyWith(_EditorTreeState value, $Res Function(_EditorTreeState) _then) = __$EditorTreeStateCopyWithImpl;
@override @useResult
$Res call({
 Menu? menu, List<entity.Page> pages, entity.Page? headerPage, entity.Page? footerPage, Map<int, List<entity.Container>> containers, Map<int, List<entity.Column>> columns, Map<int, List<WidgetInstance>> widgets, bool isLoading, String? errorMessage, Map<int, int> hoverIndex
});


@override $MenuCopyWith<$Res>? get menu;@override $PageCopyWith<$Res>? get headerPage;@override $PageCopyWith<$Res>? get footerPage;

}
/// @nodoc
class __$EditorTreeStateCopyWithImpl<$Res>
    implements _$EditorTreeStateCopyWith<$Res> {
  __$EditorTreeStateCopyWithImpl(this._self, this._then);

  final _EditorTreeState _self;
  final $Res Function(_EditorTreeState) _then;

/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menu = freezed,Object? pages = null,Object? headerPage = freezed,Object? footerPage = freezed,Object? containers = null,Object? columns = null,Object? widgets = null,Object? isLoading = null,Object? errorMessage = freezed,Object? hoverIndex = null,}) {
  return _then(_EditorTreeState(
menu: freezed == menu ? _self.menu : menu // ignore: cast_nullable_to_non_nullable
as Menu?,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<entity.Page>,headerPage: freezed == headerPage ? _self.headerPage : headerPage // ignore: cast_nullable_to_non_nullable
as entity.Page?,footerPage: freezed == footerPage ? _self.footerPage : footerPage // ignore: cast_nullable_to_non_nullable
as entity.Page?,containers: null == containers ? _self._containers : containers // ignore: cast_nullable_to_non_nullable
as Map<int, List<entity.Container>>,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as Map<int, List<entity.Column>>,widgets: null == widgets ? _self._widgets : widgets // ignore: cast_nullable_to_non_nullable
as Map<int, List<WidgetInstance>>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hoverIndex: null == hoverIndex ? _self._hoverIndex : hoverIndex // ignore: cast_nullable_to_non_nullable
as Map<int, int>,
  ));
}

/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuCopyWith<$Res>? get menu {
    if (_self.menu == null) {
    return null;
  }

  return $MenuCopyWith<$Res>(_self.menu!, (value) {
    return _then(_self.copyWith(menu: value));
  });
}/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res>? get headerPage {
    if (_self.headerPage == null) {
    return null;
  }

  return $PageCopyWith<$Res>(_self.headerPage!, (value) {
    return _then(_self.copyWith(headerPage: value));
  });
}/// Create a copy of EditorTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res>? get footerPage {
    if (_self.footerPage == null) {
    return null;
  }

  return $PageCopyWith<$Res>(_self.footerPage!, (value) {
    return _then(_self.copyWith(footerPage: value));
  });
}
}

// dart format on
