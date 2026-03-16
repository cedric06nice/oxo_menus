import 'package:oxo_menus/data/models/presence_dto.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

/// Mapper for converting between MenuPresence entity and PresenceDto
class PresenceMapper {
  static MenuPresence toEntity(PresenceDto dto) {
    return MenuPresence(
      id: int.parse(dto.id ?? '0'),
      userId: dto.userId ?? '',
      menuId: dto.menuId ?? 0,
      lastSeen: dto.lastSeen ?? DateTime.now(),
      userName: dto.userName,
      userAvatar: dto.userAvatar,
    );
  }
}
