import 'package:dio/dio.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
import '../models/account_model.dart';
import 'account_api_service.dart';

abstract class AccountRepository {
  Future<List<AccountModel>> getAccounts();
  Future<NetWorthModel> getNetWorth({bool includeDebt = true});
  Future<AccountModel> createAccount(Map<String, dynamic> body);
  Future<AccountModel> updateAccount(String id, Map<String, dynamic> body);
  Future<void> deleteAccount(String id);
  Future<AccountModel> setDefaultAccount(String id);
}

/// Default implementation backed by [AccountApiService].
///
/// All [DioException]s are caught and re-thrown as typed [Failure] subclasses
/// so that BLoC handlers never import Dio directly.
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({AccountApiService? apiService})
      : _api = apiService ?? AccountApiService();

  final AccountApiService _api;

  @override
  Future<List<AccountModel>> getAccounts() => _run(() => _api.getAccounts());

  @override
  @override
  Future<NetWorthModel> getNetWorth({bool includeDebt = true}) =>
      _run(() => _api.getNetWorth(includeDebt: includeDebt));

  @override
  Future<AccountModel> createAccount(Map<String, dynamic> body) =>
      _run(() => _api.createAccount(body));

  @override
  Future<AccountModel> updateAccount(String id, Map<String, dynamic> body) =>
      _run(() => _api.updateAccount(id, body));

  @override
  Future<void> deleteAccount(String id) => _run(() => _api.deleteAccount(id));

  @override
  Future<AccountModel> setDefaultAccount(String id) =>
      _run(() => _api.setDefaultAccount(id));

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
