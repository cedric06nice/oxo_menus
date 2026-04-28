import 'package:flutter/material.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';

/// Widget Renderer
///
/// Renders a widget instance using the widget registry.
/// Handles type-safe rendering of widgets with proper error handling.
///
/// Takes the [registry], the menu's [displayOptions], and the menu's
/// [allowedWidgets] (used to look up the per-type [WidgetAlignment]) as
/// constructor args. Pure widget — no Riverpod.
class WidgetRenderer extends StatelessWidget {
  final WidgetInstance widgetInstance;
  final PresentableWidgetRegistry registry;
  final MenuDisplayOptions? displayOptions;
  final List<WidgetTypeConfig> allowedWidgets;
  final ImageGateway? imageGateway;
  final bool isEditable;
  final void Function(Map<String, dynamic>)? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onEditStarted;
  final VoidCallback? onEditEnded;

  const WidgetRenderer({
    super.key,
    required this.widgetInstance,
    required this.registry,
    this.displayOptions,
    this.allowedWidgets = const [],
    this.imageGateway,
    this.isEditable = false,
    this.onUpdate,
    this.onDelete,
    this.onEditStarted,
    this.onEditEnded,
  });

  WidgetAlignment _resolveAlignment() {
    for (final config in allowedWidgets) {
      if (config.type == widgetInstance.type) {
        return config.alignment;
      }
    }
    return WidgetAlignment.start;
  }

  @override
  Widget build(BuildContext context) {
    final definition = registry.getDefinition(widgetInstance.type);

    if (definition == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Text('Unknown widget type: ${widgetInstance.type}'),
      );
    }

    try {
      final props = definition.parseProps(widgetInstance.props);
      final widgetContext = WidgetContext(
        isEditable: isEditable,
        onUpdate: onUpdate,
        onDelete: onDelete,
        onEditStarted: onEditStarted,
        onEditEnded: onEditEnded,
        displayOptions: displayOptions,
        alignment: _resolveAlignment(),
        imageGateway: imageGateway,
      );
      return definition.renderDynamic(props, widgetContext);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Text('Error rendering widget: $e'),
      );
    }
  }
}
