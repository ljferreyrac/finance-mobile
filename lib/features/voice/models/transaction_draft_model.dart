import 'package:equatable/equatable.dart';

import '../../transactions/models/tag_model.dart';

/// A single transaction candidate extracted from a voice transcript by the
/// backend NLP pipeline.
///
/// The backend returns a list of these when the user submits a transcript.
/// All fields except [type], [amount], [currency] and [transactionDate] are
/// nullable because the NLP may not always extract them.
class TransactionDraftModel extends Equatable {
  const TransactionDraftModel({
    required this.type,
    required this.amount,
    required this.currency,
    this.categoryId,
    this.categoryName,
    this.accountId,
    this.accountName,
    this.merchant,
    this.description,
    required this.transactionDate,
    required this.confidence,
    this.included = true,
    this.tags = const [],
  });

  /// "EXPENSE", "INCOME" or "TRANSFER".
  final String type;

  final double amount;

  /// "PEN" or "USD".
  final String currency;

  final String? categoryId;
  final String? categoryName;
  final String? accountId;
  final String? accountName;
  final String? merchant;
  final String? description;
  final DateTime transactionDate;

  /// 0.0 to 1.0. Values below 0.7 are shown with a warning indicator.
  final double confidence;

  /// Whether the user wants to include this draft when confirming.
  final bool included;

  /// Tags resolved from the AI-returned tag IDs.
  /// Stubs (name == '') are enriched by the BLoC after loading available tags.
  final List<TagModel> tags;

  factory TransactionDraftModel.fromJson(Map<String, dynamic> json) {
    return TransactionDraftModel(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      merchant: json['merchant'] as String?,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      tags: (json['tagIds'] as List<dynamic>? ?? [])
          .map((id) => TagModel(id: id as String, name: ''))
          .toList(),
    );
  }

  /// Converts this draft to the body expected by POST /api/v1/transactions.
  Map<String, dynamic> toCreateBody() => {
        'type': type,
        'amount': amount,
        'currency': currency,
        if (categoryId != null) 'categoryId': categoryId,
        if (accountId != null) 'accountId': accountId,
        if (merchant != null) 'merchant': merchant,
        if (description != null) 'description': description,
        'transactionDate':
            transactionDate.toIso8601String().split('T').first,
        'tagIds': tags.map((t) => t.id).toList(),
      };

  TransactionDraftModel copyWith({
    String? type,
    double? amount,
    String? currency,
    String? categoryId,
    bool clearCategoryId = false,
    String? categoryName,
    bool clearCategoryName = false,
    String? accountId,
    bool clearAccountId = false,
    String? accountName,
    bool clearAccountName = false,
    String? merchant,
    bool clearMerchant = false,
    String? description,
    bool clearDescription = false,
    DateTime? transactionDate,
    double? confidence,
    bool? included,
    List<TagModel>? tags,
  }) {
    return TransactionDraftModel(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryName:
          clearCategoryName ? null : (categoryName ?? this.categoryName),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      accountName: clearAccountName ? null : (accountName ?? this.accountName),
      merchant: clearMerchant ? null : (merchant ?? this.merchant),
      description: clearDescription ? null : (description ?? this.description),
      transactionDate: transactionDate ?? this.transactionDate,
      confidence: confidence ?? this.confidence,
      included: included ?? this.included,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        type,
        amount,
        currency,
        categoryId,
        categoryName,
        accountId,
        accountName,
        merchant,
        description,
        transactionDate,
        confidence,
        included,
        tags,
      ];
}
