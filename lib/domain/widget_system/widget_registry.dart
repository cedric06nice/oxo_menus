import 'widget_definition.dart';

/// Central registry for all widget types
///
/// The WidgetRegistry maintains a mapping of widget type identifiers
/// to their definitions. It provides O(1) lookup performance and
/// supports dynamic widget type resolution at runtime.
///
/// Example usage:
/// ```dart
/// final registry = WidgetRegistry();
/// registry.register(dishWidgetDefinition);
/// registry.register(sectionWidgetDefinition);
///
/// final definition = registry.getDefinition('dish');
/// if (definition != null) {
///   final props = definition.parseProps(jsonData);
///   final widget = definition.render(props, context);
/// }
/// ```
class WidgetRegistry {
  final Map<String, WidgetDefinition> _registry = {};

  /// Register a widget definition
  ///
  /// The widget definition is stored with its type as the key.
  /// If a definition with the same type already exists, it will be replaced.
  void register<P>(WidgetDefinition<P> definition) {
    _registry[definition.type] = definition as WidgetDefinition<dynamic>;
  }

  /// Get a widget definition by type
  ///
  /// Returns null if no definition is registered for the given type.
  WidgetDefinition? getDefinition(String type) {
    return _registry[type];
  }

  /// Get all registered widget types
  ///
  /// Returns a list of all widget type identifiers currently registered.
  List<String> get registeredTypes => _registry.keys.toList();

  /// Check if a widget type is registered
  ///
  /// Returns true if a definition exists for the given type.
  bool isRegistered(String type) => _registry.containsKey(type);

  /// Get the number of registered widget types
  int get count => _registry.length;
}
