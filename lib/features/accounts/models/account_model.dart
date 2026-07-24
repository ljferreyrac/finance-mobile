import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

enum AccountType { bank, creditCard, cash, wallet }

extension AccountTypeExt on AccountType {
  /// Non-localized label, kept for backwards compatibility in non-UI code.
  String get label {
    switch (this) {
      case AccountType.bank:
        return 'Cuenta bancaria';
      case AccountType.creditCard:
        return 'Tarjeta de credito';
      case AccountType.cash:
        return 'Efectivo';
      case AccountType.wallet:
        return 'Billetera digital';
    }
  }

  /// Localized label for use in UI widgets that have a [BuildContext].
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case AccountType.bank:
        return l10n.accountTypeBankLabel;
      case AccountType.creditCard:
        return l10n.accountTypeCreditCardLabel;
      case AccountType.cash:
        return l10n.accountTypeCashLabel;
      case AccountType.wallet:
        return l10n.accountTypeWalletLabel;
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.wallet:
        return Icons.smartphone_outlined;
    }
  }

  static AccountType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'BANK':
        return AccountType.bank;
      case 'CREDIT_CARD':
        return AccountType.creditCard;
      case 'CASH':
        return AccountType.cash;
      case 'WALLET':
        return AccountType.wallet;
      default:
        return AccountType.bank;
    }
  }

  String toJson() {
    switch (this) {
      case AccountType.bank:
        return 'BANK';
      case AccountType.creditCard:
        return 'CREDIT_CARD';
      case AccountType.cash:
        return 'CASH';
      case AccountType.wallet:
        return 'WALLET';
    }
  }
}

class AccountModel extends Equatable {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.bank,
    required this.currency,
    required this.currentBalance,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
    this.color,
    required this.isDefault,
    required this.isActive,
    required this.transactionCount,
    this.linkedAccountId,
  });

  final String id;
  final String name;
  final AccountType type;
  final String? bank;
  final String currency;
  final double currentBalance;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;

  /// Hex color string, e.g. "#16A34A". Null when the server sends no color.
  final String? color;
  final bool isDefault;
  final bool isActive;
  final int transactionCount;

  /// UUID of the parent bank account whose balance is adjusted when this
  /// wallet account is used in a transaction.
  final String? linkedAccountId;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountTypeExt.fromJson(json['type'] as String),
      bank: json['bank'] as String?,
      currency: json['currency'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      creditLimit: json['creditLimit'] != null
          ? (json['creditLimit'] as num).toDouble()
          : null,
      closingDay: json['closingDay'] as int?,
      dueDay: json['dueDay'] as int?,
      color: json['color'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      transactionCount: json['transactionCount'] as int? ?? 0,
      linkedAccountId: json['linkedAccountId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toJson(),
        if (bank != null) 'bank': bank,
        'currency': currency,
        'currentBalance': currentBalance,
        if (creditLimit != null) 'creditLimit': creditLimit,
        if (closingDay != null) 'closingDay': closingDay,
        if (dueDay != null) 'dueDay': dueDay,
        if (color != null) 'color': color,
        'isDefault': isDefault,
        'isActive': isActive,
        'transactionCount': transactionCount,
        if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
      };

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? bank,
    String? currency,
    double? currentBalance,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    String? color,
    bool? isDefault,
    bool? isActive,
    int? transactionCount,
    String? linkedAccountId,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      currency: currency ?? this.currency,
      currentBalance: currentBalance ?? this.currentBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      transactionCount: transactionCount ?? this.transactionCount,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        bank,
        currency,
        currentBalance,
        creditLimit,
        closingDay,
        dueDay,
        color,
        isDefault,
        isActive,
        transactionCount,
        linkedAccountId,
      ];
}

/// Lightweight account reference embedded inside transaction objects.
class AccountSummary extends Equatable {
  const AccountSummary({
    required this.id,
    required this.name,
    this.color,
    required this.type,
  });

  final String id;
  final String name;
  final String? color;
  final AccountType type;

  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    return AccountSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      type: AccountTypeExt.fromJson(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (color != null) 'color': color,
        'type': type.toJson(),
      };

  @override
  List<Object?> get props => [id, name, color, type];
}

/// Aggregated net worth across all user accounts.
class NetWorthModel extends Equatable {
  const NetWorthModel({
    required this.totalPEN,
    required this.totalUSD,
    required this.accounts,
  });

  final double totalPEN;
  final double totalUSD;
  final List<AccountModel> accounts;

  factory NetWorthModel.fromJson(Map<String, dynamic> json) {
    return NetWorthModel(
      totalPEN: (json['totalPEN'] as num).toDouble(),
      totalUSD: (json['totalUSD'] as num? ?? 0).toDouble(),
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AccountModel.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totalPEN, totalUSD, accounts];
}
