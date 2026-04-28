import 'package:oxo_menus/shared/data/models/area_dto.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

/// Mapper for converting between Area entity and AreaDto
class AreaMapper {
  /// Convert AreaDto to Area entity
  static Area toEntity(AreaDto dto) {
    final idString = dto.id ?? '0';
    return Area(id: int.parse(idString), name: dto.name);
  }
}
