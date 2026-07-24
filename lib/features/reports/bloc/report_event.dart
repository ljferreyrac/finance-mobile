import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonthlyReport extends ReportEvent {
  const LoadMonthlyReport({
    required this.year,
    required this.month,
    required this.currency,
  });

  final int year;
  final int month;
  final String currency;

  @override
  List<Object?> get props => [year, month, currency];
}

class LoadYearlyReport extends ReportEvent {
  const LoadYearlyReport({
    required this.year,
    required this.currency,
  });

  final int year;
  final String currency;

  @override
  List<Object?> get props => [year, currency];
}

/// Goes to the previous period. On the monthly tab, January wraps to
/// December of the prior year.
class PreviousPeriod extends ReportEvent {
  const PreviousPeriod();
}

/// Advances the period, capped at the current real-world month/year.
class NextPeriod extends ReportEvent {
  const NextPeriod();
}

class SwitchToMonthly extends ReportEvent {
  const SwitchToMonthly();
}

class SwitchToYearly extends ReportEvent {
  const SwitchToYearly();
}

/// Null fields clear that filter dimension; the bloc reloads the current
/// period immediately so results reflect the change.
class ApplyReportFilter extends ReportEvent {
  const ApplyReportFilter({
    this.accountId,
    this.categoryId,
    this.tagId,
  });

  final String? accountId;
  final String? categoryId;
  final String? tagId;

  @override
  List<Object?> get props => [accountId, categoryId, tagId];
}
