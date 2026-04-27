import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/auth/presentation/state/forgot_password_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// MVVM-stack forgot-password screen.
///
/// Pure widget — owns no auth state, no Riverpod providers, no navigation.
/// Reads form state from the injected [ForgotPasswordViewModel] and forwards
/// user intents back to it.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.viewModel});

  final ForgotPasswordViewModel viewModel;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    await widget.viewModel.submit(email: _emailController.text);
  }

  TextStyle _cupertinoErrorStyle() {
    return TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12);
  }

  Widget _buildEmailField(ForgotPasswordState state) {
    if (isApplePlatform(context)) {
      return Column(
        key: const Key('forgot_email_field'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _emailController,
            placeholder: 'Email',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.mail),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onSubmitted: (_) => _submit(),
          ),
          if (state.emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(state.emailError!, style: _cupertinoErrorStyle()),
            ),
        ],
      );
    }
    return TextFormField(
      key: const Key('forgot_email_field'),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: state.emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildSendButton(ForgotPasswordState state, ThemeData theme) {
    final onPressed = state.isSubmitting ? null : _submit;

    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('send_reset_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: onPressed,
          child: state.isSubmitting
              ? const CupertinoActivityIndicator()
              : const Text('Send Reset Link'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('send_reset_button'),
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
            : const Text('Send Reset Link'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset, size: 64, color: colorScheme.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Forgot Password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Enter your email address and we'll send you a link to "
                    'reset your password.',
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
                          _buildEmailField(state),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSendButton(state, theme),
                        ],
                      ),
                    ),
                  ),
                  if (state.emailSent)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Text(
                        'Check your email for a reset link',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    key: const Key('back_to_login'),
                    onPressed: widget.viewModel.goBackToLogin,
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
