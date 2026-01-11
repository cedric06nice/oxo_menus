import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';

/// Widget Renderer
///
/// Renders a widget instance using the widget registry.
/// Handles type-safe rendering of widgets with proper error handling.
class WidgetRenderer extends ConsumerWidget {
  final WidgetInstance widgetInstance;
  final bool isEditable;
  final void Function(Map<String, dynamic>)? onUpdate;
  final VoidCallback? onDelete;

  const WidgetRenderer({
    super.key,
    required this.widgetInstance,
    this.isEditable = false,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(widgetRegistryProvider);
    final definition = registry.getDefinition(widgetInstance.type);

    if (definition == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Text('Unknown widget type: ${widgetInstance.type}'),
      );
    }

    try {
      // Parse props using the definition's parseProps function
      final props = definition.parseProps(widgetInstance.props);

      // Create widget context
      final widgetContext = WidgetContext(
        isEditable: isEditable,
        onUpdate: onUpdate,
        onDelete: onDelete,
      );

      // Render the widget by calling the render function
      // The render function expects (P props, WidgetContext context)
      // We use dynamic invocation to work around the generic type constraint
      return _renderWidget(definition, props, widgetContext);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Text('Error rendering widget: $e'),
      );
    }
  }

  Widget _renderWidget(
    WidgetDefinition definition,
    dynamic props,
    WidgetContext context,
  ) {
    // Call the render function with dynamic props
    // The function signature is Widget Function(P, WidgetContext)
    // We cast to Widget Function(dynamic, WidgetContext) to avoid type issues
    final renderFn = definition.render as Widget Function(dynamic, WidgetContext);
    return renderFn(props, context);
  }
}
