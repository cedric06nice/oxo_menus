import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/domain/entities/column.dart';

/// Mapper for converting between Column entity and ColumnDto
class ColumnMapper {
  /// Convert ColumnDto to Column entity
  static Column toEntity(ColumnDto dto) {
    return Column(
      id: dto.id,
      containerId: dto.containerId,
      index: dto.index,
      flex: dto.flex,
      width: dto.width,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Column entity to ColumnDto
  static ColumnDto toDto(Column entity) {
    return ColumnDto(
      id: entity.id,
      containerId: entity.containerId,
      index: entity.index,
      flex: entity.flex,
      width: entity.width,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
    );
  }
}
