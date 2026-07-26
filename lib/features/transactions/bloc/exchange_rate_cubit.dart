import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/exchange_rate_repository.dart';
import '../models/exchange_rate_model.dart';

/// Fetches and caches today's exchange rate for the transaction form's
/// cross-currency prefill.
///
/// Scoped to a single [TransactionFormScreen] instance rather than the
/// shared [TransactionBloc], since it has nothing to do with the transaction
/// list state that bloc otherwise manages.
class ExchangeRateCubit extends Cubit<ExchangeRateModel?> {
  ExchangeRateCubit({required ExchangeRateRepository repository})
      : _repository = repository,
        super(null);

  final ExchangeRateRepository _repository;

  /// No-ops once a rate has already been loaded; the rate does not change
  /// within a single form session.
  Future<void> loadToday() async {
    if (state != null) return;
    try {
      final rate = await _repository.getToday();
      emit(rate);
    } catch (_) {
      // Non-fatal: the form field stays empty, user enters the value manually.
    }
  }
}
