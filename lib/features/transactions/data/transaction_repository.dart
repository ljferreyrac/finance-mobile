import 'package:dio/dio.dart';

import '../../../shared/models/failure.dart';
import '../../../shared/utils/dio_error_mapper.dart';
import '../models/transaction_model.dart';
import 'transaction_api_service.dart';

/// Contract for transaction data access.
abstract class TransactionRepository {
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
  });
  Future<TransactionModel> createTransaction(Map<String, dynamic> body);
  Future<TransactionModel> getTransaction(String id);
  Future<TransactionModel> updateTransaction(
    String id,
    Map<String, dynamic> body,
  );
  Future<void> deleteTransaction(String id);
}

/// Default implementation backed by [TransactionApiService].
///
/// All [DioException]s are caught and re-thrown as typed [Failure] subclasses
/// so that BLoC handlers never import Dio directly.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({TransactionApiService? apiService})
      : _api = apiService ?? TransactionApiService();

  final TransactionApiService _api;

  @override
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
  }) =>
      _run(
        () => _api.getTransactions(
          type: type,
          accountId: accountId,
          categoryId: categoryId,
          tagId: tagId,
          from: from,
          to: to,
          currency: currency,
          cursor: cursor,
          limit: limit,
        ),
      );

  @override
  Future<TransactionModel> createTransaction(Map<String, dynamic> body) =>
      _run(() => _api.createTransaction(body));

  @override
  Future<TransactionModel> getTransaction(String id) =>
      _run(() => _api.getTransaction(id));

  @override
  Future<TransactionModel> updateTransaction(
    String id,
    Map<String, dynamic> body,
  ) =>
      _run(() => _api.updateTransaction(id, body));

  @override
  Future<void> deleteTransaction(String id) =>
      _run(() => _api.deleteTransaction(id));

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
