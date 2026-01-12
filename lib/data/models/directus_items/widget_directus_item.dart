import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "widget")
class WidgetDirectusItem extends DirectusItem {
  WidgetDirectusItem(super.rawReceivedData);
  WidgetDirectusItem.newItem() : super.newItem();
  WidgetDirectusItem.withId(super.id) : super.withId();
}
