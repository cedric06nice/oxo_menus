import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/data/models/column_dto.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "widget")
class WidgetDto extends DirectusItem {
  int get index => getValue(forKey: "index");
  String get typeKey => getValue(forKey: "type_key");
  String get version => getValue(forKey: "version");
  String? get status => getValue(forKey: "status");
  bool get isTemplate => getValue(forKey: "is_template") ?? false;
  bool get lockedForEdition => getValue(forKey: "locked_for_edition") ?? false;
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");
  String? get editingBy => getValue(forKey: "editing_by");
  DateTime? get editingSince => getOptionalDateTime(forKey: "editing_since");

  Map<String, dynamic> get styleJson =>
      Map<String, dynamic>.from(getValue(forKey: "style_json") ?? const {});
  Map<String, dynamic> get propsJson =>
      Map<String, dynamic>.from(getValue(forKey: "props_json") ?? const {});

  ColumnDto? get column {
    final raw = getValue(forKey: "column");
    if (raw == null) return null;
    if (raw is int) {
      return ColumnDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return ColumnDto(raw);
    }
    return null;
  }

  WidgetDto.newItem({
    required int? index,
    required String? typeKey,
    required String? version,
    String? status,
    Map<String, dynamic>? propsJson,
    Map<String, dynamic>? styleJson,
    int? column,
  }) : super.newItem() {
    setValue(index, forKey: "index");
    setValue(typeKey, forKey: "type_key");
    setValue(version, forKey: "version");
    setValue(status, forKey: "status");
    setValue(propsJson, forKey: "props_json");
    setValue(styleJson, forKey: "style_json");
    setValue(column, forKey: "column");
  }

  WidgetDto(super.rawReceivedData);
  WidgetDto.withId(super.id) : super.withId();
}
