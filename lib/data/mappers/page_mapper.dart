import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';

/// Mapper for converting between Page entity and PageDto
class PageMapper {
  /// Convert PageDto to Page entity
  static Page toEntity(PageDto dto) {
    return Page(
      id: dto.id,
      menuId: dto.menuId,
      name: dto.name,
      index: dto.index,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Page entity to PageDto
  static PageDto toDto(Page entity) {
    return PageDto(
      id: entity.id,
      menuId: entity.menuId,
      name: entity.name,
      index: entity.index,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
    );
  }
}
