import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/yearly_report_model.dart';

/// Always renders all 12 months; months missing from [byMonth] show as
/// 0-height bars instead of being skipped.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.byMonth,
    required this.currency,
  });

  final List<MonthBreakdown> byMonth;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final amounts = _buildFullYearAmounts();
    final hasData = amounts.any((a) => a > 0);

    if (!hasData) {
      return _emptyState(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxY = amounts.fold(0.0, (a, b) => a > b ? a : b);
    final yInterval = maxY > 0 ? (maxY * 1.2 / 4).ceilToDouble() : 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.byMonth,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final symbol = currency == 'USD' ? '\$' : 'S/';
                      return BarTooltipItem(
                        '$symbol ${amounts[groupIndex].toStringAsFixed(2)}',
                        TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 12) {
                          return const SizedBox.shrink();
                        }
                        final locale = Localizations.localeOf(context).toString();
                        final monthLabel = DateFormat('MMM', locale)
                            .format(DateTime(2000, index + 1));
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            monthLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        final symbol = currency == 'USD' ? '\$' : 'S/';
                        return Text(
                          '$symbol${_compactAmount(value)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: amounts[index],
                        color: colorScheme.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indexed 0 = January; months absent from [byMonth] default to 0.
  List<double> _buildFullYearAmounts() {
    final amounts = List.filled(12, 0.0);
    for (final entry in byMonth) {
      final index = entry.month - 1;
      if (index >= 0 && index < 12) {
        amounts[index] = entry.amount;
      }
    }
    return amounts;
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noDataPeriod,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  String _compactAmount(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
