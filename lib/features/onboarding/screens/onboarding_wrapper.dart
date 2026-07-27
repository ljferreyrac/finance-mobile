import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/services/onboarding_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/accounts/bloc/account_bloc.dart';
import '../../../features/accounts/bloc/account_event.dart';
import '../../../features/accounts/bloc/account_state.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../widgets/step_indicator.dart';
import 'step_create_account.dart';
import 'step_create_categories.dart';
import 'step_try_voice.dart';

/// Hosts the three-step onboarding flow: accounts, then categories, then a
/// skippable "try voice entry now" step.
///
/// Navigation between steps is handled via setState, no extra routes pushed.
/// On completion [OnboardingService.markComplete] is called and the auth bloc
/// is refreshed so GoRouter redirects the user to the main dashboard.
///
/// [AccountBloc] must be provided above this widget.
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  int _step = 0;
  final _onboardingService = OnboardingService();

  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _resumeStep();
  }

  /// Jumps to the correct step if earlier ones are already done, so users
  /// who left mid-flow (or created accounts/categories in a previous session
  /// via the old onboarding flow) are not sent through steps they already
  /// completed. The bloc's own result is handled by the [BlocListener] in
  /// [build]; a fetch failure just leaves the user on step 1, same as
  /// before.
  Future<void> _resumeStep() async {
    if (await _onboardingService.hasCompletedCategories()) {
      if (mounted) setState(() => _step = 2);
      return;
    }
    if (await _onboardingService.hasCompletedAccounts()) {
      if (mounted) setState(() => _step = 1);
      return;
    }
    if (mounted) {
      context.read<AccountBloc>().add(const LoadAccounts());
    }
  }

  void _handleAccountState(AccountState state) {
    if (_step != 0) return;
    if (state is AccountLoaded && state.accounts.isNotEmpty) {
      _onboardingService.markAccountsComplete();
      setState(() => _step = 1);
    }
  }

  /// Only sets the accounts flag; the final onboarding flag is set at the
  /// end of step 3, so relaunching between steps resumes correctly instead
  /// of going straight to the dashboard.
  Future<void> _goToStep2() async {
    await _onboardingService.markAccountsComplete();
    if (mounted) setState(() => _step = 1);
  }

  /// Only sets the categories flag; see [_goToStep2].
  Future<void> _goToStep3() async {
    await _onboardingService.markCategoriesComplete();
    if (mounted) setState(() => _step = 2);
  }

  Future<void> _finish() async {
    await _onboardingService.markComplete();
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) => _handleAccountState(state),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OnboardingAppBar(currentStep: _step, totalSteps: _totalSteps),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _step == 0
                      ? StepCreateAccount(
                          key: const ValueKey('step_account'),
                          onComplete: _goToStep2,
                        )
                      : _step == 1
                          ? StepCreateCategories(
                              key: const ValueKey('step_categories'),
                              onComplete: _goToStep3,
                            )
                          : StepTryVoice(
                              key: const ValueKey('step_voice'),
                              onComplete: _finish,
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingAppBar extends StatelessWidget {
  const _OnboardingAppBar({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stepLabels = [
      l10n.onboardingStep1StepLabel,
      l10n.onboardingStep2StepLabel,
      l10n.onboardingStep3StepLabel,
    ];
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.teal400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.appTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 20),

          OnboardingStepIndicator(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              stepLabels[currentStep],
              key: ValueKey(currentStep),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.teal400,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
