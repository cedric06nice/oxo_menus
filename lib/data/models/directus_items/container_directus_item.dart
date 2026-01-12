import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "container")
class ContainerDirectusItem extends DirectusItem {
  ContainerDirectusItem(super.rawReceivedData);
  ContainerDirectusItem.newItem() : super.newItem();
  ContainerDirectusItem.withId(super.id) : super.withId();
}
