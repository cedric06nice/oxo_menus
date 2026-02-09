import 'package:oxo_menus/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

/// Mapper for converting between Container entity and ContainerDto
class ContainerMapper {
  /// Convert ContainerDto to Container entity
  static Container toEntity(ContainerDto dto) {
    String idString = dto.id ?? '0';
    final json = dto.styleJson;
    return Container(
      id: int.parse(idString),
      pageId: dto.page?.id != null ? int.parse(dto.page!.id!) : 0,
      index: dto.index,
      name: "Container ${dto.id}",
      layout: json.isNotEmpty
          ? _mapLayoutJsonToLayoutConfig(json)
          : null,
      styleConfig: json.isNotEmpty
          ? StyleConfigMapper.fromJson(json)
          : null,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Container entity to ContainerDto
  static ContainerDto toDto(Container entity) {
    return ContainerDto({
      'id': entity.id,
      'page': entity.pageId,
      'index': entity.index,
      'name': entity.name,
      'style_json': _mergeStyleJson(entity.layout, entity.styleConfig),
      'date_created': entity.dateCreated?.toIso8601String(),
      'date_updated': entity.dateUpdated?.toIso8601String(),
    });
  }

  // ===== Private helper methods =====

  /// Merge layout config and style config into a single JSON map for style_json.
  static Map<String, dynamic>? _mergeStyleJson(
    LayoutConfig? layout,
    StyleConfig? styleConfig,
  ) {
    if (layout == null && styleConfig == null) return null;
    final json = <String, dynamic>{};
    if (layout != null) {
      json.addAll(layoutConfigToJson(layout));
    }
    if (styleConfig != null) {
      json.addAll(StyleConfigMapper.toJson(styleConfig));
    }
    return json.isEmpty ? null : json;
  }

  /// Map layout_json to LayoutConfig
  static LayoutConfig _mapLayoutJsonToLayoutConfig(Map<String, dynamic> json) {
    return LayoutConfig(
      direction: json['direction'] as String?,
      alignment: json['alignment'] as String?,
      spacing: (json['spacing'] as num?)?.toDouble(),
    );
  }

  /// Map LayoutConfig to JSON
  static Map<String, dynamic> layoutConfigToJson(LayoutConfig config) {
    final json = <String, dynamic>{};

    if (config.direction != null) json['direction'] = config.direction;
    if (config.alignment != null) json['alignment'] = config.alignment;
    if (config.spacing != null) json['spacing'] = config.spacing;

    return json;
  }
}
