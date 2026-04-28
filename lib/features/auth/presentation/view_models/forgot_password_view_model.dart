import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/forgot_password_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

/// View model that owns the forgot-password screen's form state.
///
/// Performs local validation, drives the [RequestPasswordResetUseCase], and
/// delegates navigation to the injected [ForgotPasswordRouter]. Tracks
/// connectivity through [ConnectivityGateway] so the screen can render an
/// offline banner without reaching into Riverpod or `BuildContext`.
///
/// [resetUrl] is the platform-resolved deep-link target embedded in the
/// reset email. The route page builds it (handling `kIsWeb` / dart-define)
/// and passes it in at construction time so the view model stays
/// platform-agnostic.
class ForgotPasswordViewModel extends ViewModel<ForgotPasswordState> {
  ForgotPasswordViewModel({
    required RequestPasswordResetUseCase requestPasswordReset,
    required ForgotPasswordRouter router,
    required ConnectivityGateway connectivityGateway,
    String? resetUrl,
  }) : _requestPasswordReset = requestPasswordReset,
       _router = router,
       _connectivityGateway = connectivityGateway,
       _resetUrl = resetUrl,
       super(
         ForgotPasswordState(
           isOffline:
               connectivityGateway.currentStatus == ConnectivityStatus.offline,
         ),
       ) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
  }

  final RequestPasswordResetUseCase _requestPasswordReset;
  final ForgotPasswordRouter _router;
  final ConnectivityGateway _connectivityGateway;
  final String? _resetUrl;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  Future<void> submit({required String email}) async {
    if (state.isSubmitting) {
      return;
    }
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          emailError: 'Please enter your email',
          errorMessage: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(emailError: null, isSubmitting: true, errorMessage: null),
    );
    final result = await _requestPasswordReset.execute(
      RequestPasswordResetInput(email: trimmedEmail, resetUrl: _resetUrl),
    );
    result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            emailError: null,
            isSubmitting: false,
            errorMessage: null,
            emailSent: true,
          ),
        );
      },
      onFailure: (error) {
        emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      },
    );
  }

  void goBackToLogin() => _router.goBackToLogin();

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
