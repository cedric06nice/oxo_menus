import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/container.dart';

/// Mapper for converting between Container entity and ContainerDto
class ContainerMapper {
  /// Convert ContainerDto to Container entity
  static Container toEntity(ContainerDto dto) {
    String idString = dto.id ?? '0';
    return Container(
      id: int.parse(idString),
      pageId: dto.page?.id != null ? int.parse(dto.page!.id!) : 0,
      index: dto.index,
      name: "Container ${dto.id}",
      layout: dto.styleJson.isNotEmpty
          ? _mapLayoutJsonToLayoutConfig(dto.styleJson)
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
      'style_json': entity.layout != null
          ? layoutConfigToJson(entity.layout!)
          : null,
      'date_created': entity.dateCreated?.toIso8601String(),
      'date_updated': entity.dateUpdated?.toIso8601String(),
    });
  }

  // ===== Private helper methods =====

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
