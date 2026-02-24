/// Events emitted when menu-related data changes via WebSocket.
sealed class MenuChangeEvent {
  const MenuChangeEvent();
}

/// A widget_instance was created, updated, or deleted.
class WidgetChangedEvent extends MenuChangeEvent {
  final String eventType;
  final Map<String, dynamic>? data;
  final List<dynamic>? ids;

  const WidgetChangedEvent({
    required this.eventType,
    required this.data,
    required this.ids,
  });
}
