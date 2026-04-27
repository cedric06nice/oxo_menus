import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "menu_bundle")
class MenuBundleDto extends DirectusItem {
  String get name => getValue(forKey: "name");

  List<int> get menuIds {
    final raw = getValue(forKey: "menu_ids");
    if (raw is! List) return const [];
    final result = <int>[];
    for (final item in raw) {
      if (item is int) {
        result.add(item);
      } else if (item is num) {
        result.add(item.toInt());
      } else if (item is String) {
        final parsed = int.tryParse(item);
        if (parsed != null) result.add(parsed);
      }
    }
    return result;
  }

  String? get pdfFileId => getValue(forKey: "pdf_file_id");
  DateTime? get dateCreated => getOptionalDateTime(forKey: "date_created");
  DateTime? get dateUpdated => getOptionalDateTime(forKey: "date_updated");

  MenuBundleDto.newItem({
    required String name,
    List<int> menuIds = const [],
    String? pdfFileId,
  }) : super.newItem() {
    setValue(name, forKey: "name");
    setValue(menuIds, forKey: "menu_ids");
    if (pdfFileId != null) {
      setValue(pdfFileId, forKey: "pdf_file_id");
    }
  }

  MenuBundleDto(super.rawReceivedData);
  MenuBundleDto.withId(super.id) : super.withId();
}
