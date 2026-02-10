import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "page")
class PageDto extends DirectusItem {
  int get index => getValue(forKey: "index");
  String get status => getValue(forKey: "status");
  String get type => getValue(forKey: "type") ?? 'content';
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

  List<ContainerDto>? get containers {
    final raw = getValue(forKey: "containers");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "containers" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<ContainerDto>((e) {
      if (e is num) {
        // IDs-only shape
        return ContainerDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return ContainerDto(e);
      if (e is Map) return ContainerDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected pages element: ${e.runtimeType}');
    }).toList();
  }

  PageDto.newItem({
    required int? index,
    String? status,
    int? menu,
    List<int>? containers,
    String? type,
  }) : super.newItem() {
    setValue(index, forKey: "index");
    setValue(status, forKey: "status");
    setValue(menu, forKey: "menu");
    setValue(containers, forKey: "containers");
    setValue(type ?? 'content', forKey: "type");
  }

  PageDto(super.rawReceivedData);
  PageDto.withId(super.id) : super.withId();
}
