import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/monthly_report_model.dart';
import '../models/yearly_report_model.dart';

/// Raw HTTP calls against the reports API endpoints.
///
/// Throws [DioException] on non-2xx responses; the repository is responsible
/// for converting those into typed [Failure] objects.
class ReportApiService {
  ReportApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _monthlyPath = '/reports/monthly';
  static const String _yearlyPath = '/reports/yearly';

  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _monthlyPath,
      queryParameters: {
        'year': year,
        'month': month,
        'currency': currency,
        if (accountId != null) 'accountId': accountId,
        if (categoryId != null) 'categoryId': categoryId,
        if (tagId != null) 'tagId': tagId,
      },
    );
    return MonthlyReport.fromJson(response.data!);
  }

  Future<YearlyReport> getYearlyReport({
    required int year,
    required String currency,
    String? accountId,
    String? categoryId,
    String? tagId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _yearlyPath,
      queryParameters: {
        'year': year,
        'currency': currency,
        if (accountId != null) 'accountId': accountId,
        if (categoryId != null) 'categoryId': categoryId,
        if (tagId != null) 'tagId': tagId,
      },
    );
    return YearlyReport.fromJson(response.data!);
  }
}
