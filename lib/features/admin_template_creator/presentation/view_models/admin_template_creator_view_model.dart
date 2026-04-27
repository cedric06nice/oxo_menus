import 'dart:async';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/state/admin_template_creator_screen_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the admin-template-creator screen's state.
///
/// Eagerly drives the sizes and areas use cases on construction; the screen
/// renders progress flags from the resulting state. Listens to
/// [ConnectivityGateway] to retry both loads on offline → online transitions.
/// Knows nothing about widgets, `BuildContext`, or Riverpod — the screen
/// passes mutations through and the [AdminTemplateCreatorRouter] owns
/// navigation.
class AdminTemplateCreatorViewModel
    extends ViewModel<AdminTemplateCreatorScreenState> {
  AdminTemplateCreatorViewModel({
    required ListSizesForCreatorUseCase listSizes,
    required ListAreasForCreatorUseCase listAreas,
    required CreateTemplateUseCase createTemplate,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required AdminTemplateCreatorRouter router,
  }) : _listSizes = listSizes,
       _listAreas = listAreas,
       _createTemplate = createTemplate,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_loadAll());
  }

  final ListSizesForCreatorUseCase _listSizes;
  final ListAreasForCreatorUseCase _listAreas;
  final CreateTemplateUseCase _createTemplate;
  final ConnectivityGateway _connectivityGateway;
  final AdminTemplateCreatorRouter _router;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;

  static AdminTemplateCreatorScreenState _initialStateFor(AuthGateway gateway) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return AdminTemplateCreatorScreenState(isAdmin: isAdmin);
  }

  /// Replaces the picked size. No-op when the value is unchanged.
  void setSelectedSize(Size? size) {
    if (state.selectedSize == size) {
      return;
    }
    emit(state.copyWith(selectedSize: size));
  }

  /// Replaces the picked area. `null` means the admin chose "None". No-op
  /// when the value is unchanged.
  void setSelectedArea(Area? area) {
    if (state.selectedArea == area) {
      return;
    }
    emit(state.copyWith(selectedArea: area));
  }

  /// Submits the form. Skips when already saving or when no size is selected.
  /// On success delegates to the router to open the new template's editor and
  /// returns `true`; on failure surfaces the error and returns `false`.
  Future<bool> createTemplate({
    required String name,
    required String version,
  }) async {
    if (state.isSaving) {
      return false;
    }
    final size = state.selectedSize;
    if (size == null) {
      return false;
    }
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _createTemplate.execute(
      CreateTemplateInput(
        name: name,
        version: version,
        sizeId: size.id,
        areaId: state.selectedArea?.id,
      ),
    );
    if (isDisposed) {
      return result.isSuccess;
    }
    return result.fold(
      onSuccess: (menu) {
        emit(state.copyWith(isSaving: false, errorMessage: null));
        _router.goToAdminTemplateEditor(menu.id);
        return true;
      },
      onFailure: (error) {
        emit(state.copyWith(isSaving: false, errorMessage: error.message));
        return false;
      },
    );
  }

  void goBack() => _router.goBack();

  void openAdminSizes() => _router.goToAdminSizes();

  Future<void> _loadAll() async {
    await Future.wait(<Future<void>>[_loadSizes(), _loadAreas()]);
  }

  Future<void> _loadSizes() async {
    emit(state.copyWith(isLoadingSizes: true, errorMessage: null));
    final result = await _listSizes.execute(NoInput.instance);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (sizes) {
        final shouldAutoSelect = state.selectedSize == null && sizes.isNotEmpty;
        emit(
          state.copyWith(
            isLoadingSizes: false,
            sizes: sizes,
            selectedSize: shouldAutoSelect ? sizes.first : state.selectedSize,
            errorMessage: null,
          ),
        );
      },
      onFailure: (error) {
        emit(
          state.copyWith(isLoadingSizes: false, errorMessage: error.message),
        );
      },
    );
  }

  Future<void> _loadAreas() async {
    emit(state.copyWith(isLoadingAreas: true));
    final result = await _listAreas.execute(NoInput.instance);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (areas) {
        emit(state.copyWith(isLoadingAreas: false, areas: areas));
      },
      onFailure: (error) {
        emit(
          state.copyWith(isLoadingAreas: false, errorMessage: error.message),
        );
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
      unawaited(_loadAll());
    }
  }

  @override
  void onDispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }
}
