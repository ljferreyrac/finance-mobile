import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../accounts/models/account_model.dart';
import '../../categories/models/category_model.dart';
import 'tag_model.dart';

enum TransactionType { expense, income, transfer }

extension TransactionTypeExt on TransactionType {
  /// Non-localized label (kept for backwards compatibility in non-UI code).
  String get label {
    switch (this) {
      case TransactionType.expense:
        return 'Gasto';
      case TransactionType.income:
        return 'Ingreso';
      case TransactionType.transfer:
        return 'Transferencia';
    }
  }

  /// Localized label for use in UI widgets that have a [BuildContext].
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case TransactionType.expense:
        return l10n.transactionTypeExpense;
      case TransactionType.income:
        return l10n.transactionTypeIncome;
      case TransactionType.transfer:
        return l10n.transactionTypeTransfer;
    }
  }

  static TransactionType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return TransactionType.income;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'EXPENSE':
      default:
        return TransactionType.expense;
    }
  }

  String toJson() {
    switch (this) {
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }
}

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.amountLocal,
    this.account,
    this.fromAccount,
    this.toAccount,
    this.category,
    this.merchant,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    this.tags = const [],
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String currency;

  /// Amount converted to the account's currency, only set when [currency]
  /// differs from it (e.g. a USD expense on a PEN card also carries this).
  final double? amountLocal;

  /// Populated for EXPENSE and INCOME types.
  final AccountSummary? account;

  /// Populated for TRANSFER type (source account).
  final AccountSummary? fromAccount;

  /// Populated for TRANSFER type (destination account).
  final AccountSummary? toAccount;

  /// Required for EXPENSE, optional for INCOME.
  final CategorySummary? category;
  final String? merchant;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;

  final List<TagModel> tags;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionTypeExt.fromJson(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      amountLocal: json['amountLocal'] != null
          ? (json['amountLocal'] as num).toDouble()
          : null,
      account: json['account'] != null
          ? AccountSummary.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      fromAccount: json['fromAccount'] != null
          ? AccountSummary.fromJson(
              json['fromAccount'] as Map<String, dynamic>)
          : null,
      toAccount: json['toAccount'] != null
          ? AccountSummary.fromJson(json['toAccount'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? CategorySummary.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      merchant: json['merchant'] as String?,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(TagModel.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
        'amount': amount,
        'currency': currency,
        if (amountLocal != null) 'amountLocal': amountLocal,
        'transactionDate': transactionDate.toIso8601String().split('T').first,
        if (merchant != null) 'merchant': merchant,
        if (description != null) 'description': description,
        'tagIds': tags.map((t) => t.id).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        currency,
        amountLocal,
        account,
        fromAccount,
        toAccount,
        category,
        merchant,
        description,
        transactionDate,
        createdAt,
        tags,
      ];
}

class PagedTransactionsModel extends Equatable {
  const PagedTransactionsModel({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  final List<TransactionModel> items;
  final String? nextCursor;
  final bool hasMore;

  factory PagedTransactionsModel.fromJson(Map<String, dynamic> json) {
    return PagedTransactionsModel(
      items: (json['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(TransactionModel.fromJson)
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}
