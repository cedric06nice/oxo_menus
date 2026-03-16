import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart';

part 'menu_settings_state.freezed.dart';

@freezed
abstract class MenuSettingsState with _$MenuSettingsState {
  const MenuSettingsState._();

  const factory MenuSettingsState({
    @Default([]) List<Size> sizes,
    @Default([]) List<Area> areas,
    @Default(false) bool isLoadingSizes,
    @Default(false) bool isLoadingAreas,
    String? errorMessage,
  }) = _MenuSettingsState;

  bool get isLoading => isLoadingSizes || isLoadingAreas;
}
