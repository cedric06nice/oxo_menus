import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/reset_password_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

/// View model that owns the reset-password screen's form state.
///
/// Performs local validation, drives the [ConfirmPasswordResetUseCase], and
/// delegates navigation to the injected [ResetPasswordRouter]. Tracks
/// connectivity through [ConnectivityGateway] so the screen can render an
/// offline banner without reaching into Riverpod or `BuildContext`.
///
/// The reset [token] is captured at construction time from the deep-link query
/// parameter. A null or empty token leaves the screen in a "missing token"
/// state — the screen surfaces this via [hasToken] and submit is rejected
/// before reaching the use case.
class ResetPasswordViewModel extends ViewModel<ResetPasswordState> {
  ResetPasswordViewModel({
    required ConfirmPasswordResetUseCase confirmPasswordReset,
    required ResetPasswordRouter router,
    required ConnectivityGateway connectivityGateway,
    required String? token,
  }) : _confirmPasswordReset = confirmPasswordReset,
       _router = router,
       _connectivityGateway = connectivityGateway,
       _token = token,
       super(
         ResetPasswordState(
           isOffline:
               connectivityGateway.currentStatus == ConnectivityStatus.offline,
         ),
       ) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
  }

  final ConfirmPasswordResetUseCase _confirmPasswordReset;
  final ResetPasswordRouter _router;
  final ConnectivityGateway _connectivityGateway;
  final String? _token;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  /// The reset token captured at construction time, or `null` when the deep
  /// link was opened without one.
  String? get token => _token;

  /// `true` when the screen has a usable token. The screen renders the
  /// missing-token branch when this is `false`.
  bool get hasToken => _token != null && _token.isNotEmpty;

  Future<void> submit({
    required String password,
    required String confirm,
  }) async {
    if (state.isSubmitting) {
      return;
    }
    final passwordError = _validatePassword(password);
    final confirmError = passwordError == null
        ? _validateConfirm(password: password, confirm: confirm)
        : null;
    if (passwordError != null || confirmError != null) {
      emit(
        state.copyWith(
          passwordError: passwordError,
          confirmError: confirmError,
          errorMessage: null,
        ),
      );
      return;
    }
    if (!hasToken) {
      emit(
        state.copyWith(
          passwordError: null,
          confirmError: null,
          errorMessage: 'Invalid or missing reset token',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        passwordError: null,
        confirmError: null,
        isSubmitting: true,
        errorMessage: null,
      ),
    );
    final result = await _confirmPasswordReset.execute(
      ConfirmPasswordResetInput(token: _token!, password: password),
    );
    result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            passwordError: null,
            confirmError: null,
            isSubmitting: false,
            errorMessage: null,
            passwordChanged: true,
          ),
        );
      },
      onFailure: (error) {
        emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      },
    );
  }

  void goToLogin() => _router.goToLogin();

  void goToForgotPassword() => _router.goToForgotPassword();

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    emit(state.copyWith(isOffline: next == ConnectivityStatus.offline));
  }

  @override
  void onDispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a new password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirm({
    required String password,
    required String confirm,
  }) {
    if (confirm != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
