import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Widget types that have a price line. `Justified` is only meaningful for
/// these — for everything else the segmented control hides the option.
const _typesWithPriceLine = <String>{'dish', 'dish_to_share', 'wine'};

/// Resolves the icon for a widget definition, falling back to generic icons.
IconData _getDefinitionIcon(
  PresentableWidgetDefinition? definition, {
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
  final PresentableWidgetRegistry registry;

  /// Currently authorised widgets with their per-type alignment.
  ///
  /// `null` or empty means "all types allowed with default alignment". Outside
  /// admin mode this list also acts as the filter for which palette entries to
  /// show.
  final List<WidgetTypeConfig>? allowedWidgets;

  /// Admin-only callback fired whenever the admin checks/unchecks a type or
  /// changes its alignment. The list passed back is the new full state.
  final ValueChanged<List<WidgetTypeConfig>>? onAllowedWidgetsChanged;

  final Axis axis;

  const WidgetPalette({
    super.key,
    required this.registry,
    this.allowedWidgets,
    this.onAllowedWidgetsChanged,
    this.axis = Axis.vertical,
  });

  bool _isTypeEnabled(String type) {
    final allowed = allowedWidgets;
    if (allowed == null || allowed.isEmpty) return true;
    for (final c in allowed) {
      if (c.type == type) return c.enabled;
    }
    return false;
  }

  WidgetAlignment _alignmentFor(String type) {
    final allowed = allowedWidgets;
    if (allowed == null) return WidgetAlignment.start;
    for (final c in allowed) {
      if (c.type == type) return c.alignment;
    }
    return WidgetAlignment.start;
  }

  /// Base config list for mutation — expands an empty list to explicit entries
  /// so alignment choices are preserved per-type. Also scrubs stale `justified`
  /// on types that have no price line, so persistence can't retain a value
  /// the UI can't render.
  List<WidgetTypeConfig> _base(List<String> allTypes) {
    if (allowedWidgets == null || allowedWidgets!.isEmpty) {
      return allTypes.map((t) => WidgetTypeConfig(type: t)).toList();
    }
    final existing = {for (final c in allowedWidgets!) c.type: c};
    return allTypes.map((t) {
      final config = existing[t] ?? WidgetTypeConfig(type: t, enabled: false);
      if (!_typesWithPriceLine.contains(t) &&
          config.alignment == WidgetAlignment.justified) {
        return config.copyWith(alignment: WidgetAlignment.start);
      }
      return config;
    }).toList();
  }

  /// Flip the `enabled` flag for [type], preserving its alignment.
  List<WidgetTypeConfig> _setEnabled(
    List<String> allTypes,
    String type, {
    required bool enabled,
  }) {
    final base = _base(allTypes);
    final index = base.indexWhere((c) => c.type == type);
    base[index] = base[index].copyWith(enabled: enabled);
    return base;
  }

  List<WidgetTypeConfig> _setAlignment(
    List<String> allTypes,
    String type,
    WidgetAlignment alignment,
  ) {
    final base = _base(allTypes);
    final index = base.indexWhere((c) => c.type == type);
    base[index] = base[index].copyWith(alignment: alignment);
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final allTypes = registry.registeredTypes;
    final isAdminMode = onAllowedWidgetsChanged != null;
    final theme = Theme.of(context);

    final typesToShow = isAdminMode
        ? allTypes
        : (allowedWidgets != null && allowedWidgets!.isNotEmpty)
        ? allTypes.where(_isTypeEnabled).toList()
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
              child: IntrinsicWidth(
                child: _PaletteItem(type: type, definition: definition),
              ),
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
                    isChecked: _isTypeEnabled(type),
                    alignment: _alignmentFor(type),
                    onChanged: (checked) {
                      onAllowedWidgetsChanged!(
                        _setEnabled(allTypes, type, enabled: checked),
                      );
                    },
                    onAlignmentChanged: (a) {
                      onAllowedWidgetsChanged!(
                        _setAlignment(allTypes, type, a),
                      );
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
  final PresentableWidgetDefinition? definition;

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
            _label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _paletteItemContent(context, theme),
      ),
      child: _paletteItemContent(context, theme),
    );
  }

  String get _label => definition?.displayName ?? type;

  Widget _paletteItemContent(BuildContext context, ThemeData theme) {
    final isApple = isApplePlatform(context);
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
              _label,
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

/// Admin palette item with checkbox + alignment selector.
class _AdminPaletteItem extends StatelessWidget {
  final String type;
  final PresentableWidgetDefinition? definition;
  final bool isChecked;
  final WidgetAlignment alignment;
  final ValueChanged<bool> onChanged;
  final ValueChanged<WidgetAlignment> onAlignmentChanged;

  const _AdminPaletteItem({
    required this.type,
    required this.definition,
    required this.isChecked,
    required this.alignment,
    required this.onChanged,
    required this.onAlignmentChanged,
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
            _label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _content(context, theme)),
      child: _content(context, theme),
    );
  }

  String get _label => definition?.displayName ?? type;

  Widget _content(BuildContext context, ThemeData theme) {
    final isApple = isApplePlatform(context);
    final supportsJustified = _typesWithPriceLine.contains(type);
    return Container(
      key: Key('palette_item_$type'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  _label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AlignmentSelector(
            key: Key('alignment_selector_$type'),
            type: type,
            value: alignment,
            showJustified: supportsJustified,
            onChanged: onAlignmentChanged,
          ),
        ],
      ),
    );
  }
}

class _AlignmentSelector extends StatelessWidget {
  final String type;
  final WidgetAlignment value;
  final bool showJustified;
  final ValueChanged<WidgetAlignment> onChanged;

  const _AlignmentSelector({
    super.key,
    required this.type,
    required this.value,
    required this.showJustified,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final segments = <ButtonSegment<WidgetAlignment>>[
      const ButtonSegment(
        value: WidgetAlignment.start,
        icon: Icon(Icons.format_align_left),
        tooltip: 'Start',
      ),
      const ButtonSegment(
        value: WidgetAlignment.center,
        icon: Icon(Icons.format_align_center),
        tooltip: 'Center',
      ),
      const ButtonSegment(
        value: WidgetAlignment.end,
        icon: Icon(Icons.format_align_right),
        tooltip: 'End',
      ),
      if (showJustified)
        const ButtonSegment(
          value: WidgetAlignment.justified,
          icon: Icon(Icons.format_align_justify),
          tooltip: 'Justified',
        ),
    ];

    final effective = (!showJustified && value == WidgetAlignment.justified)
        ? WidgetAlignment.start
        : value;

    return SegmentedButton<WidgetAlignment>(
      segments: segments,
      selected: {effective},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChanged(set.first),
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}
