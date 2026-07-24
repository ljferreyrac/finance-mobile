import 'package:intl/intl.dart';

/// Date formatting helpers for the Peruvian locale.
///
/// Display format: `dd/MM/yyyy` (e.g. 15/03/2026).
/// API format:     `yyyy-MM-dd` (ISO 8601 date-only, as expected by the backend).
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  static String toDisplay(DateTime date) => _displayFormat.format(date);

  static String toApi(DateTime date) => _apiFormat.format(date);

  static DateTime fromApi(String dateStr) => _apiFormat.parse(dateStr);

  /// Parses an ISO 8601 datetime string and converts it to local time.
  static DateTime fromIso(String isoStr) => DateTime.parse(isoStr).toLocal();
}
