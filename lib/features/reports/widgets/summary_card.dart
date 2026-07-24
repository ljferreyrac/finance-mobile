import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../../shared/utils/currency_formatter.dart';

/// A card displaying the primary financial summary for a period.
///
/// Shows the total expenses in large bold text, plus income and net balance
/// rows below, and stat chips for transaction count and per-period average.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalAmount,
    required this.currency,
    required this.transactionCount,
    required this.averageAmount,
    required this.averageLabel,
    this.totalIncome = 0,
    this.incomeCount = 0,
    this.netBalance = 0,
  });

  final double totalAmount;
  final String currency;
  final int transactionCount;
  final double averageAmount;

  /// Label for the average line, e.g. "Promedio diario" or "Promedio mensual".
  final String averageLabel;

  /// Shown only when non-zero.
  final double totalIncome;
  final int incomeCount;

  /// netBalance = income - expenses for the period.
  final double netBalance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final netPrefix = netBalance >= 0 ? '+' : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.totalPeriod,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(totalAmount, currency),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  icon: Icons.receipt_long_outlined,
                  label: AppLocalizations.of(context)!.transactionCountLabel(transactionCount),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.trending_flat,
                  label:
                      '$averageLabel: ${CurrencyFormatter.format(averageAmount, currency)}',
                ),
              ],
            ),
            if (totalIncome != 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.south_east,
                          size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.incomeLabel(incomeCount),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(totalIncome, currency),
                    style: textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.balance,
                          size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.netBalance,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$netPrefix${CurrencyFormatter.format(netBalance, currency)}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
