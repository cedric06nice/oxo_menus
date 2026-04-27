import 'dart:async';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';
import 'package:oxo_menus/features/settings/presentation/state/settings_state.dart';

/// View model that owns the settings screen's state.
///
/// Eagerly resolves the [SettingsState] from the snapshot use case (no I/O)
/// then kicks off the version load. Subscribes to
/// [AdminViewAsUserGateway.valueStream] so external toggles (e.g. from the
/// legacy Riverpod provider) keep the new screen in sync.
class SettingsViewModel extends ViewModel<SettingsState> {
  SettingsViewModel({
    required GetSettingsOverviewUseCase getOverview,
    required GetAppVersionUseCase getAppVersion,
    required RequestPasswordResetUseCase requestPasswordReset,
    required LogoutUseCase logout,
    required SetAdminViewAsUserUseCase setAdminViewAsUser,
    required AdminViewAsUserGateway adminViewAsUserGateway,
    required SettingsRouter router,
  }) : _getAppVersion = getAppVersion,
       _requestPasswordReset = requestPasswordReset,
       _logout = logout,
       _setAdminViewAsUser = setAdminViewAsUser,
       _adminViewAsUserGateway = adminViewAsUserGateway,
       _router = router,
       super(_initialStateFor(getOverview)) {
    _viewAsUserSubscription = _adminViewAsUserGateway.valueStream.listen(
      _onViewAsUserChanged,
    );
    unawaited(_loadVersion());
  }

  final GetAppVersionUseCase _getAppVersion;
  final RequestPasswordResetUseCase _requestPasswordReset;
  final LogoutUseCase _logout;
  final SetAdminViewAsUserUseCase _setAdminViewAsUser;
  final AdminViewAsUserGateway _adminViewAsUserGateway;
  final SettingsRouter _router;

  StreamSubscription<bool>? _viewAsUserSubscription;

  static SettingsState _initialStateFor(GetSettingsOverviewUseCase useCase) {
    final result = useCase.execute(NoInput.instance);
    return result.fold(
      onSuccess: (overview) => SettingsState(
        user: overview.user,
        isAdmin: overview.isAdmin,
        viewAsUser: overview.viewAsUser,
      ),
      onFailure: (_) => const SettingsState(),
    );
  }

  /// Sends a password-reset email to the signed-in user's address.
  ///
  /// Returns `true` when the request succeeded so the caller can show a
  /// platform-appropriate acknowledgement.
  Future<bool> requestPasswordReset({String? resetUrl}) async {
    final email = state.user?.email;
    if (email == null) {
      emit(
        state.copyWith(
          passwordResetOutcome: PasswordResetOutcome.failed,
          passwordResetMessage: 'No signed-in user to reset.',
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        passwordResetInFlight: true,
        passwordResetOutcome: PasswordResetOutcome.idle,
        passwordResetMessage: null,
      ),
    );
    final result = await _requestPasswordReset.execute(
      RequestPasswordResetInput(email: email, resetUrl: resetUrl),
    );
    if (isDisposed) {
      return false;
    }
    return result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            passwordResetInFlight: false,
            passwordResetOutcome: PasswordResetOutcome.sent,
            passwordResetMessage:
                'A password reset link has been sent to $email.',
          ),
        );
        return true;
      },
      onFailure: (error) {
        emit(
          state.copyWith(
            passwordResetInFlight: false,
            passwordResetOutcome: PasswordResetOutcome.failed,
            passwordResetMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  /// Logs the current user out. The auth gateway flips status to
  /// unauthenticated; the router then redirects to `/login`.
  Future<void> logout() async {
    await _logout.execute(NoInput.instance);
  }

  /// Updates the admin "view as user" toggle.
  void setViewAsUser(bool value) {
    _setAdminViewAsUser.execute(value);
  }

  /// Resets the password-reset acknowledgement so the screen can dismiss the
  /// banner / snackbar after the user confirms it.
  void acknowledgePasswordReset() {
    if (state.passwordResetOutcome == PasswordResetOutcome.idle) {
      return;
    }
    emit(
      state.copyWith(
        passwordResetOutcome: PasswordResetOutcome.idle,
        passwordResetMessage: null,
      ),
    );
  }

  void goBack() => _router.goBack();

  Future<void> _loadVersion() async {
    final result = await _getAppVersion.execute(NoInput.instance);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (version) => emit(state.copyWith(version: version)),
      onFailure: (_) => emit(state.copyWith(version: 'unknown')),
    );
  }

  void _onViewAsUserChanged(bool next) {
    if (isDisposed) {
      return;
    }
    if (state.viewAsUser == next) {
      return;
    }
    emit(state.copyWith(viewAsUser: next));
  }

  @override
  void onDispose() {
    unawaited(_viewAsUserSubscription?.cancel());
    _viewAsUserSubscription = null;
  }
}
