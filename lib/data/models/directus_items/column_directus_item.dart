import 'package:directus_api_manager/directus_api_manager.dart';

@DirectusCollection()
@CollectionMetadata(endpointName: "column")
class ColumnDirectusItem extends DirectusItem {
  ColumnDirectusItem(super.rawReceivedData);
  ColumnDirectusItem.newItem() : super.newItem();
  ColumnDirectusItem.withId(super.id) : super.withId();
}
