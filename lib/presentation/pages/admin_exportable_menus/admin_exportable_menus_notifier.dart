import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_state.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

/// Notifier driving the admin exportable menus page.
///
/// Loads existing bundles in parallel with the list of available menus
/// (used by the create/edit dialog toggle list), and exposes CRUD operations.
class AdminExportableMenusNotifier extends Notifier<AdminExportableMenusState> {
  @override
  AdminExportableMenusState build() => const AdminExportableMenusState();

  /// Load bundles + available menus in parallel.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final Future<Result<List<MenuBundle>, DomainError>> bundlesFuture = ref
        .read(listMenuBundlesUseCaseProvider)
        .execute();
    final Future<Result<List<Menu>, DomainError>> menusFuture = ref
        .read(listTemplatesUseCaseProvider)
        .execute(statusFilter: 'all');
    final bundlesResult = await bundlesFuture;
    final menusResult = await menusFuture;

    if (bundlesResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: bundlesResult.errorOrNull!.message,
      );
      return;
    }
    if (menusResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: menusResult.errorOrNull!.message,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      bundles: bundlesResult.valueOrNull!,
      availableMenus: menusResult.valueOrNull!,
    );
  }

  /// Create a new bundle.
  Future<void> create(CreateMenuBundleInput input) async {
    final result = await ref
        .read(createMenuBundleUseCaseProvider)
        .execute(input);
    result.fold(
      onSuccess: (bundle) {
        state = state.copyWith(bundles: [...state.bundles, bundle]);
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Update an existing bundle in place.
  Future<void> update(UpdateMenuBundleInput input) async {
    final result = await ref
        .read(updateMenuBundleUseCaseProvider)
        .execute(input);
    result.fold(
      onSuccess: (updated) {
        state = state.copyWith(
          bundles: state.bundles
              .map((b) => b.id == updated.id ? updated : b)
              .toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Delete a bundle by ID.
  Future<void> delete(int id) async {
    final result = await ref.read(deleteMenuBundleUseCaseProvider).execute(id);
    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          bundles: state.bundles.where((b) => b.id != id).toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Clear the error banner.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
