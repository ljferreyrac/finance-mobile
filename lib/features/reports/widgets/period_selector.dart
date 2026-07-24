import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

/// Disables the next button when [isAtCurrentPeriod] to prevent navigating
/// beyond the current calendar period.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.label,
    required this.isAtCurrentPeriod,
    required this.onPrevious,
    required this.onNext,
  });

  /// Display label, e.g. "Marzo 2026" or "2026".
  final String label;

  final bool isAtCurrentPeriod;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: AppLocalizations.of(context)!.previousPeriod,
            color: colorScheme.primary,
            onPressed: onPrevious,
          ),
          Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isAtCurrentPeriod
                  ? colorScheme.onSurface.withValues(alpha: 0.3)
                  : colorScheme.primary,
            ),
            tooltip: AppLocalizations.of(context)!.nextPeriod,
            onPressed: isAtCurrentPeriod ? null : onNext,
          ),
        ],
      ),
    );
  }
}
