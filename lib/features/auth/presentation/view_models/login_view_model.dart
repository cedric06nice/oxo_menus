import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/login_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

/// View model that owns the login screen's form state.
///
/// Performs local validation, drives the [LoginUseCase], and delegates
/// navigation to the injected [LoginRouter]. Tracks connectivity through
/// [ConnectivityGateway] so the screen can render an offline banner without
/// reaching into Riverpod or `BuildContext`.
class LoginViewModel extends ViewModel<LoginState> {
  LoginViewModel({
    required LoginUseCase login,
    required LoginRouter router,
    required ConnectivityGateway connectivityGateway,
  }) : _login = login,
       _router = router,
       _connectivityGateway = connectivityGateway,
       super(
         LoginState(
           isOffline:
               connectivityGateway.currentStatus == ConnectivityStatus.offline,
         ),
       ) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
  }

  final LoginUseCase _login;
  final LoginRouter _router;
  final ConnectivityGateway _connectivityGateway;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) {
      return;
    }
    final trimmedEmail = email.trim();
    final emailError = trimmedEmail.isEmpty ? 'Please enter your email' : null;
    final passwordError = password.isEmpty
        ? 'Please enter your password'
        : null;
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          errorMessage: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        emailError: null,
        passwordError: null,
        isSubmitting: true,
        errorMessage: null,
      ),
    );
    final result = await _login.execute(
      LoginInput(email: trimmedEmail, password: password),
    );
    result.fold(
      onSuccess: (_) {
        emit(state.copyWith(isSubmitting: false, errorMessage: null));
        _router.goToHomeAfterLogin();
      },
      onFailure: (error) {
        emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      },
    );
  }

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
}
