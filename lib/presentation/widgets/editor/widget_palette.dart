import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';

/// Resolves the icon for a widget definition, falling back to generic icons.
IconData _getDefinitionIcon(
  WidgetDefinition? definition, {
  required bool isApple,
}) {
  if (definition != null) {
    final icon = isApple ? definition.cupertinoIcon : definition.materialIcon;
    if (icon != null) return icon;
  }
  return isApple ? CupertinoIcons.square_grid_2x2 : Icons.widgets;
}

/// Widget palette for dragging widgets into the editor canvas.
class WidgetPalette extends StatelessWidget {
  final WidgetRegistry registry;
  final List<String>? allowedWidgetTypes;
  final ValueChanged<List<String>>? onAllowedTypesChanged;
  final Axis axis;

  const WidgetPalette({
    super.key,
    required this.registry,
    this.allowedWidgetTypes,
    this.onAllowedTypesChanged,
    this.axis = Axis.vertical,
  });

  bool _isTypeAllowed(String type) {
    final allowed = allowedWidgetTypes;
    if (allowed == null || allowed.isEmpty) return true;
    return allowed.contains(type);
  }

  @override
  Widget build(BuildContext context) {
    final allTypes = registry.registeredTypes;
    final isAdminMode = onAllowedTypesChanged != null;
    final theme = Theme.of(context);

    // In admin mode, show all types. In regular mode, filter.
    final typesToShow = isAdminMode
        ? allTypes
        : (allowedWidgetTypes != null && allowedWidgetTypes!.isNotEmpty)
        ? allTypes.where((type) => allowedWidgetTypes!.contains(type)).toList()
        : allTypes;

    if (axis == Axis.horizontal) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 60),
        color: theme.colorScheme.surfaceContainerLow,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: typesToShow.map((type) {
            final definition = registry.getDefinition(type);
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: _PaletteItem(type: type, definition: definition),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Widget Palette', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: ListView(
              children: typesToShow.map((type) {
                final definition = registry.getDefinition(type);
                if (isAdminMode) {
                  return _AdminPaletteItem(
                    type: type,
                    definition: definition,
                    isChecked: _isTypeAllowed(type),
                    onChanged: (checked) {
                      final currentList = allowedWidgetTypes ?? [];
                      // Empty list means "all allowed" — expand to full list before toggling
                      final allowed = currentList.isEmpty
                          ? List<String>.from(allTypes)
                          : List<String>.from(currentList);
                      if (checked) {
                        if (!allowed.contains(type)) allowed.add(type);
                      } else {
                        allowed.remove(type);
                      }
                      onAllowedTypesChanged!(allowed);
                    },
                  );
                }
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

    final theme = Theme.of(context);
    return Draggable<WidgetDragData>(
      data: WidgetDragData.newWidget(type),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _paletteItemContent(theme),
      ),
      child: _paletteItemContent(theme),
    );
  }

  Widget _paletteItemContent(ThemeData theme) {
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    return Container(
      key: Key('palette_item_$type'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(isApple: isApple),
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              type.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon({required bool isApple}) =>
      _getDefinitionIcon(definition, isApple: isApple);
}

/// Admin palette item with checkbox for toggling widget availability
class _AdminPaletteItem extends StatelessWidget {
  final String type;
  final WidgetDefinition? definition;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _AdminPaletteItem({
    required this.type,
    required this.definition,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (definition == null) return const SizedBox();

    final theme = Theme.of(context);
    return Draggable<WidgetDragData>(
      data: WidgetDragData.newWidget(type),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _content(theme)),
      child: _content(theme),
    );
  }

  Widget _content(ThemeData theme) {
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    return Container(
      key: Key('palette_item_$type'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          if (isApple)
            CupertinoCheckbox(
              key: Key('allowed_type_checkbox_$type'),
              value: isChecked,
              onChanged: (value) => onChanged(value ?? false),
            )
          else
            Checkbox(
              key: Key('allowed_type_checkbox_$type'),
              value: isChecked,
              onChanged: (value) => onChanged(value ?? false),
            ),
          Icon(
            _getDefinitionIcon(definition, isApple: isApple),
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              type.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
