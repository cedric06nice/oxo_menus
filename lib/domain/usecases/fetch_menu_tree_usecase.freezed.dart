// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fetch_menu_tree_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuTree {

 Menu get menu; List<PageWithContainers> get pages; PageWithContainers? get headerPage; PageWithContainers? get footerPage;
/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuTreeCopyWith<MenuTree> get copyWith => _$MenuTreeCopyWithImpl<MenuTree>(this as MenuTree, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuTree&&(identical(other.menu, menu) || other.menu == menu)&&const DeepCollectionEquality().equals(other.pages, pages)&&(identical(other.headerPage, headerPage) || other.headerPage == headerPage)&&(identical(other.footerPage, footerPage) || other.footerPage == footerPage));
}


@override
int get hashCode => Object.hash(runtimeType,menu,const DeepCollectionEquality().hash(pages),headerPage,footerPage);

@override
String toString() {
  return 'MenuTree(menu: $menu, pages: $pages, headerPage: $headerPage, footerPage: $footerPage)';
}


}

/// @nodoc
abstract mixin class $MenuTreeCopyWith<$Res>  {
  factory $MenuTreeCopyWith(MenuTree value, $Res Function(MenuTree) _then) = _$MenuTreeCopyWithImpl;
@useResult
$Res call({
 Menu menu, List<PageWithContainers> pages, PageWithContainers? headerPage, PageWithContainers? footerPage
});


$MenuCopyWith<$Res> get menu;$PageWithContainersCopyWith<$Res>? get headerPage;$PageWithContainersCopyWith<$Res>? get footerPage;

}
/// @nodoc
class _$MenuTreeCopyWithImpl<$Res>
    implements $MenuTreeCopyWith<$Res> {
  _$MenuTreeCopyWithImpl(this._self, this._then);

  final MenuTree _self;
  final $Res Function(MenuTree) _then;

/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menu = null,Object? pages = null,Object? headerPage = freezed,Object? footerPage = freezed,}) {
  return _then(_self.copyWith(
menu: null == menu ? _self.menu : menu // ignore: cast_nullable_to_non_nullable
as Menu,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<PageWithContainers>,headerPage: freezed == headerPage ? _self.headerPage : headerPage // ignore: cast_nullable_to_non_nullable
as PageWithContainers?,footerPage: freezed == footerPage ? _self.footerPage : footerPage // ignore: cast_nullable_to_non_nullable
as PageWithContainers?,
  ));
}
/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuCopyWith<$Res> get menu {
  
  return $MenuCopyWith<$Res>(_self.menu, (value) {
    return _then(_self.copyWith(menu: value));
  });
}/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageWithContainersCopyWith<$Res>? get headerPage {
    if (_self.headerPage == null) {
    return null;
  }

  return $PageWithContainersCopyWith<$Res>(_self.headerPage!, (value) {
    return _then(_self.copyWith(headerPage: value));
  });
}/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageWithContainersCopyWith<$Res>? get footerPage {
    if (_self.footerPage == null) {
    return null;
  }

  return $PageWithContainersCopyWith<$Res>(_self.footerPage!, (value) {
    return _then(_self.copyWith(footerPage: value));
  });
}
}


/// Adds pattern-matching-related methods to [MenuTree].
extension MenuTreePatterns on MenuTree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuTree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuTree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuTree value)  $default,){
final _that = this;
switch (_that) {
case _MenuTree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuTree value)?  $default,){
final _that = this;
switch (_that) {
case _MenuTree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Menu menu,  List<PageWithContainers> pages,  PageWithContainers? headerPage,  PageWithContainers? footerPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuTree() when $default != null:
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Menu menu,  List<PageWithContainers> pages,  PageWithContainers? headerPage,  PageWithContainers? footerPage)  $default,) {final _that = this;
switch (_that) {
case _MenuTree():
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Menu menu,  List<PageWithContainers> pages,  PageWithContainers? headerPage,  PageWithContainers? footerPage)?  $default,) {final _that = this;
switch (_that) {
case _MenuTree() when $default != null:
return $default(_that.menu,_that.pages,_that.headerPage,_that.footerPage);case _:
  return null;

}
}

}

/// @nodoc


