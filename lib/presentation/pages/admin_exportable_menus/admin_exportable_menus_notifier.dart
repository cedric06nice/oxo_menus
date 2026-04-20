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
/// (used by the create/edit dialog toggle list), and exposes CRUD + publish
/// operations.
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

  /// Create a new bundle. Returns the created bundle on success, null on
  /// failure (in which case [state.errorMessage] is set).
  Future<MenuBundle?> create(CreateMenuBundleInput input) async {
    final result = await ref
        .read(createMenuBundleUseCaseProvider)
        .execute(input);
    return result.fold(
      onSuccess: (bundle) {
        state = state.copyWith(bundles: [...state.bundles, bundle]);
        return bundle;
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
        return null;
      },
    );
  }

  /// Update an existing bundle in place. Returns the updated bundle on
  /// success, null on failure.
  Future<MenuBundle?> update(UpdateMenuBundleInput input) async {
    final result = await ref
        .read(updateMenuBundleUseCaseProvider)
        .execute(input);
    return result.fold(
      onSuccess: (updated) {
        state = state.copyWith(
          bundles: state.bundles
              .map((b) => b.id == updated.id ? updated : b)
              .toList(),
        );
        return updated;
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
        return null;
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

  /// Publish (regenerate) the PDF for a bundle and refresh its state entry.
  ///
  /// On success, the bundle in state is replaced with the published one, so
  /// any newly-minted [MenuBundle.pdfFileId] appears in the list immediately.
  /// On failure, the error message is surfaced via state.errorMessage. The
  /// raw [Result] is returned so callers can show tailored UI feedback.
  Future<Result<MenuBundle, DomainError>> publish(int bundleId) async {
    final result = await ref
        .read(publishMenuBundleUseCaseProvider)
        .execute(bundleId);
    result.fold(
      onSuccess: (published) {
        state = state.copyWith(
          bundles: state.bundles
              .map((b) => b.id == published.id ? published : b)
              .toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
    return result;
  }

  /// Clear the error banner.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
