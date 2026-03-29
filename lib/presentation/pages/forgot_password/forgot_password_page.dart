import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/presentation/providers/password_reset_provider.dart';
import 'package:oxo_menus/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Page for requesting a password reset email
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }
    setState(() => _emailError = null);
    await ref.read(passwordResetProvider.notifier).requestReset(email);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                    'Enter your email address and we\'ll send you a link to reset your password.',
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
                          _buildEmailField(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSendButton(isLoading, theme),
                        ],
                      ),
                    ),
                  ),
                  state.maybeWhen(
                    emailSent: () => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Text(
                        'Check your email for a reset link',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                    error: (message) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Text(
                        message,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    key: const Key('back_to_login'),
                    onPressed: () => context.go(AppRoutes.login),
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

  Widget _buildEmailField() {
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
            onSubmitted: (_) => _handleSendReset(),
          ),
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _emailError!,
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
      key: const Key('forgot_email_field'),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: _emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSendReset(),
    );
  }

  Widget _buildSendButton(bool isLoading, ThemeData theme) {
    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('send_reset_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : _handleSendReset,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Send Reset Link'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('send_reset_button'),
        onPressed: isLoading ? null : _handleSendReset,
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
            : const Text('Send Reset Link'),
      ),
    );
  }
}
