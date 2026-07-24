import 'package:equatable/equatable.dart';

import '../models/transaction_model.dart';
import 'transaction_event.dart';

/// States emitted by [TransactionBloc].
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// First page is being fetched (list is empty or being reset).
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Transaction list has been loaded; may or may not have more pages.
class TransactionLoaded extends TransactionState {
  const TransactionLoaded({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    required this.activeFilter,
  });

  final List<TransactionModel> items;
  final bool hasMore;
  final String? nextCursor;
  final TransactionFilter activeFilter;

  @override
  List<Object?> get props => [items, hasMore, nextCursor, activeFilter];
}

class TransactionLoadingMore extends TransactionState {
  const TransactionLoadingMore({
    required this.items,
    required this.activeFilter,
  });

  final List<TransactionModel> items;
  final TransactionFilter activeFilter;

  @override
  List<Object?> get props => [items, activeFilter];
}

class TransactionOperationSuccess extends TransactionState {
  const TransactionOperationSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  const TransactionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
