import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

class MenuSettingsNotifier extends Notifier<MenuSettingsState> {
  @override
  MenuSettingsState build() => const MenuSettingsState();

  Future<void> loadSizes() async {
    state = state.copyWith(isLoadingSizes: true, errorMessage: null);
    final result = await ref.read(listSizesUseCaseProvider).execute();
    result.fold(
      onSuccess: (sizes) {
        state = state.copyWith(sizes: sizes, isLoadingSizes: false);
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoadingSizes: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadAreas() async {
    state = state.copyWith(isLoadingAreas: true, errorMessage: null);
    final result = await ref.read(areaRepositoryProvider).getAll();
    result.fold(
      onSuccess: (areas) {
        state = state.copyWith(areas: areas, isLoadingAreas: false);
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoadingAreas: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<Result<Menu, DomainError>> updateDisplayOptions(
    int menuId,
    MenuDisplayOptions options,
  ) async {
    return ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, displayOptions: options));
  }

  Future<Result<Menu, DomainError>> updatePageSize(
    int menuId,
    int sizeId,
  ) async {
    return ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, sizeId: sizeId));
  }

  Future<Result<Menu, DomainError>> updateArea(int menuId, int? areaId) async {
    return ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, areaId: areaId));
  }

  Future<Result<Menu, DomainError>> saveMenu(int menuId) async {
    return ref.read(menuRepositoryProvider).update(UpdateMenuInput(id: menuId));
  }

  Future<Result<Menu, DomainError>> createTemplate({
    required String name,
    required String version,
    required Status status,
    required int sizeId,
    int? areaId,
  }) async {
    return ref
        .read(menuRepositoryProvider)
        .create(
          CreateMenuInput(
            name: name,
            version: version,
            status: status,
            sizeId: sizeId,
            areaId: areaId,
          ),
        );
  }
}
