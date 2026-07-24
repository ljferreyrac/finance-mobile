import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Segmented progress bar that shows onboarding progress.
///
/// Active segments are teal-400; upcoming segments are neutral-200.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// Zero-indexed current step.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i <= currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 4,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.teal400 : AppColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate(key: ValueKey(isActive)).fadeIn(duration: 200.ms),
        );
      }),
    );
  }
}
