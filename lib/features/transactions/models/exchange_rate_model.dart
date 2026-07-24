import 'package:equatable/equatable.dart';

/// Exchange rate snapshot returned by `GET /api/v1/exchange-rates/today`.
///
/// [buyRate]  - the rate at which the bank buys USD (user sells USD -> PEN).
/// [sellRate] - the rate at which the bank sells USD (user buys USD -> PEN).
///              Use this when converting a USD transaction amount to PEN.
/// [rateDate] - ISO-8601 date string for the day the rate was published.
class ExchangeRateModel extends Equatable {
  const ExchangeRateModel({
    required this.buyRate,
    required this.sellRate,
    required this.rateDate,
  });

  final double buyRate;
  final double sellRate;
  final String rateDate;

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      buyRate: (json['buyRate'] as num).toDouble(),
      sellRate: (json['sellRate'] as num).toDouble(),
      rateDate: json['rateDate'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'buyRate': buyRate,
        'sellRate': sellRate,
        'rateDate': rateDate,
      };

  @override
  List<Object?> get props => [buyRate, sellRate, rateDate];
}
