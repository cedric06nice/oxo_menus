import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/auth/presentation/state/login_state.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// MVVM-stack login screen.
///
/// Pure widget — owns no auth state, no Riverpod providers, no navigation.
/// Reads form state from the injected [LoginViewModel] and forwards user
/// intents back to it.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    await widget.viewModel.submit(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  TextStyle _cupertinoErrorStyle() {
    return TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12);
  }

  Widget _buildEmailField(LoginState state) {
    if (isApplePlatform(context)) {
      return Column(
        key: const Key('email_field'),
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
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
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
      key: const Key('email_field'),
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: state.emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
    );
  }

  Widget _buildPasswordField(LoginState state) {
    if (isApplePlatform(context)) {
      return Column(
        key: const Key('password_field'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _passwordController,
            placeholder: 'Password',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(CupertinoIcons.lock),
            ),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            autofillHints: const [AutofillHints.password],
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
      key: const Key('password_field'),
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        errorText: state.passwordError,
      ),
      autofillHints: const [AutofillHints.password],
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildLoginButton(LoginState state, ThemeData theme) {
    final onPressed = state.isSubmitting ? null : _submit;

    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('login_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: onPressed,
          child: state.isSubmitting
              ? const CupertinoActivityIndicator()
              : const Text('Login'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('login_button'),
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
            : const Text('Login'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          key: const Key('tower_logo'),
                          theme.brightness == Brightness.dark
                              ? 'assets/images/OXOTowerDrawingWhite.png'
                              : 'assets/images/OXOTowerDrawingBlack.png',
                          height: 120,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'OXO',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: ' Menus',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Menu Template Builder',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                AutofillGroup(
                                  child: Column(
                                    children: [
                                      _buildEmailField(state),
                                      const SizedBox(height: AppSpacing.lg),
                                      _buildPasswordField(state),
                                      const SizedBox(height: AppSpacing.xl),
                                    ],
                                  ),
                                ),
                                _buildLoginButton(state, theme),
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    key: const Key('forgot_password_link'),
                                    onPressed:
                                        widget.viewModel.goToForgotPassword,
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                              ],
                            ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
