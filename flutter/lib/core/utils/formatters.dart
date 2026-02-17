import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double? value, {int decimals = 2}) {
    if (value == null) return '';
    final formatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    return formatter.format(value);
  }

  static String formatPercent(double value, {int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern('es_MX')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }
}
