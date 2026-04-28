import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/shared/data/models/area_dto.dart';
import 'package:oxo_menus/features/menu/data/models/page_dto.dart';
import 'package:oxo_menus/features/menu/data/models/size_dto.dart';
import 'package:oxo_menus/shared/data/models/version_dto.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "menu")
class MenuDto extends DirectusItem {
  String get name => getValue(forKey: "name");
  String get version => getValue(forKey: "version");
  String get status => getValue(forKey: "status");
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");
  String? get userUpdated => getValue(forKey: "user_updated");
  Map<String, dynamic> get styleJson =>
      Map<String, dynamic>.from(getValue(forKey: "style_json") ?? const {});

  /// Reads the new `allowed_widgets` JSON list when present, falling back to
  /// the legacy `allowed_widget_types` string list (mapped to configs with
  /// default `start` alignment) for menus created before Stage 3.
  List<WidgetTypeConfig> get allowedWidgets {
    final raw =
        getValue(forKey: "allowed_widgets") ??
        getValue(forKey: "allowed_widget_types");
    if (raw is! List) return const [];
    final result = <WidgetTypeConfig>[];
    for (final item in raw) {
      if (item is String) {
        result.add(WidgetTypeConfig(type: item));
      } else if (item is Map) {
        result.add(WidgetTypeConfig.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  Map<String, dynamic> get displayOptionsJson => Map<String, dynamic>.from(
    getValue(forKey: "display_options_json") ?? const {},
  );

  AreaDto? get area {
    final raw = getValue(forKey: "area");
    if (raw == null) return null;
    if (raw is int) {
      return AreaDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return AreaDto(raw);
    }
    return null;
  }

  List<VersionDto>? get versions {
    final raw = getValue(forKey: "versions");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "versions" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<VersionDto>((e) {
      if (e is num) {
        // IDs-only shape
        return VersionDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return VersionDto(e);
      if (e is Map) return VersionDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected versions element: ${e.runtimeType}');
    }).toList();
  }

  List<PageDto>? get pages {
    final raw = getValue(forKey: "pages");
    if (raw == null) return null;

    if (raw is! List) {
      throw FormatException(
        'Expected "pages" to be a List, got ${raw.runtimeType}',
      );
    }

    return raw.map<PageDto>((e) {
      if (e is num) {
        // IDs-only shape
        return PageDto({'id': e.toInt()});
      }
      if (e is Map<String, dynamic>) return PageDto(e);
      if (e is Map) return PageDto(Map<String, dynamic>.from(e));
      throw FormatException('Unexpected pages element: ${e.runtimeType}');
    }).toList();
  }

  SizeDto? get size {
    final raw = getValue(forKey: "size");
    if (raw == null) return null;
    if (raw is int) {
      return SizeDto.withId(raw);
    }
    if (raw is Map<String, dynamic>) {
      return SizeDto(raw);
    }
    return null;
  }

  MenuDto.newItem({
    required String name,
    required String version,
    String? status,
    Map<String, dynamic>? styleJson,
    AreaDto? area,
    List<VersionDto> versions = const [],
    List<PageDto>? pages,
    SizeDto? size,
    Map<String, dynamic>? displayOptionsJson,
  }) : super.newItem() {
    setValue(name, forKey: "name");
    setValue(version, forKey: "version");
    setValue(status, forKey: "status");
    setValue(styleJson, forKey: "style_json");
    setValue(area, forKey: "area");
    setValue(versions, forKey: "versions");
    setValue(pages, forKey: "pages");
    setValue(size, forKey: "size");
    setValue(displayOptionsJson, forKey: "display_options_json");
  }

  MenuDto(super.rawReceivedData);
  MenuDto.withId(super.id) : super.withId();
}
