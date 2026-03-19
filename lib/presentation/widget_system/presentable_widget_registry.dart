import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'presentable_widget_definition.dart';

/// Presentation-layer registry that stores [PresentableWidgetDefinition] entries.
///
/// Wraps the domain [WidgetRegistry] and provides access to render/icon metadata.
class PresentableWidgetRegistry {
  final Map<String, PresentableWidgetDefinition> _registry = {};
  final WidgetRegistry _domainRegistry = WidgetRegistry();

  /// Register a presentable widget definition.
  ///
  /// Also registers the definition in the domain registry for domain-layer consumers.
  void register<P>(PresentableWidgetDefinition<P> definition) {
    _registry[definition.type] =
        definition as PresentableWidgetDefinition<dynamic>;
    _domainRegistry.register(definition);
  }

  /// Get a presentable widget definition by type.
  PresentableWidgetDefinition? getDefinition(String type) {
    return _registry[type];
  }

  /// Get all registered widget types.
  List<String> get registeredTypes => _registry.keys.toList();

  /// Check if a widget type is registered.
  bool isRegistered(String type) => _registry.containsKey(type);

  /// Get the number of registered widget types.
  int get count => _registry.length;

  /// Access the domain-only registry (for use cases, migrators, etc.).
  WidgetRegistry get domainRegistry => _domainRegistry;
}
