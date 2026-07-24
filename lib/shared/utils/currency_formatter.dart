import 'package:intl/intl.dart';

/// Formats monetary amounts according to Peruvian display rules.
///
/// - PEN: `S/ 45.50`
/// - USD: `$ 12.00`
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _penFormat = NumberFormat('#,##0.00', 'es_PE');
  static final NumberFormat _usdFormat = NumberFormat('#,##0.00', 'en_US');

  static String format(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$ ${_usdFormat.format(amount)}';
      case 'PEN':
      default:
        return 'S/ ${_penFormat.format(amount)}';
    }
  }
}
