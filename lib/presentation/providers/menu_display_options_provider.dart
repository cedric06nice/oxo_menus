import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

/// Provider for menu-level display options.
///
/// Set by the menu editor page when a menu is loaded.
/// Read by WidgetRenderer to pass to all widgets via WidgetContext.
final menuDisplayOptionsProvider = StateProvider<MenuDisplayOptions?>(
  (ref) => null,
);
