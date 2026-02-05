import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "size")
class SizeDto extends DirectusItem {
  String get name => getValue(forKey: "name");
  double get width => (getValue(forKey: "width") as num).toDouble();
  double get height => (getValue(forKey: "height") as num).toDouble();

  SizeDto(super.rawReceivedData);
  SizeDto.withId(super.id) : super.withId();
}
