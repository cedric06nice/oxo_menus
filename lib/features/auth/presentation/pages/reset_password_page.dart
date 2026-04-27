import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/features/auth/presentation/providers/password_reset_provider.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Page for confirming a password reset with token from email link
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    String? passwordErr;
    String? confirmErr;

    if (password.isEmpty) {
      passwordErr = 'Please enter a new password';
    } else if (password.length < 8) {
      passwordErr = 'Password must be at least 8 characters';
    }

    if (password.isNotEmpty && confirm != password) {
      confirmErr = 'Passwords do not match';
    }

    setState(() {
      _passwordError = passwordErr;
      _confirmError = confirmErr;
    });

    if (passwordErr != null || confirmErr != null) return;

    await ref
        .read(passwordResetProvider.notifier)
        .confirmReset(token: widget.token!, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.token == null || widget.token!.isEmpty) {
      return _buildMissingTokenPage(theme, colorScheme);
    }

    final state = ref.watch(passwordResetProvider);
    final isLoading = state == const PasswordResetState.loading();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primaryContainer, colorScheme.surface],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: state.maybeWhen(
                passwordChanged: () => _buildSuccessContent(theme, colorScheme),
                orElse: () =>
                    _buildFormContent(state, isLoading, theme, colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissingTokenPage(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primaryContainer, colorScheme.surface],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Invalid or missing reset token',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: const Text('Request a new link'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Password reset successfully',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You can now login with your new password.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        FilledButton(
          key: const Key('go_to_login_button'),
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Go to Login'),
        ),
      ],
    );
  }

  Widget _buildFormContent(
    PasswordResetState state,
    bool isLoading,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_reset, size: 64, color: colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Reset Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enter your new password below.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildPasswordField(),
                const SizedBox(height: AppSpacing.lg),
                _buildConfirmField(),
                const SizedBox(height: AppSpacing.xl),
                _buildResetButton(isLoading, theme),
              ],
            ),
          ),
        ),
        state.maybeWhen(
          error: (message) => Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              children: [
                Text(message, style: TextStyle(color: colorScheme.error)),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: const Text('Request a new link'),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    if (isApplePlatform(context)) {
      return Column(
        key: const Key('new_password_field'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _passwordController,
            placeholder: 'New Password',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.lock),
            ),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
          ),
          if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _passwordError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }
    return TextFormField(
      key: const Key('new_password_field'),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'New Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        errorText: _passwordError,
      ),
      obscureText: true,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmField() {
    if (isApplePlatform(context)) {
      return Column(
        key: const Key('confirm_password_field'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _confirmController,
            placeholder: 'Confirm Password',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.lock),
            ),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleResetPassword(),
          ),
          if (_confirmError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _confirmError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }
    return TextFormField(
      key: const Key('confirm_password_field'),
      controller: _confirmController,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        errorText: _confirmError,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleResetPassword(),
    );
  }

  Widget _buildResetButton(bool isLoading, ThemeData theme) {
    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('reset_password_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : _handleResetPassword,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Reset Password'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('reset_password_button'),
        onPressed: isLoading ? null : _handleResetPassword,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Text('Reset Password'),
      ),
    );
  }
}
