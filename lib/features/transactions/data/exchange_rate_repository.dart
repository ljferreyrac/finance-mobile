import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
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
      throw mapDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
