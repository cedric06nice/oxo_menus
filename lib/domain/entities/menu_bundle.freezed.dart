// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuBundle {

 int get id; String get name; List<int> get menuIds; String? get pdfFileId; DateTime? get dateCreated; DateTime? get dateUpdated;
/// Create a copy of MenuBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuBundleCopyWith<MenuBundle> get copyWith => _$MenuBundleCopyWithImpl<MenuBundle>(this as MenuBundle, _$identity);

  /// Serializes this MenuBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuBundle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.menuIds, menuIds)&&(identical(other.pdfFileId, pdfFileId) || other.pdfFileId == pdfFileId)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(menuIds),pdfFileId,dateCreated,dateUpdated);

@override
String toString() {
  return 'MenuBundle(id: $id, name: $name, menuIds: $menuIds, pdfFileId: $pdfFileId, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class $MenuBundleCopyWith<$Res>  {
  factory $MenuBundleCopyWith(MenuBundle value, $Res Function(MenuBundle) _then) = _$MenuBundleCopyWithImpl;
@useResult
$Res call({
 int id, String name, List<int> menuIds, String? pdfFileId, DateTime? dateCreated, DateTime? dateUpdated
});




}
/// @nodoc
class _$MenuBundleCopyWithImpl<$Res>
    implements $MenuBundleCopyWith<$Res> {
  _$MenuBundleCopyWithImpl(this._self, this._then);

  final MenuBundle _self;
  final $Res Function(MenuBundle) _then;

/// Create a copy of MenuBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? menuIds = null,Object? pdfFileId = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,menuIds: null == menuIds ? _self.menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>,pdfFileId: freezed == pdfFileId ? _self.pdfFileId : pdfFileId // ignore: cast_nullable_to_non_nullable
as String?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuBundle].
extension MenuBundlePatterns on MenuBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuBundle value)  $default,){
final _that = this;
switch (_that) {
case _MenuBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuBundle value)?  $default,){
final _that = this;
switch (_that) {
case _MenuBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  List<int> menuIds,  String? pdfFileId,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuBundle() when $default != null:
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  List<int> menuIds,  String? pdfFileId,  DateTime? dateCreated,  DateTime? dateUpdated)  $default,) {final _that = this;
switch (_that) {
case _MenuBundle():
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  List<int> menuIds,  String? pdfFileId,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,) {final _that = this;
switch (_that) {
case _MenuBundle() when $default != null:
return $default(_that.id,_that.name,_that.menuIds,_that.pdfFileId,_that.dateCreated,_that.dateUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuBundle extends MenuBundle {
  const _MenuBundle({required this.id, required this.name, final  List<int> menuIds = const [], this.pdfFileId, this.dateCreated, this.dateUpdated}): _menuIds = menuIds,super._();
  factory _MenuBundle.fromJson(Map<String, dynamic> json) => _$MenuBundleFromJson(json);

@override final  int id;
@override final  String name;
 final  List<int> _menuIds;
@override@JsonKey() List<int> get menuIds {
  if (_menuIds is EqualUnmodifiableListView) return _menuIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_menuIds);
}

@override final  String? pdfFileId;
@override final  DateTime? dateCreated;
@override final  DateTime? dateUpdated;

/// Create a copy of MenuBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuBundleCopyWith<_MenuBundle> get copyWith => __$MenuBundleCopyWithImpl<_MenuBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuBundle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._menuIds, _menuIds)&&(identical(other.pdfFileId, pdfFileId) || other.pdfFileId == pdfFileId)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_menuIds),pdfFileId,dateCreated,dateUpdated);

@override
String toString() {
  return 'MenuBundle(id: $id, name: $name, menuIds: $menuIds, pdfFileId: $pdfFileId, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class _$MenuBundleCopyWith<$Res> implements $MenuBundleCopyWith<$Res> {
  factory _$MenuBundleCopyWith(_MenuBundle value, $Res Function(_MenuBundle) _then) = __$MenuBundleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, List<int> menuIds, String? pdfFileId, DateTime? dateCreated, DateTime? dateUpdated
});




}
/// @nodoc
class __$MenuBundleCopyWithImpl<$Res>
    implements _$MenuBundleCopyWith<$Res> {
  __$MenuBundleCopyWithImpl(this._self, this._then);

  final _MenuBundle _self;
  final $Res Function(_MenuBundle) _then;

/// Create a copy of MenuBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? menuIds = null,Object? pdfFileId = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_MenuBundle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,menuIds: null == menuIds ? _self._menuIds : menuIds // ignore: cast_nullable_to_non_nullable
as List<int>,pdfFileId: freezed == pdfFileId ? _self.pdfFileId : pdfFileId // ignore: cast_nullable_to_non_nullable
as String?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
