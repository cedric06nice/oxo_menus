import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/auth/presentation/state/reset_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// MVVM-stack reset-password screen.
///
/// Pure widget — owns no auth state, no Riverpod providers, no navigation.
/// Reads form state from the injected [ResetPasswordViewModel] and forwards
/// user intents back to it.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.viewModel});

  final ResetPasswordViewModel viewModel;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    await widget.viewModel.submit(
      password: _passwordController.text,
      confirm: _confirmController.text,
    );
  }

  TextStyle _cupertinoErrorStyle() {
    return TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = widget.viewModel.state;

    return Scaffold(
      body: Column(
        children: [
          if (state.isOffline) const OfflineBanner(),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colorScheme.primaryContainer, colorScheme.surface],
                ),
              ),
              child: _buildBranchContent(theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchContent(ThemeData theme, ColorScheme colorScheme) {
    if (!widget.viewModel.hasToken) {
      return _buildMissingTokenContent(theme, colorScheme);
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: widget.viewModel.state.passwordChanged
              ? _buildSuccessContent(theme, colorScheme)
              : _buildFormContent(theme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildMissingTokenContent(ThemeData theme, ColorScheme colorScheme) {
    return Center(
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
            onPressed: widget.viewModel.goToForgotPassword,
            child: const Text('Request a new link'),
          ),
        ],
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
          onPressed: widget.viewModel.goToLogin,
          child: const Text('Go to Login'),
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme, ColorScheme colorScheme) {
    final state = widget.viewModel.state;
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
                _buildPasswordField(state),
                const SizedBox(height: AppSpacing.lg),
                _buildConfirmField(state),
                const SizedBox(height: AppSpacing.xl),
                _buildResetButton(state, theme),
              ],
            ),
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: widget.viewModel.goToForgotPassword,
                  child: const Text('Request a new link'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField(ResetPasswordState state) {
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
          if (state.passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(state.passwordError!, style: _cupertinoErrorStyle()),
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
        errorText: state.passwordError,
      ),
      obscureText: true,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmField(ResetPasswordState state) {
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
            onSubmitted: (_) => _submit(),
          ),
          if (state.confirmError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(state.confirmError!, style: _cupertinoErrorStyle()),
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
        errorText: state.confirmError,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildResetButton(ResetPasswordState state, ThemeData theme) {
    final onPressed = state.isSubmitting ? null : _submit;

    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('reset_password_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: onPressed,
          child: state.isSubmitting
              ? const CupertinoActivityIndicator()
              : const Text('Reset Password'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('reset_password_button'),
        onPressed: onPressed,
        child: state.isSubmitting
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
