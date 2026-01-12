import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "page")
class PageDirectusItem extends DirectusItem {
  PageDirectusItem(super.rawReceivedData);
  PageDirectusItem.newItem() : super.newItem();
  PageDirectusItem.withId(super.id) : super.withId();
}