class _MenuTree extends MenuTree {
  const _MenuTree({required this.menu, required final  List<PageWithContainers> pages, this.headerPage, this.footerPage}): _pages = pages,super._();
  

@override final  Menu menu;
 final  List<PageWithContainers> _pages;
@override List<PageWithContainers> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

@override final  PageWithContainers? headerPage;
@override final  PageWithContainers? footerPage;

/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuTreeCopyWith<_MenuTree> get copyWith => __$MenuTreeCopyWithImpl<_MenuTree>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuTree&&(identical(other.menu, menu) || other.menu == menu)&&const DeepCollectionEquality().equals(other._pages, _pages)&&(identical(other.headerPage, headerPage) || other.headerPage == headerPage)&&(identical(other.footerPage, footerPage) || other.footerPage == footerPage));
}


@override
int get hashCode => Object.hash(runtimeType,menu,const DeepCollectionEquality().hash(_pages),headerPage,footerPage);

@override
String toString() {
  return 'MenuTree(menu: $menu, pages: $pages, headerPage: $headerPage, footerPage: $footerPage)';
}


}

/// @nodoc
abstract mixin class _$MenuTreeCopyWith<$Res> implements $MenuTreeCopyWith<$Res> {
  factory _$MenuTreeCopyWith(_MenuTree value, $Res Function(_MenuTree) _then) = __$MenuTreeCopyWithImpl;
@override @useResult
$Res call({
 Menu menu, List<PageWithContainers> pages, PageWithContainers? headerPage, PageWithContainers? footerPage
});


@override $MenuCopyWith<$Res> get menu;@override $PageWithContainersCopyWith<$Res>? get headerPage;@override $PageWithContainersCopyWith<$Res>? get footerPage;

}
/// @nodoc
class __$MenuTreeCopyWithImpl<$Res>
    implements _$MenuTreeCopyWith<$Res> {
  __$MenuTreeCopyWithImpl(this._self, this._then);

  final _MenuTree _self;
  final $Res Function(_MenuTree) _then;

/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menu = null,Object? pages = null,Object? headerPage = freezed,Object? footerPage = freezed,}) {
  return _then(_MenuTree(
menu: null == menu ? _self.menu : menu // ignore: cast_nullable_to_non_nullable
as Menu,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<PageWithContainers>,headerPage: freezed == headerPage ? _self.headerPage : headerPage // ignore: cast_nullable_to_non_nullable
as PageWithContainers?,footerPage: freezed == footerPage ? _self.footerPage : footerPage // ignore: cast_nullable_to_non_nullable
as PageWithContainers?,
  ));
}

/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuCopyWith<$Res> get menu {
  
  return $MenuCopyWith<$Res>(_self.menu, (value) {
    return _then(_self.copyWith(menu: value));
  });
}/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageWithContainersCopyWith<$Res>? get headerPage {
    if (_self.headerPage == null) {
    return null;
  }

  return $PageWithContainersCopyWith<$Res>(_self.headerPage!, (value) {
    return _then(_self.copyWith(headerPage: value));
  });
}/// Create a copy of MenuTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageWithContainersCopyWith<$Res>? get footerPage {
    if (_self.footerPage == null) {
    return null;
  }

  return $PageWithContainersCopyWith<$Res>(_self.footerPage!, (value) {
    return _then(_self.copyWith(footerPage: value));
  });
}
}

/// @nodoc
mixin _$PageWithContainers {

 Page get page; List<ContainerWithColumns> get containers;
/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageWithContainersCopyWith<PageWithContainers> get copyWith => _$PageWithContainersCopyWithImpl<PageWithContainers>(this as PageWithContainers, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageWithContainers&&(identical(other.page, page) || other.page == page)&&const DeepCollectionEquality().equals(other.containers, containers));
}


@override
int get hashCode => Object.hash(runtimeType,page,const DeepCollectionEquality().hash(containers));

@override
String toString() {
  return 'PageWithContainers(page: $page, containers: $containers)';
}


}

/// @nodoc
abstract mixin class $PageWithContainersCopyWith<$Res>  {
  factory $PageWithContainersCopyWith(PageWithContainers value, $Res Function(PageWithContainers) _then) = _$PageWithContainersCopyWithImpl;
@useResult
$Res call({
 Page page, List<ContainerWithColumns> containers
});


$PageCopyWith<$Res> get page;

}
/// @nodoc
class _$PageWithContainersCopyWithImpl<$Res>
    implements $PageWithContainersCopyWith<$Res> {
  _$PageWithContainersCopyWithImpl(this._self, this._then);

  final PageWithContainers _self;
  final $Res Function(PageWithContainers) _then;

/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? containers = null,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as Page,containers: null == containers ? _self.containers : containers // ignore: cast_nullable_to_non_nullable
as List<ContainerWithColumns>,
  ));
}
/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res> get page {
  
  return $PageCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}


