import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

part 'password_reset_provider.freezed.dart';

/// Password reset state
@freezed
sealed class PasswordResetState with _$PasswordResetState {
  /// Initial idle state
  const factory PasswordResetState.initial() = _Initial;

  /// Loading state during API call
  const factory PasswordResetState.loading() = _Loading;

  /// Reset email sent successfully
  const factory PasswordResetState.emailSent() = _EmailSent;

  /// Password changed successfully
  const factory PasswordResetState.passwordChanged() = _PasswordChanged;

  /// Error state with message
  const factory PasswordResetState.error(String message) = _Error;
}

/// Password reset notifier
///
/// Manages the password reset flow: request email → confirm with token
class PasswordResetNotifier extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState.initial();

  /// Request a password reset email
  Future<void> requestReset(String email) async {
    state = const PasswordResetState.loading();
    final resetUrl = _buildResetUrl();
    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(email, resetUrl: resetUrl);
    result.fold(
      onSuccess: (_) => state = const PasswordResetState.emailSent(),
      onFailure: (error) => state = PasswordResetState.error(error.message),
    );
  }

  /// Confirm password reset with token from email link
  Future<void> confirmReset({
    required String token,
    required String password,
  }) async {
    state = const PasswordResetState.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .confirmPasswordReset(token: token, password: password);
    result.fold(
      onSuccess: (_) => state = const PasswordResetState.passwordChanged(),
      onFailure: (error) => state = PasswordResetState.error(error.message),
    );
  }

  /// Reset to initial state
  void reset() => state = const PasswordResetState.initial();

  /// Build the reset URL based on platform
  ///
  /// For web, uses the current origin. For mobile, uses RESET_URL_BASE
  /// dart-define or falls back to deriving from the web app domain.
  String? _buildResetUrl() {
    if (kIsWeb) {
      return Uri.base.resolve(AppRoutes.resetPassword).toString();
    }
    // For mobile, use dart-define if provided
    const resetUrlBase = String.fromEnvironment('RESET_URL_BASE');
    if (resetUrlBase.isNotEmpty) {
      return '$resetUrlBase${AppRoutes.resetPassword}';
    }
    return null;
  }
}

/// Password reset provider
final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
      PasswordResetNotifier.new,
    );
