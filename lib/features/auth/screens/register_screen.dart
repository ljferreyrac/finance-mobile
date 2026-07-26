import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// Registration screen: full name, email, password, confirm password, currency.
///
/// All state is managed by [AuthBloc] - no setState outside leaf toggle widgets.
/// On [AuthAuthenticated] the router redirects to /transactions.
/// On [AuthError] a SnackBar is shown with the error message.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedCurrency = 'PEN';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(RegisterSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          currency: _selectedCurrency,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigation is handled by the GoRouter redirect reacting to AuthAuthenticated.
        if (state is AuthError) {
          AppSnackBar.showError(context, state.message.resolve(l10n));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.registerTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isLoading ? null : () => context.pop(),
              tooltip: l10n.backTooltip,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FullNameField(
                        controller: _fullNameController, enabled: !isLoading),
                    const SizedBox(height: 16),
                    _EmailField(
                        controller: _emailController, enabled: !isLoading),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscure: _obscurePassword,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 16),
                    _ConfirmPasswordField(
                      controller: _confirmPasswordController,
                      passwordController: _passwordController,
                      enabled: !isLoading,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    _CurrencySelector(
                      value: _selectedCurrency,
                      enabled: !isLoading,
                      onChanged: (v) =>
                          setState(() => _selectedCurrency = v ?? 'PEN'),
                    ),
                    const SizedBox(height: 24),
                    _LanguageSelector(enabled: !isLoading),
                    const SizedBox(height: 32),
                    _SubmitButton(isLoading: isLoading, onPressed: _submit),
                    const SizedBox(height: 24),
                    _LoginLink(enabled: !isLoading),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FullNameField extends StatelessWidget {
  const _FullNameField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      decoration: InputDecoration(
        labelText: l10n.fullNameLabel,
        hintText: l10n.fullNameHint,
        prefixIcon: const Icon(Icons.person_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.fullNameRequired;
        }
        if (value.trim().length < 2) {
          return l10n.fullNameTooShort;
        }
        return null;
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newUsername],
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        hintText: l10n.emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.emailRequired;
        }
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value.trim())) {
          return l10n.emailInvalid;
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: l10n.passwordLabel,
        helperText: l10n.passwordHelperText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggleObscure,
          tooltip: obscure ? l10n.showPassword : l10n.hidePassword,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.passwordRequiredRegister;
        }
        if (value.length < 10) {
          return l10n.passwordTooShort;
        }
        return null;
      },
    );
  }
}

class _ConfirmPasswordField extends StatelessWidget {
  const _ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
    required this.enabled,
    required this.obscure,
    required this.onToggleObscure,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool enabled;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: l10n.confirmPasswordLabel,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggleObscure,
          tooltip: obscure ? l10n.showPassword : l10n.hidePassword,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.confirmPasswordRequired;
        }
        if (value != passwordController.text) {
          return l10n.passwordsNoMatch;
        }
        return null;
      },
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mainCurrencyLabel,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.currency_exchange),
          ),
          items: [
            DropdownMenuItem(
              value: 'PEN',
              child: Text(l10n.solesCurrency),
            ),
            DropdownMenuItem(
              value: 'USD',
              child: Text(l10n.dollarsCurrency),
            ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registerLanguageLabel,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, currentLocale) {
            return SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'es',
                  label: Text(l10n.spanishLanguage),
                  icon: const Icon(Icons.language, size: 16),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(l10n.englishLanguage),
                  icon: const Icon(Icons.language, size: 16),
                ),
              ],
              selected: {currentLocale.languageCode},
              onSelectionChanged: enabled
                  ? (s) => context
                      .read<LocaleCubit>()
                      .setLocale(Locale(s.first))
                  : null,
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              l10n.registerButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        TextButton(
          onPressed: enabled ? () => context.pop() : null,
          child: Text(l10n.loginLink),
        ),
      ],
    );
  }
}
