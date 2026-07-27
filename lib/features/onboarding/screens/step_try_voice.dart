import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../voice/bloc/voice_bloc.dart';
import '../../voice/screens/voice_record_screen.dart';

/// Step 3 of onboarding: a skippable invitation to record one transaction by
/// voice while the user still has momentum, instead of dropping them onto an
/// empty dashboard and hoping they discover the feature later.
///
/// Pushes the same voice flow used elsewhere in the app
/// ([VoiceRecordScreen] -> [VoiceReviewScreen]) in a screen-scoped
/// [VoiceBloc], matching the pattern used to launch voice entry from the
/// transaction list. [onComplete] is called either when the user taps skip,
/// or after returning from the voice flow (whether they completed it,
/// cancelled, or denied the mic permission), so no path can strand a new
/// user mid-onboarding.
class StepTryVoice extends StatelessWidget {
  const StepTryVoice({super.key, required this.onComplete});

  final VoidCallback onComplete;

  Future<void> _openVoiceFlow(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => VoiceBloc(),
          child: const VoiceRecordScreen(),
        ),
      ),
    );
    // Whether the user finished, cancelled, or the mic permission was
    // denied, returning here means they've engaged with the step, so move
    // onboarding forward rather than showing this same screen again.
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingStep3Title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep3Subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 60.ms),
          const SizedBox(height: 40),

          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.teal50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 44,
                color: AppColors.teal400,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 24),

          Text(
            l10n.voiceIdleExample,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 140.ms),
          const SizedBox(height: 40),

          FilledButton.icon(
            onPressed: () => _openVoiceFlow(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.mic_rounded),
            label: Text(l10n.onboardingTryVoiceButton),
          ).animate().fadeIn(duration: 300.ms, delay: 180.ms),
          const SizedBox(height: 12),

          TextButton(
            onPressed: onComplete,
            child: Text(l10n.onboardingSkipVoiceButton),
          ).animate().fadeIn(duration: 300.ms, delay: 220.ms),
        ],
      ),
    );
  }
}
