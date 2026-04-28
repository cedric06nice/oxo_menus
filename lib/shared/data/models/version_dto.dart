import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/features/menu/data/models/menu_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "version")
class VersionDto extends DirectusItem {
  Map<String, dynamic> get snapshotJson =>
      getValue(forKey: "snapshot_json") ?? const {};
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");
  MenuDto? get menu {
    final raw = getValue(forKey: "menu");
    if (raw == null) return null;
    if (raw is int) {
      return MenuDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return MenuDto(raw);
    }
    return null;
  }

  VersionDto(super.rawReceivedData);
  VersionDto.withId(super.id) : super.withId();
}
