import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/account_model.dart';

/// Raw HTTP calls against the accounts API endpoints.
///
/// Throws [DioException] on non-2xx responses. The repository layer
/// converts those into typed [Failure] objects.
class AccountApiService {
  AccountApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/accounts';

  Future<List<AccountModel>> getAccounts() async {
    final response = await _dio.get<List<dynamic>>(_path);
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(AccountModel.fromJson)
        .toList();
  }

  Future<NetWorthModel> getNetWorth({bool includeDebt = true}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_path/net-worth',
      queryParameters: {'includeDebt': includeDebt},
    );
    return NetWorthModel.fromJson(response.data!);
  }

  Future<AccountModel> createAccount(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(_path, data: body);
    return AccountModel.fromJson(response.data!);
  }

  Future<AccountModel> updateAccount(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response =
        await _dio.put<Map<String, dynamic>>('$_path/$id', data: body);
    return AccountModel.fromJson(response.data!);
  }

  Future<void> deleteAccount(String id) async {
    await _dio.delete('$_path/$id');
  }

  Future<AccountModel> setDefaultAccount(String id) async {
    final response =
        await _dio.patch<Map<String, dynamic>>('$_path/$id/default');
    return AccountModel.fromJson(response.data!);
  }
}