/// Adds pattern-matching-related methods to [PageWithContainers].
extension PageWithContainersPatterns on PageWithContainers {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageWithContainers value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageWithContainers() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageWithContainers value)  $default,){
final _that = this;
switch (_that) {
case _PageWithContainers():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageWithContainers value)?  $default,){
final _that = this;
switch (_that) {
case _PageWithContainers() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Page page,  List<ContainerWithColumns> containers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageWithContainers() when $default != null:
return $default(_that.page,_that.containers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Page page,  List<ContainerWithColumns> containers)  $default,) {final _that = this;
switch (_that) {
case _PageWithContainers():
return $default(_that.page,_that.containers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Page page,  List<ContainerWithColumns> containers)?  $default,) {final _that = this;
switch (_that) {
case _PageWithContainers() when $default != null:
return $default(_that.page,_that.containers);case _:
  return null;

}
}

}

/// @nodoc


class _PageWithContainers extends PageWithContainers {
  const _PageWithContainers({required this.page, required final  List<ContainerWithColumns> containers}): _containers = containers,super._();
  

@override final  Page page;
 final  List<ContainerWithColumns> _containers;
@override List<ContainerWithColumns> get containers {
  if (_containers is EqualUnmodifiableListView) return _containers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_containers);
}


/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageWithContainersCopyWith<_PageWithContainers> get copyWith => __$PageWithContainersCopyWithImpl<_PageWithContainers>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageWithContainers&&(identical(other.page, page) || other.page == page)&&const DeepCollectionEquality().equals(other._containers, _containers));
}


@override
int get hashCode => Object.hash(runtimeType,page,const DeepCollectionEquality().hash(_containers));

@override
String toString() {
  return 'PageWithContainers(page: $page, containers: $containers)';
}


}

/// @nodoc
abstract mixin class _$PageWithContainersCopyWith<$Res> implements $PageWithContainersCopyWith<$Res> {
  factory _$PageWithContainersCopyWith(_PageWithContainers value, $Res Function(_PageWithContainers) _then) = __$PageWithContainersCopyWithImpl;
@override @useResult
$Res call({
 Page page, List<ContainerWithColumns> containers
});


@override $PageCopyWith<$Res> get page;

}
/// @nodoc
class __$PageWithContainersCopyWithImpl<$Res>
    implements _$PageWithContainersCopyWith<$Res> {
  __$PageWithContainersCopyWithImpl(this._self, this._then);

  final _PageWithContainers _self;
  final $Res Function(_PageWithContainers) _then;

/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? containers = null,}) {
  return _then(_PageWithContainers(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as Page,containers: null == containers ? _self._containers : containers // ignore: cast_nullable_to_non_nullable
as List<ContainerWithColumns>,
  ));
}

/// Create a copy of PageWithContainers
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageCopyWith<$Res> get page {
  
  return $PageCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}

/// @nodoc
mixin _$ContainerWithColumns {

 Container get container; List<ColumnWithWidgets> get columns; List<ContainerWithColumns> get children;
/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerWithColumnsCopyWith<ContainerWithColumns> get copyWith => _$ContainerWithColumnsCopyWithImpl<ContainerWithColumns>(this as ContainerWithColumns, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerWithColumns&&(identical(other.container, container) || other.container == container)&&const DeepCollectionEquality().equals(other.columns, columns)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,container,const DeepCollectionEquality().hash(columns),const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ContainerWithColumns(container: $container, columns: $columns, children: $children)';
}


}

