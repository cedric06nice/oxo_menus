import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

/// Mapper for converting between WidgetInstance entity and WidgetDto
class WidgetMapper {
  /// Convert WidgetDto to WidgetInstance entity
  static WidgetInstance toEntity(WidgetDto dto) {
    return WidgetInstance(
      id: dto.id,
      columnId: dto.columnId,
      type: dto.type,
      version: dto.version,
      index: dto.index,
      props: Map<String, dynamic>.from(dto.props),
      style: dto.styleJson != null
          ? _mapStyleJsonToWidgetStyle(dto.styleJson!)
          : null,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert WidgetInstance entity to WidgetDto
  static WidgetDto toDto(WidgetInstance entity) {
    return WidgetDto(
      id: entity.id,
      columnId: entity.columnId,
      type: entity.type,
      version: entity.version,
      index: entity.index,
      props: Map<String, dynamic>.from(entity.props),
      styleJson: entity.style != null
          ? widgetStyleToJson(entity.style!)
          : null,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
    );
  }

  // ===== Private helper methods =====

  /// Map style_json to WidgetStyle
  static WidgetStyle _mapStyleJsonToWidgetStyle(Map<String, dynamic> json) {
    return WidgetStyle(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      color: json['color'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      border: json['border'] as String?,
      padding: (json['padding'] as num?)?.toDouble(),
    );
  }

  /// Map WidgetStyle to JSON
  static Map<String, dynamic> widgetStyleToJson(WidgetStyle style) {
    final json = <String, dynamic>{};

    if (style.fontFamily != null) json['fontFamily'] = style.fontFamily;
    if (style.fontSize != null) json['fontSize'] = style.fontSize;
    if (style.color != null) json['color'] = style.color;
    if (style.backgroundColor != null) {
      json['backgroundColor'] = style.backgroundColor;
    }
    if (style.border != null) json['border'] = style.border;
    if (style.padding != null) json['padding'] = style.padding;

    return json;
  }
}
