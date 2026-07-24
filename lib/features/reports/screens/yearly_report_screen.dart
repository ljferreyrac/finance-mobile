import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../../shared/utils/currency_formatter.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../models/yearly_report_model.dart';
import '../widgets/active_report_filters_row.dart';
import '../widgets/category_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/summary_card.dart';
import '../widgets/top_merchants_list.dart';

/// Requires [ReportBloc] above it in the tree (provided by [ReportsShellScreen]).
class YearlyReportScreen extends StatelessWidget {
  const YearlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<ReportBloc>().add(const SwitchToYearly()),
          );
        }

        if (state is YearlyReportLoaded) {
          return _LoadedView(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final YearlyReportLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportBloc>();
    final report = state.report;

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const SwitchToYearly()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeriodSelector(
              label: '${report.year}',
              isAtCurrentPeriod: bloc.isAtCurrentPeriod,
              onPrevious: () => bloc.add(const PreviousPeriod()),
              onNext: () => bloc.add(const NextPeriod()),
            ),

            const ActiveReportFiltersRow(),
            const SizedBox(height: 8),

            SummaryCard(
              totalAmount: report.summary.totalAmount,
              currency: report.summary.currency,
              transactionCount: report.summary.transactionCount,
              averageAmount: report.summary.monthlyAverage,
              averageLabel: AppLocalizations.of(context)!.monthlyAverage,
              totalIncome: report.summary.totalIncome,
              incomeCount: report.summary.incomeCount,
              netBalance: report.summary.netBalance,
            ),
            const SizedBox(height: 8),

            MonthlyBarChart(
              byMonth: report.byMonth,
              currency: report.summary.currency,
            ),
            const SizedBox(height: 8),

            CategoryChart(categories: report.byCategory),
            const SizedBox(height: 8),

            if (!report.highlights.isEmpty)
              _HighlightSection(
                highlights: report.highlights,
                currency: report.summary.currency,
              ),
            const SizedBox(height: 8),

            TopMerchantsList(
              merchants: report.topMerchants,
              currency: report.summary.currency,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HighlightSection extends StatelessWidget {
  const _HighlightSection({
    required this.highlights,
    required this.currency,
  });

  final YearlyHighlights highlights;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.yearHighlights,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (highlights.peakMonth != null)
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFF166534),
                    iconBackground: const Color(0xFFDCFCE7),
                    title: AppLocalizations.of(context)!.peakMonth,
                    subtitle: highlights.peakMonth!.label,
                    amount: CurrencyFormatter.format(
                      highlights.peakMonth!.amount,
                      currency,
                    ),
                  ),
                ),
              if (highlights.peakMonth != null && highlights.lowestMonth != null)
                const SizedBox(width: 8),
              if (highlights.lowestMonth != null)
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.trending_down,
                    iconColor: const Color(0xFF1E40AF),
                    iconBackground: const Color(0xFFDBEAFE),
                    title: AppLocalizations.of(context)!.lowestMonth,
                    subtitle: highlights.lowestMonth!.label,
                    amount: CurrencyFormatter.format(
                      highlights.lowestMonth!.amount,
                      currency,
                    ),
                  ),
                ),
              if (highlights.lowestMonth != null && highlights.topCategory != null)
                const SizedBox(width: 8),
              if (highlights.topCategory != null)
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.category_outlined,
                    iconColor: const Color(0xFF92400E),
                    iconBackground: const Color(0xFFFEF3C7),
                    title: AppLocalizations.of(context)!.topCategory,
                    subtitle: highlights.topCategory!.label,
                    amount: CurrencyFormatter.format(
                      highlights.topCategory!.amount,
                      currency,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
