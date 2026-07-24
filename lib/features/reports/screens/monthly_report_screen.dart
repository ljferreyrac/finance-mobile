import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/active_report_filters_row.dart';
import '../widgets/category_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/summary_card.dart';
import '../widgets/top_merchants_list.dart';
import '../widgets/trend_badge.dart';
import '../widgets/weekly_bar_chart.dart';

/// Requires [ReportBloc] above it in the tree (provided by [ReportsShellScreen]).
class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

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
            onRetry: () => context.read<ReportBloc>().add(const SwitchToMonthly()),
          );
        }

        if (state is MonthlyReportLoaded) {
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

  final MonthlyReportLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportBloc>();
    final report = state.report;

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const SwitchToMonthly()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeriodSelector(
              label: report.period.label,
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
              averageAmount: report.summary.dailyAverage,
              averageLabel: AppLocalizations.of(context)!.dailyAverage,
              totalIncome: report.summary.totalIncome,
              incomeCount: report.summary.incomeCount,
              netBalance: report.summary.netBalance,
            ),

            TrendBadge(
              trend: report.vsLastMonth.trend,
              changePercent: report.vsLastMonth.changePercent,
              previousAmount: report.vsLastMonth.previousAmount,
              currency: report.summary.currency,
            ),
            const SizedBox(height: 8),

            CategoryChart(categories: report.byCategory),
            const SizedBox(height: 8),

            WeeklyBarChart(
              weeks: report.byWeek,
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
