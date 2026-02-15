import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';

/// Widget palette for dragging widgets into the editor canvas.
class WidgetPalette extends StatelessWidget {
  final WidgetRegistry registry;

  const WidgetPalette({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Widget Palette',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView(
              children: registry.registeredTypes.map((type) {
                final definition = registry.getDefinition(type);
                return _PaletteItem(type: type, definition: definition);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual palette item that can be dragged
class _PaletteItem extends StatelessWidget {
  final String type;
  final WidgetDefinition? definition;

  const _PaletteItem({required this.type, required this.definition});

  @override
  Widget build(BuildContext context) {
    if (definition == null) return const SizedBox();

    return Draggable<WidgetDragData>(
      data: WidgetDragData.newWidget(type),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _paletteItemContent()),
      child: _paletteItemContent(),
    );
  }

  Widget _paletteItemContent() {
    return Container(
      key: Key('palette_item_$type'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(_getIconForType(type), size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'dish':
        return Icons.restaurant_menu;
      case 'image':
        return Icons.image;
      case 'section':
        return Icons.title;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.widgets;
    }
  }
}
