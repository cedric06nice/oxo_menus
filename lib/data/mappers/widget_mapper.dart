import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

/// Mapper for converting between WidgetInstance entity and WidgetDto
class WidgetMapper {
  /// Convert WidgetDto to WidgetInstance entity
  static WidgetInstance toEntity(WidgetDto dto) {
    String idString = dto.id ?? '0';
    return WidgetInstance(
      id: int.parse(idString),
      columnId: dto.column?.id != null ? int.parse(dto.column!.id!) : 0,
      type: dto.typeKey,
      version: dto.version,
      index: dto.index,
      props: dto.propsJson.isNotEmpty
          ? Map<String, dynamic>.from(dto.propsJson)
          : {},
      style: dto.styleJson.isNotEmpty
          ? _mapStyleJsonToWidgetStyle(dto.styleJson)
          : null,
      isTemplate: dto.isTemplate,
      lockedForEdition: dto.lockedForEdition,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
      editingBy: dto.editingBy,
      editingSince: dto.editingSince,
    );
  }

  /// Convert WidgetInstance entity to WidgetDto
  static WidgetDto toDto(WidgetInstance entity) {
    return WidgetDto({
      'id': entity.id,
      'column': entity.columnId,
      'type_key': entity.type,
      'version': entity.version,
      'index': entity.index,
      'props_json': Map<String, dynamic>.from(entity.props),
      'style_json': entity.style != null
          ? widgetStyleToJson(entity.style!)
          : null,
      'is_template': entity.isTemplate,
      'locked_for_edition': entity.lockedForEdition,
      'date_created': entity.dateCreated,
      'date_updated': entity.dateUpdated,
      'editing_by': entity.editingBy,
      'editing_since': entity.editingSince?.toIso8601String(),
    });
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
