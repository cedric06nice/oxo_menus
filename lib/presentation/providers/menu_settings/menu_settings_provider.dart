import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_notifier.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';

final menuSettingsProvider =
    NotifierProvider<MenuSettingsNotifier, MenuSettingsState>(
      MenuSettingsNotifier.new,
    );
