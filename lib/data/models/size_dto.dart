import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "size")
class SizeDto extends DirectusItem {
  String get name => getValue(forKey: "name");
  double get width => (getValue(forKey: "width") as num).toDouble();
  double get height => (getValue(forKey: "height") as num).toDouble();
  String get status => getValue(forKey: "status");
  String get direction => getValue(forKey: "direction");

  SizeDto.newItem({
    required String name,
    required double width,
    required double height,
    required String status,
    required String direction,
  }) : super.newItem() {
    setValue(name, forKey: "name");
    setValue(width, forKey: "width");
    setValue(height, forKey: "height");
    setValue(status, forKey: "status");
    setValue(direction, forKey: "direction");
  }

  SizeDto(super.rawReceivedData);
  SizeDto.withId(super.id) : super.withId();
}
