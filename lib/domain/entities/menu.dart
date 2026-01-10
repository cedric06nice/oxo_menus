import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu.freezed.dart';
part 'menu.g.dart';

/// Represents a menu template (created by admin) or menu instance (used by regular user).
@freezed
class Menu with _$Menu {
  const factory Menu({
    required String id,
    required String name,
    required MenuStatus status,
    required String version,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? userCreated,
    String? userUpdated,
    StyleConfig? styleConfig,
    PageSize? pageSize,
    String? area,
  }) = _Menu;

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
}

/// Menu status enumeration
enum MenuStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
}

/// Style configuration for a menu
@freezed
class StyleConfig with _$StyleConfig {
  const factory StyleConfig({
    String? fontFamily,
    double? fontSize,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
    double? padding,
  }) = _StyleConfig;

  factory StyleConfig.fromJson(Map<String, dynamic> json) =>
      _$StyleConfigFromJson(json);
}

/// Page size configuration
@freezed
class PageSize with _$PageSize {
  const factory PageSize({
    required String name,
    required double width,
    required double height,
  }) = _PageSize;

  factory PageSize.fromJson(Map<String, dynamic> json) =>
      _$PageSizeFromJson(json);
}
