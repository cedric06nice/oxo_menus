import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/state/admin_sizes_screen_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the admin-sizes screen's state.
///
/// Listens to [ConnectivityGateway] to retry the load on offline → online
/// transitions. Knows nothing about widgets, `BuildContext`, or Riverpod —
/// the screen passes mutations through and the [AdminSizesRouter] owns
/// navigation.
class AdminSizesViewModel extends ViewModel<AdminSizesScreenState> {
  AdminSizesViewModel({
    required ListSizesForAdminUseCase listSizes,
    required CreateSizeUseCase createSize,
    required UpdateSizeUseCase updateSize,
    required DeleteSizeUseCase deleteSize,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required AdminSizesRouter router,
  }) : _listSizes = listSizes,
       _createSize = createSize,
       _updateSize = updateSize,
       _deleteSize = deleteSize,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_load());
  }

  final ListSizesForAdminUseCase _listSizes;
  final CreateSizeUseCase _createSize;
  final UpdateSizeUseCase _updateSize;
  final DeleteSizeUseCase _deleteSize;
  final ConnectivityGateway _connectivityGateway;
  final AdminSizesRouter _router;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;

  static AdminSizesScreenState _initialStateFor(AuthGateway gateway) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return AdminSizesScreenState(isAdmin: isAdmin);
  }

  /// Re-runs the list use case (pull-to-refresh, retry after error).
  Future<void> refresh() => _load();

  /// Updates the status filter and reloads with the new value. A no-op when
  /// the filter is unchanged.
  void setStatusFilter(String filter) {
    if (state.statusFilter == filter) {
      return;
    }
    emit(state.copyWith(statusFilter: filter));
    unawaited(_load());
  }

  /// Creates a size; on success appends it to the list and returns `true`.
  Future<bool> createSize(CreateSizeInput input) async {
    final result = await _createSize.execute(input);
    return result.fold(
      onSuccess: (created) {
        emit(
          state.copyWith(
            sizes: <Size>[...state.sizes, created],
            errorMessage: null,
          ),
        );
        return true;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  }

  /// Updates a size; on success replaces the matching entry in place and
  /// returns `true`.
  Future<bool> updateSize(UpdateSizeInput input) async {
    final result = await _updateSize.execute(input);
    return result.fold(
      onSuccess: (updated) {
        emit(
          state.copyWith(
            sizes: state.sizes
                .map((s) => s.id == updated.id ? updated : s)
                .toList(),
            errorMessage: null,
          ),
        );
        return true;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  }

  /// Deletes a size; on success removes it from the list and returns `true`.
  Future<bool> deleteSize(int sizeId) async {
    final result = await _deleteSize.execute(sizeId);
    return result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            sizes: state.sizes.where((s) => s.id != sizeId).toList(),
            errorMessage: null,
          ),
        );
        return true;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  }

  void goBack() => _router.goBack();

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _listSizes.execute(
      ListSizesForAdminInput(statusFilter: state.statusFilter),
    );
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (sizes) {
        emit(
          state.copyWith(isLoading: false, sizes: sizes, errorMessage: null),
        );
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
      },
    );
  }

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    final wasOffline = _lastConnectivity == ConnectivityStatus.offline;
    _lastConnectivity = next;
    if (wasOffline && next == ConnectivityStatus.online) {
      unawaited(_load());
    }
  }

  @override
  void onDispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }
}