/// @nodoc
abstract mixin class $ContainerWithColumnsCopyWith<$Res>  {
  factory $ContainerWithColumnsCopyWith(ContainerWithColumns value, $Res Function(ContainerWithColumns) _then) = _$ContainerWithColumnsCopyWithImpl;
@useResult
$Res call({
 Container container, List<ColumnWithWidgets> columns, List<ContainerWithColumns> children
});


$ContainerCopyWith<$Res> get container;

}
/// @nodoc
class _$ContainerWithColumnsCopyWithImpl<$Res>
    implements $ContainerWithColumnsCopyWith<$Res> {
  _$ContainerWithColumnsCopyWithImpl(this._self, this._then);

  final ContainerWithColumns _self;
  final $Res Function(ContainerWithColumns) _then;

/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? container = null,Object? columns = null,Object? children = null,}) {
  return _then(_self.copyWith(
container: null == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as Container,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<ColumnWithWidgets>,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ContainerWithColumns>,
  ));
}
/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCopyWith<$Res> get container {
  
  return $ContainerCopyWith<$Res>(_self.container, (value) {
    return _then(_self.copyWith(container: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContainerWithColumns].
extension ContainerWithColumnsPatterns on ContainerWithColumns {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerWithColumns value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerWithColumns() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerWithColumns value)  $default,){
final _that = this;
switch (_that) {
case _ContainerWithColumns():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerWithColumns value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerWithColumns() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Container container,  List<ColumnWithWidgets> columns,  List<ContainerWithColumns> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerWithColumns() when $default != null:
return $default(_that.container,_that.columns,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Container container,  List<ColumnWithWidgets> columns,  List<ContainerWithColumns> children)  $default,) {final _that = this;
switch (_that) {
case _ContainerWithColumns():
return $default(_that.container,_that.columns,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Container container,  List<ColumnWithWidgets> columns,  List<ContainerWithColumns> children)?  $default,) {final _that = this;
switch (_that) {
case _ContainerWithColumns() when $default != null:
return $default(_that.container,_that.columns,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _ContainerWithColumns extends ContainerWithColumns {
  const _ContainerWithColumns({required this.container, required final  List<ColumnWithWidgets> columns, final  List<ContainerWithColumns> children = const []}): _columns = columns,_children = children,super._();
  

@override final  Container container;
 final  List<ColumnWithWidgets> _columns;
@override List<ColumnWithWidgets> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<ContainerWithColumns> _children;
@override@JsonKey() List<ContainerWithColumns> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerWithColumnsCopyWith<_ContainerWithColumns> get copyWith => __$ContainerWithColumnsCopyWithImpl<_ContainerWithColumns>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerWithColumns&&(identical(other.container, container) || other.container == container)&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,container,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ContainerWithColumns(container: $container, columns: $columns, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ContainerWithColumnsCopyWith<$Res> implements $ContainerWithColumnsCopyWith<$Res> {
  factory _$ContainerWithColumnsCopyWith(_ContainerWithColumns value, $Res Function(_ContainerWithColumns) _then) = __$ContainerWithColumnsCopyWithImpl;
@override @useResult
$Res call({
 Container container, List<ColumnWithWidgets> columns, List<ContainerWithColumns> children
});


@override $ContainerCopyWith<$Res> get container;

}
/// @nodoc
class __$ContainerWithColumnsCopyWithImpl<$Res>
    implements _$ContainerWithColumnsCopyWith<$Res> {
  __$ContainerWithColumnsCopyWithImpl(this._self, this._then);

  final _ContainerWithColumns _self;
  final $Res Function(_ContainerWithColumns) _then;

/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? container = null,Object? columns = null,Object? children = null,}) {
  return _then(_ContainerWithColumns(
container: null == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as Container,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<ColumnWithWidgets>,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ContainerWithColumns>,
  ));
}

/// Create a copy of ContainerWithColumns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCopyWith<$Res> get container {
  
  return $ContainerCopyWith<$Res>(_self.container, (value) {
    return _then(_self.copyWith(container: value));
  });
}
}

/// @nodoc
mixin _$ColumnWithWidgets {

 Column get column; List<WidgetInstance> get widgets;
/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColumnWithWidgetsCopyWith<ColumnWithWidgets> get copyWith => _$ColumnWithWidgetsCopyWithImpl<ColumnWithWidgets>(this as ColumnWithWidgets, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColumnWithWidgets&&(identical(other.column, column) || other.column == column)&&const DeepCollectionEquality().equals(other.widgets, widgets));
}


@override
int get hashCode => Object.hash(runtimeType,column,const DeepCollectionEquality().hash(widgets));

@override
String toString() {
  return 'ColumnWithWidgets(column: $column, widgets: $widgets)';
}


}

/// @nodoc
abstract mixin class $ColumnWithWidgetsCopyWith<$Res>  {
  factory $ColumnWithWidgetsCopyWith(ColumnWithWidgets value, $Res Function(ColumnWithWidgets) _then) = _$ColumnWithWidgetsCopyWithImpl;
@useResult
$Res call({
 Column column, List<WidgetInstance> widgets
});


$ColumnCopyWith<$Res> get column;

}
/// @nodoc
class _$ColumnWithWidgetsCopyWithImpl<$Res>
    implements $ColumnWithWidgetsCopyWith<$Res> {
  _$ColumnWithWidgetsCopyWithImpl(this._self, this._then);

  final ColumnWithWidgets _self;
  final $Res Function(ColumnWithWidgets) _then;

/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? column = null,Object? widgets = null,}) {
  return _then(_self.copyWith(
column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as Column,widgets: null == widgets ? _self.widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<WidgetInstance>,
  ));
}
/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ColumnCopyWith<$Res> get column {
  
  return $ColumnCopyWith<$Res>(_self.column, (value) {
    return _then(_self.copyWith(column: value));
  });
}
}


/// Adds pattern-matching-related methods to [ColumnWithWidgets].
extension ColumnWithWidgetsPatterns on ColumnWithWidgets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColumnWithWidgets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColumnWithWidgets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColumnWithWidgets value)  $default,){
final _that = this;
switch (_that) {
case _ColumnWithWidgets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColumnWithWidgets value)?  $default,){
final _that = this;
switch (_that) {
case _ColumnWithWidgets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Column column,  List<WidgetInstance> widgets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColumnWithWidgets() when $default != null:
return $default(_that.column,_that.widgets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Column column,  List<WidgetInstance> widgets)  $default,) {final _that = this;
switch (_that) {
case _ColumnWithWidgets():
return $default(_that.column,_that.widgets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Column column,  List<WidgetInstance> widgets)?  $default,) {final _that = this;
switch (_that) {
case _ColumnWithWidgets() when $default != null:
return $default(_that.column,_that.widgets);case _:
  return null;

}
}

}

/// @nodoc


class _ColumnWithWidgets extends ColumnWithWidgets {
  const _ColumnWithWidgets({required this.column, required final  List<WidgetInstance> widgets}): _widgets = widgets,super._();
  

@override final  Column column;
 final  List<WidgetInstance> _widgets;
@override List<WidgetInstance> get widgets {
  if (_widgets is EqualUnmodifiableListView) return _widgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_widgets);
}


/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColumnWithWidgetsCopyWith<_ColumnWithWidgets> get copyWith => __$ColumnWithWidgetsCopyWithImpl<_ColumnWithWidgets>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColumnWithWidgets&&(identical(other.column, column) || other.column == column)&&const DeepCollectionEquality().equals(other._widgets, _widgets));
}


@override
int get hashCode => Object.hash(runtimeType,column,const DeepCollectionEquality().hash(_widgets));

@override
String toString() {
  return 'ColumnWithWidgets(column: $column, widgets: $widgets)';
}


}

