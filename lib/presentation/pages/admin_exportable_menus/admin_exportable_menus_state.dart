import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';

part 'admin_exportable_menus_state.freezed.dart';

/// State for the admin exportable menus list page
@freezed
abstract class AdminExportableMenusState with _$AdminExportableMenusState {
  const factory AdminExportableMenusState({
    @Default([]) List<MenuBundle> bundles,
    @Default([]) List<Menu> availableMenus,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _AdminExportableMenusState;
}
