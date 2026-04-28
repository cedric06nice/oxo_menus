import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/border_type.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

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
    @Default([]) List<WidgetTypeConfig> allowedWidgets,
  }) = _Menu;

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  /// Set of widget type strings currently enabled for regular users.
  /// Alignment may be configured for types that aren't enabled.
  Set<String> get allowedWidgetTypes =>
      allowedWidgets.where((c) => c.enabled).map((c) => c.type).toSet();

  /// Looks up the configured alignment for a given widget type.
  /// Returns [WidgetAlignment.start] when the type isn't in the allow-list.
  WidgetAlignment alignmentFor(String type) {
    for (final config in allowedWidgets) {
      if (config.type == type) return config.alignment;
    }
    return WidgetAlignment.start;
  }
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
