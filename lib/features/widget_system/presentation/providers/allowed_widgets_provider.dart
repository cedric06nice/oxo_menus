import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

/// Notifier for the active menu's per-type widget configuration.
///
/// Set by the menu editor / template editor when a menu loads. Read by
/// [WidgetRenderer] (and others) to look up the alignment for a given widget
/// type via [AllowedWidgetsNotifier.alignmentFor].
class AllowedWidgetsNotifier extends Notifier<List<WidgetTypeConfig>> {
  @override
  List<WidgetTypeConfig> build() => const [];

  void set(List<WidgetTypeConfig> configs) => state = configs;

  WidgetAlignment alignmentFor(String type) {
    for (final c in state) {
      if (c.type == type) return c.alignment;
    }
    return WidgetAlignment.start;
  }
}

final allowedWidgetsProvider =
    NotifierProvider<AllowedWidgetsNotifier, List<WidgetTypeConfig>>(
      AllowedWidgetsNotifier.new,
    );
