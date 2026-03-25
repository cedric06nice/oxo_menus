import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';

part 'menu.freezed.dart';
part 'menu.g.dart';

/// Represents a menu template (created by admin) or menu instance (used by regular user).
@freezed
abstract class Menu with _$Menu {
  const Menu._();

  const factory Menu({
    required int id,
    required String name,
    required Status status,
    required String version,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? userCreated,
    String? userUpdated,
    StyleConfig? styleConfig,
    PageSize? pageSize,
    Area? area,
    MenuDisplayOptions? displayOptions,
    @Default([]) List<String> allowedWidgetTypes,
  }) = _Menu;

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
}

/// Style configuration for a menu
@freezed
abstract class StyleConfig with _$StyleConfig {
  const StyleConfig._();

  const factory StyleConfig({
    String? fontFamily,
    double? fontSize,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    double? margin,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
    double? padding,
    double? paddingTop,
    double? paddingBottom,
    double? paddingLeft,
    double? paddingRight,
    BorderType? borderType,
    VerticalAlignment? verticalAlignment,
  }) = _StyleConfig;

  factory StyleConfig.fromJson(Map<String, dynamic> json) =>
      _$StyleConfigFromJson(json);
}

/// Page size configuration
@freezed
abstract class PageSize with _$PageSize {
  const PageSize._();

  const factory PageSize({
    required String name,
    required double width,
    required double height,
  }) = _PageSize;

  factory PageSize.fromJson(Map<String, dynamic> json) =>
      _$PageSizeFromJson(json);
}
