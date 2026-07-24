import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../../../shared/models/failure.dart';
import '../models/exchange_rate_model.dart';

/// Contract for exchange-rate data access.
abstract class ExchangeRateRepository {
  Future<ExchangeRateModel> getToday();
}

/// Default implementation that fetches today's rate from
/// `GET /api/v1/exchange-rates/today`.
///
/// [DioException]s are mapped to typed [Failure] subclasses so callers never
/// need to import Dio directly.
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/exchange-rates/today';

  @override
  Future<ExchangeRateModel> getToday() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_path);
      return ExchangeRateModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) return const UnauthorizedFailure();
    if (status == 404) return const NotFoundFailure();
    final body = e.response?.data;
    final message = (body is Map)
        ? ((body['detail'] ?? body['message']) as String? ??
            e.message ??
            'Error del servidor')
        : (e.message ?? 'Error del servidor');
    return ServerFailure(message, statusCode: status);
  }
}
