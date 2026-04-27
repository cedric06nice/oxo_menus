import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/state/admin_templates_screen_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the admin-templates screen's state.
///
/// Listens to [ConnectivityGateway] to retry the load on offline → online
/// transitions. Knows nothing about widgets, `BuildContext`, or Riverpod —
/// the screen passes mutations through and the [AdminTemplatesRouter] owns
/// navigation.
class AdminTemplatesViewModel extends ViewModel<AdminTemplatesScreenState> {
  AdminTemplatesViewModel({
    required ListTemplatesForAdminUseCase listTemplates,
    required DeleteTemplateUseCase deleteTemplate,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required AdminTemplatesRouter router,
  }) : _listTemplates = listTemplates,
       _deleteTemplate = deleteTemplate,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_load());
  }

  final ListTemplatesForAdminUseCase _listTemplates;
  final DeleteTemplateUseCase _deleteTemplate;
  final ConnectivityGateway _connectivityGateway;
  final AdminTemplatesRouter _router;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;

  static AdminTemplatesScreenState _initialStateFor(AuthGateway gateway) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return AdminTemplatesScreenState(isAdmin: isAdmin);
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

  /// Deletes a template; on success removes it from the list and returns
  /// `true`.
  Future<bool> deleteTemplate(int templateId) async {
    final result = await _deleteTemplate.execute(templateId);
    return result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            templates: state.templates
                .where((t) => t.id != templateId)
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

  void openTemplate(int menuId) => _router.goToAdminTemplateEditor(menuId);

  void openCreateTemplate() => _router.goToAdminTemplateCreate();

  void goBack() => _router.goBack();

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _listTemplates.execute(
      ListTemplatesForAdminInput(statusFilter: state.statusFilter),
    );
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (templates) {
        emit(
          state.copyWith(
            isLoading: false,
            templates: templates,
            errorMessage: null,
          ),
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
