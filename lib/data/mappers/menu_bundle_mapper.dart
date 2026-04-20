import 'package:oxo_menus/data/models/menu_bundle_dto.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

/// Mapper for MenuBundle <-> MenuBundleDto and the Directus JSON payloads.
class MenuBundleMapper {
  /// Convert a DTO into a domain [MenuBundle] entity.
  static MenuBundle toEntity(MenuBundleDto dto) {
    final idString = dto.id ?? '0';
    return MenuBundle(
      id: int.parse(idString),
      name: dto.name,
      menuIds: dto.menuIds,
      pdfFileId: dto.pdfFileId,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
    );
  }

  /// Convert [CreateMenuBundleInput] into a Directus-friendly JSON map.
  static Map<String, dynamic> toCreatePayload(CreateMenuBundleInput input) {
    return {'name': input.name, 'menu_ids': input.menuIds};
  }

  /// Convert [UpdateMenuBundleInput] into a Directus-friendly JSON map,
  /// including only non-null fields.
  static Map<String, dynamic> toUpdatePayload(UpdateMenuBundleInput input) {
    final map = <String, dynamic>{};
    if (input.name != null) map['name'] = input.name;
    if (input.menuIds != null) map['menu_ids'] = input.menuIds;
    if (input.pdfFileId != null) map['pdf_file_id'] = input.pdfFileId;
    return map;
  }
}
