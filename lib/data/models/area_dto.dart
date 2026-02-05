import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "area")
class AreaDto extends DirectusItem {
  String get name => getValue(forKey: "name");
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");
  List<MenuDto>? get menus {
    final raw = getValue(forKey: "menus");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "menus" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<MenuDto>((e) {
      if (e is num) {
        // IDs-only shape
        return MenuDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return MenuDto(e);
      if (e is Map) return MenuDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected menus element: ${e.runtimeType}');
    }).toList();
  }

  AreaDto(super.rawReceivedData);
  AreaDto.withId(super.id) : super.withId();
}
