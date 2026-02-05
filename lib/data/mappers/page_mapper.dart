import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';

/// Mapper for converting between Page entity and PageDto
class PageMapper {
  /// Convert PageDto to Page entity
  static Page toEntity(PageDto dto) {
    String idString = dto.id ?? '0';
    return Page(
      id: int.parse(idString),
      menuId: dto.menu?.id != null ? int.parse(dto.menu!.id!) : 0,
      name: "Page ${dto.index}",
      index: dto.index,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert Page entity to PageDto
  static PageDto toDto(Page entity) {
    return PageDto({
      'id': entity.id,
      'menu': entity.menuId,
      'name': entity.name,
      'index': entity.index,
      'date_created': entity.dateCreated?.toIso8601String(),
      'date_updated': entity.dateUpdated?.toIso8601String(),
    });
  }
}
