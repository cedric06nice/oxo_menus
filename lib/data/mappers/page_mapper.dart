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
      type: _parsePageType(dto.type),
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Parse string type to PageType enum
  static PageType _parsePageType(String type) {
    switch (type) {
      case 'header':
        return PageType.header;
      case 'footer':
        return PageType.footer;
      case 'content':
      default:
        return PageType.content;
    }
  }

  /// Convert Page entity to PageDto
  static PageDto toDto(Page entity) {
    return PageDto({
      'id': entity.id,
      'menu': entity.menuId,
      'name': entity.name,
      'index': entity.index,
      'type': entity.type.name,
      'date_created': entity.dateCreated?.toIso8601String(),
      'date_updated': entity.dateUpdated?.toIso8601String(),
    });
  }
}
