import 'package:equatable/equatable.dart';

import '../models/transaction_model.dart';

/// Filter parameters for the transaction list.
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.type,
    this.accountId,
    this.categoryId,
    this.tagId,
    this.from,
    this.to,
    this.currency,
  });

  final TransactionType? type;
  final String? accountId;
  final String? categoryId;

  /// UUID of a tag to filter by. Null means no tag filter.
  final String? tagId;

  final DateTime? from;
  final DateTime? to;
  final String? currency;

  TransactionFilter copyWith({
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? tagId,
    DateTime? from,
    DateTime? to,
    String? currency,
    bool clearType = false,
    bool clearAccountId = false,
    bool clearCategoryId = false,
    bool clearTagId = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      tagId: clearTagId ? null : (tagId ?? this.tagId),
      from: from ?? this.from,
      to: to ?? this.to,
      currency: currency ?? this.currency,
    );
  }

  /// Used by the UI to show a badge count on the filter icon.
  int get activeDimensionCount =>
      (accountId != null ? 1 : 0) +
      (categoryId != null ? 1 : 0) +
      (tagId != null ? 1 : 0);

  @override
  List<Object?> get props =>
      [type, accountId, categoryId, tagId, from, to, currency];
}

/// Events dispatched to [TransactionBloc].
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions(this.filter);

  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Uses the cursor stored in the bloc; this event carries none itself.
class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

/// Reloads the first page while keeping the current filter.
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}

class ApplyFilter extends TransactionEvent {
  const ApplyFilter(this.filter);

  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}

class CreateTransaction extends TransactionEvent {
  const CreateTransaction(this.body);

  final Map<String, dynamic> body;

  @override
  List<Object?> get props => [body];
}

class UpdateTransaction extends TransactionEvent {
  const UpdateTransaction(this.id, this.body);

  final String id;
  final Map<String, dynamic> body;

  @override
  List<Object?> get props => [id, body];
}

class DeleteTransaction extends TransactionEvent {
  const DeleteTransaction(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
