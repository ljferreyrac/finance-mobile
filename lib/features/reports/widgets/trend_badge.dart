import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../../shared/utils/currency_formatter.dart';

/// Colored badge for expense trend vs the previous period: green for "UP",
/// red for "DOWN", grey for "FLAT" or any unrecognized value.
class TrendBadge extends StatelessWidget {
  const TrendBadge({
    super.key,
    required this.trend,
    required this.changePercent,
    required this.previousAmount,
    required this.currency,
  });

  /// One of: "UP", "DOWN", "FLAT"
  final String trend;
  final double changePercent;
  final double previousAmount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = _trendConfig(trend);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: config.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(config.icon, size: 16, color: config.foreground),
                const SizedBox(width: 4),
                Text(
                  '${changePercent.abs().toStringAsFixed(1)}%',
                  style: textTheme.labelMedium?.copyWith(
                    color: config.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.vsLastMonth(
                CurrencyFormatter.format(previousAmount, currency)),
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  _TrendConfig _trendConfig(String trend) {
    switch (trend.toUpperCase()) {
      case 'UP':
        return const _TrendConfig(
          icon: Icons.arrow_upward,
          background: Color(0xFFDCFCE7),
          foreground: Color(0xFF166534),
        );
      case 'DOWN':
        return const _TrendConfig(
          icon: Icons.arrow_downward,
          background: Color(0xFFFEE2E2),
          foreground: Color(0xFF991B1B),
        );
      default:
        return const _TrendConfig(
          icon: Icons.remove,
          background: Color(0xFFF3F4F6),
          foreground: Color(0xFF6B7280),
        );
    }
  }
}

class _TrendConfig {
  const _TrendConfig({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}
