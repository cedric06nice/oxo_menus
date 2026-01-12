import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "menu")
class MenuDirectusItem extends DirectusItem {
  MenuDirectusItem(super.rawReceivedData);
  MenuDirectusItem.newItem() : super.newItem();
  MenuDirectusItem.withId(super.id) : super.withId();
}