/// @nodoc
abstract mixin class _$ColumnWithWidgetsCopyWith<$Res> implements $ColumnWithWidgetsCopyWith<$Res> {
  factory _$ColumnWithWidgetsCopyWith(_ColumnWithWidgets value, $Res Function(_ColumnWithWidgets) _then) = __$ColumnWithWidgetsCopyWithImpl;
@override @useResult
$Res call({
 Column column, List<WidgetInstance> widgets
});


@override $ColumnCopyWith<$Res> get column;

}
/// @nodoc
class __$ColumnWithWidgetsCopyWithImpl<$Res>
    implements _$ColumnWithWidgetsCopyWith<$Res> {
  __$ColumnWithWidgetsCopyWithImpl(this._self, this._then);

  final _ColumnWithWidgets _self;
  final $Res Function(_ColumnWithWidgets) _then;

/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? column = null,Object? widgets = null,}) {
  return _then(_ColumnWithWidgets(
column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as Column,widgets: null == widgets ? _self._widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<WidgetInstance>,
  ));
}

/// Create a copy of ColumnWithWidgets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ColumnCopyWith<$Res> get column {
  
  return $ColumnCopyWith<$Res>(_self.column, (value) {
    return _then(_self.copyWith(column: value));
  });
}
}

// dart format on
