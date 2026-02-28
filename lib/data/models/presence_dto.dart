import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "menu_presence")
class PresenceDto extends DirectusItem {
  String? get userId {
    final raw = getValue(forKey: "user");
    if (raw is String) return raw;
    if (raw is Map<String, dynamic>) return raw['id'] as String?;
    return null;
  }

  String? get userAvatar {
    final raw = getValue(forKey: "user");
    if (raw is Map<String, dynamic>) return raw['avatar'] as String?;
    return null;
  }

  DateTime? get lastSeen => getOptionalDateTime(forKey: "last_seen");

  int? get menuId {
    final raw = getValue(forKey: "menu");
    if (raw is int) return raw;
    if (raw is Map<String, dynamic>) return raw['id'] as int?;
    return null;
  }

  String? get userName => getValue(forKey: "user_name");

  PresenceDto.newItem({
    required String? userId,
    required int? menuId,
    required String? lastSeen,
  }) : super.newItem() {
    setValue(userId, forKey: "user");
    setValue(menuId, forKey: "menu");
    setValue(lastSeen, forKey: "last_seen");
  }

  PresenceDto(super.rawReceivedData);
  PresenceDto.withId(super.id) : super.withId();
}
