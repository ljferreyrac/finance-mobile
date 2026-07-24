import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/transaction_model.dart';

/// Raw HTTP calls against the transactions API endpoints.
///
/// Throws [DioException] on non-2xx responses. The repository layer
/// converts those into typed [Failure] objects.
class TransactionApiService {
  TransactionApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/transactions';

  Future<PagedTransactionsModel> getTransactions({
    String? type,
    String? accountId,
    String? categoryId,
    String? tagId,
    String? from,
    String? to,
    String? currency,
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      if (type != null) 'type': type,
      if (accountId != null) 'accountId': accountId,
      if (categoryId != null) 'categoryId': categoryId,
      if (tagId != null) 'tagId': tagId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (currency != null) 'currency': currency,
      if (cursor != null) 'cursor': cursor,
      'limit': limit,
    };
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: params,
    );
    return PagedTransactionsModel.fromJson(response.data!);
  }

  Future<TransactionModel> createTransaction(
    Map<String, dynamic> body,
  ) async {
    // Ensure tagIds key is always present so the API can process it.
    final payload = <String, dynamic>{
      ...body,
      if (!body.containsKey('tagIds')) 'tagIds': <String>[],
    };
    final response =
        await _dio.post<Map<String, dynamic>>(_path, data: payload);
    return TransactionModel.fromJson(response.data!);
  }

  Future<TransactionModel> getTransaction(String id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('$_path/$id');
    return TransactionModel.fromJson(response.data!);
  }

  Future<TransactionModel> updateTransaction(
    String id,
    Map<String, dynamic> body,
  ) async {
    // Ensure tagIds key is always present so the API can process it.
    final payload = <String, dynamic>{
      ...body,
      if (!body.containsKey('tagIds')) 'tagIds': <String>[],
    };
    final response =
        await _dio.put<Map<String, dynamic>>('$_path/$id', data: payload);
    return TransactionModel.fromJson(response.data!);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('$_path/$id');
  }
}
