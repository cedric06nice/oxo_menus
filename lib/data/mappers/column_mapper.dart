import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/domain/entities/column.dart';

/// Mapper for converting between Column entity and ColumnDto
class ColumnMapper {
  /// Convert ColumnDto to Column entity
  static Column toEntity(ColumnDto dto) {
    String idString = dto.id ?? '0';
    return Column(
      id: int.parse(idString),
      containerId: dto.container?.id != null ? int.parse(dto.container!.id!) : 0,
      index: dto.index,
      flex: null, // Don't hardcode flex - DTO doesn't have this field
      width: dto.width.toDouble(),
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Column entity to ColumnDto
  static ColumnDto toDto(Column entity) {
    return ColumnDto({
      'id': entity.id,
      'container': entity.containerId,
      'index': entity.index,
      // Don't map flex - DTO doesn't have this field
      'width': entity.width?.toInt() ?? 0, // Default to 0 if null
      'date_created': entity.dateCreated?.toIso8601String(),
      'date_updated': entity.dateUpdated?.toIso8601String(),
    });
  }
}
