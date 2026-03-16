import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

/// Notifier for menu-level display options.
///
/// Set by the menu editor page when a menu is loaded.
/// Read by WidgetRenderer to pass to all widgets via WidgetContext.
class MenuDisplayOptionsNotifier extends Notifier<MenuDisplayOptions?> {
  @override
  MenuDisplayOptions? build() => null;

  void set(MenuDisplayOptions? options) => state = options;
}

final menuDisplayOptionsProvider =
    NotifierProvider<MenuDisplayOptionsNotifier, MenuDisplayOptions?>(
      MenuDisplayOptionsNotifier.new,
    );
