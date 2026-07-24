import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/failure.dart';
import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// Manages the transaction list with cursor-based pagination.
///
/// - [LoadTransactions] / [ApplyFilter] / [RefreshTransactions] reset the list
///   and load the first page.
/// - [LoadMoreTransactions] appends the next page using the stored cursor.
/// - Mutation events ([CreateTransaction], [UpdateTransaction],
///   [DeleteTransaction]) emit [TransactionOperationSuccess] on success,
///   which the UI screen listens to in order to refresh the list or navigate.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<RefreshTransactions>(_onRefresh);
    on<ApplyFilter>(_onApplyFilter);
    on<LoadMoreTransactions>(_onLoadMore);
    on<CreateTransaction>(_onCreate);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
  }

  final TransactionRepository _repository;

  // Persisted across events so refresh/load-more can reuse the last filter.
  TransactionFilter _activeFilter = const TransactionFilter();

  Future<void> _onLoad(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    _activeFilter = event.filter;
    emit(const TransactionLoading());
    try {
      final page = await _fetch(cursor: null);
      emit(TransactionLoaded(
        items: page.items,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        activeFilter: _activeFilter,
      ));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final page = await _fetch(cursor: null);
      emit(TransactionLoaded(
        items: page.items,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        activeFilter: _activeFilter,
      ));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<TransactionState> emit,
  ) async {
    _activeFilter = event.filter;
    emit(const TransactionLoading());
    try {
      final page = await _fetch(cursor: null);
      emit(TransactionLoaded(
        items: page.items,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        activeFilter: _activeFilter,
      ));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransactionLoaded) return;
    if (!current.hasMore || current.nextCursor == null) return;

    emit(TransactionLoadingMore(
      items: current.items,
      activeFilter: _activeFilter,
    ));
    try {
      final page = await _fetch(cursor: current.nextCursor);
      emit(TransactionLoaded(
        items: [...current.items, ...page.items],
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        activeFilter: _activeFilter,
      ));
    } on Failure catch (f) {
      // Keep the existing page visible instead of clearing it on error.
      emit(TransactionLoaded(
        items: current.items,
        hasMore: current.hasMore,
        nextCursor: current.nextCursor,
        activeFilter: _activeFilter,
      ));
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionLoaded(
        items: current.items,
        hasMore: current.hasMore,
        nextCursor: current.nextCursor,
        activeFilter: _activeFilter,
      ));
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.createTransaction(event.body);
      emit(const TransactionOperationSuccess(message: 'Transacción creada'));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.updateTransaction(event.id, event.body);
      emit(const TransactionOperationSuccess(
          message: 'Transacción actualizada'));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.id);
      emit(const TransactionOperationSuccess(message: 'Transacción eliminada'));
    } on Failure catch (f) {
      emit(TransactionError(f.message));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<PagedTransactionsModel> _fetch({String? cursor}) {
    return _repository.getTransactions(
      type: _activeFilter.type?.toJson(),
      accountId: _activeFilter.accountId,
      categoryId: _activeFilter.categoryId,
      tagId: _activeFilter.tagId,
      from: _activeFilter.from?.toIso8601String().split('T').first,
      to: _activeFilter.to?.toIso8601String().split('T').first,
      currency: _activeFilter.currency,
      cursor: cursor,
      limit: defaultPageSize,
    );
  }
}
