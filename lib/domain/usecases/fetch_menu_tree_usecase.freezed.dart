// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fetch_menu_tree_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MenuTree {
  Menu get menu => throw _privateConstructorUsedError;
  List<PageWithContainers> get pages => throw _privateConstructorUsedError;

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuTreeCopyWith<MenuTree> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuTreeCopyWith<$Res> {
  factory $MenuTreeCopyWith(MenuTree value, $Res Function(MenuTree) then) =
      _$MenuTreeCopyWithImpl<$Res, MenuTree>;
  @useResult
  $Res call({Menu menu, List<PageWithContainers> pages});

  $MenuCopyWith<$Res> get menu;
}

/// @nodoc
class _$MenuTreeCopyWithImpl<$Res, $Val extends MenuTree>
    implements $MenuTreeCopyWith<$Res> {
  _$MenuTreeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menu = null,
    Object? pages = null,
  }) {
    return _then(_value.copyWith(
      menu: null == menu
          ? _value.menu
          : menu // ignore: cast_nullable_to_non_nullable
              as Menu,
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<PageWithContainers>,
    ) as $Val);
  }

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MenuCopyWith<$Res> get menu {
    return $MenuCopyWith<$Res>(_value.menu, (value) {
      return _then(_value.copyWith(menu: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MenuTreeImplCopyWith<$Res>
    implements $MenuTreeCopyWith<$Res> {
  factory _$$MenuTreeImplCopyWith(
          _$MenuTreeImpl value, $Res Function(_$MenuTreeImpl) then) =
      __$$MenuTreeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Menu menu, List<PageWithContainers> pages});

  @override
  $MenuCopyWith<$Res> get menu;
}

/// @nodoc
class __$$MenuTreeImplCopyWithImpl<$Res>
    extends _$MenuTreeCopyWithImpl<$Res, _$MenuTreeImpl>
    implements _$$MenuTreeImplCopyWith<$Res> {
  __$$MenuTreeImplCopyWithImpl(
      _$MenuTreeImpl _value, $Res Function(_$MenuTreeImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menu = null,
    Object? pages = null,
  }) {
    return _then(_$MenuTreeImpl(
      menu: null == menu
          ? _value.menu
          : menu // ignore: cast_nullable_to_non_nullable
              as Menu,
      pages: null == pages
          ? _value._pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<PageWithContainers>,
    ));
  }
}

/// @nodoc

class _$MenuTreeImpl implements _MenuTree {
  const _$MenuTreeImpl(
      {required this.menu, required final List<PageWithContainers> pages})
      : _pages = pages;

  @override
  final Menu menu;
  final List<PageWithContainers> _pages;
  @override
  List<PageWithContainers> get pages {
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pages);
  }

  @override
  String toString() {
    return 'MenuTree(menu: $menu, pages: $pages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuTreeImpl &&
            (identical(other.menu, menu) || other.menu == menu) &&
            const DeepCollectionEquality().equals(other._pages, _pages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, menu, const DeepCollectionEquality().hash(_pages));

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuTreeImplCopyWith<_$MenuTreeImpl> get copyWith =>
      __$$MenuTreeImplCopyWithImpl<_$MenuTreeImpl>(this, _$identity);
}

abstract class _MenuTree implements MenuTree {
  const factory _MenuTree(
      {required final Menu menu,
      required final List<PageWithContainers> pages}) = _$MenuTreeImpl;

  @override
  Menu get menu;
  @override
  List<PageWithContainers> get pages;

  /// Create a copy of MenuTree
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuTreeImplCopyWith<_$MenuTreeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PageWithContainers {
  Page get page => throw _privateConstructorUsedError;
  List<ContainerWithColumns> get containers =>
      throw _privateConstructorUsedError;

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageWithContainersCopyWith<PageWithContainers> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageWithContainersCopyWith<$Res> {
  factory $PageWithContainersCopyWith(
          PageWithContainers value, $Res Function(PageWithContainers) then) =
      _$PageWithContainersCopyWithImpl<$Res, PageWithContainers>;
  @useResult
  $Res call({Page page, List<ContainerWithColumns> containers});

  $PageCopyWith<$Res> get page;
}

/// @nodoc
class _$PageWithContainersCopyWithImpl<$Res, $Val extends PageWithContainers>
    implements $PageWithContainersCopyWith<$Res> {
  _$PageWithContainersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? containers = null,
  }) {
    return _then(_value.copyWith(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as Page,
      containers: null == containers
          ? _value.containers
          : containers // ignore: cast_nullable_to_non_nullable
              as List<ContainerWithColumns>,
    ) as $Val);
  }

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PageCopyWith<$Res> get page {
    return $PageCopyWith<$Res>(_value.page, (value) {
      return _then(_value.copyWith(page: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PageWithContainersImplCopyWith<$Res>
    implements $PageWithContainersCopyWith<$Res> {
  factory _$$PageWithContainersImplCopyWith(_$PageWithContainersImpl value,
          $Res Function(_$PageWithContainersImpl) then) =
      __$$PageWithContainersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Page page, List<ContainerWithColumns> containers});

  @override
  $PageCopyWith<$Res> get page;
}

/// @nodoc
class __$$PageWithContainersImplCopyWithImpl<$Res>
    extends _$PageWithContainersCopyWithImpl<$Res, _$PageWithContainersImpl>
    implements _$$PageWithContainersImplCopyWith<$Res> {
  __$$PageWithContainersImplCopyWithImpl(_$PageWithContainersImpl _value,
      $Res Function(_$PageWithContainersImpl) _then)
      : super(_value, _then);

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? containers = null,
  }) {
    return _then(_$PageWithContainersImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as Page,
      containers: null == containers
          ? _value._containers
          : containers // ignore: cast_nullable_to_non_nullable
              as List<ContainerWithColumns>,
    ));
  }
}

/// @nodoc

class _$PageWithContainersImpl implements _PageWithContainers {
  const _$PageWithContainersImpl(
      {required this.page,
      required final List<ContainerWithColumns> containers})
      : _containers = containers;

  @override
  final Page page;
  final List<ContainerWithColumns> _containers;
  @override
  List<ContainerWithColumns> get containers {
    if (_containers is EqualUnmodifiableListView) return _containers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_containers);
  }

  @override
  String toString() {
    return 'PageWithContainers(page: $page, containers: $containers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageWithContainersImpl &&
            (identical(other.page, page) || other.page == page) &&
            const DeepCollectionEquality()
                .equals(other._containers, _containers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, page, const DeepCollectionEquality().hash(_containers));

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageWithContainersImplCopyWith<_$PageWithContainersImpl> get copyWith =>
      __$$PageWithContainersImplCopyWithImpl<_$PageWithContainersImpl>(
          this, _$identity);
}

abstract class _PageWithContainers implements PageWithContainers {
  const factory _PageWithContainers(
          {required final Page page,
          required final List<ContainerWithColumns> containers}) =
      _$PageWithContainersImpl;

  @override
  Page get page;
  @override
  List<ContainerWithColumns> get containers;

  /// Create a copy of PageWithContainers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageWithContainersImplCopyWith<_$PageWithContainersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ContainerWithColumns {
  Container get container => throw _privateConstructorUsedError;
  List<ColumnWithWidgets> get columns => throw _privateConstructorUsedError;

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContainerWithColumnsCopyWith<ContainerWithColumns> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerWithColumnsCopyWith<$Res> {
  factory $ContainerWithColumnsCopyWith(ContainerWithColumns value,
          $Res Function(ContainerWithColumns) then) =
      _$ContainerWithColumnsCopyWithImpl<$Res, ContainerWithColumns>;
  @useResult
  $Res call({Container container, List<ColumnWithWidgets> columns});

  $ContainerCopyWith<$Res> get container;
}

/// @nodoc
class _$ContainerWithColumnsCopyWithImpl<$Res,
        $Val extends ContainerWithColumns>
    implements $ContainerWithColumnsCopyWith<$Res> {
  _$ContainerWithColumnsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? container = null,
    Object? columns = null,
  }) {
    return _then(_value.copyWith(
      container: null == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as Container,
      columns: null == columns
          ? _value.columns
          : columns // ignore: cast_nullable_to_non_nullable
              as List<ColumnWithWidgets>,
    ) as $Val);
  }

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContainerCopyWith<$Res> get container {
    return $ContainerCopyWith<$Res>(_value.container, (value) {
      return _then(_value.copyWith(container: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ContainerWithColumnsImplCopyWith<$Res>
    implements $ContainerWithColumnsCopyWith<$Res> {
  factory _$$ContainerWithColumnsImplCopyWith(_$ContainerWithColumnsImpl value,
          $Res Function(_$ContainerWithColumnsImpl) then) =
      __$$ContainerWithColumnsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Container container, List<ColumnWithWidgets> columns});

  @override
  $ContainerCopyWith<$Res> get container;
}

/// @nodoc
class __$$ContainerWithColumnsImplCopyWithImpl<$Res>
    extends _$ContainerWithColumnsCopyWithImpl<$Res, _$ContainerWithColumnsImpl>
    implements _$$ContainerWithColumnsImplCopyWith<$Res> {
  __$$ContainerWithColumnsImplCopyWithImpl(_$ContainerWithColumnsImpl _value,
      $Res Function(_$ContainerWithColumnsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? container = null,
    Object? columns = null,
  }) {
    return _then(_$ContainerWithColumnsImpl(
      container: null == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as Container,
      columns: null == columns
          ? _value._columns
          : columns // ignore: cast_nullable_to_non_nullable
              as List<ColumnWithWidgets>,
    ));
  }
}

/// @nodoc

class _$ContainerWithColumnsImpl implements _ContainerWithColumns {
  const _$ContainerWithColumnsImpl(
      {required this.container, required final List<ColumnWithWidgets> columns})
      : _columns = columns;

  @override
  final Container container;
  final List<ColumnWithWidgets> _columns;
  @override
  List<ColumnWithWidgets> get columns {
    if (_columns is EqualUnmodifiableListView) return _columns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columns);
  }

  @override
  String toString() {
    return 'ContainerWithColumns(container: $container, columns: $columns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerWithColumnsImpl &&
            (identical(other.container, container) ||
                other.container == container) &&
            const DeepCollectionEquality().equals(other._columns, _columns));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, container, const DeepCollectionEquality().hash(_columns));

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerWithColumnsImplCopyWith<_$ContainerWithColumnsImpl>
      get copyWith =>
          __$$ContainerWithColumnsImplCopyWithImpl<_$ContainerWithColumnsImpl>(
              this, _$identity);
}

abstract class _ContainerWithColumns implements ContainerWithColumns {
  const factory _ContainerWithColumns(
          {required final Container container,
          required final List<ColumnWithWidgets> columns}) =
      _$ContainerWithColumnsImpl;

  @override
  Container get container;
  @override
  List<ColumnWithWidgets> get columns;

  /// Create a copy of ContainerWithColumns
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerWithColumnsImplCopyWith<_$ContainerWithColumnsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ColumnWithWidgets {
  Column get column => throw _privateConstructorUsedError;
  List<WidgetInstance> get widgets => throw _privateConstructorUsedError;

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnWithWidgetsCopyWith<ColumnWithWidgets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnWithWidgetsCopyWith<$Res> {
  factory $ColumnWithWidgetsCopyWith(
          ColumnWithWidgets value, $Res Function(ColumnWithWidgets) then) =
      _$ColumnWithWidgetsCopyWithImpl<$Res, ColumnWithWidgets>;
  @useResult
  $Res call({Column column, List<WidgetInstance> widgets});

  $ColumnCopyWith<$Res> get column;
}

/// @nodoc
class _$ColumnWithWidgetsCopyWithImpl<$Res, $Val extends ColumnWithWidgets>
    implements $ColumnWithWidgetsCopyWith<$Res> {
  _$ColumnWithWidgetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? column = null,
    Object? widgets = null,
  }) {
    return _then(_value.copyWith(
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as Column,
      widgets: null == widgets
          ? _value.widgets
          : widgets // ignore: cast_nullable_to_non_nullable
              as List<WidgetInstance>,
    ) as $Val);
  }

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ColumnCopyWith<$Res> get column {
    return $ColumnCopyWith<$Res>(_value.column, (value) {
      return _then(_value.copyWith(column: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ColumnWithWidgetsImplCopyWith<$Res>
    implements $ColumnWithWidgetsCopyWith<$Res> {
  factory _$$ColumnWithWidgetsImplCopyWith(_$ColumnWithWidgetsImpl value,
          $Res Function(_$ColumnWithWidgetsImpl) then) =
      __$$ColumnWithWidgetsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Column column, List<WidgetInstance> widgets});

  @override
  $ColumnCopyWith<$Res> get column;
}

/// @nodoc
class __$$ColumnWithWidgetsImplCopyWithImpl<$Res>
    extends _$ColumnWithWidgetsCopyWithImpl<$Res, _$ColumnWithWidgetsImpl>
    implements _$$ColumnWithWidgetsImplCopyWith<$Res> {
  __$$ColumnWithWidgetsImplCopyWithImpl(_$ColumnWithWidgetsImpl _value,
      $Res Function(_$ColumnWithWidgetsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? column = null,
    Object? widgets = null,
  }) {
    return _then(_$ColumnWithWidgetsImpl(
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as Column,
      widgets: null == widgets
          ? _value._widgets
          : widgets // ignore: cast_nullable_to_non_nullable
              as List<WidgetInstance>,
    ));
  }
}

/// @nodoc

class _$ColumnWithWidgetsImpl implements _ColumnWithWidgets {
  const _$ColumnWithWidgetsImpl(
      {required this.column, required final List<WidgetInstance> widgets})
      : _widgets = widgets;

  @override
  final Column column;
  final List<WidgetInstance> _widgets;
  @override
  List<WidgetInstance> get widgets {
    if (_widgets is EqualUnmodifiableListView) return _widgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_widgets);
  }

  @override
  String toString() {
    return 'ColumnWithWidgets(column: $column, widgets: $widgets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnWithWidgetsImpl &&
            (identical(other.column, column) || other.column == column) &&
            const DeepCollectionEquality().equals(other._widgets, _widgets));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, column, const DeepCollectionEquality().hash(_widgets));

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnWithWidgetsImplCopyWith<_$ColumnWithWidgetsImpl> get copyWith =>
      __$$ColumnWithWidgetsImplCopyWithImpl<_$ColumnWithWidgetsImpl>(
          this, _$identity);
}

abstract class _ColumnWithWidgets implements ColumnWithWidgets {
  const factory _ColumnWithWidgets(
      {required final Column column,
      required final List<WidgetInstance> widgets}) = _$ColumnWithWidgetsImpl;

  @override
  Column get column;
  @override
  List<WidgetInstance> get widgets;

  /// Create a copy of ColumnWithWidgets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnWithWidgetsImplCopyWith<_$ColumnWithWidgetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
