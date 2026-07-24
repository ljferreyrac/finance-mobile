import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/failure.dart';
import '../data/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

enum _ActiveTab { monthly, yearly }

/// Manages report loading, period navigation, and tab switching.
///
/// Keeps the active period/tab as internal state so [PreviousPeriod] and
/// [NextPeriod] know where to navigate without the UI passing values.
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc({required ReportRepository repository})
      : _repository = repository,
        super(const ReportInitial()) {
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;

    on<LoadMonthlyReport>(_onLoadMonthlyReport);
    on<LoadYearlyReport>(_onLoadYearlyReport);
    on<PreviousPeriod>(_onPreviousPeriod);
    on<NextPeriod>(_onNextPeriod);
    on<SwitchToMonthly>(_onSwitchToMonthly);
    on<SwitchToYearly>(_onSwitchToYearly);
    on<ApplyReportFilter>(_onApplyReportFilter);
  }

  final ReportRepository _repository;

  _ActiveTab _activeTab = _ActiveTab.monthly;
  late int _currentYear;
  late int _currentMonth;
  String _currency = 'PEN';
  String? _accountId;
  String? _categoryId;
  String? _tagId;

  Future<void> _onLoadMonthlyReport(
    LoadMonthlyReport event,
    Emitter<ReportState> emit,
  ) async {
    _activeTab = _ActiveTab.monthly;
    _currentYear = event.year;
    _currentMonth = event.month;
    _currency = event.currency;
    emit(const ReportLoading());
    try {
      final report = await _repository.getMonthlyReport(
        year: event.year,
        month: event.month,
        currency: event.currency,
        accountId: _accountId,
        categoryId: _categoryId,
        tagId: _tagId,
      );
      emit(MonthlyReportLoaded(report));
    } on Failure catch (f) {
      emit(ReportError(f.message));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onLoadYearlyReport(
    LoadYearlyReport event,
    Emitter<ReportState> emit,
  ) async {
    _activeTab = _ActiveTab.yearly;
    _currentYear = event.year;
    _currency = event.currency;
    emit(const ReportLoading());
    try {
      final report = await _repository.getYearlyReport(
        year: event.year,
        currency: event.currency,
        accountId: _accountId,
        categoryId: _categoryId,
        tagId: _tagId,
      );
      emit(YearlyReportLoaded(report));
    } on Failure catch (f) {
      emit(ReportError(f.message));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onPreviousPeriod(
    PreviousPeriod event,
    Emitter<ReportState> emit,
  ) async {
    if (_activeTab == _ActiveTab.monthly) {
      // Decrement month, wrapping January to December of the prior year.
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear -= 1;
      } else {
        _currentMonth -= 1;
      }
      add(LoadMonthlyReport(
        year: _currentYear,
        month: _currentMonth,
        currency: _currency,
      ));
    } else {
      _currentYear -= 1;
      add(LoadYearlyReport(year: _currentYear, currency: _currency));
    }
  }

  Future<void> _onNextPeriod(
    NextPeriod event,
    Emitter<ReportState> emit,
  ) async {
    final now = DateTime.now();

    if (_activeTab == _ActiveTab.monthly) {
      // Do not advance beyond the current real-world month.
      final isCurrentMonth =
          _currentYear == now.year && _currentMonth == now.month;
      if (isCurrentMonth) return;

      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear += 1;
      } else {
        _currentMonth += 1;
      }
      add(LoadMonthlyReport(
        year: _currentYear,
        month: _currentMonth,
        currency: _currency,
      ));
    } else {
      // Do not advance beyond the current real-world year.
      if (_currentYear >= now.year) return;
      _currentYear += 1;
      add(LoadYearlyReport(year: _currentYear, currency: _currency));
    }
  }

  Future<void> _onSwitchToMonthly(
    SwitchToMonthly event,
    Emitter<ReportState> emit,
  ) async {
    final now = DateTime.now();
    _activeTab = _ActiveTab.monthly;
    _currentYear = now.year;
    _currentMonth = now.month;
    add(LoadMonthlyReport(
      year: _currentYear,
      month: _currentMonth,
      currency: _currency,
    ));
  }

  Future<void> _onSwitchToYearly(
    SwitchToYearly event,
    Emitter<ReportState> emit,
  ) async {
    final now = DateTime.now();
    _activeTab = _ActiveTab.yearly;
    _currentYear = now.year;
    add(LoadYearlyReport(year: _currentYear, currency: _currency));
  }

  Future<void> _onApplyReportFilter(
    ApplyReportFilter event,
    Emitter<ReportState> emit,
  ) async {
    _accountId = event.accountId;
    _categoryId = event.categoryId;
    _tagId = event.tagId;

    // Reload the currently active period with the new filter values.
    if (_activeTab == _ActiveTab.monthly) {
      add(LoadMonthlyReport(
        year: _currentYear,
        month: _currentMonth,
        currency: _currency,
      ));
    } else {
      add(LoadYearlyReport(year: _currentYear, currency: _currency));
    }
  }

  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;
  String get currency => _currency;
  String? get currentAccountId => _accountId;
  String? get currentCategoryId => _categoryId;
  String? get currentTagId => _tagId;

  /// Count of active filter dimensions (0-3).
  int get activeFilterCount =>
      (_accountId != null ? 1 : 0) +
      (_categoryId != null ? 1 : 0) +
      (_tagId != null ? 1 : 0);

  /// Whether the next-period button should be disabled.
  bool get isAtCurrentPeriod {
    final now = DateTime.now();
    if (_activeTab == _ActiveTab.monthly) {
      return _currentYear == now.year && _currentMonth == now.month;
    }
    return _currentYear >= now.year;
  }
}
