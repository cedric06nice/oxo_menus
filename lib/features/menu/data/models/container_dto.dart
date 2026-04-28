import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/features/menu/data/models/column_dto.dart';
import 'package:oxo_menus/features/menu/data/models/page_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "container")
class ContainerDto extends DirectusItem {
  int get index => getValue(forKey: "index");
  String get status => getValue(forKey: "status");
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");
  String? get direction => getValue(forKey: "direction");
  Map<String, dynamic> get styleJson =>
      Map<String, dynamic>.from(getValue(forKey: "style_json") ?? const {});

  int? get parentContainerId {
    final raw = getValue(forKey: "parent_container");
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is Map<String, dynamic>) {
      final id = raw['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    return null;
  }

  PageDto? get page {
    final raw = getValue(forKey: "page");
    if (raw == null) return null;
    if (raw is int) {
      return PageDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return PageDto(raw);
    }
    return null;
  }

  List<ColumnDto>? get columns {
    final raw = getValue(forKey: "columns");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "columns" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<ColumnDto>((e) {
      if (e is num) {
        // IDs-only shape
        return ColumnDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return ColumnDto(e);
      if (e is Map) return ColumnDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected columns element: ${e.runtimeType}');
    }).toList();
  }

  ContainerDto.newItem({
    required int? index,
    String? status,
    String? direction,
    Map<String, dynamic>? styleJson,
    int? page,
    int? parentContainer,
    List<int>? columns,
  }) : super.newItem() {
    setValue(index, forKey: "index");
    setValue(status, forKey: "status");
    setValue(direction, forKey: "direction");
    setValue(styleJson, forKey: "style_json");
    setValue(page, forKey: "page");
    setValue(parentContainer, forKey: "parent_container");
    setValue(columns, forKey: "columns");
  }

  ContainerDto(super.rawReceivedData);
  ContainerDto.withId(super.id) : super.withId();
}
