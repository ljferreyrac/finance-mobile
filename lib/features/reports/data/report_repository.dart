import 'package:dio/dio.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
import '../models/monthly_report_model.dart';
import '../models/yearly_report_model.dart';
import 'report_api_service.dart';

abstract class ReportRepository {
  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  });

  Future<YearlyReport> getYearlyReport({
    required int year,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  });
}

/// Default implementation backed by [ReportApiService].
///
/// All [DioException]s are caught here and re-thrown as typed [Failure]
/// subclasses so that BLoC handlers never need to import Dio directly.
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({ReportApiService? apiService})
      : _api = apiService ?? ReportApiService();

  final ReportApiService _api;

  @override
  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  }) =>
      _run(
        () => _api.getMonthlyReport(
          year: year,
          month: month,
          currency: currency,
          accountId: accountId,
          categoryId: categoryId,
          tagId: tagId,
        ),
      );

  @override
  Future<YearlyReport> getYearlyReport({
    required int year,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  }) =>
      _run(
        () => _api.getYearlyReport(
          year: year,
          currency: currency,
          accountId: accountId,
          categoryId: categoryId,
          tagId: tagId,
        ),
      );

  /// Wraps [action] and maps [DioException] to a typed [Failure].
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
