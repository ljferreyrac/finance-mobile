// JSON field names must match the API contract in docs/features/reports.md exactly.

import 'monthly_report_model.dart';

class YearlyReport {
  const YearlyReport({
    required this.year,
    required this.summary,
    required this.byMonth,
    required this.byCategory,
    required this.topMerchants,
    required this.highlights,
  });

  final int year;
  final YearlySummary summary;
  final List<MonthBreakdown> byMonth;
  final List<CategoryBreakdown> byCategory;
  final List<MerchantSummary> topMerchants;
  final YearlyHighlights highlights;

  factory YearlyReport.fromJson(Map<String, dynamic> json) {
    return YearlyReport(
      year: json['year'] as int,
      summary:
          YearlySummary.fromJson(json['summary'] as Map<String, dynamic>),
      byMonth: (json['byMonth'] as List<dynamic>)
          .map((e) => MonthBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      byCategory: (json['byCategory'] as List<dynamic>)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMerchants: (json['topMerchants'] as List<dynamic>)
          .map((e) => MerchantSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      highlights:
          YearlyHighlights.fromJson(json['highlights'] as Map<String, dynamic>),
    );
  }
}

class YearlySummary {
  const YearlySummary({
    required this.totalAmount,
    required this.currency,
    required this.transactionCount,
    required this.monthlyAverage,
    required this.totalIncome,
    required this.incomeCount,
    required this.netBalance,
  });

  final double totalAmount;
  final String currency;
  final int transactionCount;
  final double monthlyAverage;

  final double totalIncome;
  final int incomeCount;

  /// netBalance = totalIncome - totalAmount (expenses).
  final double netBalance;

  factory YearlySummary.fromJson(Map<String, dynamic> json) {
    return YearlySummary(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionCount: json['transactionCount'] as int,
      monthlyAverage: (json['monthlyAverage'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num? ?? 0).toDouble(),
      incomeCount: json['incomeCount'] as int? ?? 0,
      netBalance: (json['netBalance'] as num? ?? 0).toDouble(),
    );
  }
}

class MonthBreakdown {
  const MonthBreakdown({
    required this.month,
    required this.label,
    required this.amount,
    required this.count,
  });

  final int month;
  final String label;
  final double amount;
  final int count;

  factory MonthBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthBreakdown(
      month: json['month'] as int,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class MonthHighlight {
  const MonthHighlight({
    required this.month,
    required this.label,
    required this.amount,
  });

  final int month;
  final String label;
  final double amount;

  factory MonthHighlight.fromJson(Map<String, dynamic> json) {
    return MonthHighlight(
      month: json['month'] as int,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class CategoryHighlight {
  const CategoryHighlight({
    required this.category,
    required this.label,
    required this.amount,
  });

  final String category;
  final String label;
  final double amount;

  factory CategoryHighlight.fromJson(Map<String, dynamic> json) {
    return CategoryHighlight(
      category: json['category'] as String,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class YearlyHighlights {
  const YearlyHighlights({
    this.peakMonth,
    this.lowestMonth,
    this.topCategory,
  });

  final MonthHighlight? peakMonth;
  final MonthHighlight? lowestMonth;
  final CategoryHighlight? topCategory;

  bool get isEmpty => peakMonth == null && lowestMonth == null && topCategory == null;

  factory YearlyHighlights.fromJson(Map<String, dynamic> json) {
    return YearlyHighlights(
      peakMonth: json['peakMonth'] == null
          ? null
          : MonthHighlight.fromJson(json['peakMonth'] as Map<String, dynamic>),
      lowestMonth: json['lowestMonth'] == null
          ? null
          : MonthHighlight.fromJson(json['lowestMonth'] as Map<String, dynamic>),
      topCategory: json['topCategory'] == null
          ? null
          : CategoryHighlight.fromJson(
              json['topCategory'] as Map<String, dynamic>),
    );
  }
}
