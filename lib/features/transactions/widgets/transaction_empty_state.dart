import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../models/transaction_model.dart';
import '../bloc/transaction_event.dart';

/// Empty state shown when the transaction list has no results.
///
/// The message and hint adapt to the currently active [TransactionFilter]
/// and use encouraging language rather than blank generic copy.
class TransactionEmptyState extends StatelessWidget {
  const TransactionEmptyState({
    super.key,
    required this.filter,
    this.onVoiceTap,
  });

  final TransactionFilter filter;

  /// Called when the voice CTA is tapped. The CTA (and the example phrase
  /// below it) only render when this is non-null AND the active filter is
  /// unfiltered or expense-only; a "no transfers found" state shouldn't
  /// prompt the user to say an expense.
  final VoidCallback? onVoiceTap;

  bool get _showVoiceCta =>
      filter.type == null || filter.type == TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final (icon, title, hint) = _content(context);
    final showCta = _showVoiceCta && onVoiceTap != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.teal50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.teal400),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (showCta) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onVoiceTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal400,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.mic_rounded),
                label: Text(l10n.voiceFabLabel),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.voiceIdleExample,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _content(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter.type) {
      case TransactionType.expense:
        return (
          Icons.receipt_long_outlined,
          l10n.emptyExpenses,
          l10n.emptyExpensesHint,
        );
      case TransactionType.income:
        return (
          Icons.south_east,
          l10n.emptyIncome,
          l10n.emptyIncomeHint,
        );
      case TransactionType.transfer:
        return (
          Icons.swap_horiz_outlined,
          l10n.emptyTransfers,
          l10n.emptyTransfersHint,
        );
      case null:
        return (
          Icons.receipt_long_outlined,
          l10n.emptyTransactions,
          l10n.emptyTransactionsHint,
        );
    }
  }
}
