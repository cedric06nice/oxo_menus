import 'dart:async';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';

class MenuSubscriptionRepositoryImpl implements MenuSubscriptionRepository {
  final DirectusDataSource _dataSource;

  /// Tracks active subscription UIDs by menuId for cleanup.
  final Map<int, String> _activeSubscriptions = {};

  /// Tracks active stream controllers by menuId for cleanup.
  final Map<int, StreamController<MenuChangeEvent>> _controllers = {};

  MenuSubscriptionRepositoryImpl({required DirectusDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Stream<MenuChangeEvent> subscribeToMenuChanges(int menuId) {
    final controller = StreamController<MenuChangeEvent>.broadcast();
    final uid = 'menu_widgets_$menuId';

    _activeSubscriptions[menuId] = uid;
    _controllers[menuId] = controller;

    final subscription = DirectusWebSocketSubscription<WidgetDto>(
      uid: uid,
      filter: RelationFilter(
        propertyName: 'column',
        linkedObjectFilter: RelationFilter(
          propertyName: 'container',
          linkedObjectFilter: RelationFilter(
            propertyName: 'page',
            linkedObjectFilter: PropertyFilter(
              field: 'menu',
              operator: FilterOperator.equals,
              value: menuId,
            ),
          ),
        ),
      ),
      onCreate: (data) {
        controller.add(
          WidgetChangedEvent(eventType: 'create', data: data, ids: null),
        );
        return null;
      },
      onUpdate: (data) {
        controller.add(
          WidgetChangedEvent(eventType: 'update', data: data, ids: null),
        );
        return null;
      },
      onDelete: (data) {
        final ids = data['ids'] as List<dynamic>?;
        controller.add(
          WidgetChangedEvent(eventType: 'delete', data: data, ids: ids),
        );
        return null;
      },
    );

    // Start the subscription asynchronously
    _dataSource.startSubscription(subscription);

    controller.onCancel = () {
      _activeSubscriptions.remove(menuId);
      _controllers.remove(menuId);
    };

    return controller.stream;
  }

  @override
  Future<void> unsubscribe(int menuId) async {
    final uid = _activeSubscriptions.remove(menuId);
    final controller = _controllers.remove(menuId);
    await controller?.close();
    if (uid != null) {
      try {
        await _dataSource.stopSubscription(uid);
      } on StateError catch (_) {
        // WebSocket sink already closed — safe to ignore
      }
    }
  }
}
