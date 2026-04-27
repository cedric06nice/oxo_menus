import 'dart:async';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/delete_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_available_menus_for_bundles_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/update_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/state/admin_exportable_menus_screen_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the admin-exportable-menus screen's state.
///
/// Eagerly drives the bundle and available-menu list use cases on construction
/// and exposes admin CRUD plus background publish through state. A reload is
/// triggered automatically on offline → online when the previous load surfaced
/// an error. Knows nothing about widgets, `BuildContext`, or Riverpod —
/// navigation is delegated to [AdminExportableMenusRouter].
class AdminExportableMenusViewModel
    extends ViewModel<AdminExportableMenusScreenState> {
  AdminExportableMenusViewModel({
    required ListMenuBundlesForAdminUseCase listBundles,
    required ListAvailableMenusForBundlesUseCase listAvailableMenus,
    required CreateMenuBundleForAdminUseCase createBundle,
    required UpdateMenuBundleForAdminUseCase updateBundle,
    required DeleteMenuBundleForAdminUseCase deleteBundle,
    required PublishMenuBundleForAdminUseCase publishBundle,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required AdminExportableMenusRouter router,
  }) : _listBundles = listBundles,
       _listAvailableMenus = listAvailableMenus,
       _createBundle = createBundle,
       _updateBundle = updateBundle,
       _deleteBundle = deleteBundle,
       _publishBundle = publishBundle,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_load());
  }

  final ListMenuBundlesForAdminUseCase _listBundles;
  final ListAvailableMenusForBundlesUseCase _listAvailableMenus;
  final CreateMenuBundleForAdminUseCase _createBundle;
  final UpdateMenuBundleForAdminUseCase _updateBundle;
  final DeleteMenuBundleForAdminUseCase _deleteBundle;
  final PublishMenuBundleForAdminUseCase _publishBundle;
  final ConnectivityGateway _connectivityGateway;
  final AdminExportableMenusRouter _router;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;

  static AdminExportableMenusScreenState _initialStateFor(
    AuthGateway gateway,
  ) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return AdminExportableMenusScreenState(isAdmin: isAdmin);
  }

  /// Reload bundles + available menus. Used by the retry affordance and by
  /// the connectivity-restore listener.
  Future<void> reload() => _load();

  /// Create a new bundle. Returns the created bundle on success, `null` on
  /// failure (in which case [state.errorMessage] is set).
  Future<MenuBundle?> createBundle(CreateMenuBundleInput input) async {
    final result = await _createBundle.execute(input);
    if (isDisposed) {
      return result.valueOrNull;
    }
    return result.fold(
      onSuccess: (bundle) {
        emit(
          state.copyWith(
            bundles: [...state.bundles, bundle],
            errorMessage: null,
          ),
        );
        return bundle;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return null;
      },
    );
  }

  /// Update an existing bundle in place. Returns the updated bundle on
  /// success, `null` on failure.
  Future<MenuBundle?> updateBundle(UpdateMenuBundleInput input) async {
    final result = await _updateBundle.execute(input);
    if (isDisposed) {
      return result.valueOrNull;
    }
    return result.fold(
      onSuccess: (updated) {
        emit(
          state.copyWith(
            bundles: state.bundles
                .map((b) => b.id == updated.id ? updated : b)
                .toList(growable: false),
            errorMessage: null,
          ),
        );
        return updated;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return null;
      },
    );
  }

  /// Delete a bundle by id. On success the bundle is removed from state; on
  /// failure an error message is surfaced.
  Future<void> deleteBundle(int id) async {
    final result = await _deleteBundle.execute(id);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            bundles: state.bundles
                .where((b) => b.id != id)
                .toList(growable: false),
            errorMessage: null,
          ),
        );
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
      },
    );
  }

  /// (Re)publish the bundle PDF for [bundleId]. Marks the bundle as publishing
  /// while the call is in flight; replaces the bundle in state on success and
  /// surfaces an error message on failure. Returns the raw [Result] so callers
  /// can show tailored UI feedback.
  Future<Result<MenuBundle, DomainError>> publishBundle(int bundleId) async {
    emit(
      state.copyWith(
        publishingBundleIds: <int>{...state.publishingBundleIds, bundleId},
      ),
    );
    final result = await _publishBundle.execute(bundleId);
    if (isDisposed) {
      return result;
    }
    final remaining = <int>{...state.publishingBundleIds}..remove(bundleId);
    result.fold(
      onSuccess: (published) {
        emit(
          state.copyWith(
            publishingBundleIds: remaining,
            bundles: state.bundles
                .map((b) => b.id == published.id ? published : b)
                .toList(growable: false),
            errorMessage: null,
          ),
        );
      },
      onFailure: (error) {
        emit(
          state.copyWith(
            publishingBundleIds: remaining,
            errorMessage: error.message,
          ),
        );
      },
    );
    return result;
  }

  /// Clear the surfaced error message (typically after the screen has shown
  /// it).
  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    emit(state.copyWith(errorMessage: null));
  }

  void goBack() => _router.goBack();

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final bundlesFuture = _listBundles.execute(NoInput.instance);
    final menusFuture = _listAvailableMenus.execute(NoInput.instance);
    final bundlesResult = await bundlesFuture;
    final menusResult = await menusFuture;
    if (isDisposed) {
      return;
    }
    if (bundlesResult.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: bundlesResult.errorOrNull!.message,
        ),
      );
      return;
    }
    if (menusResult.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: menusResult.errorOrNull!.message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        bundles: bundlesResult.valueOrNull!,
        availableMenus: menusResult.valueOrNull!,
        errorMessage: null,
      ),
    );
  }

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    final wasOffline = _lastConnectivity == ConnectivityStatus.offline;
    _lastConnectivity = next;
    if (wasOffline &&
        next == ConnectivityStatus.online &&
        state.errorMessage != null) {
      unawaited(_load());
    }
  }

  @override
  void onDispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }
}
