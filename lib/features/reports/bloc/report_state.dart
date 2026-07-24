import 'package:equatable/equatable.dart';

import '../models/monthly_report_model.dart';
import '../models/yearly_report_model.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class MonthlyReportLoaded extends ReportState {
  const MonthlyReportLoaded(this.report);

  final MonthlyReport report;

  @override
  List<Object?> get props => [report];
}

class YearlyReportLoaded extends ReportState {
  const YearlyReportLoaded(this.report);

  final YearlyReport report;

  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  const ReportError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
