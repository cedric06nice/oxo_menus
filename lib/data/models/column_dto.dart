import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "column")
class ColumnDto extends DirectusItem {
  int get index => getValue(forKey: "index");
  num get width => getValue(forKey: "width"); // Accept both int and double
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");

  Map<String, dynamic> get styleJson =>
      Map<String, dynamic>.from(getValue(forKey: "style_json") ?? const {});

  ContainerDto? get container {
    final raw = getValue(forKey: "container");
    if (raw == null) return null;
    if (raw is int) {
      return ContainerDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return ContainerDto(raw);
    }
    return null;
  }

  List<WidgetDto>? get widgets {
    final raw = getValue(forKey: "widgets");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "widgets" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<WidgetDto>((e) {
      if (e is num) {
        // IDs-only shape
        return WidgetDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return WidgetDto(e);
      if (e is Map) return WidgetDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected widgets element: ${e.runtimeType}');
    }).toList();
  }

  ColumnDto.newItem({
    required int? index,
    required int? width,
    Map<String, dynamic>? styleJson,
    int? container,
    List<int>? widgets,
  }) : super.newItem() {
    setValue(index, forKey: "index");
    setValue(width, forKey: "width");
    setValue(styleJson, forKey: "style_json");
    setValue(container, forKey: "container");
    setValue(widgets, forKey: "widgets");
  }

  ColumnDto(super.rawReceivedData);
  ColumnDto.withId(super.id) : super.withId();
}
