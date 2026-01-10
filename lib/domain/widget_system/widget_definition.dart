import 'package:flutter/widgets.dart';

/// Context provided to widgets during rendering
///
/// Contains runtime information about the widget's editing state
/// and callbacks for updates and deletion.
class WidgetContext {
  /// Whether the widget is in editable mode
  final bool isEditable;

  /// Callback to update widget props
  final void Function(Map<String, dynamic>)? onUpdate;

  /// Callback to delete the widget
  final VoidCallback? onDelete;

  const WidgetContext({
    required this.isEditable,
    this.onUpdate,
    this.onDelete,
  });
}

/// Generic widget definition with type-safe props
///
/// This class defines how a widget type behaves, including:
/// - Parsing JSON props into typed objects
/// - Rendering the widget with props and context
/// - Providing default props for new instances
/// - Optional migration function for version upgrades
///
/// Example:
/// ```dart
/// final dishWidgetDefinition = WidgetDefinition<DishProps>(
///   type: 'dish',
///   version: '1.0.0',
///   parseProps: (json) => DishProps.fromJson(json),
///   render: (props, context) => DishWidget(props: props, context: context),
///   defaultProps: const DishProps(name: 'New Dish', price: 0.0),
/// );
/// ```
class WidgetDefinition<P> {
  /// Unique widget type identifier (e.g., 'dish', 'section')
  final String type;

  /// Semantic version for this widget (e.g., '1.0.0')
  final String version;

  /// Parse JSON props into typed props object
  final P Function(Map<String, dynamic>) parseProps;

  /// Render the widget with props and context
  final Widget Function(P props, WidgetContext context) render;

  /// Default props for new instances
  final P defaultProps;

  /// Optional migration function for version upgrades
  ///
  /// When a widget instance has an older version than the definition,
  /// this function is called to migrate the props to the new format.
  final P Function(Map<String, dynamic>)? migrate;

  const WidgetDefinition({
    required this.type,
    required this.version,
    required this.parseProps,
    required this.render,
    required this.defaultProps,
    this.migrate,
  });
}
