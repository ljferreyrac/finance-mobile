// JSON field names must match the API contract in docs/features/reports.md exactly.

class MonthlyReport {
  const MonthlyReport({
    required this.period,
    required this.summary,
    required this.vsLastMonth,
    required this.byCategory,
    required this.byWeek,
    required this.topMerchants,
  });

  final ReportPeriod period;
  final MonthlySummary summary;
  final VsLastMonth vsLastMonth;
  final List<CategoryBreakdown> byCategory;
  final List<WeekBreakdown> byWeek;
  final List<MerchantSummary> topMerchants;

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      period: ReportPeriod.fromJson(json['period'] as Map<String, dynamic>),
      summary: MonthlySummary.fromJson(json['summary'] as Map<String, dynamic>),
      vsLastMonth:
          VsLastMonth.fromJson(json['vsLastMonth'] as Map<String, dynamic>),
      byCategory: (json['byCategory'] as List<dynamic>)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      byWeek: (json['byWeek'] as List<dynamic>)
          .map((e) => WeekBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMerchants: (json['topMerchants'] as List<dynamic>)
          .map((e) => MerchantSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReportPeriod {
  const ReportPeriod({
    required this.year,
    required this.month,
    required this.label,
  });

  final int year;
  final int month;
  final String label;

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      year: json['year'] as int,
      month: json['month'] as int,
      label: json['label'] as String,
    );
  }
}

class MonthlySummary {
  const MonthlySummary({
    required this.totalAmount,
    required this.currency,
    required this.transactionCount,
    required this.dailyAverage,
    required this.totalIncome,
    required this.incomeCount,
    required this.netBalance,
  });

  final double totalAmount;
  final String currency;
  final int transactionCount;
  final double dailyAverage;

  final double totalIncome;
  final int incomeCount;

  /// netBalance = totalIncome - totalAmount (expenses).
  final double netBalance;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionCount: json['transactionCount'] as int,
      dailyAverage: (json['dailyAverage'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num? ?? 0).toDouble(),
      incomeCount: json['incomeCount'] as int? ?? 0,
      netBalance: (json['netBalance'] as num? ?? 0).toDouble(),
    );
  }
}

class VsLastMonth {
  const VsLastMonth({
    required this.previousAmount,
    required this.changeAmount,
    required this.changePercent,
    required this.trend,
  });

  final double previousAmount;
  final double changeAmount;
  final double changePercent;

  /// One of: "UP", "DOWN", "FLAT"
  final String trend;

  factory VsLastMonth.fromJson(Map<String, dynamic> json) {
    return VsLastMonth(
      previousAmount: (json['previousAmount'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.category,
    required this.label,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  final String category;
  final String label;
  final double amount;
  final int count;
  final double percentage;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class WeekBreakdown {
  const WeekBreakdown({
    required this.weekNumber,
    required this.label,
    required this.amount,
    required this.count,
  });

  final int weekNumber;
  final String label;
  final double amount;
  final int count;

  factory WeekBreakdown.fromJson(Map<String, dynamic> json) {
    return WeekBreakdown(
      weekNumber: json['weekNumber'] as int,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class MerchantSummary {
  const MerchantSummary({
    required this.name,
    required this.amount,
    required this.count,
  });

  final String name;
  final double amount;
  final int count;

  factory MerchantSummary.fromJson(Map<String, dynamic> json) {
    return MerchantSummary(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}
