import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_banner.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Please enter your password';
    return null;
  }

  Future<void> _handleLogin() async {
    final emailErr = _validateEmail(_emailController.text);
    final passwordErr = _validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
    if (emailErr != null || passwordErr != null) return;
    await ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);
  }

  TextStyle _cupertinoErrorStyle() {
    return TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12);
  }

  Widget _buildEmailField() {
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
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(_emailError!, style: _cupertinoErrorStyle()),
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
        errorText: _emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
    );
  }

  Widget _buildPasswordField() {
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
            onSubmitted: (_) => _handleLogin(),
            autofillHints: const [AutofillHints.password],
          ),
          if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(_passwordError!, style: _cupertinoErrorStyle()),
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
        errorText: _passwordError,
      ),
      autofillHints: const [AutofillHints.password],
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildLoginButton(AuthState authState, ThemeData theme) {
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    if (isApplePlatform(context)) {
      return SizedBox(
        key: const Key('login_button'),
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : _handleLogin,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Login'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('login_button'),
        onPressed: isLoading ? null : _handleLogin,
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
            : const Text('Login'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isOffline =
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;

    return Scaffold(
      body: Column(
        children: [
          if (isOffline) const OfflineBanner(),
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
                                      _buildEmailField(),
                                      const SizedBox(height: AppSpacing.lg),
                                      _buildPasswordField(),
                                      const SizedBox(height: AppSpacing.xl),
                                    ],
                                  ),
                                ),
                                _buildLoginButton(authState, theme),
                              ],
                            ),
                          ),
                        ),
                        authState.maybeWhen(
                          error: (message) => Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.lg),
                            child: Text(
                              message,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
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
