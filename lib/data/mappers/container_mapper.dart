import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/container.dart';

/// Mapper for converting between Container entity and ContainerDto
class ContainerMapper {
  /// Convert ContainerDto to Container entity
  static Container toEntity(ContainerDto dto) {
    return Container(
      id: dto.id,
      pageId: dto.pageId,
      index: dto.index,
      name: dto.name,
      layout: dto.layoutJson != null
          ? _mapLayoutJsonToLayoutConfig(dto.layoutJson!)
          : null,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Container entity to ContainerDto
  static ContainerDto toDto(Container entity) {
    return ContainerDto(
      id: entity.id,
      pageId: entity.pageId,
      index: entity.index,
      name: entity.name,
      layoutJson: entity.layout != null
          ? layoutConfigToJson(entity.layout!)
          : null,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
    );
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
